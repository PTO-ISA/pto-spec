#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { createRequire } from "node:module";
import { fileURLToPath } from "node:url";
import {
  XLSX_COLUMNS,
  excelProjectionFingerprint,
  loadDocuments,
  projectionForDocument,
  sourceFingerprint,
} from "./intrinsic_docs_lib.mjs";
import { auditState, buildStateRow, decideCell, decideRowPresence, migrateState, normalize, rowObject, valuesEqual } from "./intrinsic_sync_state.mjs";

const SCRIPT_DIR = path.dirname(fileURLToPath(import.meta.url));

function parseArgs(argv) {
  const options = { command: argv[2] || "dry-run", ids: [], deleteIds: [], physicalDeleteIds: [], clearOverrides: [] };
  for (let i = 3; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--root") options.root = argv[++i];
    else if (arg === "--workbook") options.workbook = argv[++i];
    else if (arg === "--sidecar") options.sidecar = argv[++i];
    else if (arg === "--artifact-node-modules") options.nodeModules = argv[++i];
    else if (arg === "--id") options.ids.push(argv[++i]);
    else if (arg === "--delete-id") options.deleteIds.push(argv[++i]);
    else if (arg === "--physical-delete-id") options.physicalDeleteIds.push(argv[++i]);
    else if (arg === "--clear-override") options.clearOverrides.push(argv[++i]);
    else throw new Error(`Unknown argument: ${arg}`);
  }
  return options;
}

function hashBuffer(buffer) {
  return crypto.createHash("sha256").update(buffer).digest("hex");
}

async function loadArtifactTool(nodeModules) {
  if (!nodeModules) throw new Error("Pass --artifact-node-modules with the loader-provided node_modules path.");
  const require = createRequire(path.join(path.resolve(nodeModules), "package.json"));
  try {
    return require("@oai/artifact-tool");
  } catch (error) {
    throw new Error(`Could not load @oai/artifact-tool from ${nodeModules}: ${error.message}`);
  }
}

function resolvePaths(options) {
  const repoRoot = path.resolve(options.root || path.join(SCRIPT_DIR, "..", ".."));
  const intrinsicRoot = path.join(repoRoot, "docs", "instructions", "tile");
  return {
    intrinsicRoot,
    workbookPath: path.resolve(options.workbook || path.join(repoRoot, "spec", "encoding", "PTO-ISA-Encoding.xlsx")),
    sidecarPath: path.resolve(options.sidecar || path.join(repoRoot, "spec", "encoding", "PTO-ISA-Encoding.sync.json")),
  };
}

function projectionValues(projection) {
  return XLSX_COLUMNS.map((column) => projection[column] ?? null);
}

function copyCellFormat(source, target) {
  const font = source.format.font;
  target.format.setFont({
    name: font.name,
    size: font.size,
    bold: font.bold,
    italic: font.italic,
    ...(font.color ? { color: font.color } : {}),
  });
  if (source.format.fill?.color) target.format.fill = { color: source.format.fill.color };
  const borders = source.format.getBorderBlueprintSnapshot();
  if (Object.keys(borders).length) target.format.borders = borders;
  target.format.numberFormat = source.format.numberFormat;
  target.format.horizontalAlignment = source.format.horizontalAlignment;
  target.format.verticalAlignment = source.format.verticalAlignment;
  target.format.wrapText = source.format.wrapText;
}

function copyRowFormat(sheet, sourceRowIndex, targetRowIndex) {
  for (let columnIndex = 0; columnIndex < XLSX_COLUMNS.length; columnIndex += 1) {
    copyCellFormat(sheet.getCell(sourceRowIndex, columnIndex), sheet.getCell(targetRowIndex, columnIndex));
  }
  sheet.getRangeByIndexes(targetRowIndex, 0, 1, XLSX_COLUMNS.length).format.rowHeight = sheet.getRangeByIndexes(sourceRowIndex, 0, 1, XLSX_COLUMNS.length).format.rowHeight;
}

function locateRow(values, opcodeIndex, candidates) {
  const wanted = new Set(candidates.filter(Boolean));
  for (let index = 1; index < values.length; index += 1) {
    if (wanted.has(normalize(values[index][opcodeIndex]))) return index;
  }
  return -1;
}

function currentRowState(headers, values, rowIndex) {
  return rowObject(headers, values[rowIndex]);
}

function parseCellAddress(address) {
  const match = /^(\$?[A-Z]+)(\$?)(\d+)$/.exec(address);
  if (!match) throw new Error(`Unsupported cell address in physical row deletion: ${address}`);
  return { column: match[1], absoluteRow: match[2], row: Number(match[3]) };
}

