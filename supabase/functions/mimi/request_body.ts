// Bound the actual stream, not just the optional/untrusted Content-Length.
export const MAX_BODY_BYTES = 5.5 * 1024 * 1024;

export class RequestBodyError extends Error {
  readonly status: number;
  readonly code: string;

  constructor(message: string, status = 400, code = "BAD_REQUEST") {
    super(message);
    this.status = status;
    this.code = code;
  }
}

function tooLarge(): RequestBodyError {
  return new RequestBodyError(
    "The attachment is too large for one server request — use a smaller file.",
    413,
    "PAYLOAD_TOO_LARGE",
  );
}

export async function readJsonObject(
  request: Request,
  maxBytes = MAX_BODY_BYTES,
): Promise<Record<string, unknown>> {
  if (Number(request.headers.get("Content-Length") ?? 0) > maxBytes) {
    throw tooLarge();
  }
  if (!request.body) throw new RequestBodyError("Missing JSON body.");

  const reader = request.body.getReader();
  const chunks: Uint8Array[] = [];
  let total = 0;
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      total += value.byteLength;
      if (total > maxBytes) {
        await reader.cancel();
        throw tooLarge();
      }
      chunks.push(value);
    }
  } finally {
    reader.releaseLock();
  }

  const bytes = new Uint8Array(total);
  let offset = 0;
  for (const chunk of chunks) {
    bytes.set(chunk, offset);
    offset += chunk.byteLength;
  }
  let payload: unknown;
  try {
    payload = JSON.parse(new TextDecoder("utf-8", { fatal: true }).decode(bytes));
  } catch {
    throw new RequestBodyError("Invalid JSON body.");
  }
  if (payload === null || typeof payload !== "object" || Array.isArray(payload)) {
    throw new RequestBodyError("JSON body must be an object.");
  }
  return payload as Record<string, unknown>;
}
