import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";

export const SCHEMA_VERSION = 1;
export const PROFILES = Object.freeze(["davincioo-v4-pe-local", "davincioo-v5-superscalar", "pto-isa-0.58.0"]);
export const PROFILE = "davincioo-v5-superscalar";
export const FRONTMATTER_RULES = Object.freeze({
  required: ["schema_version", "id", "kind", "title", "status", "visibility", "profile", "sources"],
  topLevel: ["schema_version", "id", "kind", "title", "status", "visibility", "profile", "opcode", "family", "sources", "bundle", "operands", "dtypes", "encoding", "xlsx"],
  enums: {
    kind: ["intrinsic", "header", "overview", "coverage"],
    status: ["mapped", "planned", "unmapped", "removed", "active", "review"],
    visibility: ["public", "internal"],
  },
  objects: {
    sources: ["davincioo", "pto", "linx"],
    operands: ["output", "input0", "input1", "input2"],
    encoding: ["block", "mode", "function", "shared_functions", "tile_op", "text"],
    xlsx: ["include", "category", "subcategory", "order", "description_section", "constraints_section"],
  },
});
export const XLSX_COLUMNS = [
  "类型",
  "子类型",
  "Opcode",
  "BSTART / bundle",
  "Output",
  "Input 0",
  "Input 1 / attrs",
  "Input 2",
  "Dtype",
  "Encoding",
  "Description",
  "Constraints",
];

const OVERVIEW_FILES = new Set([
  "README.md",
  "ISA_OVERVIEW.md",
  "PROGRAMMING_MODEL.md",
  "STATE_AND_TYPES.md",
  "ENCODING.md",
  "ASSEMBLY_SYNTAX.md",
  "MEMORY_AND_EXCEPTIONS.md",
]);

const COVERAGE_FILES = new Set([
  "SOURCE_GAPS_AND_CONFLICTS.md",
  "LINX_COVERAGE.md",
  "UNMAPPED_PTOISA.md",
  "LINX_TILEBLOCK_ENCODING_REVIEW.md",
  "OPERAND_BINDING_REVIEW.md",
]);

const SPECIAL_OPCODE_NAMES = new Map([
  ["get-scale-addr", "TGET_SCALE_ADDR"],
  ["set-img2col-padding", "TSET_IMG2COL_PADDING"],
  ["set-img2col-rpt", "TSET_IMG2COL_RPT"],
  ["setfmatrix", "TSETFMATRIX"],
  ["sethf32mode", "TSETHF32MODE"],
  ["settf32mode", "TSETTF32MODE"],
  ["subview", "TSUBVIEW"],
  ["syncall", "SYNCALL"],
]);

export function normalize(value) {
  return value == null ? "" : String(value);
}

export function normalizeCell(value) {
  const text = normalize(value).replace(/\r\n/g, "\n");
  return text === "" ? null : text;
}

export function sha256(value) {
  return crypto.createHash("sha256").update(value).digest("hex");
}

export function walk(dir, predicate = () => true) {
  if (!fs.existsSync(dir)) return [];
  const result = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) result.push(...walk(full, predicate));
    else if (entry.isFile() && predicate(full)) result.push(full);
  }
  return result;
}

export function toPosix(value) {
  return value.replaceAll(path.sep, "/");
}

export function parseFrontmatter(text, filePath = "<memory>") {
  const normalized = text.replace(/\r\n/g, "\n");
  if (!normalized.startsWith("---\n")) {
    return { metadata: null, body: normalized };
  }
  const end = normalized.indexOf("\n---\n", 4);
  if (end < 0) throw new Error(`${filePath}: unterminated frontmatter`);
  const raw = normalized.slice(4, end).trim();
  let metadata;
  try {
    metadata = JSON.parse(raw);
  } catch (error) {
    throw new Error(`${filePath}: frontmatter must be JSON-compatible YAML: ${error.message}`);
  }
  return { metadata, body: normalized.slice(end + 5) };
}

export function serializeDocument(metadata, body) {
  const cleanBody = body.replace(/^\s+/, "").replace(/\s*$/, "\n");
  return `---\n${JSON.stringify(metadata, null, 2)}\n---\n${cleanBody}`;
}