function cellAddress(column, absoluteRow, row) {
  return `${column}${absoluteRow}${row}`;
}

function deletedBefore(sortedRows, row) {
  let count = 0;
  for (const deleted of sortedRows) {
    if (deleted >= row) break;
    count += 1;
  }
  return count;
}

function physicalDeleteRows(workbook, sheetName, rowNumbers) {
  const sortedRows = [...new Set(rowNumbers)].sort((left, right) => left - right);
  const deleted = new Set(sortedRows);
  const proto = workbook.toProto();
  const sheet = proto.sheets.find((candidate) => candidate.name === sheetName);
  if (!sheet) throw new Error(`Worksheet not found for physical row deletion: ${sheetName}`);
  const originalRows = new Map(sheet.rows.map((row) => [row.index, structuredClone(row)]));
  sheet.rows = sheet.rows
    .filter((row) => !deleted.has(row.index))
    .map((row) => {
      const oldIndex = row.index;
      const newIndex = oldIndex - deletedBefore(sortedRows, oldIndex);
      row.index = newIndex;
      for (const cell of row.cells || []) {
        const parsed = parseCellAddress(cell.address);
        cell.address = cellAddress(parsed.column, parsed.absoluteRow, newIndex);
      }
      return row;
    });
  const shiftedMerges = [];
  for (const merge of sheet.mergedCells || []) {
    const start = parseCellAddress(merge.startAddress);
    const end = parseCellAddress(merge.endAddress);
    const survivors = [];
    for (let row = start.row; row <= end.row; row += 1) if (!deleted.has(row)) survivors.push(row);
    if (!survivors.length) continue;
    const newStartRow = survivors[0] - deletedBefore(sortedRows, survivors[0]);
    const newEndRow = survivors.at(-1) - deletedBefore(sortedRows, survivors.at(-1));
    if (newStartRow < newEndRow || start.column !== end.column) {
      shiftedMerges.push({
        ...merge,
        startAddress: cellAddress(start.column, start.absoluteRow, newStartRow),
        endAddress: cellAddress(end.column, end.absoluteRow, newEndRow),
      });
    }
    if (deleted.has(start.row)) {
      const originalTop = originalRows.get(start.row)?.cells?.find((cell) => parseCellAddress(cell.address).column === start.column);
      const targetRow = sheet.rows.find((row) => row.index === newStartRow);
      if (originalTop && targetRow) {
        const replacement = structuredClone(originalTop);
        replacement.address = cellAddress(start.column, start.absoluteRow, newStartRow);
        targetRow.cells ||= [];
        const targetIndex = targetRow.cells.findIndex((cell) => parseCellAddress(cell.address).column === start.column);
        if (targetIndex >= 0) targetRow.cells[targetIndex] = replacement;
        else targetRow.cells.push(replacement);
      }
    }
  }
  sheet.mergedCells = shiftedMerges;
  return proto;
}

async function importWorkbook(artifact, workbookPath) {
  return artifact.SpreadsheetFile.importXlsx(await artifact.FileBlob.load(workbookPath));
}

async function workbookContext(artifact, workbookPath) {
  const workbook = await importWorkbook(artifact, workbookPath);
  const sheet = workbook.worksheets.getItem("Sheet1");
  const values = sheet.getUsedRange(true).values;
  const headers = values[0].map((value) => String(value ?? ""));
  if (headers.join("|") !== XLSX_COLUMNS.join("|")) {
    throw new Error(`Unexpected Sheet1 columns: ${headers.join(" | ")}`);
  }
  return { workbook, sheet, values, headers, opcodeIndex: headers.indexOf("Opcode") };
}

async function bootstrap(artifact, paths) {
  const docs = loadDocuments(paths.intrinsicRoot);
  const mapped = docs.filter((doc) => doc.metadata.kind === "intrinsic" && doc.metadata.xlsx?.include);
  const context = await workbookContext(artifact, paths.workbookPath);
  const rows = {};
  const missing = [];
  for (const doc of mapped) {
    const projection = projectionForDocument(doc);
    const rowIndex = locateRow(context.values, context.opcodeIndex, [doc.metadata.opcode]);
    if (rowIndex < 0) {
      missing.push(doc.metadata.opcode);
      continue;
    }
    rows[doc.metadata.id] = buildStateRow(doc, projection, currentRowState(context.headers, context.values, rowIndex), rowIndex + 1);
  }
  if (missing.length) throw new Error(`Cannot bootstrap: workbook rows missing for ${missing.join(", ")}`);
  const workbookBytes = await fs.readFile(paths.workbookPath);
  const state = {
    version: 2,
    workbook: path.basename(paths.workbookPath),
    sheet: "Sheet1",
    columns: XLSX_COLUMNS,
    workbook_sha256: hashBuffer(workbookBytes),
    source_fingerprint: sourceFingerprint(docs),
    projection_fingerprint: excelProjectionFingerprint(docs),
    rows,
  };
  await fs.writeFile(paths.sidecarPath, `${JSON.stringify(state, null, 2)}\n`);
  const overrideCount = Object.values(rows).reduce((sum, row) => sum + Object.keys(row.overrides).length, 0);
  console.log(`sidecar=${paths.sidecarPath}`);
  console.log(`rows=${Object.keys(rows).length}`);
  console.log(`protected_initial_overrides=${overrideCount}`);
}

