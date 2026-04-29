// Build schema-docs.pdf:
//   1. Read data.html, extract the per-table <div class="card"> blocks from the
//      "details-grid" section.
//   2. Strip the <td class="col-type"> column so each fields table is just
//      "field name + note".
//   3. Prepend schema.png as the hero.
//   4. Render to schema-docs.pdf via puppeteer.
// Usage: node scripts/build-schema-docs.mjs

import { promises as fs } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import puppeteer from 'puppeteer';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');

const DOCS = path.join(ROOT, 'docs');
const dataHtml = await fs.readFile(path.join(DOCS, 'data.html'), 'utf8');

// Slice the details-grid block (start of first card → close of </section>).
const gridStart = dataHtml.indexOf('<div class="details-grid">');
const gridEnd = dataHtml.indexOf('</section>', gridStart);
if (gridStart < 0 || gridEnd < 0) {
  throw new Error('Could not locate details-grid section in data.html');
}
let cardsHtml = dataHtml.slice(gridStart, gridEnd);

// Drop the `col-type` cells entirely.
cardsHtml = cardsHtml.replace(
  /<td class="col-type"[^>]*>[\s\S]*?<\/td>/g,
  ''
);

// Tighten the field-table so removed columns don't leave dead space.
// (No-op for the rendered version — CSS below handles layout.)

const printHtml = `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Trial Weave · Schema reference</title>
  <style>
    :root {
      --ink: #1C1C1C;
      --muted: #6B7280;
      --border: #E5E7EB;
      --teal: #234a67;
      --accent: #e8f4f8;
      --amber: #B45309;
    }
    @page { size: letter; margin: 0.5in; }
    * { box-sizing: border-box; }
    body {
      font-family: ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
      color: var(--ink);
      margin: 0;
      -webkit-font-smoothing: antialiased;
      font-size: 12px;
      line-height: 1.5;
    }
    h1 { font-size: 24px; margin: 0 0 4px; }
    h2 { font-size: 16px; margin: 20px 0 10px; color: var(--teal); }
    h3 { font-size: 14px; margin: 0 0 6px; font-family: ui-monospace, monospace; color: var(--teal); }
    h4 { font-size: 10px; margin: 10px 0 4px; color: var(--muted); letter-spacing: 0.1em; text-transform: uppercase; }
    .eyebrow { font-size: 10px; letter-spacing: 0.14em; text-transform: uppercase; color: var(--muted); font-weight: 700; margin-bottom: 6px; }
    .sub { color: var(--muted); margin: 4px 0 16px; }

    .hero {
      text-align: center;
      margin-bottom: 28px;
      page-break-after: always;
    }
    .hero img { max-width: 100%; height: auto; border: 1px solid var(--border); border-radius: 8px; }
    .hero .caption { color: var(--muted); font-size: 11px; margin-top: 8px; }

    .grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 16px;
    }
    .card {
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 12px 14px;
      break-inside: avoid;
      background: white;
    }
    .card.highlight { border-color: var(--teal); background: #f4fafe; }
    .card .eyebrow { color: var(--teal); }
    .purpose { font-size: 11.5px; color: var(--ink); margin: 4px 0 0; }
    .why { font-size: 11px; color: var(--ink); background: #FAFAFA; border-left: 3px solid var(--teal); padding: 8px 10px; border-radius: 4px; }
    .why strong { color: var(--teal); }

    .field-table {
      width: 100%;
      border-collapse: collapse;
      margin: 4px 0 0;
      font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
      font-size: 11px;
    }
    .field-table td {
      padding: 3px 0;
      border-bottom: 1px solid var(--border);
      vertical-align: top;
    }
    .field-table tr:last-child td { border-bottom: 0; }
    .col-name { color: var(--ink); font-weight: 600; white-space: nowrap; padding-right: 10px !important; }
    .col-name.pk { color: var(--teal); }
    .col-name.fk { color: var(--amber); }
    .col-note { color: var(--muted); font-family: ui-sans-serif, sans-serif; font-size: 10.5px; }

    .used-by { display: flex; flex-wrap: wrap; gap: 4px; }
    .pill {
      display: inline-block;
      font-size: 10px;
      font-family: ui-monospace, monospace;
      padding: 2px 6px;
      border-radius: 4px;
      background: #F3F4F6;
      color: var(--ink);
      border: 1px solid var(--border);
    }
    .pill.teal { background: var(--accent); color: var(--teal); border-color: rgba(35, 74, 103, 0.3); }

    header { padding-bottom: 12px; border-bottom: 1px solid var(--border); margin-bottom: 20px; }
  </style>
</head>
<body>
  <header>
    <div class="eyebrow">Trial Weave · Schema reference</div>
    <h1>Database schema &amp; per-table documentation</h1>
    <p class="sub">Every table, why it exists, and the fields it holds. Field types omitted — see <code>schema.sql</code> for the authoritative Postgres DDL.</p>
  </header>

  <div class="hero">
    <img src="schema.png" alt="Trial Weave ERD" />
    <div class="caption">ERD rendered from <code>schema.mmd</code>. Each box is a table, each line is a FK relationship.</div>
  </div>

  <h2>Why each table exists</h2>
  ${cardsHtml}
</body>
</html>
`;

const outHtml = path.join(DOCS, 'schema-docs.html');
await fs.writeFile(outHtml, printHtml, 'utf8');

// Render to PDF
const browser = await puppeteer.launch();
const page = await browser.newPage();
await page.goto('file:///' + outHtml.replace(/\\/g, '/'), { waitUntil: 'networkidle0' });
await page.pdf({
  path: path.join(DOCS, 'schema-docs.pdf'),
  format: 'Letter',
  printBackground: true,
  margin: { top: '0.5in', right: '0.5in', bottom: '0.5in', left: '0.5in' },
});
await browser.close();

const stat = await fs.stat(path.join(DOCS, 'schema-docs.pdf'));
console.log(`Wrote docs/schema-docs.html and docs/schema-docs.pdf (${stat.size} bytes)`);