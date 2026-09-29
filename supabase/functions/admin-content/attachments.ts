import { RequestBodyError } from "../mimi/request_body.ts";

export type PaperImage = { mimeType: string; data: string };
export const MAX_IMAGE_BYTES = 3 * 1024 * 1024;

/** Validate before forwarding source pages to the model. Never accepts remote URLs. */
export function validateAttachments(value: unknown): PaperImage[] {
  if (value === undefined) return [];
  if (!Array.isArray(value) || value.length > 10) {
    throw new RequestBodyError("Supply at most 10 image pages.");
  }
  let total = 0;
  return value.map((item: unknown) => {
    if (!item || typeof item !== "object" || Array.isArray(item)) {
      throw new RequestBodyError("Invalid image page.");
    }
    const { mimeType, data } = item as Record<string, unknown>;
    if (
      typeof mimeType !== "string" ||
      !["image/jpeg", "image/png", "image/webp"].includes(mimeType) ||
      typeof data !== "string"
    ) {
      throw new RequestBodyError(
        "Image pages must be JPEG, PNG or WebP base64 data.",
      );
    }
    if (
      !data.length ||
      data.length % 4 !== 0 ||
      !/^[A-Za-z0-9+/]+={0,2}$/.test(data)
    ) {
      throw new RequestBodyError("Invalid base64 image page.");
    }
    const bytes =
      (data.length * 3) / 4 -
      (data.endsWith("==") ? 2 : data.endsWith("=") ? 1 : 0);
    total += bytes;
    if (total > MAX_IMAGE_BYTES)
      throw new RequestBodyError(
        "Image pages exceed the combined 3 MB limit.",
        413,
      );
    let head: string;
    try {
      head = atob(data.slice(0, 32));
    } catch {
      throw new RequestBodyError("Invalid image encoding.");
    }
    const signature =
      mimeType === "image/jpeg"
        ? head.startsWith("\xff\xd8\xff")
        : mimeType === "image/png"
          ? head.startsWith("\x89PNG\r\n\x1a\n")
          : head.startsWith("RIFF") && head.slice(8, 12) === "WEBP";
    if (!signature)
      throw new RequestBodyError(
        "Image content does not match its declared type.",
      );
    return { mimeType, data };
  });
}
