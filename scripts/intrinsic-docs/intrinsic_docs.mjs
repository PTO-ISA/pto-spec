#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import {
  PROFILE,
  SCHEMA_VERSION,
  XLSX_COLUMNS,
  classifyFamily,
  discoverPtoOperations,
  documentKind,
  excelProjectionFingerprint,
  encodingText,
  generatedSchema,
  hasLocalAbsolutePath,
  headingSlug,
  loadDocuments,
  managedMarkdownFiles,
  normalizeCell,
  opcodeFromSourcePath,
  parseFrontmatter,
  projectionForDocument,
  publicDocument,
  serializeDocument,
  sha256,
  slug,
  sourceFingerprint,
  titleFromBody,
  toPosix,
  validateMetadata,
  validateProjectionFormatting,
  walk,
} from "./intrinsic_docs_lib.mjs";
const SCRIPT_DIR = path.dirname(fileURLToPath(import.meta.url));

function parseArgs(argv) {
  const command = argv[2] || "help";
  const options = { command, ids: [] };
  for (let i = 3; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--root") options.root = argv[++i];
    else if (arg === "--pto-docs-root") options.ptoDocsRoot = argv[++i];
    else if (arg === "--linx-root") options.linxRoot = argv[++i];
    else if (arg === "--xlsx-json") options.xlsxJson = argv[++i];
    else if (arg === "--output-root") options.outputRoot = argv[++i];
    else if (arg === "--id") options.ids.push(argv[++i]);
    else if (arg === "--all") options.all = true;
    else if (arg === "--check") options.checkOnly = true;
    else throw new Error(`Unknown argument: ${arg}`);
  }
  return options;
}

function resolveRoots(options) {
  const repoRoot = path.resolve(options.root || path.join(SCRIPT_DIR, "..", ".."));
  const intrinsicRoot = repoRoot;
  const defaultPtoRoot = [
    path.resolve(intrinsicRoot, "..", "..", "..", "pto-isa", "docs", "isa"),
    path.resolve(intrinsicRoot, "..", "pto"),
  ].find((candidate) => fs.existsSync(candidate));
  return {
    intrinsicRoot,
    repoRoot,
    ptoDocsRoot: path.resolve(options.ptoDocsRoot || defaultPtoRoot || path.join(intrinsicRoot, "..", "pto")),
    linxRoot: path.resolve(options.linxRoot || process.env.LINX_ISA_ROOT || path.join(repoRoot, "..", "linx-isa")),
    outputRoot: path.resolve(options.outputRoot || path.join(repoRoot, "build", "intrinsic-docs")),
  };
}

const LINX_LEGACY_FILES = [
  "arch/exception.md",
  "arch/fixup.md",
  "blockIntro/mem_block/dimmode.md",
  "blockIntro/sys_block/atomic.md",
  "blockIntro/sys_block/cachemaintain.md",
  "blockIntro/sys_block/excutecontrol.md",
  "blockIntro/sys_block/gqm.md",
  "blockIntro/sys_block/instlist.md",
  "blockIntro/sys_block/intro.md",
  "blockIntro/sys_block/lr_sc.md",
  "blockIntro/sys_block/tlb.md",
  "blockIntro/vecinstrs/instIntro.md",
  "inst/LibPseudoCode.md",
  "instset/baseExtInstrs.md",
  "instset/baseInstrs.md",
  "instset/compressInstrs.md",
  "instset/haflLongInstrs.md",
  "instset/longInstrs.md",
  "instset/standardInstrs.md",
  "register/common/barg.md",
  "register/common/ggpr.md",
  "register/common/loop.md",
  "register/common/pred.md",
  "register/ssr/CSTATE.md",
  "register/ssr/TRAPNO.md",
  "register/ssr/ssrintro.md",
  "header/templateblock/FENTRY.md",
  "header/templateblock/FEXIT.md",
  "header/templateblock/FRET.RA.md",
  "header/templateblock/FRET.STK.md",
  "header/templateblock/MCOPY.D.md",
  "header/templateblock/MCOPY.md",
  "header/templateblock/MSET.md",
  "header/templateblock/intro.md",
];

function linxSysFiles(root) {
  const dir = path.join(root, "inst", "misa_s");
  if (!fs.existsSync(dir)) return [];
  return fs.readdirSync(dir, { withFileTypes: true })
    .filter((entry) => entry.isFile() && entry.name.endsWith(".md"))
    .map((entry) => `inst/misa_s/${entry.name}`)
    .sort();
}

function linxSnapshotRoot(roots) {
  return roots.repoRoot
    ? path.join(roots.repoRoot, "docs", "compatibility", "scalar", "support", "linx-v0.56")
    : path.join(roots.intrinsicRoot, "scalar", "support", "linx-v0.56");
}

function linxLockPath(roots) {
  return roots.repoRoot
    ? path.join(roots.repoRoot, "spec", "evidence", "source-locks", "LINX-ISA.source-lock.json")
    : path.join(roots.intrinsicRoot, "LINX-ISA.source-lock.json");
}

function linxSourceRoot(roots) {
  return path.join(roots.linxRoot, "docs", "zh", "isa");
}

function linxInventory(root, paths = LINX_LEGACY_FILES) {
  const files = paths.map((relativePath) => {
    const filePath = path.join(root, relativePath);
    if (!fs.existsSync(filePath)) throw new Error(`Missing Linx legacy dependency: ${filePath}`);
    const bytes = fs.readFileSync(filePath);
    return { path: relativePath, language: relativePath.endsWith(".md") ? "zh" : "asset", sha256: sha256(bytes), bytes: bytes.length };
  });
  return { files, fingerprint: sha256(files.map((item) => `${item.path}\n${item.sha256}`).join("\n")) };
}

function refreshLinxLegacy(roots) {
  const sourceRoot = linxSourceRoot(roots);
  if (!fs.existsSync(sourceRoot)) throw new Error(`Linx source is unavailable: ${sourceRoot}; pass --linx-root`);
  if (gitValue(roots.linxRoot, ["status", "--porcelain"])) throw new Error(`Refusing to refresh from dirty Linx checkout: ${roots.linxRoot}`);
  const sysSeeds = [...LINX_LEGACY_FILES.filter((item) => item.startsWith("blockIntro/sys_block/")), ...linxSysFiles(sourceRoot)];
  const paths = new Set([...LINX_LEGACY_FILES, ...sysSeeds]);
  const queue = [...sysSeeds];
  for (let index = 0; index < queue.length; index += 1) {
    const relativePath = queue[index];
    const body = fs.readFileSync(path.join(sourceRoot, relativePath), "utf8");
    for (const link of markdownLinks(body)) {
      const [filePart] = splitHref(link.href);
      if (!/\.(?:md|png|jpe?g|gif|svg|webp)$/i.test(filePart)) continue;
      const dependencyPath = toPosix(path.normalize(path.join(path.dirname(relativePath), filePart)));
      if (dependencyPath.startsWith("../") || !fs.existsSync(path.join(sourceRoot, dependencyPath)) || paths.has(dependencyPath)) continue;
      paths.add(dependencyPath);
      if (dependencyPath.endsWith(".md")) queue.push(dependencyPath);
    }
    for (const match of body.matchAll(/<(?:img|source)[^>]+(?:src|href)=["']([^"']+)["']/gi)) {
      const assetPath = toPosix(path.normalize(path.join(path.dirname(relativePath), match[1])));
      if (!assetPath.startsWith("../") && fs.existsSync(path.join(sourceRoot, assetPath))) paths.add(assetPath);
    }
  }
  const inventory = linxInventory(sourceRoot, [...paths].sort());
  const snapshotRoot = linxSnapshotRoot(roots);
  fs.rmSync(snapshotRoot, { recursive: true, force: true });
  for (const item of inventory.files) {
    const destination = path.join(snapshotRoot, item.path);
    fs.mkdirSync(path.dirname(destination), { recursive: true });
    fs.copyFileSync(path.join(sourceRoot, item.path), destination);
  }
  const lock = {
    version: 1,
    repository: gitValue(roots.linxRoot, ["remote", "get-url", "origin"]),
    commit: gitValue(roots.linxRoot, ["rev-parse", "HEAD"]),
    source_root: "docs/zh/isa",
    aggregate_sha256: inventory.fingerprint,
    files: inventory.files.map((item) => ({ ...item, original_path: `docs/zh/isa/${item.path}` })),
  };
  writeText(linxLockPath(roots), `${JSON.stringify(lock, null, 2)}\n`);
  console.log(`linx_lock=${linxLockPath(roots)}`);
  console.log(`linx_commit=${lock.commit}`);
  console.log(`linx_files=${lock.files.length}`);
}

export function checkLinxLock(roots) {
  const errors = [];
  const lockFile = linxLockPath(roots);
  if (!fs.existsSync(lockFile)) return ["LINX-ISA.source-lock.json: missing source lock"];
  const lock = readJson(lockFile);
  if (lock.version !== 1 || !Array.isArray(lock.files) || typeof lock.aggregate_sha256 !== "string") return ["LINX-ISA.source-lock.json: invalid source lock"];
  try {
    const snapshot = linxInventory(linxSnapshotRoot(roots), lock.files.map((item) => item.path));
    if (snapshot.fingerprint !== lock.aggregate_sha256) errors.push("LINX-ISA.source-lock.json: committed snapshot differs from lock");
  } catch (error) {
    errors.push(error.message);
  }
  if (fs.existsSync(linxSourceRoot(roots))) {
    try {
      const live = linxInventory(linxSourceRoot(roots), lock.files.map((item) => item.path));
      if (live.fingerprint !== lock.aggregate_sha256) errors.push("LINX-ISA.source-lock.json: live Linx source differs; run refresh-linx-legacy explicitly");
      if (gitValue(roots.linxRoot, ["rev-parse", "HEAD"]) !== lock.commit) errors.push("LINX-ISA.source-lock.json: live Linx commit differs; run refresh-linx-legacy");
    } catch (error) {
      errors.push(`LINX-ISA.source-lock.json: ${error.message}`);
    }
  }
  return errors;
}

export function checkSysInventory(roots) {
  const errors = [];
  const lockFile = linxLockPath(roots);
  if (!fs.existsSync(lockFile)) return errors;
  const lock = readJson(lockFile);
  const locked = new Set((lock.files || []).map((item) => item.path));
  const sysList = "blockIntro/sys_block/instlist.md";
  if (!locked.has(sysList)) errors.push(`SYS inventory: ${sysList} is absent from the Linx lock`);
  const lockedSys = [...locked].filter((item) => item.startsWith("inst/misa_s/") && item.endsWith(".md"));
  if (!lockedSys.length) errors.push("SYS inventory: no Linx misa_s pages are locked");
  for (const relativePath of lockedSys) {
    const name = path.posix.basename(relativePath);
    if (!fs.existsSync(path.join(roots.intrinsicRoot, "scalar", "misa_s", name))) {
      errors.push(`SYS inventory: scalar/misa_s/${name} is missing while the profile claims a fully open SYS body`);
    }
  }
  return errors;
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeText(filePath, text) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, text);
}

