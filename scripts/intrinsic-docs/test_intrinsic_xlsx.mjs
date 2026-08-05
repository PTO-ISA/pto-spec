#!/usr/bin/env node
import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { createRequire } from "node:module";

function option(name) {
  const index = process.argv.indexOf(name);
  return index < 0 ? null : process.argv[index + 1];
}

const root = path.resolve(option("--root") || process.cwd());
const nodeModules = option("--artifact-node-modules");
if (!nodeModules) throw new Error("Pass --artifact-node-modules from load_workspace_dependencies.");
const require = createRequire(path.join(path.resolve(nodeModules), "package.json"));
const artifact = require("@oai/artifact-tool");
const temp = await fs.mkdtemp(path.join(os.tmpdir(), "davincioo-intrinsic-xlsx-test-"));
const tempRoot = path.join(temp, "repo");
await fs.cp(path.join(root, "scripts", "intrinsic-docs"), path.join(tempRoot, "scripts", "intrinsic-docs"), { recursive: true, filter: (source) => !source.endsWith(".DS_Store") });
await fs.cp(path.join(root, "docs", "instructions", "tile"), path.join(tempRoot, "docs", "instructions", "tile"), { recursive: true, filter: (source) => !source.endsWith(".DS_Store") });
await fs.cp(path.join(root, "spec", "encoding"), path.join(tempRoot, "spec", "encoding"), { recursive: true, filter: (source) => !source.endsWith(".DS_Store") });
const intrinsicRoot = path.join(tempRoot, "docs", "instructions", "tile");
const workbookPath = path.join(tempRoot, "spec", "encoding", "PTO-ISA-Encoding.xlsx");
const sidecarPath = path.join(tempRoot, "spec", "encoding", "PTO-ISA-Encoding.sync.json");
const tempTool = path.join(tempRoot, "scripts", "intrinsic-docs", "sync_intrinsic_xlsx.mjs");

function sync(command, ...args) {
  return execFileSync(process.execPath, [tempTool, command, "--root", tempRoot, "--workbook", workbookPath, "--sidecar", sidecarPath, "--artifact-node-modules", nodeModules, ...args], { encoding: "utf8" });
}

const testDoc = (opcode, include = true, status = "mapped") => `---
{
  "schema_version": 1,
  "id": "intrinsic.test_sync",
  "kind": "intrinsic",
  "title": "${opcode} Intrinsic",
  "status": "${status}",
  "visibility": "${status === "mapped" ? "public" : "internal"}",
  "profile": "pto-isa-0.58.0",
  "opcode": "${opcode}",
  "family": "element-wise",
  "sources": { "davincioo": "docs/instructions/tile/TEST_SYNC.md" },
  "bundle": "BSTART.TEPL ${opcode}, DataType + B.DIM LB0 + B.IOT",
  "operands": { "output": "dst tile", "input0": "src tile", "input1": null, "input2": null },
  "dtypes": ["F16"],
  "encoding": { "block": "TEPL", "mode": 0, "function": 31, "tile_op": "0x1F" },
  "xlsx": { "include": ${include}, "category": "Tile-Tile Elementwise\\n逐元素双输入\\n短Latency", "subcategory": "算术计算", "order": 101, "description_section": "PTO 语义来源", "constraints_section": "约束与合法性" }
}
---
# ${opcode} Intrinsic

## PTO 语义来源

用于 Excel round-trip 测试。

## 约束与合法性

仅用于临时测试。
`;