export function titleFromBody(body, fallback) {
  return body.match(/^#\s+(.+)$/m)?.[1]?.trim() || fallback;
}

export function documentKind(relativePath) {
  if (relativePath.startsWith("status/")) return "intrinsic";
  if (relativePath.startsWith("header/")) return "header";
  if (OVERVIEW_FILES.has(relativePath)) return "overview";
  if (COVERAGE_FILES.has(relativePath)) return "coverage";
  if (!relativePath.includes("/")) return "intrinsic";
  return null;
}

export function managedMarkdownFiles(intrinsicRoot) {
  const rootFiles = fs.readdirSync(intrinsicRoot, { withFileTypes: true })
    .filter((entry) => entry.isFile() && entry.name.endsWith(".md"))
    .map((entry) => path.join(intrinsicRoot, entry.name));
  const headerFiles = fs.existsSync(path.join(intrinsicRoot, "header"))
    ? fs.readdirSync(path.join(intrinsicRoot, "header"), { withFileTypes: true })
      .filter((entry) => entry.isFile() && entry.name.endsWith(".md"))
      .map((entry) => path.join(intrinsicRoot, "header", entry.name))
    : [];
  const statusFiles = walk(path.join(intrinsicRoot, "status"), (file) => file.endsWith(".md"));
  return [...rootFiles, ...headerFiles, ...statusFiles].sort();
}

export function loadDocuments(intrinsicRoot, { requireMetadata = true } = {}) {
  return managedMarkdownFiles(intrinsicRoot).map((filePath) => {
    const relativePath = toPosix(path.relative(intrinsicRoot, filePath));
    const text = fs.readFileSync(filePath, "utf8");
    const parsed = parseFrontmatter(text, relativePath);
    if (requireMetadata && !parsed.metadata) throw new Error(`${relativePath}: missing frontmatter`);
    return {
      filePath,
      relativePath,
      text,
      body: parsed.body,
      metadata: parsed.metadata,
      kind: parsed.metadata?.kind || documentKind(relativePath),
      title: parsed.metadata?.title || titleFromBody(parsed.body, path.basename(relativePath, ".md")),
    };
  });
}

export function slug(value) {
  return value
    .replace(/\.md$/i, "")
    .replace(/[^A-Za-z0-9._-]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .toLowerCase();
}

export function headingSlug(value) {
  return String(value)
    .replace(/<[^>]*>/g, "")
    .replace(/[`*_~]/g, "")
    .trim()
    .toLowerCase()
    .replace(/\s+/g, "-")
    .replace(/[^\p{Letter}\p{Number}._-]+/gu, "-")
    .replace(/-+/g, "-")
    .replace(/^-+|-+$/g, "") || "section";
}

export function generatedSchema() {
  const stringOrNull = { type: ["string", "null"] };
  return {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "https://davincioo.local/schemas/intrinsic.schema.json",
    title: "DavinciOO PTO intrinsic managed Markdown frontmatter",
    type: "object",
    additionalProperties: false,
    required: FRONTMATTER_RULES.required,
    properties: {
      schema_version: { const: SCHEMA_VERSION },
      id: { type: "string", pattern: "^[a-z0-9][a-z0-9._-]+$" },
      kind: { enum: FRONTMATTER_RULES.enums.kind },
      title: { type: "string", minLength: 1 },
      status: { enum: FRONTMATTER_RULES.enums.status },
      visibility: { enum: FRONTMATTER_RULES.enums.visibility },
      profile: { enum: PROFILES },
      opcode: { type: "string", minLength: 1 },
      family: { type: "string", minLength: 1 },
      sources: { type: "object", additionalProperties: false, required: ["davincioo"], properties: Object.fromEntries(FRONTMATTER_RULES.objects.sources.map((field) => [field, { type: "string", minLength: 1 }])) },
      bundle: stringOrNull,
      operands: { type: "object", additionalProperties: false, properties: Object.fromEntries(FRONTMATTER_RULES.objects.operands.map((field) => [field, stringOrNull])) },
      dtypes: { oneOf: [{ type: "string" }, { type: "array", items: { type: "string" } }] },
      encoding: { type: "object", additionalProperties: false, properties: { block: stringOrNull, mode: { type: ["integer", "null"], minimum: 0 }, function: { type: ["integer", "null"], minimum: 0 }, tile_op: { type: ["string", "null"], pattern: "^0x[0-9A-F]+$" }, text: stringOrNull } },
      xlsx: { type: "object", additionalProperties: false, required: ["include"], properties: { include: { type: "boolean" }, category: stringOrNull, subcategory: stringOrNull, order: { type: ["integer", "null"], minimum: 1 }, description_section: stringOrNull, constraints_section: stringOrNull } },
    },
  };
}

export function classifyFamily(opcode, sourcePath = "") {
  const upper = opcode.toUpperCase();
  if (sourcePath.startsWith("comm/") || sourcePath.includes("/comm/")) return "communication";
  if (sourcePath.startsWith("system/") || sourcePath.includes("/system/")) return "system-scheduling";
  if (sourcePath.includes("elementwise-tile-tile")) return "element-wise";
  if (sourcePath.includes("tile-scalar-and-immediate")) return "tile-scalar";
  if (sourcePath.includes("reduce-and-expand")) return "reduce-expand";
  if (sourcePath.includes("memory-and-data-movement")) return "memory-tlsu";
  if (sourcePath.includes("matrix-and-matrix-vector")) return "matrix-cube";
  if (sourcePath.includes("layout-and-rearrangement")) return "layout-movement";
  if (sourcePath.includes("irregular-and-complex")) return "complex-special";
  if (sourcePath.includes("sync-and-config")) return "sync-config";
  if (upper === "ACCCVT" || upper.startsWith("TMATMUL") || upper.startsWith("TGEMV")) return "matrix-cube";
  if (["TLOAD", "TSTORE", "TPREFETCH", "TPREFETCH_ASYNC", "MGATHER", "MSCATTER", "MGATHER_MASK", "MSCATTER_MASK"].includes(upper)) return "memory-tlsu";
  if (upper.startsWith("TROW") || upper.startsWith("TCOL")) return "reduce-expand";
  if (/S$/.test(upper) || ["TADDSC", "TSUBSC", "TEXPANDS", "TAXPY"].includes(upper)) return "tile-scalar";
  if (["TMOV", "TTRANS", "TCONCAT", "TEXTRACT", "TINSERT", "TIMG2COL", "TRESHAPE", "TSUBVIEW"].includes(upper)) return "layout-movement";
  if (["TQUANT", "TDEQUANT", "TPACK", "TSORT32", "TMRGSORT", "TRANDOM", "TTRI", "TCI", "TPRINT", "TGATHER", "TSCATTER", "TGATHERB", "THISTOGRAM"].includes(upper)) return "complex-special";
  if (["TSYNC", "SYNCALL", "TASSIGN", "TALIAS", "TSETFMATRIX", "TSET_IMG2COL_PADDING", "TSET_IMG2COL_RPT", "TSETHF32MODE", "TSETTF32MODE", "TGET_SCALE_ADDR"].includes(upper)) return "sync-config";
  return "element-wise";
}

export function opcodeFromSourcePath(sourcePath) {
  const base = path.posix.basename(sourcePath, ".md");
  if (SPECIAL_OPCODE_NAMES.has(base)) return SPECIAL_OPCODE_NAMES.get(base);
  return base.toUpperCase().replaceAll("-", "_");
}

export function discoverPtoOperations(ptoDocsRoot) {
  const sources = [];
  const tileRoot = path.join(ptoDocsRoot, "tile", "ops");
  for (const filePath of walk(tileRoot, (file) => file.endsWith(".md") && !file.endsWith("_zh.md"))) {
    const relativePath = toPosix(path.relative(ptoDocsRoot, filePath));
    sources.push({ opcode: opcodeFromSourcePath(relativePath), sourcePath: relativePath, family: classifyFamily(opcodeFromSourcePath(relativePath), relativePath) });
  }
  const commRoot = path.join(ptoDocsRoot, "comm");
  for (const filePath of walk(commRoot, (file) => file.endsWith(".md") && !file.endsWith("_zh.md"))) {
    const relativePath = toPosix(path.relative(ptoDocsRoot, filePath));
    const base = path.basename(filePath);
    if (base === "README.md" || base.startsWith("communication-runtime")) continue;
    sources.push({ opcode: `comm/${path.basename(filePath, ".md").toUpperCase()}`, sourcePath: relativePath, family: "communication" });
  }
  const systemRoot = path.join(ptoDocsRoot, "system", "ops");
  for (const filePath of walk(systemRoot, (file) => file.endsWith(".md") && !file.endsWith("_zh.md"))) {
    const relativePath = toPosix(path.relative(ptoDocsRoot, filePath));
    sources.push({ opcode: path.basename(filePath, ".md").toUpperCase(), sourcePath: relativePath, family: "system-scheduling" });
  }
  if (!sources.some((item) => item.opcode === "TALLOC")) {
    sources.push({ opcode: "TALLOC", sourcePath: "TALLOC.md", family: "system-scheduling" });
  }
  const seen = new Set();
  return sources
    .filter((item) => !seen.has(item.opcode) && seen.add(item.opcode))
    .sort((a, b) => a.opcode.localeCompare(b.opcode));
}

export function extractSection(body, heading) {
  const escaped = heading.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const match = body.match(new RegExp(`^##\\s+${escaped}\\s*$([\\s\\S]*?)(?=^##\\s+|(?![\\s\\S]))`, "m"));
  return match ? match[1].trim() : "";
}

export function markdownToPlain(markdown) {
  return markdown
    .replace(/```[\s\S]*?```/g, "")
    .replace(/!\[([^\]]*)\]\([^)]+\)/g, "$1")
    .replace(/\[([^\]]+)\]\([^)]+\)/g, "$1")
    .replace(/^\|.*\|$/gm, "")
    .replace(/^>\s?/gm, "")
    .replace(/^[-*]\s+/gm, "")
    .replace(/`/g, "")
    .replace(/\*\*/g, "")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}

export function summaryFromSection(body, heading) {
  const plain = markdownToPlain(extractSection(body, heading));
  const paragraphs = plain.split(/\n\s*\n/).map((item) => item.replace(/\s+/g, " ").trim()).filter(Boolean);
  return paragraphs.find((item) => item.length >= 20 && !/^PTO/.test(item)) || paragraphs[0] || "";
}

export function encodingText(encoding) {
  if (!encoding) return null;
  if (encoding.text) return encoding.text;
  const block = encoding.block || "";
  const parts = [];
  if (encoding.mode != null) parts.push(`Mode ${encoding.mode}`);
  if (encoding.function != null) parts.push(`Function ${encoding.function}`);
  if (Array.isArray(encoding.shared_functions) && encoding.shared_functions.length) {
    const values = encoding.shared_functions;
    const consecutive = values.every((value, index) => index === 0 || value === values[index - 1] + 1);
    const range = consecutive && values.length > 1 ? `${values[0]}–${values.at(-1)}` : values.join(", ");
    parts.push(`Shared Functions ${range}`);
  }
  if (encoding.tile_op) parts.push(`TileOp ${encoding.tile_op}`);
  return `${block}${parts.length ? ` ${parts.join(", ")}` : ""};`;
}

export function projectionForDocument(doc) {
  const meta = doc.metadata;
  if (!meta?.xlsx?.include) return null;
  const operands = meta.operands || {};
  const dtype = Array.isArray(meta.dtypes) ? meta.dtypes.join(", ") : normalizeCell(meta.dtypes);
  const descriptionHeading = meta.xlsx.description_section || "PTO 语义来源";
  const constraintsHeading = meta.xlsx.constraints_section || "约束与合法性";
  const values = [
    normalizeCell(meta.xlsx.category),
    normalizeCell(meta.xlsx.subcategory),
    normalizeCell(meta.opcode),
    normalizeCell(meta.bundle),
    normalizeCell(operands.output),
    normalizeCell(operands.input0),
    normalizeCell(operands.input1),
    normalizeCell(operands.input2),
    dtype,
    normalizeCell(encodingText(meta.encoding)),
    normalizeCell(summaryFromSection(doc.body, descriptionHeading)),
    normalizeCell(markdownToPlain(extractSection(doc.body, constraintsHeading))),
  ];
  return Object.fromEntries(XLSX_COLUMNS.map((column, index) => [column, values[index]]));
}

export function publicDocument(doc) {
  const meta = doc.metadata;
  if (!meta || meta.visibility !== "public") return false;
  if (meta.kind === "coverage") return false;
  if (meta.kind === "intrinsic" && meta.status !== "mapped") return false;
  if (["header", "overview"].includes(meta.kind) && meta.status !== "active") return false;
  return ["intrinsic", "header", "overview"].includes(meta.kind);
}

export function hasLocalAbsolutePath(text) {
  return /(?:file:\/\/|(?:^|[\s('"`])[A-Za-z]:[\\/]|(?:^|[\s('"`])\\\\[A-Za-z0-9._-]+\\[^\\\s]+|(?:^|[\s('"`])\/(?:Users|home|root|private|tmp|var\/folders)\/)/m.test(text);
}

export function validateMetadata(doc) {
  const errors = [];
  const meta = doc.metadata;
  if (!meta || typeof meta !== "object") return [`${doc.relativePath}: missing metadata`];
  const allowedTopLevel = new Set(FRONTMATTER_RULES.topLevel);
  for (const field of Object.keys(meta)) if (!allowedTopLevel.has(field)) errors.push(`${doc.relativePath}: schema rejects unknown field ${field}`);
  for (const field of FRONTMATTER_RULES.required) {
    if (meta[field] == null || meta[field] === "") errors.push(`${doc.relativePath}: missing ${field}`);
  }
  if (meta.schema_version !== SCHEMA_VERSION) errors.push(`${doc.relativePath}: unsupported schema_version ${meta.schema_version}`);
  if (typeof meta.id !== "string" || !/^[a-z0-9][a-z0-9._-]+$/.test(meta.id)) errors.push(`${doc.relativePath}: invalid id ${meta.id}`);
  if (!FRONTMATTER_RULES.enums.kind.includes(meta.kind)) errors.push(`${doc.relativePath}: invalid kind ${meta.kind}`);
  if (!FRONTMATTER_RULES.enums.status.includes(meta.status)) errors.push(`${doc.relativePath}: invalid status ${meta.status}`);
  if (!FRONTMATTER_RULES.enums.visibility.includes(meta.visibility)) errors.push(`${doc.relativePath}: invalid visibility ${meta.visibility}`);
  if (!PROFILES.includes(meta.profile)) errors.push(`${doc.relativePath}: invalid profile ${meta.profile}`);
  if (!meta.sources || typeof meta.sources !== "object" || Array.isArray(meta.sources)) errors.push(`${doc.relativePath}: missing sources`);
  else {
    for (const field of Object.keys(meta.sources)) if (!FRONTMATTER_RULES.objects.sources.includes(field)) errors.push(`${doc.relativePath}: schema rejects sources.${field}`);
    if (typeof meta.sources.davincioo !== "string" || !meta.sources.davincioo) errors.push(`${doc.relativePath}: sources.davincioo is required`);
    else if (meta.sources.davincioo !== doc.relativePath) errors.push(`${doc.relativePath}: sources.davincioo must match the live document path`);
  }
  if (meta.kind === "intrinsic") {
    if (!meta.opcode) errors.push(`${doc.relativePath}: intrinsic missing opcode`);
    if (!meta.family) errors.push(`${doc.relativePath}: intrinsic missing family`);
    if (!meta.xlsx || typeof meta.xlsx.include !== "boolean") errors.push(`${doc.relativePath}: intrinsic missing xlsx.include`);
    if (["planned", "unmapped", "removed"].includes(meta.status) && meta.xlsx?.include) errors.push(`${doc.relativePath}: inactive intrinsic cannot remain in Excel`);
    if (meta.status === "mapped" && meta.visibility !== "public") errors.push(`${doc.relativePath}: mapped intrinsic must be public`);
    if (meta.status !== "mapped" && meta.visibility !== "internal") errors.push(`${doc.relativePath}: non-mapped intrinsic must be internal`);
    if (meta.xlsx?.include) {
      if (!meta.bundle && !["planned", "unmapped", "removed"].includes(meta.status)) errors.push(`${doc.relativePath}: Excel-mapped intrinsic missing bundle`);
      if (!meta.operands) errors.push(`${doc.relativePath}: Excel-mapped intrinsic missing operands`);
      if (!meta.encoding) errors.push(`${doc.relativePath}: Excel-mapped intrinsic missing encoding`);
    }
  }
  for (const [objectName, allowed] of Object.entries(FRONTMATTER_RULES.objects).filter(([name]) => name !== "sources")) {
    const value = meta[objectName];
    if (value != null && (typeof value !== "object" || Array.isArray(value))) errors.push(`${doc.relativePath}: ${objectName} must be an object`);
    else if (value) for (const field of Object.keys(value)) if (!allowed.includes(field)) errors.push(`${doc.relativePath}: schema rejects ${objectName}.${field}`);
  }
  if (meta.encoding?.mode != null && (!Number.isInteger(meta.encoding.mode) || meta.encoding.mode < 0)) errors.push(`${doc.relativePath}: invalid encoding.mode`);
  if (meta.encoding?.function != null && (!Number.isInteger(meta.encoding.function) || meta.encoding.function < 0)) errors.push(`${doc.relativePath}: invalid encoding.function`);
  if (meta.encoding?.tile_op != null && !/^0x[0-9A-F]+$/.test(meta.encoding.tile_op)) errors.push(`${doc.relativePath}: invalid encoding.tile_op`);
  if (meta.xlsx?.order != null && (!Number.isInteger(meta.xlsx.order) || meta.xlsx.order < 1)) errors.push(`${doc.relativePath}: invalid xlsx.order`);
  if (hasLocalAbsolutePath(doc.text)) errors.push(`${doc.relativePath}: contains a local absolute path`);
  return errors;
}

export function validateProjectionFormatting(doc) {
  const errors = [];
  const meta = doc.metadata;
  if (meta?.kind !== "intrinsic" || !meta.xlsx?.include) return errors;
  if (typeof meta.bundle === "string") {
    if (/\s\+\s|;/.test(meta.bundle)) errors.push(`${doc.relativePath}: bundle must put distinct entries on separate lines`);
    if (meta.bundle.split("\n").some((line) => !line.trim())) errors.push(`${doc.relativePath}: bundle contains an empty display line`);
  }
  for (const [field, value] of Object.entries(meta.operands || {})) {
    if (value === "-") errors.push(`${doc.relativePath}: operands.${field} must use null for absence`);
    if (typeof value !== "string") continue;
    for (const line of value.split("\n")) {
      if (/[;+]/.test(line)) errors.push(`${doc.relativePath}: operands.${field} packs multiple roles on one line`);
      if (/optional/i.test(line) && !/\(optional\)$/.test(line)) errors.push(`${doc.relativePath}: operands.${field} must use the exact (optional) suffix`);
    }
  }
  if (meta.family === "matrix-cube") {
    const operands = meta.operands || {};
    if (!String(operands.input0 || "").startsWith("A Tile")) errors.push(`${doc.relativePath}: matrix Input 0 must begin with A Tile`);
    if (!String(operands.input1 || "").startsWith("B/Right Tile")) errors.push(`${doc.relativePath}: matrix Input 1 must begin with B/Right Tile`);
    if (/Bias|RowMax|Quant|ReLU|ACC/.test(String(operands.input1 || ""))) errors.push(`${doc.relativePath}: matrix auxiliary operands must not be packed into Input 1`);
    if (/A Tile|B\/Right Tile|ScaleA|ScaleB|ScaleRight/.test(String(operands.input2 || ""))) errors.push(`${doc.relativePath}: matrix A/B-side operands are in Input 2`);
    if (!/^D Tile/.test(String(operands.output || ""))) errors.push(`${doc.relativePath}: matrix Output must begin with explicit D Tile`);
  }
  return errors;
}

export function excelProjectionFingerprint(docs) {
  const normalized = docs
    .filter((doc) => doc.metadata?.kind === "intrinsic" && doc.metadata.xlsx?.include)
    .map((doc) => `${doc.metadata.id}\n${JSON.stringify(projectionForDocument(doc))}`)
    .sort()
    .join("\n---ROW---\n");
  return sha256(normalized);
}

export function sourceFingerprint(docs) {
  const normalized = docs
    .filter(publicDocument)
    .map((doc) => `${doc.relativePath}\n${serializeDocument(doc.metadata, doc.body)}`)
    .sort()
    .join("\n---DOC---\n");
  return sha256(normalized);
}