function parseEncoding(text) {
  if (!text) return { text: null };
  const block = text.match(/^([A-Z]+)/)?.[1] || null;
  const mode = text.match(/Mode\s+(\d+)/i)?.[1];
  const fn = text.match(/Function\s+(\d+)/i)?.[1];
  const tileOp = text.match(/TileOp\s+(0x[0-9A-Fa-f]+)/i)?.[1];
  if (!block || (mode == null && fn == null && !tileOp)) return { text };
  return {
    block,
    ...(mode == null ? {} : { mode: Number(mode) }),
    ...(fn == null ? {} : { function: Number(fn) }),
    ...(tileOp ? { tile_op: tileOp.toUpperCase().replace("0X", "0x") } : {}),
  };
}

function splitDtypes(value) {
  if (!value) return [];
  return String(value).split(/,\s*/).map((item) => item.trim()).filter(Boolean);
}

function blockStartFromBody(body) {
  const section = body.match(/^##\s+DavinciOO Block Intrinsic\s*$([\s\S]*?)(?=^##\s+|(?![\s\S]))/m)?.[1] || "";
  const match = section.match(/^\s*(BSTART\.[A-Z]+)\s+([^,\s]+)/m);
  return match ? { header: match[1], opcode: match[2] } : null;
}

function descriptionSectionForBody(body) {
  return body.match(/^##\s+(.+语义来源)\s*$/m)?.[1]?.trim() || "PTO 语义来源";
}

function propagatedWorkbookRows(matrix) {
  const rows = [];
  let category = null;
  let subcategory = null;
  for (let i = 1; i < matrix.length; i += 1) {
    const row = [...matrix[i]];
    if (row[0] != null && row[0] !== "") category = row[0];
    if (row[1] != null && row[1] !== "") subcategory = row[1];
    row[0] = category;
    row[1] = subcategory;
    if (row[2]) rows.push({ rowNumber: i + 1, values: row });
  }
  return rows;
}

function ptoSourceMap(ptoDocsRoot) {
  return new Map(discoverPtoOperations(ptoDocsRoot).map((item) => [item.opcode, item]));
}

function ptoSourceAvailable(ptoDocsRoot) {
  return fs.existsSync(path.join(ptoDocsRoot, "tile", "ops"));
}

function ptoInventory(ptoDocsRoot) {
  const operations = discoverPtoOperations(ptoDocsRoot).map((item) => ({ opcode: item.opcode, family: item.family, source_path: item.sourcePath }));
  const fingerprint = sha256(operations.map((item) => {
    const source = path.join(ptoDocsRoot, item.source_path);
    return `${item.opcode}\n${item.family}\n${item.source_path}\n${fs.existsSync(source) ? fs.readFileSync(source) : "<missing>"}`;
  }).join("\n---PTO-OP---\n"));
  return { operations, fingerprint };
}

function ptoLockPath(roots) {
  return roots.repoRoot
    ? path.join(roots.repoRoot, "spec", "evidence", "source-locks", "PTO-ISA.source-lock.json")
    : path.join(roots.intrinsicRoot, "PTO-ISA.source-lock.json");
}

function gitValue(repoRoot, args) {
  return execFileSync("git", ["-C", repoRoot, ...args], { encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] }).trim();
}

function refreshPtoLock(roots) {
  if (!ptoSourceAvailable(roots.ptoDocsRoot)) throw new Error(`PTO source is unavailable: ${roots.ptoDocsRoot}`);
  const ptoRepoRoot = path.resolve(roots.ptoDocsRoot, "..", "..");
  if (gitValue(ptoRepoRoot, ["status", "--porcelain"])) throw new Error(`Refusing to lock dirty PTO checkout: ${ptoRepoRoot}`);
  const inventory = ptoInventory(roots.ptoDocsRoot);
  const lock = {
    version: 1,
    repository: gitValue(ptoRepoRoot, ["remote", "get-url", "origin"]),
    commit: gitValue(ptoRepoRoot, ["rev-parse", "HEAD"]),
    source_tree_sha256: inventory.fingerprint,
    operations: inventory.operations,
  };
  writeText(ptoLockPath(roots), `${JSON.stringify(lock, null, 2)}\n`);
  console.log(`pto_lock=${ptoLockPath(roots)}`);
  console.log(`pto_commit=${lock.commit}`);
  console.log(`pto_operations=${lock.operations.length}`);
}

function checkedPtoOperations(roots, errors) {
  const lockFile = ptoLockPath(roots);
  if (!fs.existsSync(lockFile)) {
    errors.push("PTO-ISA.source-lock.json: missing source lock");
    return [];
  }
  const lock = readJson(lockFile);
  if (lock.version !== 1 || !Array.isArray(lock.operations) || typeof lock.source_tree_sha256 !== "string") {
    errors.push("PTO-ISA.source-lock.json: invalid source lock");
    return [];
  }
  if (ptoSourceAvailable(roots.ptoDocsRoot)) {
    const inventory = ptoInventory(roots.ptoDocsRoot);
    if (inventory.fingerprint !== lock.source_tree_sha256) errors.push("PTO-ISA.source-lock.json: live PTO source differs; run refresh-pto-lock from a clean checkout");
    const ptoRepoRoot = path.resolve(roots.ptoDocsRoot, "..", "..");
    try {
      if (gitValue(ptoRepoRoot, ["rev-parse", "HEAD"]) !== lock.commit) errors.push("PTO-ISA.source-lock.json: live PTO commit differs; run refresh-pto-lock");
    } catch {
      errors.push("PTO-ISA.source-lock.json: unable to read live PTO commit");
    }
    return inventory.operations.map((item) => ({ opcode: item.opcode, family: item.family, sourcePath: item.source_path }));
  }
  return lock.operations.map((item) => ({ opcode: item.opcode, family: item.family, sourcePath: item.source_path }));
}

function metadataForExisting(relativePath, body, workbookRow, sourceItem) {
  const kind = documentKind(relativePath);
  const base = path.basename(relativePath, ".md");
  const title = titleFromBody(body, base);
  const opcode = kind === "intrinsic" ? base : null;
  const status = kind === "coverage" ? "review" : kind === "intrinsic" ? "mapped" : "active";
  const visibility = kind === "coverage" ? "internal" : "public";
  const metadata = {
    schema_version: SCHEMA_VERSION,
    id: `${kind}.${slug(relativePath)}`,
    kind,
    title,
    status,
    visibility,
    profile: PROFILE,
    sources: {
      davincioo: relativePath,
      ...(sourceItem ? { pto: sourceItem.sourcePath } : {}),
    },
  };
  if (kind !== "intrinsic") return metadata;
  metadata.opcode = opcode;
  metadata.family = sourceItem?.family || classifyFamily(opcode);
  if (!workbookRow) {
    metadata.xlsx = { include: false };
    return metadata;
  }
  const row = workbookRow.values;
  metadata.bundle = normalizeCell(row[3]);
  const documentedBlockStart = blockStartFromBody(body);
  if (metadata.bundle && documentedBlockStart) {
    metadata.bundle = metadata.bundle.replace(/^BSTART\.[A-Z]+\s+[^,\s]+/, `${documentedBlockStart.header} ${documentedBlockStart.opcode}`);
  }
  metadata.operands = {
    output: normalizeCell(row[4]),
    input0: normalizeCell(row[5]),
    input1: normalizeCell(row[6]),
    input2: normalizeCell(row[7]),
  };
  metadata.dtypes = splitDtypes(row[8]);
  metadata.encoding = parseEncoding(normalizeCell(row[9]));
  metadata.xlsx = {
    include: true,
    category: normalizeCell(row[0]),
    subcategory: normalizeCell(row[1]),
    order: workbookRow.rowNumber,
    description_section: descriptionSectionForBody(body),
    constraints_section: "约束与合法性",
  };
  return metadata;
}

function stubPath(intrinsicRoot, sourceItem) {
  if (sourceItem.family === "communication") return path.join(intrinsicRoot, "status", "comm", `${sourceItem.opcode.replace("comm/", "")}.md`);
  if (sourceItem.family === "system-scheduling") return path.join(intrinsicRoot, "status", "system", `${sourceItem.opcode}.md`);
  return path.join(intrinsicRoot, "status", "unmapped", `${sourceItem.opcode}.md`);
}

function stubDocument(relativePath, sourceItem, workbookRow) {
  const isPlanned = Boolean(workbookRow);
  const displayOpcode = sourceItem.opcode;
  const metadata = {
    schema_version: SCHEMA_VERSION,
    id: `intrinsic.${slug(displayOpcode)}`,
    kind: "intrinsic",
    title: `${displayOpcode} Intrinsic Status`,
    status: isPlanned ? "planned" : "unmapped",
    visibility: "internal",
    profile: PROFILE,
    opcode: displayOpcode,
    family: sourceItem.family,
    sources: {
      davincioo: relativePath,
      pto: sourceItem.sourcePath,
    },
    xlsx: { include: isPlanned },
  };
  if (workbookRow) {
    const row = workbookRow.values;
    metadata.bundle = normalizeCell(row[3]);
    metadata.operands = { output: normalizeCell(row[4]), input0: normalizeCell(row[5]), input1: normalizeCell(row[6]), input2: normalizeCell(row[7]) };
    metadata.dtypes = splitDtypes(row[8]);
    metadata.encoding = parseEncoding(normalizeCell(row[9]));
    metadata.xlsx = {
      include: true,
      category: normalizeCell(row[0]),
      subcategory: normalizeCell(row[1]),
      order: workbookRow.rowNumber,
      description_section: "PTO 语义来源",
      constraints_section: "约束与合法性",
    };
  }
  const body = `# ${displayOpcode} Intrinsic Status\n\n> 状态：当前 DavinciOO ${isPlanned ? "规划中" : "尚未映射"}，本页不是 normative encoding 定义。\n\n## PTO 语义来源\n\n- PTO ISA source: \`${sourceItem.sourcePath}\`\n\n## 当前映射状态\n\n${isPlanned ? "该操作保留为 Excel planning row；DavinciOO block/header encoding 尚未正式分配。" : "当前 active DavinciOO v5 superscalar intrinsic 集尚未为该 PTO 操作定义完整 block/header 映射。"}\n\n## 约束与合法性\n\n- 在完成语义、operand、profile 与 encoding 审阅前，不得将本状态页视为可编码指令。\n- 任何正式映射必须按 PTO 语义、active header encoding 和 DavinciOO v5 profile 分别核验。\n`;
  return { metadata, body };
}

function generatedIndex(docs) {
  const intrinsics = docs.filter((doc) => doc.metadata?.kind === "intrinsic");
  const group = (status) => intrinsics.filter((doc) => doc.metadata.status === status).sort((a, b) => a.metadata.opcode.localeCompare(b.metadata.opcode));
  const lines = ["<!-- BEGIN GENERATED: instruction-index -->"];
  for (const [status, heading] of [["mapped", "已映射 Intrinsic"], ["planned", "计划中 / Reserved"], ["unmapped", "尚未映射的 PTOISA"], ["removed", "已移出 Active Profile"]]) {
    lines.push(`## ${heading}`, "");
    const items = group(status);
    if (!items.length) lines.push("- 无。", "");
    else for (const doc of items) lines.push(`- [${doc.metadata.opcode}](${doc.relativePath}) - ${doc.metadata.family}`);
    lines.push("");
  }
  lines.push("<!-- END GENERATED: instruction-index -->");
  return lines.join("\n");
}

function generatedUnmappedSummary(docs) {
  const items = docs
    .filter((doc) => doc.metadata?.kind === "intrinsic" && ["planned", "unmapped", "removed"].includes(doc.metadata.status))
    .sort((a, b) => a.metadata.opcode.localeCompare(b.metadata.opcode));
  const lines = [
    "<!-- BEGIN GENERATED: status-summary -->",
    "## 当前状态摘要",
    "",
    "本表由各指令状态页的 frontmatter 生成；下方历史审阅材料不再作为状态权威源。",
    "",
    "| Opcode | 状态 | 指令族 | 状态页 |",
    "| --- | --- | --- | --- |",
  ];
  for (const doc of items) lines.push(`| \`${doc.metadata.opcode}\` | ${doc.metadata.status} | ${doc.metadata.family} | [${doc.relativePath}](${doc.relativePath}) |`);
  lines.push("", "<!-- END GENERATED: status-summary -->");
  return lines.join("\n");
}

function ensureMaintenanceSection(body) {
  let output = body.replace(
    /- 全量 HTML 文档入口见 \[DavinciOO_PTO_Intrinsic_Complete\.html\]\(DavinciOO_PTO_Intrinsic_Complete\.html\)。?\n?/,
    "- Complete HTML 入口见 `docs/DavinciOO_PTO_Intrinsic_Complete.html`；当前 encoding workbook 位于 `spec/encoding/PTO-ISA-Encoding.xlsx`。\n",
  );
  if (/^## (?:Maintenance Workflow|维护流程)$/m.test(output)) return output;
  const section = `## 维护流程\n\n- Markdown frontmatter 与固定正文段落是结构化事实和语义的权威源。\n- 运行 \`node scripts/intrinsic-docs/intrinsic_docs.mjs check\` 检查 schema、coverage、链接和派生索引。\n- 使用 \`sync_intrinsic_xlsx.mjs\` 增量同步 Excel；sidecar 会保护人工修改。\n- 使用 \`build_intrinsic_html.mjs\` 生成并验证 Complete HTML 候选站点。\n\n`;
  const marker = "<!-- BEGIN GENERATED: instruction-index -->";
  return output.includes(marker) ? output.replace(marker, `${section}${marker}`) : `${output.trimEnd()}\n\n${section}`;
}

function replaceGeneratedSection(body, name, replacement) {
  const pattern = new RegExp(`<!-- BEGIN GENERATED: ${name} -->[\\s\\S]*?<!-- END GENERATED: ${name} -->`);
  if (pattern.test(body)) return body.replace(pattern, replacement);
  const firstHeadingEnd = body.indexOf("\n", body.indexOf("# "));
  return `${body.slice(0, firstHeadingEnd + 1)}\n${replacement}\n${body.slice(firstHeadingEnd + 1).replace(/^\s+/, "")}`;
}

function updateIndexes(intrinsicRoot, { checkOnly = false } = {}) {
  const docs = loadDocuments(intrinsicRoot);
  const readme = docs.find((doc) => doc.relativePath === "README.md");
  const unmapped = docs.find((doc) => doc.relativePath === "UNMAPPED_PTOISA.md");
  const expectedReadme = ensureMaintenanceSection(replaceGeneratedSection(readme.body, "instruction-index", generatedIndex(docs)));
  const expectedUnmapped = replaceGeneratedSection(unmapped.body, "status-summary", generatedUnmappedSummary(docs));
  const changes = [];
  if (readme.body !== expectedReadme) changes.push("README.md");
  if (unmapped.body !== expectedUnmapped) changes.push("UNMAPPED_PTOISA.md");
  if (!checkOnly) {
    if (readme.body !== expectedReadme) writeText(readme.filePath, serializeDocument(readme.metadata, expectedReadme));
    if (unmapped.body !== expectedUnmapped) writeText(unmapped.filePath, serializeDocument(unmapped.metadata, expectedUnmapped));
  }
  return changes;
}

function migrate(roots, options) {
  if (!options.xlsxJson) throw new Error("migrate requires --xlsx-json with the inspected Sheet1 matrix");
  const matrix = readJson(path.resolve(options.xlsxJson));
  const workbookRows = propagatedWorkbookRows(matrix);
  const rowByOpcode = new Map(workbookRows.map((row) => [String(row.values[2]), row]));
  const sourceMap = ptoSourceMap(roots.ptoDocsRoot);
  let migrated = 0;
  for (const filePath of managedMarkdownFiles(roots.intrinsicRoot)) {
    const relativePath = toPosix(path.relative(roots.intrinsicRoot, filePath));
    const parsed = parseFrontmatter(fs.readFileSync(filePath, "utf8"), relativePath);
    if (parsed.metadata) continue;
    const kind = documentKind(relativePath);
    const opcode = kind === "intrinsic" ? path.basename(relativePath, ".md") : null;
    const metadata = metadataForExisting(relativePath, parsed.body, opcode ? rowByOpcode.get(opcode) : null, opcode ? sourceMap.get(opcode) : null);
    writeText(filePath, serializeDocument(metadata, parsed.body));
    migrated += 1;
  }
  const currentDocs = loadDocuments(roots.intrinsicRoot);
  const existingOpcodes = new Set(currentDocs.filter((doc) => doc.metadata.kind === "intrinsic").map((doc) => doc.metadata.opcode));
  let stubs = 0;
  for (const sourceItem of discoverPtoOperations(roots.ptoDocsRoot)) {
    if (existingOpcodes.has(sourceItem.opcode)) continue;
    const filePath = stubPath(roots.intrinsicRoot, sourceItem);
    const relativePath = toPosix(path.relative(roots.intrinsicRoot, filePath));
    const stub = stubDocument(relativePath, sourceItem, rowByOpcode.get(sourceItem.opcode));
    writeText(filePath, serializeDocument(stub.metadata, stub.body));
    stubs += 1;
  }
  const indexChanges = updateIndexes(roots.intrinsicRoot);
  console.log(`migrated=${migrated}`);
  console.log(`status_stubs=${stubs}`);
  console.log(`generated_indexes=${indexChanges.join(",") || "unchanged"}`);
}

export function markdownLinks(body) {
  const links = [];
  const pattern = /\[((?:\\.|[^\]])+)\]\(([^)]+)\)/g;
  for (const match of body.matchAll(pattern)) links.push({ label: match[1], href: match[2] });
  return links;
}