function parseOverrideSpec(spec) {
  const colon = spec.indexOf(":");
  if (colon < 0) throw new Error(`Override selector must be ID:COLUMN: ${spec}`);
  return { id: spec.slice(0, colon), column: spec.slice(colon + 1) };
}

async function synchronize(artifact, paths, options, apply) {
  const docs = loadDocuments(paths.intrinsicRoot);
  const docsById = new Map(docs.filter((doc) => doc.metadata.kind === "intrinsic").map((doc) => [doc.metadata.id, doc]));
  const state = migrateState(JSON.parse(await fs.readFile(paths.sidecarPath, "utf8")));
  const clearedOverrideKeys = new Set();
  for (const spec of options.clearOverrides) {
    const { id, column } = parseOverrideSpec(spec);
    if (!state.rows[id]) throw new Error(`Unknown sync id: ${id}`);
    delete state.rows[id].overrides[column];
    clearedOverrideKeys.add(`${id}:${column}`);
  }
  const context = await workbookContext(artifact, paths.workbookPath);
  const selectedIds = options.ids.length || options.physicalDeleteIds.length ? new Set(options.ids) : null;
  const deleteIds = new Set(options.deleteIds);
  const physicalDeleteIds = new Set(options.physicalDeleteIds);
  for (const id of physicalDeleteIds) {
    if (deleteIds.has(id)) throw new Error(`Choose either --delete-id or --physical-delete-id for ${id}, not both.`);
  }
  const changes = [];
  const preserved = [];
  const blocked = [];
  const additions = [];
  const cleared = [];
  const physicalDeletions = [];
  state.physical_deletions ||= [];

  for (const id of physicalDeleteIds) {
    const doc = docsById.get(id);
    if (doc && projectionForDocument(doc)) {
      blocked.push({ id, opcode: doc.metadata.opcode, reason: "Markdown still produces an Excel projection" });
      continue;
    }
    const rowState = state.rows[id];
    if (!rowState) {
      if (!state.physical_deletions.includes(id)) blocked.push({ id, reason: "unknown physical-delete stable id" });
      continue;
    }
    const rowIndex = locateRow(context.values, context.opcodeIndex, [rowState.opcode]);
    if (rowIndex < 0) {
      blocked.push({ id, opcode: rowState.opcode, reason: "sidecar row exists but workbook row is missing" });
      continue;
    }
    const rowNumber = rowIndex + 1;
    const mergeImpacts = (context.sheet.toProto().mergedCells || [])
      .filter((merge) => {
        const start = parseCellAddress(merge.startAddress);
        const end = parseCellAddress(merge.endAddress);
        return start.row <= rowNumber && rowNumber <= end.row;
      })
      .map((merge) => `${merge.startAddress}:${merge.endAddress}`);
    const plan = {
      type: "physical-delete-row",
      id,
      opcode: rowState.opcode,
      row: rowNumber,
      merge_impacts: mergeImpacts,
      override_columns: Object.keys(rowState.overrides || {}),
      layout_columns: Object.keys(rowState.layout_placeholders || {}),
    };
    physicalDeletions.push(plan);
    changes.push(plan);
  }

  for (const [id, doc] of docsById) {
    if (selectedIds && !selectedIds.has(id) && !selectedIds.has(doc.metadata.opcode)) continue;
    const desired = projectionForDocument(doc);
    const rowState = state.rows[id];
    const rowIndex = locateRow(context.values, context.opcodeIndex, [doc.metadata.opcode, rowState?.opcode]);
    if (!desired) {
      const overrides = Object.keys(rowState?.overrides || {});
      const decision = decideRowPresence({ hasProjection: false, rowExists: rowIndex >= 0, overrides, deleteAuthorized: deleteIds.has(id) || deleteIds.has(doc.metadata.opcode) });
      if (decision.action === "none") continue;
      if (decision.action === "block") {
        blocked.push({ id, opcode: doc.metadata.opcode, reason: decision.reason });
        continue;
      }
      changes.push({ type: "clear-row", id, opcode: doc.metadata.opcode, row: rowIndex + 1, range: `C${rowIndex + 1}:L${rowIndex + 1}` });
      if (apply) context.sheet.getRange(`C${rowIndex + 1}:L${rowIndex + 1}`).clear({ applyTo: "contents" });
      delete state.rows[id];
      cleared.push(doc.metadata.opcode);
      continue;
    }

    if (rowIndex < 0) {
      const values = projectionValues(desired);
      const addedRowNumber = context.values.length + additions.length + 1;
      changes.push({ type: "add-row", id, opcode: doc.metadata.opcode, row: addedRowNumber, values });
      if (apply) {
        const targetRowIndex = context.values.length + additions.length;
        const target = context.sheet.getRangeByIndexes(targetRowIndex, 0, 1, XLSX_COLUMNS.length);
        let templateRowIndex = context.values.length - 1;
        for (let candidate = context.values.length - 1; candidate >= 1; candidate -= 1) {
          const candidateRow = currentRowState(context.headers, context.values, candidate);
          if (valuesEqual(candidateRow["类型"], desired["类型"]) || valuesEqual(candidateRow["子类型"], desired["子类型"])) {
            templateRowIndex = candidate;
            break;
          }
        }
        target.copyFrom(context.sheet.getRangeByIndexes(templateRowIndex, 0, 1, XLSX_COLUMNS.length), "all");
        copyRowFormat(context.sheet, templateRowIndex, targetRowIndex);
        target.values = [values];
      }
      state.rows[id] = {
        opcode: doc.metadata.opcode,
        row_number: addedRowNumber,
        last_generated: desired,
        overrides: {},
        layout_placeholders: {},
      };
      additions.push(doc.metadata.opcode);
      continue;
    }

    const current = currentRowState(context.headers, context.values, rowIndex);
    const nextState = rowState || buildStateRow(doc, desired, current, rowIndex + 1);
    nextState.row_number = rowIndex + 1;
    nextState.overrides ||= {};
    nextState.layout_placeholders ||= {};
    nextState.last_generated ||= {};
    const oldOpcode = nextState.opcode;
    if (!valuesEqual(current.Opcode, oldOpcode) && !valuesEqual(current.Opcode, doc.metadata.opcode)) {
      blocked.push({ id, opcode: doc.metadata.opcode, reason: `controlled Opcode cell was changed to ${current.Opcode}` });
      continue;
    }
    for (let columnIndex = 0; columnIndex < XLSX_COLUMNS.length; columnIndex += 1) {
      const column = XLSX_COLUMNS[columnIndex];
      const actual = current[column] ?? null;
      const wanted = desired[column] ?? null;
      const previous = nextState.last_generated[column] ?? null;
      const clearAuthorized = clearedOverrideKeys.has(`${id}:${column}`);
      const decision = decideCell({ column, actual, previous, wanted, overrideProtected: Object.hasOwn(nextState.overrides, column), layoutProtected: Object.hasOwn(nextState.layout_placeholders, column), clearAuthorized });
      if (decision.action === "preserve") {
        preserved.push({ id, opcode: doc.metadata.opcode, column, value: actual, ...(decision.kind === "layout" ? { layout: true } : {}) });
        continue;
      }
      if (decision.action === "protect") {
        if (decision.kind === "layout") nextState.layout_placeholders[column] = actual;
        else nextState.overrides[column] = actual;
        preserved.push({ id, opcode: doc.metadata.opcode, column, value: actual, detected: true, ...(decision.kind === "layout" ? { layout: true } : {}) });
        continue;
      }
      if (decision.action === "write") {
        changes.push({ type: "cell", id, opcode: doc.metadata.opcode, cell: `${String.fromCharCode(65 + columnIndex)}${rowIndex + 1}`, column, from: actual, to: wanted });
        if (apply) context.sheet.getCell(rowIndex, columnIndex).values = [[wanted]];
      }
      nextState.last_generated[column] = wanted;
    }
    nextState.opcode = doc.metadata.opcode;
    state.rows[id] = nextState;
  }

  for (const id of deleteIds) {
    if (!docsById.has(id) && state.rows[id]) {
      const rowState = state.rows[id];
      const rowIndex = locateRow(context.values, context.opcodeIndex, [rowState.opcode]);
      if (rowIndex >= 0) {
        changes.push({ type: "clear-row", id, opcode: rowState.opcode, row: rowIndex + 1, range: `C${rowIndex + 1}:L${rowIndex + 1}` });
        if (apply) context.sheet.getRange(`C${rowIndex + 1}:L${rowIndex + 1}`).clear({ applyTo: "contents" });
      }
      delete state.rows[id];
    }
  }

  if (apply && !blocked.length && physicalDeletions.length) {
    const deletedRows = physicalDeletions.map((item) => item.row).sort((left, right) => left - right);
    for (const item of physicalDeletions) {
      delete state.rows[item.id];
      if (!state.physical_deletions.includes(item.id)) state.physical_deletions.push(item.id);
      cleared.push(item.opcode);
    }
    for (const rowState of Object.values(state.rows)) {
      if (Number.isInteger(rowState.row_number)) rowState.row_number -= deletedBefore(deletedRows, rowState.row_number);
    }
  }

  console.log(JSON.stringify({
    apply,
    changes,
    additions,
    cleared,
    physical_deletions: physicalDeletions,
    preserved_count: preserved.length,
    newly_detected_overrides: preserved.filter((item) => item.detected),
    preserved_sample: preserved.slice(0, 20),
    blocked,
  }, null, 2));
  if (blocked.length) process.exitCode = 2;
  if (!apply || blocked.length) return;
  const tempDir = await fs.mkdtemp(path.join(os.tmpdir(), "davincioo-intrinsic-xlsx-"));
  const tempWorkbook = path.join(tempDir, path.basename(paths.workbookPath));
  const outputWorkbook = physicalDeletions.length
    ? artifact.Workbook.load(physicalDeleteRows(context.workbook, context.sheet.name, physicalDeletions.map((item) => item.row)))
    : context.workbook;
  if (changes.length) {
    const exported = await artifact.SpreadsheetFile.exportXlsx(outputWorkbook);
    await exported.save(tempWorkbook);
    await fs.copyFile(tempWorkbook, paths.workbookPath);
  }
  const workbookBytes = await fs.readFile(paths.workbookPath);
  state.workbook_sha256 = hashBuffer(workbookBytes);
  state.source_fingerprint = sourceFingerprint(docs);
  state.projection_fingerprint = excelProjectionFingerprint(docs);
  await fs.writeFile(paths.sidecarPath, `${JSON.stringify(state, null, 2)}\n`);
  if (!changes.length) console.log("No workbook changes; sidecar state refreshed.");
  const errors = await outputWorkbook.inspect({ kind: "match", searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A", options: { useRegex: true, maxResults: 300 }, summary: "final formula error scan" });
  console.log(errors.ndjson);
  const renderDir = path.join(tempDir, "rendered");
  await fs.mkdir(renderDir, { recursive: true });
  const changedRows = changes.map((change) => change.row || Number(String(change.cell || "").match(/\d+/)?.[0])).filter(Number.isFinite);
  const sheet1Range = changedRows.length
    ? `A${Math.max(1, Math.min(...changedRows) - 2)}:L${Math.max(...changedRows) + 2}`
    : "A1:L25";
  for (const [sheetName, range] of [["Sheet1", sheet1Range], ["Sheet2", "A1:B13"], ["Sheet3", "A1:B12"]]) {
    const preview = await outputWorkbook.render({ sheetName, range, scale: 1.1, format: "png" });
    await fs.writeFile(path.join(renderDir, `${sheetName}.png`), new Uint8Array(await preview.arrayBuffer()));
  }
  console.log(`verification_renders=${renderDir}`);
}

function help() {
  console.log(`Usage: node sync_intrinsic_xlsx.mjs <bootstrap|audit|dry-run|apply> [options]\n\nOptions:\n  --root DIR\n  --artifact-node-modules DIR (required for bootstrap/dry-run/apply)\n  --id ID_OR_OPCODE\n  --delete-id ID_OR_OPCODE\n  --physical-delete-id STABLE_ID\n  --clear-override ID:COLUMN\n`);
}

const options = parseArgs(process.argv);
const paths = resolvePaths(options);
try {
  if (!["bootstrap", "audit", "dry-run", "apply"].includes(options.command)) help();
  else if (options.command === "audit") {
    const state = migrateState(JSON.parse(await fs.readFile(paths.sidecarPath, "utf8")));
    console.log(JSON.stringify(auditState(state), null, 2));
  } else {
    const artifact = await loadArtifactTool(options.nodeModules);
    if (options.command === "bootstrap") await bootstrap(artifact, paths);
    else await synchronize(artifact, paths, options, options.command === "apply");
  }
} catch (error) {
  console.error(error.stack || error.message);
  process.exitCode = 1;
}
