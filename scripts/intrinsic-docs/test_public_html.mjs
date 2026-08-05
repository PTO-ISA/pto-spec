#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const rootIndex = process.argv.indexOf("--root");
const repoRoot = path.resolve(rootIndex >= 0 ? process.argv[rootIndex + 1] : path.join(scriptDir, "..", ".."));
const docsRoot = path.join(repoRoot, "docs");
const siteRoot = path.join(docsRoot, "html");
const landingPath = path.join(docsRoot, "DavinciOO_PTO_Intrinsic_Complete.html");

function walk(directory) {
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const entryPath = path.join(directory, entry.name);
    return entry.isDirectory() ? walk(entryPath) : [entryPath];
  });
}

const errors = [];
if (!fs.existsSync(siteRoot)) errors.push("docs/html is missing");
if (!fs.existsSync(landingPath)) errors.push("Complete HTML landing page is missing");

if (!errors.length) {
  const files = walk(siteRoot);
  const htmlFiles = files.filter((file) => file.endsWith(".html"));
  const assetFiles = files.filter((file) => !file.endsWith(".html"));
  if (files.length !== 1255) errors.push(`docs/html must contain 1255 files, found ${files.length}`);
  if (htmlFiles.length !== 1253) errors.push(`docs/html must contain 1253 HTML files, found ${htmlFiles.length}`);
  if (assetFiles.length !== 2) errors.push(`docs/html must contain 2 assets, found ${assetFiles.length}`);

  for (const filePath of [landingPath, ...htmlFiles]) {
    const html = fs.readFileSync(filePath, "utf8");
    const relativePath = path.relative(repoRoot, filePath);
    if (/unavailable-reference|known-missing-link/.test(html)) errors.push(`${relativePath}: contains a forbidden missing-reference marker`);
    if (/\[[^\]]+\]\([^)]+\.md(?:#[^)]+)?\)/.test(html)) errors.push(`${relativePath}: contains an unrendered Markdown link`);
    if (/(?:href|src)=["'](?:file:|\/Users\/|[A-Za-z]:\\)/.test(html)) errors.push(`${relativePath}: contains a local absolute path`);
    for (const match of html.matchAll(/(?:href|src)=["']([^"']+)["']/g)) {
      const reference = match[1].split("#", 1)[0];
      if (!reference || /^(?:https?:|mailto:|data:)/i.test(reference)) continue;
      const target = path.resolve(path.dirname(filePath), reference);
      const workbook = reference === "../../spec/encoding/PTO-ISA-Encoding.xlsx"
        ? path.join(repoRoot, "spec", "encoding", "PTO-ISA-Encoding.xlsx")
        : null;
      if (!fs.existsSync(target) && !(workbook && fs.existsSync(workbook))) errors.push(`${relativePath}: broken local reference ${match[1]}`);
    }
  }

  const indexHtml = fs.readFileSync(path.join(siteRoot, "index.html"), "utf8");
  for (const label of ["Home", "Architecture Reference", "Scalar ISA", "Block ISA", "Tile ISA", "Support Status"]) {
    if (!indexHtml.includes(label)) errors.push(`docs/html/index.html: missing navigation label ${label}`);
  }
  const landingHtml = fs.readFileSync(landingPath, "utf8");
  if (!landingHtml.includes("url=html/index.html")) errors.push("Complete HTML landing page must redirect to html/index.html");
}

if (errors.length) {
  console.error(errors.join("\n"));
  process.exitCode = 1;
} else {
  console.log("public_html_ok files=1255 html=1253 assets=2");
}
