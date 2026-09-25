import { RequestBodyError } from './request_body.ts';
export type TeacherAttachment = {mimeType:string; data:string};
export const MAX_TEACHER_BYTES = 3 * 1024 * 1024;
// Sniff only allowlisted inline files; never fetch a user-supplied URL.
export function teacherAttachments(value: unknown): TeacherAttachment[] {
  if (value === undefined) return [];
  if (!Array.isArray(value) || value.length > 3) throw new RequestBodyError('Attach at most 3 photos or PDFs.');
  let total = 0;
  return value.map(item => {
    if (!item || typeof item !== 'object' || Array.isArray(item)) throw new RequestBodyError('Invalid attachment.');
    const {mimeType, data} = item;
    if (!['image/jpeg','image/png','image/webp','application/pdf'].includes(mimeType) || typeof data !== 'string') throw new RequestBodyError('Only JPEG, PNG, WebP and PDF files are supported.');
    // Check lengths before scanning/decoding untrusted data.
    if (!data.length || data.length > 4 * Math.ceil(MAX_TEACHER_BYTES / 3)) throw new RequestBodyError('Attachments exceed the combined 3 MB limit.', 413);
    if (data.length % 4 || !/^[A-Za-z0-9+/]+={0,2}$/.test(data)) throw new RequestBodyError('Invalid attachment encoding.');
    total += data.length * 3 / 4 - (data.endsWith('==') ? 2 : data.endsWith('=') ? 1 : 0);
    if (total > MAX_TEACHER_BYTES) throw new RequestBodyError('Attachments exceed the combined 3 MB limit.', 413);
    const head = atob(data.slice(0,32));
    const valid = mimeType === 'application/pdf' ? head.startsWith('%PDF-')
      : mimeType === 'image/jpeg' ? head.startsWith('\xff\xd8\xff')
      : mimeType === 'image/png' ? head.startsWith('\x89PNG\r\n\x1a\n')
      : head.startsWith('RIFF') && head.slice(8,12) === 'WEBP';
    if (!valid) throw new RequestBodyError('Attachment contents do not match the declared file type.');
    return {mimeType, data};
  });
}