try {
  sync("bootstrap");
  const page = path.join(intrinsicRoot, "TEST_SYNC.md");
  await fs.writeFile(page, testDoc("TEST_SYNC"));
  assert.match(sync("dry-run", "--id", "intrinsic.test_sync"), /add-row/);
  sync("apply", "--id", "intrinsic.test_sync");

  let workbook = await artifact.SpreadsheetFile.importXlsx(await artifact.FileBlob.load(workbookPath));
  let sheet = workbook.worksheets.getItem("Sheet1");
  let values = sheet.getUsedRange(true).values;
  const row = values.findIndex((entry) => entry[2] === "TEST_SYNC");
  assert.ok(row > 0, "added Opcode row exists");
  assert.equal(sheet.getCell(row, 2).format.wrapText, true, "added row inherits wrap style");
  sheet.getCell(row, 10).values = [["MANUAL_DESCRIPTION"]];
  let exported = await artifact.SpreadsheetFile.exportXlsx(workbook);
  await exported.save(workbookPath);
  assert.match(sync("apply", "--id", "intrinsic.test_sync"), /newly_detected_overrides/);
  assert.match(sync("dry-run", "--id", "intrinsic.test_sync"), /MANUAL_DESCRIPTION/);

  await fs.writeFile(page, testDoc("TEST_SYNC_RENAMED"));
  assert.match(sync("apply", "--id", "intrinsic.test_sync"), /TEST_SYNC_RENAMED/);
  workbook = await artifact.SpreadsheetFile.importXlsx(await artifact.FileBlob.load(workbookPath));
  sheet = workbook.worksheets.getItem("Sheet1");
  values = sheet.getUsedRange(true).values;
  assert.ok(values.some((entry) => entry[2] === "TEST_SYNC_RENAMED"), "stable id renames controlled Opcode cell");

  await fs.writeFile(page, testDoc("TEST_SYNC_RENAMED", false, "removed"));
  let blocked = false;
  try { sync("dry-run", "--id", "intrinsic.test_sync"); } catch (error) { blocked = String(error.stdout || "").includes("manual overrides"); }
  assert.equal(blocked, true, "manual override blocks removal without authorization");
  sync("apply", "--id", "intrinsic.test_sync", "--delete-id", "intrinsic.test_sync");
  workbook = await artifact.SpreadsheetFile.importXlsx(await artifact.FileBlob.load(workbookPath));
  sheet = workbook.worksheets.getItem("Sheet1");
  values = sheet.getUsedRange(true).values;
  assert.equal(values[row][2], null, "authorized removal clears the controlled Opcode cell");
  assert.equal(values[row][3], null, "authorized removal clears the bundle cell");

  let projectionBlocked = false;
  try { sync("dry-run", "--physical-delete-id", "intrinsic.tadd"); } catch (error) { projectionBlocked = String(error.stdout || "").includes("still produces an Excel projection"); }
  assert.equal(projectionBlocked, true, "physical deletion blocks while Markdown still projects the row");

  const beforePhysical = await fs.readFile(workbookPath);
  const beforePhysicalRows = values.length;
  await fs.unlink(path.join(intrinsicRoot, "TADD.md"));
  await fs.unlink(path.join(intrinsicRoot, "TSUB.md"));
  const dryRun = sync("dry-run", "--physical-delete-id", "intrinsic.tadd", "--physical-delete-id", "intrinsic.tsub");
  assert.match(dryRun, /physical-delete-row/);
  assert.deepEqual(await fs.readFile(workbookPath), beforePhysical, "physical-delete dry-run does not mutate workbook");
  sync("apply", "--physical-delete-id", "intrinsic.tadd", "--physical-delete-id", "intrinsic.tsub");

  workbook = await artifact.SpreadsheetFile.importXlsx(await artifact.FileBlob.load(workbookPath));
  sheet = workbook.worksheets.getItem("Sheet1");
  values = sheet.getUsedRange(true).values;
  assert.equal(values.length, beforePhysicalRows - 2, "physical deletion removes two worksheet rows");
  assert.equal(values.some((entry) => entry[2] === "TADD" || entry[2] === "TSUB"), false, "deleted opcodes are absent");
  const merges = sheet.toProto().mergedCells.map((merge) => `${merge.startAddress}:${merge.endAddress}`);
  assert.ok(merges.includes("A2:A12"), "category merge shrinks across adjacent deletions");
  assert.ok(merges.includes("B2:B4"), "subcategory merge shrinks across adjacent deletions");
  assert.doesNotMatch(sync("dry-run", "--physical-delete-id", "intrinsic.tadd", "--physical-delete-id", "intrinsic.tsub"), /physical-delete-row/);
  assert.doesNotThrow(() => sync("audit"));

  let unknownBlocked = false;
  try { sync("dry-run", "--physical-delete-id", "intrinsic.typo"); } catch (error) { unknownBlocked = String(error.stdout || "").includes("unknown physical-delete stable id"); }
  assert.equal(unknownBlocked, true, "unknown physical-delete stable id is diagnosed");
  console.log("xlsx_integration_ok add override rename clear physical-delete");
} finally {
  await fs.rm(temp, { recursive: true, force: true });
}
