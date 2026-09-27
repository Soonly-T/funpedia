import { readFile, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { marked } from 'marked';

const directory = fileURLToPath(new URL('.', import.meta.url));
const markdownPath = `${directory}README.md`;
const htmlPath = `${directory}index.html`;
const startMarker = '<!-- DOCS_CONTENT_START -->';
const endMarker = '<!-- DOCS_CONTENT_END -->';

const [markdown, html] = await Promise.all([
  readFile(markdownPath, 'utf8'),
  readFile(htmlPath, 'utf8'),
]);
const start = html.indexOf(startMarker);
const end = html.indexOf(endMarker);

if (start === -1 || end === -1 || end < start) {
  throw new Error('Could not find the documentation content markers in index.html.');
}

const generated = marked.parse(markdown, { gfm: true, breaks: false });
const output = `${html.slice(0, start + startMarker.length)}\n${generated}\n${html.slice(end)}`;
await writeFile(htmlPath, output);
console.log('Built standalone index.html from README.md.');
