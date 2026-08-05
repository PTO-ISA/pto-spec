import { XLSX_COLUMNS, normalizeCell } from "./intrinsic_docs_lib.mjs";

export function normalize(value) {
  return normalizeCell(value);
}

export function valuesEqual(a, b) {
  return normalize(a) === normalize(b);
}

export function decideRowPresence({ hasProjection, rowExists, overrides = [], deleteAuthorized = false }) {
  if (hasProjection && !rowExists) return { action: "add" };
  if (hasProjection) return { action: "update" };
  if (!rowExists) return { action: "none" };
  if (overrides.length && !deleteAuthorized) return { action: "block", reason: `manual overrides: ${overrides.join(", ")}` };
  return { action: "clear" };
}

export function decideCell({ column, actual, previous, wanted, overrideProtected = false, layoutProtected = false, clearAuthorized = false }) {
  if (column === "Opcode") return valuesEqual(actual, wanted) ? { action: "none" } : { action: "write", value: wanted };
  if (overrideProtected && !clearAuthorized) return { action: "preserve", kind: "manual" };
  if (layoutProtected && !clearAuthorized) return { action: "preserve", kind: "layout" };
  if (!clearAuthorized && !valuesEqual(actual, previous) && !valuesEqual(actual, wanted)) {
    if (["类型", "子类型"].includes(column) && actual == null) return { action: "protect", kind: "layout", value: actual };
    return { action: "protect", kind: "manual", value: actual };
  }
  return valuesEqual(actual, wanted) ? { action: "none" } : { action: "write", value: wanted };
}

export function rowObject(headers, values) {
  return Object.fromEntries(headers.map((header, index) => [header, normalize(values[index])]));
}

export function buildStateRow(doc, projection, current, rowNumber) {
  const overrides = {};
  const layoutPlaceholders = {};
  const lastGenerated = {};
  for (const column of XLSX_COLUMNS) {
    const desired = projection[column] ?? null;
    const actual = current[column] ?? null;
    lastGenerated[column] = desired;
    if (column !== "Opcode" && !valuesEqual(actual, desired)) {
      if (["类型", "子类型"].includes(column) && actual == null) layoutPlaceholders[column] = actual;
      else overrides[column] = actual;
    }
  }
  return { opcode: doc.metadata.opcode, row_number: rowNumber, last_generated: lastGenerated, overrides, layout_placeholders: layoutPlaceholders };
}

export function migrateState(state) {
  if (state.version === 2) return state;
  if (state.version !== 1) throw new Error(`Unsupported sidecar version: ${state.version}`);
  for (const row of Object.values(state.rows || {})) {
    row.overrides ||= {};
    row.layout_placeholders ||= {};
    for (const column of ["类型", "子类型"]) {
      if (Object.hasOwn(row.overrides, column) && row.overrides[column] == null) {
        row.layout_placeholders[column] = row.overrides[column];
        delete row.overrides[column];
      }
    }
  }
  state.version = 2;
  return state;
}

export function auditState(state) {
  const result = { version: state.version, manual_overrides: 0, layout_placeholders: 0, by_column: {}, rows: 0 };
  for (const row of Object.values(state.rows || {})) {
    const entries = [...Object.keys(row.overrides || {}).map((column) => ["manual", column]), ...Object.keys(row.layout_placeholders || {}).map((column) => ["layout", column])];
    if (entries.length) result.rows += 1;
    for (const [kind, column] of entries) {
      if (kind === "manual") result.manual_overrides += 1;
      else result.layout_placeholders += 1;
      result.by_column[column] ||= { manual: 0, layout: 0 };
      result.by_column[column][kind] += 1;
    }
  }
  return result;
}
