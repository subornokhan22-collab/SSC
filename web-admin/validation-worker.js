importScripts("content-core.js");
onmessage = (e) => {
  try {
    postMessage({
      hits: ContentCore.duplicates(e.data.rows, e.data.threshold).map(
        ({ a, b, score }) => ({ a: a.id, b: b.id, score }),
      ),
    });
  } catch (error) {
    postMessage({ error: String(error) });
  }
};
