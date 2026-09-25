// Direct English-paper source intake. Originals stay local until an explicit AI request.
export function createEnglishUploader({ client, isDemo, onDraft }) {
  const C = window.ContentCore;
  const dialog = document.createElement("dialog");
  dialog.id = "english-upload";
  dialog.setAttribute("aria-labelledby", "upload-title");
  dialog.innerHTML = `
    <div class="dialog-head"><div><span class="eyebrow">ENGLISH PAPER IMPORT</span><h2 id="upload-title">Upload PDF / images</h2></div><button type="button" id="upload-close" class="ghost">Close ✕</button></div>
    <p>Upload one complete question-paper PDF, or photos of its pages in reading order. Nothing is published automatically.</p>
    <div class="form-grid"><label>Paper type<select id="upload-paper-type"><option value="first">English 1st Paper</option><option value="second">English 2nd Paper</option></select></label><label>Board<input id="upload-board" placeholder="e.g. Dhaka — confirm from your source"></label><label>Year<input id="upload-year" type="number" min="2000" max="2100" placeholder="Year printed on the paper"></label></div>
    <label class="paper-drop" id="paper-drop">Choose a PDF or question-paper photos<input id="english-source-files" type="file" multiple accept="application/pdf,image/jpeg,image/png,image/webp,.pdf,.jpg,.jpeg,.png,.webp"><span>Or drop files here · One PDF (up to 10 pages) or up to 10 images · 20 MB total</span></label>
    <div id="upload-status" role="status" aria-live="polite">Your files stay in this tab until you choose AI extraction.</div>
    <div id="upload-source" hidden><div class="toolbar"><button type="button" id="source-prev" class="ghost small">← Previous page</button><span id="source-page"></span><button type="button" id="source-next" class="ghost small">Next page →</button><button type="button" id="source-up" class="ghost small">Move page earlier</button><button type="button" id="source-down" class="ghost small">Move page later</button></div><p id="source-filename" class="muted"></p><canvas id="source-canvas" aria-label="Question-paper source preview"></canvas></div>
    <label>Extracted / transcribed source text<textarea id="upload-text" rows="8" placeholder="Selectable PDF text appears here. For a photo or scan, use AI extraction below, or paste a manual transcription."></textarea></label>
    <p class="muted" id="upload-ai-note"></p>
    <p class="muted">Check every passage, table and question after extraction. Unreadable content stays blank; missing answers are never filled in. Saving a draft stores the extracted content and filenames, not the original files.</p>
    <div class="dialog-foot"><button type="button" id="upload-manual" class="ghost">Continue to draft editor</button><button type="button" id="upload-ai" class="primary">Extract PDF / images with AI</button></div>`;
  document.body.append(dialog);
  const $ = (id) => dialog.querySelector("#" + id);
  let files = [],
    images = [],
    pdf = null,
    page = 0,
    busy = false;
  const count = () => (pdf ? pdf.numPages : images.length);
  const status = (text, error = false) => {
    $("upload-status").textContent = text;
    $("upload-status").className = error ? "warn" : "muted";
  };
  function controls() {
    dialog
      .querySelectorAll("button,input,select,textarea")
      .forEach((el) => (el.disabled = busy));
    $("source-prev").disabled = busy || page === 0;
    $("source-next").disabled = busy || page >= count() - 1;
    $("source-up").hidden = $("source-down").hidden = !!pdf;
    $("source-up").disabled = busy || page === 0;
    $("source-down").disabled = busy || page >= count() - 1;
    $("upload-ai").disabled = busy || !count() || isDemo();
    $("upload-manual").disabled = busy || !count();
  }
  async function run(fn) {
    if (busy) return;
    busy = true;
    controls();
    try {
      await fn();
    } catch (e) {
      status(e.message || String(e), true);
    } finally {
      busy = false;
      controls();
    }
  }
  async function resetSources() {
    if (pdf) await pdf.destroy();
    pdf = null;
    images.forEach((img) => img.close());
    images = [];
    files = [];
    page = 0;
    $("upload-source").hidden = true;
    $("source-canvas").width = $("source-canvas").height = 1;
    $("upload-text").value = "";
  }
  async function draw(target, index, maxSize = 1600) {
    let width, height, pdfPage;
    if (pdf) {
      pdfPage = await pdf.getPage(index + 1);
      const v = pdfPage.getViewport({ scale: 1 });
      width = v.width;
      height = v.height;
    } else {
      width = images[index].width;
      height = images[index].height;
    }
    const scale = maxSize / Math.max(width, height);
    target.width = Math.max(1, Math.round(width * scale));
    target.height = Math.max(1, Math.round(height * scale));
    const context = target.getContext("2d");
    context.fillStyle = "#fff";
    context.fillRect(0, 0, target.width, target.height);
    if (pdfPage)
      await pdfPage.render({
        canvasContext: context,
        viewport: pdfPage.getViewport({ scale }),
      }).promise;
    else context.drawImage(images[index], 0, 0, target.width, target.height);
  }
  async function preview() {
    if (!count()) return;
    $("upload-source").hidden = false;
    $("source-page").textContent = `Page ${page + 1} of ${count()}`;
    $("source-filename").textContent = pdf ? files[0].name : files[page].name;
    await draw($("source-canvas"), page, 1100);
  }
  async function load(selection) {
    const incoming = [...selection];
    if (!incoming.length) return;
    if (
      incoming.length > 10 ||
      incoming.reduce((n, f) => n + f.size, 0) > 20 * 1024 * 1024
    )
      throw Error("Choose up to 10 pages/images and at most 20 MB total.");
    const isPdf = (f) => f.type === "application/pdf" || /\.pdf$/i.test(f.name);
    if (incoming.some(isPdf) && (incoming.length !== 1 || !isPdf(incoming[0])))
      throw Error(
        "Choose one PDF, or a group of images. Do not mix PDFs and images.",
      );
    if (
      !incoming.every(
        (f) =>
          isPdf(f) ||
          ["image/jpeg", "image/png", "image/webp"].includes(f.type),
      )
    )
      throw Error(
        "Supported files: PDF, JPG, PNG and WebP. Convert HEIC images to JPG first.",
      );
    await resetSources();
    status("Reading source pages…");
    try {
      files = incoming;
      if (isPdf(files[0])) {
        const pdfjs = await import("./vendor/pdf.mjs");
        pdfjs.GlobalWorkerOptions.workerSrc = new URL(
          "./vendor/pdf.worker.mjs",
          import.meta.url,
        ).href;
        pdf = await pdfjs.getDocument({
          data: await files[0].arrayBuffer(),
          isEvalSupported: false,
        }).promise;
        if (pdf.numPages > 10)
          throw Error(
            "This PDF exceeds 10 pages. Split it into individual question papers first.",
          );
        const text = [];
        for (let i = 1; i <= pdf.numPages; i++) {
          const p = await pdf.getPage(i),
            content = await p.getTextContent();
          text.push(
            content.items.map((x) => x.str + (x.hasEOL ? "\n" : " ")).join(""),
          );
        }
        $("upload-text").value = text.join("\n\n");
        const detected = C.draftFromText(
          $("upload-text").value,
          $("upload-paper-type").value,
        );
        if (!$("upload-board").value && detected.board)
          $("upload-board").value = detected.board;
        const year = $("upload-text").value.match(/\b20\d{2}\b/);
        if (!$("upload-year").value && year) $("upload-year").value = year[0];
      } else {
        for (const f of files) {
          const img = await createImageBitmap(f);
          if (img.width * img.height > 40000000) {
            img.close();
            throw Error("An image exceeds 40 megapixels. Resize it first.");
          }
          const scale = Math.min(1, 2200 / Math.max(img.width, img.height));
          if (scale < 1) {
            const resized = await createImageBitmap(img, {
              resizeWidth: Math.round(img.width * scale),
              resizeHeight: Math.round(img.height * scale),
            });
            img.close();
            images.push(resized);
          } else images.push(img);
        }
      }
      await preview();
      status(
        $("upload-text").value.trim()
          ? `${count()} page(s) loaded. PDF text extracted locally; inspect tables and reading order.`
          : `${count()} page(s) loaded. This source needs image reading: use AI extraction or manually transcribe it below.`,
        !$("upload-text").value.trim(),
      );
    } catch (e) {
      await resetSources();
      throw e;
    }
  }
  function draft(data) {
    const type = $("upload-paper-type").value,
      text = $("upload-text").value;
    const row = C.draftFromText(text, type);
    row.board = $("upload-board").value.trim();
    row.year = $("upload-year").value ? Number($("upload-year").value) : null;
    if (
      !row.board ||
      !Number.isInteger(row.year) ||
      row.year < 2000 ||
      row.year > 2100
    )
      throw Error(
        "Confirm the board and year printed on the source before continuing.",
      );
    row.id = `english${type === "first" ? 1 : 2}_${row.board.toLowerCase().replace(/[^a-z0-9]+/g, "_") || "board"}_${row.year}`;
    row.source_label = files.map((f) => f.name).join(" / ");
    if (data) {
      if (typeof data !== "object" || Array.isArray(data))
        throw Error("AI returned an invalid paper. Nothing was saved.");
      row.data = {
        ...C.englishTemplate(type).data,
        ...data,
        schema_version: 1,
      };
    }
    row.data.source_text = text;
    row.data.source_files = files.map((f) => ({
      name: f.name,
      size: f.size,
      type: f.type,
    }));
    row.data.answers = C.englishTemplate(type).data.answers;
    row.review_status = "draft";
    return row;
  }
  function finish(row) {
    onDraft(row);
    dialog.close();
  }
  $("english-source-files").onchange = (e) => run(() => load(e.target.files));
  $("paper-drop").ondragover = (e) => {
    e.preventDefault();
  };
  $("paper-drop").ondrop = (e) => {
    e.preventDefault();
    run(() => load(e.dataTransfer.files));
  };
  $("source-prev").onclick = () =>
    run(async () => {
      page--;
      await preview();
    });
  $("source-next").onclick = () =>
    run(async () => {
      page++;
      await preview();
    });
  for (const [id, step] of [
    ["source-up", -1],
    ["source-down", 1],
  ])
    $(id).onclick = () =>
      run(async () => {
        const next = page + step;
        [files[page], files[next]] = [files[next], files[page]];
        [images[page], images[next]] = [images[next], images[page]];
        page = next;
        await preview();
      });
  $("upload-manual").onclick = () =>
    run(async () => {
      const row = draft();
      if (
        !$("upload-text").value.trim() &&
        !confirm(
          "No text has been extracted. Open a blank structured draft for manual transcription?",
        )
      )
        return;
      finish(row);
    });
  $("upload-ai").onclick = () =>
    run(async () => {
      if (isDemo())
        throw Error(
          "Sign in to use AI extraction. Offline demo never sends your files to a server.",
        );
      draft(); // Verify source identity before spending a model request.
      if (
        !confirm(
          "Send these question-paper pages to the configured AI service for extraction? Check that you have permission to share them. The result will still need your review.",
        )
      )
        return;
      status(
        "Reading the paper with AI… This can take up to two minutes. Nothing will be published.",
      );
      const attachments = [],
        canvas = document.createElement("canvas");
      let bytes = 0;
      for (let i = 0; i < count(); i++) {
        await draw(canvas, i);
        const data = canvas.toDataURL("image/jpeg", 0.85).split(",")[1];
        bytes += Math.floor((data.length * 3) / 4);
        if (bytes > 3 * 1024 * 1024)
          throw Error(
            "The prepared pages exceed the 3 MB AI limit. Use smaller images or fewer pages. Nothing was sent.",
          );
        attachments.push({ mimeType: "image/jpeg", data });
      }
      const text = $("upload-text").value.trim();
      if (text.length > 60000)
        throw Error(
          "The extracted text exceeds 60,000 characters. Split the source into individual papers.",
        );
      const { data, error } = await client.functions.invoke("admin-content", {
        body: {
          action: "structure",
          format: $("upload-paper-type").value,
          text,
          attachments,
        },
      });
      if (error || data?.error) {
        let message = data?.error;
        if (!message && error?.context?.json) {
          try {
            message = (await error.context.json()).error;
          } catch {
            /* Keep generic transport error below. */
          }
        }
        throw Error(
          message ||
            "AI extraction failed. Check that the updated admin-content function and its AI secret are deployed. You can still use manual transcription.",
        );
      }
      finish(draft(data.result));
    });
  $("upload-close").onclick = () => {
    if (!busy) dialog.close();
  };
  dialog.oncancel = (e) => {
    if (busy) e.preventDefault();
  };
  return {
    refresh: controls,
    open(type = "first") {
      $("upload-paper-type").value = type === "second" ? "second" : "first";
      $("upload-ai-note").textContent = isDemo()
        ? "Offline demo: file preview and PDF text extraction work locally. Automatic image reading needs a signed-in administrator and the deployed AI function."
        : "AI extraction sends page images to your configured AI service only when you explicitly confirm. It supports photos and scanned PDFs; carefully check all extracted content.";
      controls();
      dialog.showModal();
    },
  };
}