export function headingIds(body) {
  const seen = new Map();
  const ids = new Set();
  for (const line of body.replace(/\r\n/g, "\n").split("\n")) {
    const match = line.trim().match(/^#{1,6}\s+(.+)$/);
    if (!match) continue;
    const base = headingSlug(match[1]);
    const count = (seen.get(base) || 0) + 1;
    seen.set(base, count);
    ids.add(count === 1 ? base : `${base}-${count}`);
  }
  return ids;
}

function splitHref(href) {
  const index = href.indexOf("#");
  return index < 0 ? [href, ""] : [href.slice(0, index), decodeURIComponent(href.slice(index + 1))];
}

function legacySupportTarget(roots, href, sourceRelativePath = "") {
  const [filePart] = splitHref(href);
  const relative = toPosix(path.normalize(path.join(path.dirname(sourceRelativePath), filePart)));
  const scalarMatch = sourceRelativePath.match(/^scalar\/(misa_s)\/(.+)$/);
  const scalarRelative = scalarMatch
    ? toPosix(path.normalize(path.join("inst", scalarMatch[1], path.dirname(scalarMatch[2]), filePart)))
    : null;
  const stripped = filePart.replace(/^(?:\.\.\/|\.\/)+/, "");
  const normalized = scalarRelative && !scalarRelative.startsWith("../")
    ? scalarRelative
    : /^(?:arch|register|blockIntro|instset|inst|header\/templateblock)\//.test(relative) ? relative : stripped;
  return /^(?:arch|register|blockIntro|instset|inst|header\/templateblock)\//.test(normalized) ? path.join(linxSnapshotRoot(roots), normalized) : null;
}

function checkLinks(doc, docsByRel, roots) {
  const errors = [];
  for (const link of markdownLinks(doc.body)) {
    const [filePart, fragment] = splitHref(link.href);
    if (/^(https?:|mailto:)/i.test(filePart)) continue;
    let target = filePart ? path.resolve(path.dirname(doc.filePath), filePart) : doc.filePath;
    if (!fs.existsSync(target)) target = legacySupportTarget(roots, link.href, doc.relativePath) || target;
    if (!fs.existsSync(target)) {
      errors.push(`${doc.relativePath}: broken link ${link.href}`);
      continue;
    }
    if (fragment && target.endsWith(".md")) {
      const targetBody = parseFrontmatter(fs.readFileSync(target, "utf8"), target).body;
      if (!headingIds(targetBody).has(headingSlug(fragment))) errors.push(`${doc.relativePath}: broken fragment ${link.href}`);
    }
    if (publicDocument(doc) && target.startsWith(roots.intrinsicRoot) && target.endsWith(".md")) {
      const rel = toPosix(path.relative(roots.intrinsicRoot, target));
      const targetDoc = docsByRel.get(rel);
      if (targetDoc && !publicDocument(targetDoc)) {
        // The public renderer de-links this reference; keep it visible to authors as a warning only.
      }
    }
  }
  return errors;
}

function legacyBaselinePath(roots) {
  return roots.repoRoot
    ? path.join(roots.repoRoot, "spec", "evidence", "source-locks", "legacy-missing-links.json")
    : path.join(roots.intrinsicRoot, "legacy-missing-links.json");
}

export function legacyBrokenLinks(roots) {
  const legacyFiles = [
    ...walk(path.join(roots.intrinsicRoot, "scalar"), (file) => file.endsWith(".md")),
    ...walk(path.join(roots.intrinsicRoot, "header", "unused"), (file) => file.endsWith(".md")),
  ];
  const missing = [];
  for (const filePath of legacyFiles.sort()) {
    const relativePath = toPosix(path.relative(roots.intrinsicRoot, filePath));
    const body = parseFrontmatter(fs.readFileSync(filePath, "utf8"), relativePath).body;
    for (const link of markdownLinks(body)) {
      const [filePart, fragment] = splitHref(link.href);
      if (/^(https?:|mailto:)/i.test(filePart)) continue;
      let target = filePart ? path.resolve(path.dirname(filePath), filePart) : filePath;
      if (!fs.existsSync(target)) target = legacySupportTarget(roots, link.href, relativePath) || target;
      let reason = "";
      if (!fs.existsSync(target)) reason = "missing-file";
      else if (fragment && target.endsWith(".md")) {
        const targetBody = parseFrontmatter(fs.readFileSync(target, "utf8"), target).body;
        if (!headingIds(targetBody).has(headingSlug(fragment))) reason = "missing-fragment";
      }
      if (reason) missing.push({ source: relativePath, href: link.href, reason });
    }
  }
  return missing.sort((a, b) => `${a.source}\0${a.href}`.localeCompare(`${b.source}\0${b.href}`));
}

export function checkLegacyBaseline(roots) {
  const filePath = legacyBaselinePath(roots);
  if (!fs.existsSync(filePath)) return ["legacy-missing-links.json: missing baseline"];
  const baseline = readJson(filePath);
  const actual = legacyBrokenLinks(roots);
  if (baseline.version !== 1 || !Array.isArray(baseline.missing)) return ["legacy-missing-links.json: invalid baseline"];
  if (baseline.count !== baseline.missing.length) return ["legacy-missing-links.json: stored count does not match entries"];
  if (JSON.stringify(actual) !== JSON.stringify(baseline.missing)) return [`legacy-missing-links.json: baseline drift (expected ${baseline.missing.length}, actual ${actual.length})`];
  return [];
}

function refreshLegacyBaseline(roots) {
  const missing = legacyBrokenLinks(roots);
  writeText(legacyBaselinePath(roots), `${JSON.stringify({ version: 1, count: missing.length, missing }, null, 2)}\n`);
  console.log(`legacy_missing_links=${missing.length}`);
}

function checkDirectoryWhitelist(roots) {
  const errors = [];
  const allowedTools = new Set([
    "tools/intrinsic_docs_lib.mjs",
    "tools/intrinsic_docs.mjs",
    "tools/intrinsic_sync_state.mjs",
    "tools/sync_intrinsic_xlsx.mjs",
    "tools/build_intrinsic_html.mjs",
    "tools/test_public_html.mjs",
    "tools/test_intrinsic_xlsx.mjs",
  ]);
  const allowedArtifacts = new Set([
    "PTO-ISA-Encoding.xlsx",
    "PTO-ISA-Encoding.sync.json",
    "PTO-ISA.source-lock.json",
    "LINX-ISA.source-lock.json",
    "legacy-missing-links.json",
    "intrinsic.schema.json",
  ]);
  for (const filePath of walk(roots.intrinsicRoot, (file) => fs.statSync(file).isFile())) {
    const rel = toPosix(path.relative(roots.intrinsicRoot, filePath));
    if ((rel.startsWith("scalar/") || rel.startsWith("header/unused/")) && rel.endsWith(".md")) continue;
    if (rel.endsWith(".md") || allowedTools.has(rel) || allowedArtifacts.has(rel)) continue;
    errors.push(`${rel}: file is not declared by the intrinsic directory whitelist`);
  }
  return errors;
}

function checkV5DocumentationSurfaces(docs) {
  const errors = [];
  const overviewTitles = new Map([
    ["overview.isa_overview", "ISA Overview"],
    ["overview.programming_model", "Programming Model"],
    ["overview.state_and_types", "State and Data Types"],
    ["overview.memory_and_exceptions", "Memory, Ordering and Exceptions"],
    ["overview.assembly_syntax", "Assembly Syntax"],
    ["overview.encoding", "Encoding Conventions"],
  ]);
  for (const doc of docs) {
    if (overviewTitles.has(doc.metadata?.id)) {
      const expectedTitle = overviewTitles.get(doc.metadata.id);
      if (doc.metadata.title !== expectedTitle) errors.push(`${doc.relativePath}: active overview title must be ${expectedTitle}`);
      let fenced = false;
      const headings = [];
      for (const line of doc.body.split("\n")) {
        if (/^```/.test(line.trim())) { fenced = !fenced; continue; }
        if (!fenced && /^#{1,3}\s+/.test(line)) headings.push(line.replace(/^#{1,3}\s+/, "").trim());
      }
      if (headings[0] !== expectedTitle) errors.push(`${doc.relativePath}: H1 must match metadata title ${expectedTitle}`);
      for (const heading of headings) if (/[\u3400-\u9fff]/u.test(heading)) errors.push(`${doc.relativePath}: public architecture heading must be English: ${heading}`);
    }
    const opcode = String(doc.metadata?.opcode || "");
    if (doc.metadata?.status === "mapped" && /^(?:TMATMUL|TGEMV)/.test(opcode)) {
      if (!doc.body.includes("## 公开 C++ Form 与执行范围")) errors.push(`${doc.relativePath}: matrix page is missing the public Local/Shared form section`);
      if (!doc.body.includes("SharedTile<")) errors.push(`${doc.relativePath}: matrix page does not expose a SharedTile overload`);
      if (!doc.body.includes("| Form | Operand storage | 执行范围 | Collective | Machine lowering |")) errors.push(`${doc.relativePath}: matrix page is missing the Local/Shared execution table`);
    }
  }
  return errors;
}

function check(roots) {
  const docs = loadDocuments(roots.intrinsicRoot);
  const errors = [];
  const ids = new Map();
  const opcodes = new Map();
  const docsByRel = new Map(docs.map((doc) => [doc.relativePath, doc]));
  for (const doc of docs) {
    errors.push(...validateMetadata(doc));
    errors.push(...validateProjectionFormatting(doc));
    const id = doc.metadata?.id;
    if (id && ids.has(id)) errors.push(`${doc.relativePath}: duplicate id ${id} also used by ${ids.get(id)}`);
    else if (id) ids.set(id, doc.relativePath);
    const opcode = doc.metadata?.kind === "intrinsic" ? doc.metadata.opcode : null;
    if (opcode && opcodes.has(opcode)) errors.push(`${doc.relativePath}: duplicate opcode ${opcode} also used by ${opcodes.get(opcode)}`);
    else if (opcode) opcodes.set(opcode, doc.relativePath);
    errors.push(...checkLinks(doc, docsByRel, roots));
  }
  errors.push(...checkLinxLock(roots));
  errors.push(...checkSysInventory(roots));
  errors.push(...checkLegacyBaseline(roots));
  errors.push(...checkV5DocumentationSurfaces(docs));
  const upstream = checkedPtoOperations(roots, errors);
  for (const item of upstream) if (!opcodes.has(item.opcode)) errors.push(`coverage: missing status page for ${item.opcode} (${item.sourcePath})`);
  const indexChanges = updateIndexes(roots.intrinsicRoot, { checkOnly: true });
  for (const rel of indexChanges) errors.push(`${rel}: generated index is stale`);
  errors.push(...checkDirectoryWhitelist(roots));
  const schemaPath = path.join(roots.intrinsicRoot, "intrinsic.schema.json");
  const expectedSchema = `${JSON.stringify(generatedSchema(), null, 2)}\n`;
  if (!fs.existsSync(schemaPath) || fs.readFileSync(schemaPath, "utf8") !== expectedSchema) errors.push("intrinsic.schema.json: generated schema is stale; run generate-schema");
  const sidecarPath = path.join(roots.intrinsicRoot, "PTO-ISA-Encoding.sync.json");
  if (fs.existsSync(sidecarPath)) {
    const state = readJson(sidecarPath);
    if (state.version !== 2) errors.push("PTO-ISA-Encoding.sync.json: unsupported version");
    const workbookPath = path.join(roots.intrinsicRoot, "PTO-ISA-Encoding.xlsx");
    if (fs.existsSync(workbookPath) && state.workbook_sha256 !== sha256(fs.readFileSync(workbookPath))) errors.push("PTO-ISA-Encoding.sync.json: workbook hash is stale; run Excel sync");
    if (state.projection_fingerprint !== excelProjectionFingerprint(docs)) errors.push("PTO-ISA-Encoding.sync.json: Markdown Excel projection is stale; run Excel sync");
    for (const doc of docs.filter((item) => item.metadata.kind === "intrinsic" && item.metadata.xlsx?.include)) {
      if (!state.rows?.[doc.metadata.id]) errors.push(`${doc.relativePath}: missing Excel sync state`);
    }
  } else {
    errors.push("PTO-ISA-Encoding.sync.json: missing sidecar");
  }
  if (errors.length) {
    for (const error of errors) console.error(`ERROR ${error}`);
    console.error(`check_failed=${errors.length}`);
    process.exitCode = 1;
    return false;
  }
  console.log(`check_ok managed_docs=${docs.length} intrinsics=${opcodes.size} upstream_ops=${upstream.length}`);
  return true;
}

function escapeHtml(value) {
  return String(value).replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;");
}

function externalPtoHref(filePart, doc, roots) {
  const fromThisPage = doc.metadata?.sources?.pto;
  const opcode = path.posix.basename(filePart, ".md").toUpperCase();
  const discovered = ptoSourceAvailable(roots.ptoDocsRoot) ? ptoSourceMap(roots.ptoDocsRoot).get(opcode)?.sourcePath : null;
  const sourcePath = fromThisPage || discovered;
  if (!sourcePath) return null;
  const lock = readJson(ptoLockPath(roots));
  return `https://github.com/hw-native-sys/pto-isa/blob/${encodeURIComponent(lock.commit)}/docs/isa/${sourcePath}`;
}

function externalLinxHref(sourcePath, hash, roots) {
  const lock = readJson(linxLockPath(roots));
  const entry = lock.files.find((item) => item.path === sourcePath);
  if (!entry) return null;
  const repository = String(lock.repository).replace(/^git@github\.com:/, "https://github.com/").replace(/\.git$/, "");
  return `${repository}/blob/${encodeURIComponent(lock.commit)}/${entry.original_path || `docs/zh/isa/${entry.path}`}${hash ? `#${headingSlug(hash)}` : ""}`;
}

function renderInline(text, doc, pageByRel, roots) {
  const parts = text.split(/(`[^`]*`|\[(?:\\.|[^\]])+\]\([^)]+\))/g);
  return parts.map((part) => {
    if (part.startsWith("`") && part.endsWith("`")) return `<code>${escapeHtml(part.slice(1, -1))}</code>`;
    const link = part.match(/^\[((?:\\.|[^\]])+)\]\(([^)]+)\)$/);
    if (link) {
      const [, rawLabel, href] = link;
      const label = rawLabel.replace(/\\([\[\]])/g, "$1");
      if (/^https?:/i.test(href)) return `<a href="${escapeHtml(href)}">${renderInline(label, doc, pageByRel, roots)}</a>`;
      const [filePart, hash] = splitHref(href);
      if (/(?:^|\/)pto\/.+\.md$/i.test(filePart)) {
        const ptoHref = externalPtoHref(filePart, doc, roots);
        return ptoHref ? `<a href="${escapeHtml(ptoHref)}">${renderInline(label, doc, pageByRel, roots)}</a>` : `<span>${renderInline(label, doc, pageByRel, roots)}</span>`;
      }
      const legacyOverviewSources = {
        "architecture/isa-overview.md": "ISA_OVERVIEW.md",
        "architecture/programming-model.md": "PROGRAMMING_MODEL.md",
        "architecture/state-and-data-types.md": "STATE_AND_TYPES.md",
        "architecture/encoding-conventions.md": "ENCODING.md",
        "architecture/assembly-syntax.md": "ASSEMBLY_SYNTAX.md",
        "architecture/memory-ordering-and-exceptions.md": "MEMORY_AND_EXCEPTIONS.md",
        "overview/intrinsic-workflow.md": "README.md",
        "status/UNMAPPED_PTOISA.md": "UNMAPPED_PTOISA.md",
        "status/LINX_COVERAGE.md": "LINX_COVERAGE.md",
        "status/SOURCE_GAPS_AND_CONFLICTS.md": "SOURCE_GAPS_AND_CONFLICTS.md",
      };
      const legacySource = legacyOverviewSources[doc.relativePath] || doc.relativePath.replace(/^compatibility\//, "");
      const baseline = fs.existsSync(legacyBaselinePath(roots)) ? readJson(legacyBaselinePath(roots)).missing : [];
      const knownLegacy = baseline.some((item) => item.source === legacySource && item.href === href);
      if (knownLegacy) return `<span title="Legacy source link is not part of the public PTO ISA site">${renderInline(label, doc, pageByRel, roots)}</span>`;
      if (!filePart.endsWith(".md")) return `<a href="${escapeHtml(href)}">${renderInline(label, doc, pageByRel, roots)}</a>`;
      const normalized = toPosix(path.normalize(path.join(path.dirname(doc.relativePath), filePart)));
      const inherited = filePart.replace(/^(?:\.\.\/|\.\/)+/, "");
      const scalarMatch = legacySource.match(/^scalar\/(misa_s)\/(.+)$/);
      const scalarSupportPath = scalarMatch
        ? toPosix(path.normalize(path.join("inst", scalarMatch[1], path.dirname(scalarMatch[2]), filePart)))
        : null;
      const supportPath = scalarSupportPath && !scalarSupportPath.startsWith("../")
        ? scalarSupportPath
        : /^(?:arch|register|blockIntro|instset|inst|header\/templateblock)\//.test(normalized) ? normalized : inherited;
      const supportRel = roots.repoRoot
        ? `compatibility/scalar/support/linx-v0.56/${supportPath}`
        : `scalar/support/linx-v0.56/${supportPath}`;
      const tileCandidate = `instructions/tile/${path.posix.basename(filePart)}`;
      const bundleCandidate = `instructions/bundle/${filePart.replace(/^(?:\.\.\/|\.\/|header\/)+/, "")}`;
      const scalarCandidate = `compatibility/scalar/${filePart.replace(/^(?:\.\.\/|\.\/|scalar\/)+/, "")}`;
      const statusCandidate = `status/${filePart.replace(/^(?:\.\.\/|\.\/|status\/)+/, "")}`;
      const overviewCandidate = `overview/${path.posix.basename(filePart).toLowerCase()}`;
      const targetPage = pageByRel.get(normalized) || pageByRel.get(supportRel) ||
        pageByRel.get(tileCandidate) || pageByRel.get(bundleCandidate) ||
        pageByRel.get(scalarCandidate) || pageByRel.get(statusCandidate) ||
        pageByRel.get(overviewCandidate);
      const renderedLabel = renderInline(label, doc, pageByRel, roots);
      if (targetPage) return `<a href="${targetPage}${hash ? `#${headingSlug(hash)}` : ""}">${renderedLabel}</a>`;
      const linxHref = externalLinxHref(supportPath, hash, roots);
      return linxHref ? `<a href="${escapeHtml(linxHref)}">${renderedLabel}</a>` :
        `<span title="Reference is not part of the public PTO ISA site">${renderedLabel}</span>`;
    }
    return escapeHtml(part).replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>");
  }).join("");
}

export function renderMarkdown(body, doc, pageByRel, roots) {
  const lines = body.replace(/\r\n/g, "\n").split("\n");
  const output = [];
  let index = 0;
  const headingCounts = new Map();
  while (index < lines.length) {
    const line = lines[index];
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("<!--")) { index += 1; continue; }
    if (trimmed.startsWith("```")) {
      const language = trimmed.slice(3).trim();
      const code = [];
      index += 1;
      while (index < lines.length && !lines[index].trim().startsWith("```")) code.push(lines[index++]);
      index += 1;
      output.push(`<pre><code data-lang="${escapeHtml(language)}">${escapeHtml(code.join("\n"))}</code></pre>`);
      continue;
    }
    if (trimmed.startsWith("|") && lines[index + 1]?.trim().startsWith("|") && /[-:| ]+/.test(lines[index + 1].trim())) {
      const rows = [];
      while (index < lines.length && lines[index].trim().startsWith("|")) rows.push(lines[index++].trim());
      const cells = (row) => row.split("|").slice(1, -1).map((cell) => cell.trim());
      const header = cells(rows[0]);
      const bodyRows = rows.slice(2).map(cells);
      output.push(`<div class="table-wrap"><table><thead><tr>${header.map((cell) => `<th>${renderInline(cell, doc, pageByRel, roots)}</th>`).join("")}</tr></thead><tbody>${bodyRows.map((row) => `<tr>${row.map((cell) => `<td>${renderInline(cell, doc, pageByRel, roots)}</td>`).join("")}</tr>`).join("")}</tbody></table></div>`);
      continue;
    }
    const heading = trimmed.match(/^(#{1,6})\s+(.+)$/);
    if (heading) {
      const level = Math.min(6, heading[1].length + 1);
      const base = headingSlug(heading[2]);
      const count = (headingCounts.get(base) || 0) + 1;
      headingCounts.set(base, count);
      const id = count === 1 ? base : `${base}-${count}`;
      output.push(`<h${level} id="${escapeHtml(id)}">${renderInline(heading[2], doc, pageByRel, roots)}</h${level}>`);
      index += 1;
      continue;
    }
    if (trimmed.startsWith(">")) {
      output.push(`<blockquote>${renderInline(trimmed.replace(/^>\s?/, ""), doc, pageByRel, roots)}</blockquote>`);
      index += 1;
      continue;
    }
    if (/^[-*]\s+/.test(trimmed)) {
      const items = [];
      while (index < lines.length && /^[-*]\s+/.test(lines[index].trim())) items.push(lines[index++].trim().replace(/^[-*]\s+/, ""));
      output.push(`<ul>${items.map((item) => `<li>${renderInline(item, doc, pageByRel, roots)}</li>`).join("")}</ul>`);
      continue;
    }
    if (/^\d+\.\s+/.test(trimmed)) {
      const items = [];
      while (index < lines.length && /^\d+\.\s+/.test(lines[index].trim())) items.push(lines[index++].trim().replace(/^\d+\.\s+/, ""));
      output.push(`<ol>${items.map((item) => `<li>${renderInline(item, doc, pageByRel, roots)}</li>`).join("")}</ol>`);
      continue;
    }
    const paragraph = [trimmed];
    index += 1;
    while (index < lines.length && lines[index].trim() && !/^(#{1,6}\s+|```|\||>|[-*]\s+|\d+\.\s+)/.test(lines[index].trim())) paragraph.push(lines[index++].trim());
    output.push(`<p>${renderInline(paragraph.join(" "), doc, pageByRel, roots)}</p>`);
  }
  return output.join("\n");
}

function stripNonPublicReferenceLines(body, doc, publicRels, allMarkdownRels) {
  return body.split("\n").filter((line) => {
    for (const match of line.matchAll(/\[[^\]]+\]\(([^)#]+\.md)(?:#[^)]+)?\)/g)) {
      const target = toPosix(path.normalize(path.join(path.dirname(doc.relativePath), match[1])));
      if (allMarkdownRels.has(target) && !publicRels.has(target)) return false;
    }
    return true;
  }).join("\n");
}

function siteCss() {
  return `:root{--bg:#f7f4ef;--panel:#fffdf9;--ink:#24211c;--muted:#6d665d;--line:#ddd6cb;--teal:#0f766e;--amber:#a15c07;--code:#171717}*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font:15px/1.62 ui-sans-serif,-apple-system,BlinkMacSystemFont,"Segoe UI","PingFang SC","Microsoft YaHei",sans-serif}a{color:var(--teal);text-decoration:none}a:hover{text-decoration:underline}.layout{display:grid;grid-template-columns:320px minmax(0,1fr);min-height:100vh}aside{position:sticky;top:0;height:100vh;padding:22px;border-right:1px solid var(--line);background:#fbfaf7;overflow:auto}aside h1{margin:0 0 8px;font-size:21px}aside p{margin:0 0 16px;color:var(--muted);font-size:13px}#search{width:100%;border:1px solid var(--line);background:#fff;border-radius:8px;padding:9px 11px;margin-bottom:16px}nav{display:grid;gap:5px}nav a{display:block;padding:6px 9px;border-radius:7px;color:var(--ink)}nav a.active,nav a:hover{background:#fff;color:var(--teal);text-decoration:none}main{padding:32px clamp(24px,4vw,56px) 80px;max-width:1380px}.chapter{background:var(--panel);border:1px solid var(--line);border-radius:9px;padding:clamp(18px,3vw,32px)}.eyebrow{color:var(--amber);text-transform:uppercase;letter-spacing:.08em;font-size:12px;font-weight:700}.markdown-body h2{margin-top:28px}.markdown-body h3{margin-top:24px}.table-wrap{overflow:auto;border:1px solid var(--line);border-radius:8px;margin:14px 0}table{width:100%;border-collapse:collapse;min-width:640px}th,td{border-bottom:1px solid var(--line);padding:9px 10px;text-align:left;vertical-align:top}th{background:#f4efe7}blockquote{border-left:4px solid var(--teal);margin:14px 0;padding:10px 14px;background:#eef8f6}code{font-family:ui-monospace,SFMono-Regular,Menlo,monospace;background:#f0ece5;border-radius:4px;padding:1px 5px}pre{background:var(--code);color:#f5f5f5;border-radius:8px;padding:16px;overflow:auto}pre code{background:transparent;padding:0}.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:10px}.card{border:1px solid var(--line);border-radius:8px;padding:14px;background:#fff}.card a{display:block;margin-top:6px}.is-hidden{display:none!important}@media(max-width:900px){.layout{grid-template-columns:1fr}aside{position:relative;height:auto;max-height:45vh;border-bottom:1px solid var(--line)}main{padding:20px}}`;
}

function siteJs(nav) {
  return `const NAV=${JSON.stringify(nav)};const nav=document.getElementById("nav");const current=document.body.dataset.page;for(const item of NAV){const a=document.createElement("a");a.href=item.page;a.textContent=item.label;a.dataset.search=item.search;if(item.page===current)a.classList.add("active");nav.appendChild(a)}const search=document.getElementById("search");search.addEventListener("input",()=>{const q=search.value.trim().toLowerCase();for(const a of nav.querySelectorAll("a"))a.classList.toggle("is-hidden",q&&!a.dataset.search.includes(q))});`;
}

function pageShell(doc, page, bodyHtml) {
  return `<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${escapeHtml(doc.title)} - DavinciOO PTO Intrinsic</title><link rel="stylesheet" href="assets/site.css"></head><body data-page="${page}"><div class="layout"><aside><h1>DavinciOO PTO Intrinsic</h1><p>当前 DavinciOO PE-local 公开规范与指令参考。</p><input id="search" type="search" placeholder="筛选导航"><nav id="nav"></nav></aside><main><article class="chapter"><p class="eyebrow">${escapeHtml(doc.metadata.kind)} · ${escapeHtml(doc.relativePath)}</p><div class="markdown-body">${bodyHtml}</div></article></main></div><script src="assets/site.js"></script></body></html>`;
}

function validateBuiltSite(roots, siteDir, landingPath, options = {}) {
  const errors = [];
  const htmlFiles = options.htmlFiles || [landingPath, ...walk(siteDir, (file) => file.endsWith(".html"))];
  for (const filePath of htmlFiles) {
    const html = fs.readFileSync(filePath, "utf8");
    const rel = toPosix(path.relative(roots.outputRoot, filePath));
    if (hasLocalAbsolutePath(html)) errors.push(`${rel}: contains a local absolute path`);
    if (!options.allowUnrenderedMarkdownLinks && /\[[^\]]+\]\([^)]+\.md(?:#[^)]+)?\)/.test(html)) errors.push(`${rel}: contains an unrendered Markdown link`);
    for (const match of html.matchAll(/(?:href|src)="([^"]+)"/g)) {
      const [ref, fragment] = splitHref(match[1]);
      if (!ref || /^(?:https?:|mailto:|data:)/i.test(ref)) continue;
      const target = path.resolve(path.dirname(filePath), ref);
      const repositoryTarget = ref === "../../spec/encoding/PTO-ISA-Encoding.xlsx" ? path.join(roots.repoRoot, "spec", "encoding", "PTO-ISA-Encoding.xlsx") : null;
      if (!fs.existsSync(target) && !(repositoryTarget && fs.existsSync(repositoryTarget))) errors.push(`${rel}: broken generated link ${match[1]}`);
      else if (fragment && target.endsWith(".html")) {
        const targetHtml = fs.readFileSync(target, "utf8");
        if (!new RegExp(`\\bid=["']${fragment.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}["']`).test(targetHtml)) errors.push(`${rel}: broken generated fragment ${match[1]}`);
      }
    }
    const headings = [...html.matchAll(/<h[1-6][^>]*>(.*?)<\/h[1-6]>/g)].map((match) => match[1].replace(/<[^>]+>/g, "").trim());
    for (let index = 1; index < headings.length; index += 1) if (headings[index] === headings[index - 1]) errors.push(`${rel}: adjacent duplicate heading ${headings[index]}`);
  }
  if (errors.length) throw new Error(`Generated HTML validation failed:\n${errors.join("\n")}`);
}

function buildPublicHtml(roots) {
  const allDocs = loadDocuments(roots.intrinsicRoot);
  const docs = allDocs.filter(publicDocument);
  const publicRels = new Set(docs.map((doc) => doc.relativePath));
  const allMarkdownRels = new Set(walk(roots.intrinsicRoot, (file) => file.endsWith(".md")).map((file) => toPosix(path.relative(roots.intrinsicRoot, file))));
  const siteName = "DavinciOO_PTO_Intrinsic_Complete";
  const siteDir = path.join(roots.outputRoot, siteName);
  const landingPath = path.join(roots.outputRoot, `${siteName}.html`);
  const pageByRel = new Map(docs.map((doc) => [doc.relativePath, `doc-${slug(doc.relativePath)}.html`]));
  const nav = docs
    .sort((a, b) => (a.metadata.xlsx?.order ?? 10000) - (b.metadata.xlsx?.order ?? 10000) || a.title.localeCompare(b.title))
    .map((doc) => ({ page: pageByRel.get(doc.relativePath), label: doc.metadata.opcode || doc.title, search: `${doc.metadata.opcode || ""} ${doc.title} ${doc.metadata.family || ""}`.toLowerCase() }));
  fs.rmSync(roots.outputRoot, { recursive: true, force: true });
  fs.mkdirSync(path.join(siteDir, "assets"), { recursive: true });
  writeText(path.join(siteDir, "assets", "site.css"), siteCss());
  writeText(path.join(siteDir, "assets", "site.js"), siteJs(nav));
  for (const doc of docs) {
    const page = pageByRel.get(doc.relativePath);
    const publicBody = stripNonPublicReferenceLines(doc.body, doc, publicRels, allMarkdownRels);
    writeText(path.join(siteDir, page), pageShell(doc, page, renderMarkdown(publicBody, doc, pageByRel, roots)));
  }
  const cards = docs.map((doc) => `<div class="card"><strong>${escapeHtml(doc.metadata.opcode || doc.title)}</strong><span>${escapeHtml(doc.metadata.family || doc.metadata.kind)}</span><a href="${pageByRel.get(doc.relativePath)}">打开页面</a></div>`).join("");
  const indexDoc = { title: "DavinciOO PTO Intrinsic Manual", relativePath: "index", metadata: { kind: "overview" } };
  writeText(path.join(siteDir, "index.html"), pageShell(indexDoc, "index.html", `<h2>DavinciOO PTO Intrinsic Manual</h2><p>公开规范、active header 与 mapped intrinsic，共 ${docs.length} 页。</p><div class="cards">${cards}</div>`));
  writeText(landingPath, `<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><meta http-equiv="refresh" content="0; url=${siteName}/index.html"><title>DavinciOO PTO Intrinsic Manual</title></head><body><p>Open <a href="${siteName}/index.html">DavinciOO PTO Intrinsic Manual</a>.</p></body></html>`);
  const expected = new Set(["index.html", ...docs.map((doc) => pageByRel.get(doc.relativePath))]);
  for (const filePath of walk(siteDir, (file) => file.endsWith(".html"))) {
    if (!expected.has(path.basename(filePath))) fs.rmSync(filePath);
  }
  validateBuiltSite(roots, siteDir, landingPath);
  console.log(`html_output=${roots.outputRoot}`);
  console.log(`public_pages=${docs.length}`);
  console.log(`rendered_pages=${docs.length}`);
  return { docs, siteDir, landingPath };
}

const COMPLETE_OVERVIEW = [
  ["index.html", "home", "Home"],
  ["tile-intrinsics.html", "tile", "Tile Intrinsics"],
  ["scalar-system-isa.html", "scalar", "Scalar & System ISA"],
];

const TILE_FAMILY_ORDER = [
  "Tile-Tile Elementwise",
  "Unary Tile Elementwise",
  "Tile Scalar Elementwise",
  "Tile Operation Reduce",
  "1D Vector+2D Tile",
  "MATRIX Operation",
  "Tile Memory Operation",
  "Complex Layout Transformation",
];

function completeFamilyForTile(metadata) {
  const category = String(metadata.xlsx?.category || "").split("\n")[0].trim();
  if (!TILE_FAMILY_ORDER.includes(category)) throw new Error(`${metadata.opcode}: unknown xlsx.category ${category || "<missing>"}`);
  return category;
}

const HEADER_FAMILY_LABELS = new Set([
  "Overview",
  "Lifecycle & Control",
  "Execution Classes",
  "Operand Bindings",
  "Dimensions & Attributes",
  "Encoding Forms",
]);

function completeFamilyForHeader(relativePath, metadata = null) {
  const family = metadata?.family;
  if (!HEADER_FAMILY_LABELS.has(family)) throw new Error(`${relativePath}: active Block page requires a known frontmatter family; got ${family || "<missing>"}`);
  return family;
}

function completeLegacyDocs(roots) {
  const files = [
    ...walk(path.join(roots.repoRoot, "docs", "compatibility", "scalar"), (file) => file.endsWith(".md")),
  ];
  const familyLabels = new Map([
    ["misa_c", "MISA-C"], ["misa_f", "MISA-F"], ["misa_g", "MISA-G"],
    ["misa_h", "MISA-H"], ["misa_l", "MISA-L"], ["misa_s", "MISA-S"],
    ["register", "Registers"], ["support", "Supporting Reference"],
  ]);
  return files.sort().map((filePath) => {
    const relativePath = toPosix(path.relative(path.join(roots.repoRoot, "docs"), filePath));
    const parsed = parseFrontmatter(fs.readFileSync(filePath, "utf8"), relativePath);
    return {
      filePath,
      relativePath,
      body: parsed.body,
      title: titleFromBody(parsed.body, path.basename(relativePath, ".md")),
      metadata: { kind: "scalar", status: "legacy" },
      section: "scalar",
      family: familyLabels.get(relativePath.split("/")[2]) || "Supporting Reference",
      label: path.posix.basename(relativePath, ".md"),
    };
  });
}

function sanitizeCompleteMarkdown(body) {
  return body
    .replaceAll("/Users/chenkewei/Desktop/DavinciOO-main/", "DavinciOO-main/")
    .replaceAll("/Users/chenkewei/Desktop/linx-isa/", "linx-isa/")
    .replaceAll("/Users/chenkewei/Desktop/pto-isa/", "pto-isa/");
}

function completeDocs(roots) {
  const docsRoot = path.join(roots.repoRoot, "docs");
  const managedRoots = [
    [path.join(docsRoot, "instructions", "tile"), "instructions/tile", "intrinsic"],
    [path.join(docsRoot, "instructions", "bundle"), "instructions/bundle", "header"],
    [path.join(docsRoot, "status", "public"), "status/public", "coverage"],
  ];
  const selected = managedRoots.flatMap(([directory, prefix, defaultKind]) =>
    walk(directory, (file) => file.endsWith(".md")).map((filePath) => {
      const relative = toPosix(path.relative(directory, filePath));
      const parsed = parseFrontmatter(fs.readFileSync(filePath, "utf8"), relative);
      return {
        filePath,
        relativePath: `${prefix}/${relative}`,
        body: parsed.body,
        title: parsed.metadata?.title || titleFromBody(parsed.body, path.basename(relative, ".md")),
        metadata: parsed.metadata || { kind: defaultKind, status: defaultKind === "header" ? "unused" : "mapped" },
      };
    }),
  ).filter((doc) => {
    if (doc.relativePath.startsWith("status/public/")) return doc.metadata.visibility === "public" && doc.metadata.status === "active";
    if (doc.metadata.kind === "header") return doc.metadata.visibility === "public" && doc.metadata.status === "active";
    return doc.metadata.kind === "intrinsic" && doc.metadata.visibility === "public" && doc.metadata.status === "mapped";
  });
  const overviewFiles = [
    "isa-overview.md",
    "programming-model.md",
    "state-and-data-types.md",
    "encoding-conventions.md",
    "assembly-syntax.md",
    "memory-ordering-and-exceptions.md",
  ];
  for (const name of overviewFiles) {
    const filePath = path.join(docsRoot, "davincioo-arch", name);
    const parsed = parseFrontmatter(fs.readFileSync(filePath, "utf8"), name);
    selected.push({
      filePath,
      relativePath: `architecture/${name}`,
      body: parsed.body,
      title: titleFromBody(parsed.body, name.replace(/\.md$/, "")),
      metadata: { ...(parsed.metadata || {}), kind: "overview" },
    });
  }
  const managed = selected.map((doc) => {
    let section;
    let family;
    let label = doc.metadata.opcode || doc.title;
    if (doc.relativePath.startsWith("status/public/")) {
      section = "status";
      family = "Support Status";
    } else if (doc.metadata.kind === "overview") {
      section = "architecture";
      family = "Architecture Reference";
    } else if (doc.metadata.kind === "header") {
      section = "block";
      family = completeFamilyForHeader(doc.relativePath, doc.metadata);
    } else {
      section = "tile";
      family = completeFamilyForTile(doc.metadata);
    }
    return { ...doc, body: sanitizeCompleteMarkdown(doc.body), section, family, label };
  });
  return [...managed, ...completeLegacyDocs(roots)].map((doc) => ({ ...doc, page: `doc-${slug(doc.relativePath)}.html` }));
}

const COMPLETE_FAMILY_ORDER = [
  "Architecture Reference",
  ...TILE_FAMILY_ORDER,
  "Overview", "Lifecycle & Control", "Execution Classes", "Operand Bindings", "Dimensions & Attributes", "Encoding Forms",
  "MISA-C", "MISA-F", "MISA-G", "MISA-H", "MISA-L", "MISA-S", "Registers", "Supporting Reference",
  "Support Status",
];

function completeGroups(docs) {
  const groups = new Map();
  for (const doc of docs) {
    if (!groups.has(doc.family)) groups.set(doc.family, []);
    groups.get(doc.family).push(doc);
  }
  return [...groups.entries()].map(([family, entries]) => [family, entries.sort((a, b) => (a.metadata.xlsx?.order ?? 10000) - (b.metadata.xlsx?.order ?? 10000) || a.label.localeCompare(b.label))]).sort((a, b) => COMPLETE_FAMILY_ORDER.indexOf(a[0]) - COMPLETE_FAMILY_ORDER.indexOf(b[0]));
}

function completeCss() {
  return `:root{--bg:#f7f4ef;--panel:#fffdf9;--ink:#24211c;--muted:#6d665d;--line:#ddd6cb;--teal:#0f766e;--amber:#a15c07;--code:#171717}*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font:15px/1.62 ui-sans-serif,-apple-system,BlinkMacSystemFont,"Segoe UI","PingFang SC","Microsoft YaHei",sans-serif}a{color:var(--teal);text-decoration:none}a:hover{text-decoration:underline}.layout{display:grid;grid-template-columns:320px minmax(0,1fr);min-height:100vh;min-width:0}aside{position:sticky;top:0;height:100vh;padding:22px;border-right:1px solid var(--line);background:#fbfaf7;overflow:auto;min-width:0}aside h1{margin:0 0 8px;font-size:21px}aside p{margin:0 0 16px;color:var(--muted);font-size:13px}#search{width:100%;border:1px solid var(--line);background:#fff;border-radius:8px;padding:9px 11px;margin-bottom:16px}nav,.nav-tree,.nav-subtree{display:block}.nav-tree,.nav-subtree{border-left:1px solid var(--line);padding-left:10px;margin:2px 0 4px}.nav-tree summary,.nav-subtree summary{cursor:pointer;color:var(--ink);font-weight:700;padding:5px 0}.nav-subtree summary{font-size:13px;color:var(--muted)}nav a{display:block;width:100%;padding:6px 9px;border-radius:7px;color:var(--ink);overflow-wrap:anywhere}.nav-tree>a,.nav-subtree>a{margin:2px 0}nav a.active,nav a:hover{background:#fff;color:var(--teal);text-decoration:none}main{padding:32px clamp(24px,4vw,56px) 80px;max-width:1380px;min-width:0}.chapter,.doc-card{background:var(--panel);border:1px solid var(--line);border-radius:9px;padding:clamp(18px,3vw,32px);min-width:0}.doc-card{margin:0;padding:0;overflow:hidden}.doc-head{display:flex;justify-content:space-between;gap:16px;padding:18px;border-bottom:1px solid var(--line)}.doc-head h2{margin:3px 0 0}.markdown-body{padding:0 18px 24px;min-width:0}.eyebrow{color:var(--amber);text-transform:uppercase;letter-spacing:.08em;font-size:12px;font-weight:700}.hero{padding:38px;border-radius:8px;color:white;background:linear-gradient(120deg,#24211c,#0f766e)}.hero h2{font-size:clamp(32px,5vw,64px);line-height:1;margin:0 0 12px}.hero p{margin:0;max-width:850px}.stats,.family-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));gap:10px;margin:18px 0}.stat,.family-card{border:1px solid var(--line);border-radius:8px;background:#fff;padding:14px}.stat strong{display:block;font-size:28px}.family-card{display:grid;gap:7px}.family-card span{color:var(--muted);font-size:12px}.family-card em{color:var(--muted);font-style:normal}blockquote{border-left:4px solid var(--teal);margin:14px 0;padding:10px 14px;background:#eef8f6}code{font-family:ui-monospace,SFMono-Regular,Menlo,monospace;background:#f0ece5;border-radius:4px;padding:1px 5px}pre{background:var(--code);color:#f5f5f5;border-radius:8px;padding:16px;overflow:auto}pre code{background:transparent;padding:0}.table-wrap{overflow:auto;max-width:100%;border:1px solid var(--line);border-radius:8px;margin:14px 0}table{width:100%;border-collapse:collapse;min-width:640px}th,td{border-bottom:1px solid var(--line);padding:9px 10px;text-align:left;vertical-align:top}th{background:#f4efe7}.is-hidden{display:none!important}@media(max-width:900px){.layout{grid-template-columns:minmax(0,1fr)}aside{position:relative;height:auto;max-height:45vh;border-bottom:1px solid var(--line)}main{padding:20px}}`;
}

export function validateEnglishNavigationLabels(labels) {
  const invalid = [...new Set(labels.filter((label) => /[\u3400-\u9fff]/u.test(String(label))))];
  if (invalid.length) throw new Error(`Complete visible navigation labels must be English: ${invalid.join(", ")}`);
}

function completeVisibleNavigationLabels(bySection) {
  const labels = ["Home", "Architecture Reference", "Tile Intrinsics", "Block Intrinsics", "Scalar & System ISA", "Support Status", "Overview"];
  for (const docs of bySection.values()) {
    for (const doc of docs) labels.push(doc.label, doc.family);
  }
  return labels;
}

function completeNavHtml(currentPage, bySection) {
  const directGroup = (title, entry, docs) => `<details class="nav-tree" ${currentPage === entry || docs.some((doc) => doc.page === currentPage) ? "open" : ""}><summary><a class="${currentPage === entry ? "active" : ""}" data-search="${title.toLowerCase()}" href="${entry}">${title}</a></summary>${docs.filter((doc) => doc.page !== entry).map((doc) => `<a class="${doc.page === currentPage ? "active" : ""}" data-search="${`${doc.label} ${doc.title}`.toLowerCase()}" href="${doc.page}">${escapeHtml(doc.label)}</a>`).join("")}</details>`;
  const categorizedGroup = (title, overview, docs) => `<details class="nav-tree" ${currentPage === overview || docs.some((doc) => doc.page === currentPage) ? "open" : ""}><summary>${title}</summary><a class="${currentPage === overview ? "active" : ""}" data-search="${title.toLowerCase()}" href="${overview}">Overview</a>${completeGroups(docs).map(([family, entries]) => `<details class="nav-subtree" ${entries.some((doc) => doc.page === currentPage) ? "open" : ""}><summary>${family} <span>${entries.length}</span></summary>${entries.map((doc) => `<a class="${doc.page === currentPage ? "active" : ""}" data-search="${`${doc.label} ${doc.title} ${family}`.toLowerCase()}" href="${doc.page}">${escapeHtml(doc.label)}</a>`).join("")}</details>`).join("")}</details>`;
  const statusDocs = (bySection.get("status") || []).sort((a, b) => (a.metadata.xlsx?.order ?? 10000) - (b.metadata.xlsx?.order ?? 10000));
  const architectureDocs = bySection.get("architecture") || [];
  const blockDocs = bySection.get("block") || [];
  const architectureEntry = architectureDocs.find((doc) => doc.metadata.id === "overview.isa_overview").page;
  const blockEntry = blockDocs.find((doc) => doc.metadata.id === "header.header-intro").page;
  const statusEntry = statusDocs.find((doc) => doc.metadata.id === "status.version-history").page;
  return `<a class="${currentPage === "index.html" ? "active" : ""}" data-search="home" href="index.html">Home</a>${directGroup("Architecture Reference", architectureEntry, architectureDocs)}${categorizedGroup("Tile Intrinsics", "tile-intrinsics.html", bySection.get("tile") || [])}${directGroup("Block Intrinsics", blockEntry, blockDocs)}${categorizedGroup("Scalar & System ISA", "scalar-system-isa.html", bySection.get("scalar") || [])}${directGroup("Support Status", statusEntry, statusDocs)}`;
}

function completeSiteJs() {
  return `const search=document.getElementById("search");const searchable=[...document.querySelectorAll(".searchable")];const links=[...document.querySelectorAll("nav a")];const trees=[...document.querySelectorAll("nav details")];search.addEventListener("input",()=>{const q=search.value.trim().toLowerCase();for(const node of searchable){const text=(node.dataset.search||node.textContent).toLowerCase();node.classList.toggle("is-hidden",Boolean(q)&&!text.includes(q));}for(const link of links)link.classList.toggle("is-hidden",Boolean(q)&&!(link.dataset.search||link.textContent).includes(q));if(q)for(const tree of trees)tree.open=true;});`;
}

function renderCompleteHtml(roots, { log = true } = {}) {
  const docs = completeDocs(roots);
  const bySection = new Map(["architecture", "tile", "block", "scalar", "status"].map((section) => [section, docs.filter((doc) => doc.section === section)]));
  const requiredCounts = { architecture: 6, tile: 106, block: 26, scalar: 1105, status: 3 };
  for (const [section, expected] of Object.entries(requiredCounts)) {
    const actual = bySection.get(section)?.length || 0;
    if (actual !== expected) throw new Error(`Complete public ${section} count mismatch: expected ${expected}, got ${actual}`);
  }
  validateEnglishNavigationLabels(completeVisibleNavigationLabels(bySection));
  const siteName = "html";
  const siteDir = path.join(roots.outputRoot, siteName);
  const landingPath = path.join(roots.outputRoot, "DavinciOO_PTO_Intrinsic_Complete.html");
  fs.rmSync(roots.outputRoot, { recursive: true, force: true });
  fs.mkdirSync(path.join(siteDir, "assets"), { recursive: true });
  writeText(path.join(siteDir, "assets", "site.css"), completeCss());
  writeText(path.join(siteDir, "assets", "site.js"), completeSiteJs());
  const shell = (page, body) => `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${escapeHtml(page.title)} - DavinciOO PTO Intrinsic</title><link rel="stylesheet" href="assets/site.css"></head><body><div class="layout"><aside><h1>DavinciOO PTO Intrinsic</h1><p>PTO ISA 0.58.0 architecture and instruction reference.</p><input id="search" type="search" placeholder="Search navigation"><nav>${completeNavHtml(page.file, bySection)}</nav></aside><main><section class="chapter searchable" data-search="${escapeHtml(page.title)}">${body}</section></main></div><script src="assets/site.js"></script></body></html>`;
  const cards = (page, section, description) => `<h2>${escapeHtml(page.title)}</h2><p>${escapeHtml(description)}</p><div class="family-grid">${completeGroups(bySection.get(section) || []).map(([family, entries]) => `<div class="family-card searchable" data-search="${escapeHtml(`${family} ${entries.map((doc) => `${doc.label} ${doc.title}`).join(" ")}`)}"><strong>${escapeHtml(family)}</strong><span>${entries.length} pages</span>${entries.slice(0, 12).map((doc) => `<a href="${doc.page}">${escapeHtml(doc.label)}</a>`).join("")}${entries.length > 12 ? `<em>+ ${entries.length - 12} more</em>` : ""}</div>`).join("")}</div>`;
  const counts = Object.fromEntries([...bySection].map(([section, entries]) => [section, entries.length]));
  const architectureEntry = bySection.get("architecture").find((doc) => doc.metadata.id === "overview.isa_overview").page;
  const blockEntry = bySection.get("block").find((doc) => doc.metadata.id === "header.header-intro").page;
  const statusEntry = bySection.get("status").find((doc) => doc.metadata.id === "status.version-history").page;
  for (const [file, section, title] of COMPLETE_OVERVIEW) {
    const page = { file, section, title };
    let body;
    if (section === "home") {
      body = `<div class="hero"><h2>DavinciOO PTO Intrinsic Manual</h2><p>Public PTO ISA 0.58.0 architecture, Tile, Block, Scalar/System, and encoding reference.</p></div><div class="stats"><div class="stat"><strong>${counts.tile}</strong><span>Tile Intrinsics</span></div><div class="stat"><strong>${counts.block}</strong><span>Block pages</span></div><div class="stat"><strong>${counts.scalar}</strong><span>Scalar & System pages</span></div><div class="stat"><strong>0.58.0</strong><span>Documentation version</span></div></div><div class="family-grid"><div class="family-card"><strong>Architecture Reference</strong><span>Start with the architecture and programming model.</span><a href="${architectureEntry}">Open reference</a></div><div class="family-card"><strong>Instruction Reference</strong><span>Browse Tile, Block, Scalar and System ISA.</span><a href="tile-intrinsics.html">Open Tile Intrinsics</a><a href="${blockEntry}">Open Block Intrinsics</a></div><div class="family-card"><strong>Encoding Workbook</strong><span>Open the canonical Tile and Block encoding workbook.</span><a href="../../spec/encoding/PTO-ISA-Encoding.xlsx">Open workbook</a></div><div class="family-card"><strong>Support Status</strong><span>Review version history and supported boundaries.</span><a href="${statusEntry}">Open status</a></div></div>`;
    } else {
      body = cards(page, section, `Browse the published ${title} pages.`);
    }
    writeText(path.join(siteDir, file), shell(page, body));
  }
  const pageByRel = new Map(docs.map((doc) => [doc.relativePath, doc.page]));
  for (const doc of docs) {
    const compatibilityNotice = doc.family === "Supporting Reference" ? `<blockquote><strong>Compatibility reference:</strong> this inherited Linx material is preserved for context and does not independently declare PTO ISA 0.58.0 support.</blockquote>` : "";
    const body = `<article class="doc-card searchable" data-search="${escapeHtml(`${doc.label} ${doc.title} ${doc.family}`)}"><div class="doc-head"><div><p class="eyebrow">${escapeHtml(doc.relativePath)}</p><p>${escapeHtml(doc.title)}</p></div><span>${escapeHtml(doc.family)}</span></div><div class="markdown-body">${compatibilityNotice}${renderMarkdown(doc.body, doc, pageByRel, roots)}</div></article>`;
    writeText(path.join(siteDir, doc.page), shell({ file: doc.page, title: doc.title }, body));
  }
  writeText(landingPath, `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta http-equiv="refresh" content="0; url=${siteName}/index.html"><title>DavinciOO PTO Intrinsic Manual</title></head><body><p>Open <a href="${siteName}/index.html">DavinciOO PTO Intrinsic Manual</a>.</p></body></html>`);
  validateBuiltSite(roots, siteDir, landingPath);
  if (log) {
    console.log(`html_output=${roots.outputRoot}`);
    console.log(`complete_pages=${docs.length}`);
    console.log(`architecture=${counts.architecture} tile=${counts.tile} block=${counts.block} scalar=${counts.scalar} status=${counts.status}`);
  }
  return { docs, siteDir, landingPath };
}

export function replaceDirectoryAtomically(destination, prepared) {
  const backup = `${destination}.backup-${process.pid}-${Date.now()}`;
  let hadDestination = false;
  try {
    if (fs.existsSync(destination)) {
      fs.renameSync(destination, backup);
      hadDestination = true;
    }
    fs.renameSync(prepared, destination);
    if (hadDestination) fs.rmSync(backup, { recursive: true, force: true });
  } catch (error) {
    if (!fs.existsSync(destination) && hadDestination && fs.existsSync(backup)) fs.renameSync(backup, destination);
    throw error;
  }
}

function buildCompleteHtml(roots) {
  const parent = path.dirname(roots.outputRoot);
  fs.mkdirSync(parent, { recursive: true });
  const tempRoot = fs.mkdtempSync(path.join(parent, ".intrinsic-docs-build-"));
  const prepared = path.join(tempRoot, "site");
  try {
    const result = renderCompleteHtml({ ...roots, outputRoot: prepared }, { log: false });
    replaceDirectoryAtomically(roots.outputRoot, prepared);
    console.log(`html_output=${roots.outputRoot}`);
    console.log(`complete_pages=${result.docs.length}`);
    return { ...result, siteDir: result.siteDir.replace(prepared, roots.outputRoot), landingPath: result.landingPath.replace(prepared, roots.outputRoot) };
  } finally {
    fs.rmSync(tempRoot, { recursive: true, force: true });
  }
}

function help() {
  console.log(`Usage: node scripts/intrinsic-docs/intrinsic_docs.mjs <command> [options]\n\nCommands:\n  migrate --xlsx-json FILE [--pto-docs-root DIR]\n  refresh-pto-lock [--pto-docs-root DIR]\n  refresh-linx-legacy --linx-root DIR\n  refresh-legacy-link-baseline\n  generate-schema\n  generate-indexes\n  check\n  build-html\n`);
}

if (path.resolve(process.argv[1] || "") === fileURLToPath(import.meta.url)) {
  const options = parseArgs(process.argv);
  const roots = resolveRoots(options);
  try {
    if (options.command === "migrate") migrate(roots, options);
    else if (options.command === "refresh-pto-lock") refreshPtoLock(roots);
    else if (options.command === "refresh-linx-legacy") refreshLinxLegacy(roots);
    else if (options.command === "refresh-legacy-link-baseline") refreshLegacyBaseline(roots);
    else if (options.command === "generate-schema") writeText(path.join(roots.intrinsicRoot, "intrinsic.schema.json"), `${JSON.stringify(generatedSchema(), null, 2)}\n`);
    else if (options.command === "generate-indexes") console.log(`updated=${updateIndexes(roots.intrinsicRoot).join(",") || "none"}`);
    else if (options.command === "check") check(roots);
    else if (options.command === "build-html") buildCompleteHtml(roots);
    else help();
  } catch (error) {
    console.error(error.stack || error.message);
    process.exitCode = 1;
  }
}
