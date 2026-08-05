import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  FRONTMATTER_RULES,
  PROFILE,
  PROFILES,
  generatedSchema,
  hasLocalAbsolutePath,
  headingSlug,
  parseFrontmatter,
  projectionForDocument,
  publicDocument,
  serializeDocument,
  sha256,
  validateMetadata,
  validateProjectionFormatting,
} from "./intrinsic_docs_lib.mjs";
import { checkLegacyBaseline, checkLinxLock, headingIds, markdownLinks, renderMarkdown, replaceDirectoryAtomically, validateEnglishNavigationLabels } from "./intrinsic_docs.mjs";
import { beginChange, inspectChangeScope, readHandoff, validateTargetSections } from "./intrinsic_change.mjs";
import { auditState, buildStateRow, decideCell, decideRowPresence, migrateState } from "./intrinsic_sync_state.mjs";

function fixture(overrides = {}) {
  const metadata = {
    schema_version: 1,
    id: "intrinsic.tadd",
    kind: "intrinsic",
    title: "TADD Intrinsic",
    status: "mapped",
    visibility: "public",
    profile: PROFILE,
    opcode: "TADD",
    family: "element-wise",
    sources: { davincioo: "TADD.md", pto: "tile/ops/elementwise-tile-tile/tadd.md" },
    bundle: "BSTART.TEPL TADD",
    operands: { output: "dst tile", input0: "src0 tile", input1: "src1 tile", input2: null },
    dtypes: ["F16", "F32"],
    encoding: { block: "TEPL", mode: 0, function: 0, tile_op: "0x00" },
    xlsx: { include: true, category: "Elementwise", subcategory: "Arithmetic", order: 2, description_section: "PTO 语义来源", constraints_section: "约束与合法性" },
    ...overrides,
  };
  const body = "# TADD Intrinsic\n\n## PTO 语义来源\n\n逐元素加法。\n\n## 约束与合法性\n\n- dtype 必须兼容。\n- valid region 必须匹配。\n";
  return { metadata, body, relativePath: "TADD.md", text: serializeDocument(metadata, body) };
}

test("frontmatter round-trips as JSON-compatible YAML", () => {
  const doc = fixture();
  const parsed = parseFrontmatter(doc.text, "TADD.md");
  assert.deepEqual(parsed.metadata, doc.metadata);
  assert.match(parsed.body, /^# TADD Intrinsic/m);
});

test("Excel projection comes from structured metadata and fixed prose sections", () => {
  const projection = projectionForDocument(fixture());
  assert.equal(projection.Opcode, "TADD");
  assert.equal(projection.Dtype, "F16, F32");
  assert.equal(projection.Description, "逐元素加法。");
  assert.equal(projection.Constraints, "dtype 必须兼容。\nvalid region 必须匹配。");
});

test("public output excludes non-mapped and internal intrinsic pages", () => {
  assert.equal(publicDocument(fixture()), true);
  assert.equal(publicDocument(fixture({ status: "unmapped", visibility: "internal" })), false);
  assert.equal(publicDocument(fixture({ kind: "header", status: "review", opcode: undefined, family: undefined, xlsx: undefined })), false);
});

test("Complete visible navigation labels reject Chinese text", () => {
  assert.doesNotThrow(() => validateEnglishNavigationLabels(["Home", "Architecture Reference", "BSTART.FP"]));
  assert.throws(() => validateEnglishNavigationLabels(["Home", "浮点块块头"]), /must be English/);
});

test("metadata validation rejects local absolute paths and missing controlled opcode", () => {
  const doc = fixture({ opcode: "" });
  doc.text += "\n/Users/example/private/source.md\n";
  const errors = validateMetadata(doc);
  assert.ok(errors.some((item) => item.includes("missing opcode")));
  assert.ok(errors.some((item) => item.includes("local absolute path")));
});

test("absolute-path validation accepts HTTPS links but rejects machine-local paths", () => {
  assert.equal(hasLocalAbsolutePath("https://github.com/hw-native-sys/pto-isa/blob/main/docs/isa/tile/ops/tadd.md"), false);
  assert.equal(hasLocalAbsolutePath("See /Users/example/private/source.md"), true);
  assert.equal(hasLocalAbsolutePath("See C:\\private\\source.md"), true);
});

test("metadata validation enforces live path and inactive Excel consistency", () => {
  const doc = fixture({ status: "removed", visibility: "internal", sources: { davincioo: "old/TADD.md" } });
  const errors = validateMetadata(doc);
  assert.ok(errors.some((item) => item.includes("live document path")));
  assert.ok(errors.some((item) => item.includes("cannot remain in Excel")));
});

test("projection formatting rejects packed bundle entries and misplaced matrix operands", () => {
  const doc = fixture({
    family: "matrix-cube",
    bundle: "BSTART.CUBE TMATMUL + B.IOT",
    operands: { output: "D Tile", input0: "A Tile", input1: "B/Right Tile\nBias Tile (optional)", input2: null },
  });
  const errors = validateProjectionFormatting(doc);
  assert.ok(errors.some((item) => item.includes("separate lines")));
  assert.ok(errors.some((item) => item.includes("auxiliary operands")));
});

test("sync state separates merged layout placeholders from manual prose overrides", () => {
  const doc = fixture();
  const projection = projectionForDocument(doc);
  const current = { ...projection, "类型": null, "子类型": null, Description: "Manual summary", Constraints: "Manual constraints" };
  const row = buildStateRow(doc, projection, current, 2);
  assert.deepEqual(row.layout_placeholders, { "类型": null, "子类型": null });
  assert.deepEqual(row.overrides, { Description: "Manual summary", Constraints: "Manual constraints" });
  const audit = auditState({ version: 2, rows: { [doc.metadata.id]: row } });
  assert.equal(audit.layout_placeholders, 2);
  assert.equal(audit.manual_overrides, 2);
});

test("version-one sidecar migrates null category overrides into layout placeholders", () => {
  const state = migrateState({ version: 1, rows: { "intrinsic.tadd": { overrides: { "类型": null, Description: "Manual" } } } });
  assert.equal(state.version, 2);
  assert.deepEqual(state.rows["intrinsic.tadd"].layout_placeholders, { "类型": null });
  assert.deepEqual(state.rows["intrinsic.tadd"].overrides, { Description: "Manual" });
});

test("shared frontmatter definition generates the runtime schema", () => {
  const schema = generatedSchema();
  assert.deepEqual(schema.required, FRONTMATTER_RULES.required);
  assert.deepEqual(schema.properties.kind.enum, FRONTMATTER_RULES.enums.kind);
  assert.deepEqual(schema.properties.profile.enum, PROFILES);
  assert.equal(schema.additionalProperties, false);
});

test("profile validation accepts v4 compatibility and v5 active documents", () => {
  assert.equal(validateMetadata(fixture({ profile: "davincioo-v4-pe-local" })).length, 0);
  assert.equal(validateMetadata(fixture({ profile: "davincioo-v5-superscalar" })).length, 0);
  assert.ok(validateMetadata(fixture({ profile: "davincioo-v6-unknown" })).some((item) => item.includes("invalid profile")));
});

test("stable heading slugs and fragments preserve Chinese and disambiguate duplicates", () => {
  assert.equal(headingSlug("PTO 语义来源"), "pto-语义来源");
  assert.deepEqual([...headingIds("# Title\n\n## PTO 语义来源\n\n## PTO 语义来源\n")], ["title", "pto-语义来源", "pto-语义来源-2"]);
});

test("Markdown parser sees inline-code-adjacent and escaped-bracket links", () => {
  const links = markdownLinks("`BSTART` [B\\[0\\]](B.IOT.md#字段编码) and [PTO](../pto/TADD.md)");
  assert.deepEqual(links.map((item) => item.href), ["B.IOT.md#字段编码", "../pto/TADD.md"]);
});

test("renderer creates internal fragments and PTO commit permalinks", () => {
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), "render-links-test-"));
  try {
    const doc = fixture();
    fs.writeFileSync(path.join(temp, "PTO-ISA.source-lock.json"), `${JSON.stringify({ commit: "0123456789abcdef" })}\n`);
    const roots = { intrinsicRoot: temp, ptoDocsRoot: "/missing" };
    const html = renderMarkdown("## 字段编码\n\nSee [BSTART](header/BSTART.md#编码方式) and [PTO](../pto/TADD.md).", doc, new Map([["header/BSTART.md", "doc-header-bstart.html"]]), roots);
    assert.match(html, /id="字段编码"/);
    assert.match(html, /href="doc-header-bstart.html#编码方式"/);
    assert.match(html, /blob\/0123456789abcdef\/docs\/isa\/tile\/ops\/elementwise-tile-tile\/tadd.md/);
  } finally {
    fs.rmSync(temp, { recursive: true, force: true });
  }
});

test("renderer maps active misa_s support links into the locked Linx snapshot", () => {
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), "render-sys-links-test-"));
  try {
    const doc = { ...fixture(), relativePath: "scalar/misa_s/ASSERT.md", metadata: { kind: "scalar" } };
    const target = "scalar/support/linx-v0.56/inst/LibPseudoCode.md";
    const html = renderMarkdown("See [pseudo](../LibPseudoCode.md).", doc, new Map([[target, "doc-lib.html"]]), { intrinsicRoot: temp });
    assert.match(html, /href="doc-lib.html"/);
  } finally {
    fs.rmSync(temp, { recursive: true, force: true });
  }
});

test("pure Excel decisions cover add, rename, override, blocked deletion, and authorized clear", () => {
  assert.equal(decideRowPresence({ hasProjection: true, rowExists: false }).action, "add");
  assert.deepEqual(decideCell({ column: "Opcode", actual: "OLD", previous: "OLD", wanted: "NEW" }), { action: "write", value: "NEW" });
  assert.equal(decideCell({ column: "Description", actual: "Manual", previous: "Generated", wanted: "Changed" }).action, "protect");
  assert.equal(decideCell({ column: "Description", actual: "Manual", previous: "Generated", wanted: "Changed", overrideProtected: true }).action, "preserve");
  assert.equal(decideRowPresence({ hasProjection: false, rowExists: true, overrides: ["Description"] }).action, "block");
  assert.equal(decideRowPresence({ hasProjection: false, rowExists: true, overrides: ["Description"], deleteAuthorized: true }).action, "clear");
  assert.equal(decideCell({ column: "Description", actual: "Manual", previous: "Generated", wanted: "Changed", overrideProtected: true, clearAuthorized: true }).action, "write");
});

test("Linx lock supports lock-only validation and detects stale snapshots", () => {
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), "linx-lock-test-"));
  try {
    const intrinsicRoot = path.join(temp, "intrinsic");
    const snapshot = path.join(intrinsicRoot, "scalar/support/linx-v0.56/instset/base.md");
    fs.mkdirSync(path.dirname(snapshot), { recursive: true });
    fs.writeFileSync(snapshot, "# Base\n");
    const fileHash = sha256(fs.readFileSync(snapshot));
    const aggregate = sha256(`instset/base.md\n${fileHash}`);
    fs.writeFileSync(path.join(intrinsicRoot, "LINX-ISA.source-lock.json"), `${JSON.stringify({ version: 1, commit: "abc", aggregate_sha256: aggregate, files: [{ path: "instset/base.md", sha256: fileHash }] })}\n`);
    const roots = { intrinsicRoot, linxRoot: path.join(temp, "missing-linx") };
    assert.deepEqual(checkLinxLock(roots), []);
    fs.appendFileSync(snapshot, "stale\n");
    assert.ok(checkLinxLock(roots).some((item) => item.includes("snapshot differs")));
  } finally {
    fs.rmSync(temp, { recursive: true, force: true });
  }
});

test("legacy missing-link baseline rejects new regressions", () => {
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), "legacy-links-test-"));
  try {
    const intrinsicRoot = path.join(temp, "intrinsic");
    fs.mkdirSync(path.join(intrinsicRoot, "scalar"), { recursive: true });
    fs.writeFileSync(path.join(intrinsicRoot, "scalar/README.md"), "# Scalar\n");
    fs.writeFileSync(path.join(intrinsicRoot, "legacy-missing-links.json"), `${JSON.stringify({ version: 1, count: 0, missing: [] })}\n`);
    const roots = { intrinsicRoot };
    assert.deepEqual(checkLegacyBaseline(roots), []);
    fs.appendFileSync(path.join(intrinsicRoot, "scalar/README.md"), "[missing](nope.md)\n");
    assert.ok(checkLegacyBaseline(roots).some((item) => item.includes("baseline drift")));
  } finally {
    fs.rmSync(temp, { recursive: true, force: true });
  }
});

function handoffText(overrides = {}) {
  const metadata = {
    handoff_version: 1,
    change_id: "test-change",
    status: "frozen",
    profile: PROFILE,
    change_type: "content",
    targets: [{ file: "isa/intrinsic/TADD.md", sections: { "PTO 语义来源": "replace" } }],
    allowed_files: ["isa/intrinsic/TADD.md"],
    mechanical_files: [],
    forbidden_prefixes: ["isa/intrinsic/tools/"],
    xlsx_ids: ["intrinsic.tadd"],
    html_expectations: ["TADD page renders"],
    unresolved_questions: [],
    non_goals: ["No renderer changes"],
    ...overrides,
  };
  return `---\n${JSON.stringify(metadata, null, 2)}\n---\n# Final decisions\n\n# Per-section content\n\n# Background and rationale\n\n# Open questions\n\n# Non-goals\n`;
}

test("handoff contract rejects unresolved frozen decisions and tooling scope", () => {
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), "handoff-contract-test-"));
  try {
    const good = path.join(temp, "good.md");
    fs.writeFileSync(good, handoffText());
    assert.equal(readHandoff(good, { requireFrozen: true }).handoff.change_id, "test-change");
    const unresolved = path.join(temp, "unresolved.md");
    fs.writeFileSync(unresolved, handoffText({ unresolved_questions: ["Which encoding?"] }));
    assert.throws(() => readHandoff(unresolved, { requireFrozen: true }), /cannot contain unresolved_questions/);
    const tooling = path.join(temp, "tooling.md");
    fs.writeFileSync(tooling, handoffText({ allowed_files: ["isa/intrinsic/TADD.md", "isa/intrinsic/tools/intrinsic_docs.mjs"] }));
    assert.throws(() => readHandoff(tooling), /cannot modify isa\/intrinsic\/tools/);
  } finally {
    fs.rmSync(temp, { recursive: true, force: true });
  }
});

test("change baseline detects out-of-scope edits and Excel projection changes", () => {
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), "change-scope-test-"));
  try {
    const intrinsicRoot = path.join(temp, "isa/intrinsic");
    fs.mkdirSync(intrinsicRoot, { recursive: true });
    fs.writeFileSync(path.join(intrinsicRoot, "TADD.md"), fixture().text);
    fs.writeFileSync(path.join(intrinsicRoot, "OTHER.md"), fixture({ id: "intrinsic.other", opcode: "OTHER", sources: { davincioo: "OTHER.md" }, xlsx: { include: false } }).text);
    const handoffFile = path.join(temp, "handoff.md");
    fs.writeFileSync(handoffFile, handoffText());
    const handoff = readHandoff(handoffFile, { requireFrozen: true }).handoff;
    const roots = { repoRoot: temp, intrinsicRoot };
    beginChange(roots, handoff);
    fs.appendFileSync(path.join(intrinsicRoot, "TADD.md"), "\n## Implementation note\n\nChanged non-projected prose.\n");
    let scope = inspectChangeScope(roots, handoff);
    assert.deepEqual(scope.violations, []);
    assert.equal(scope.xlsxProjectionChanged, false);
    const changed = fixture();
    changed.body = changed.body.replace("逐元素加法。", "逐元素加法，采用新语义。");
    fs.writeFileSync(path.join(intrinsicRoot, "TADD.md"), serializeDocument(changed.metadata, changed.body));
    scope = inspectChangeScope(roots, handoff);
    assert.equal(scope.xlsxProjectionChanged, true);
    fs.appendFileSync(path.join(intrinsicRoot, "OTHER.md"), "\nOut of scope.\n");
    assert.deepEqual(inspectChangeScope(roots, handoff).violations, ["isa/intrinsic/OTHER.md"]);
    assert.deepEqual(validateTargetSections(roots, handoff), []);
  } finally {
    fs.rmSync(temp, { recursive: true, force: true });
  }
});

test("remove handoff permits a physically absent target only when every section action is remove", () => {
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), "handoff-physical-remove-test-"));
  try {
    const intrinsicRoot = path.join(temp, "isa/intrinsic");
    fs.mkdirSync(intrinsicRoot, { recursive: true });
    const target = "isa/intrinsic/TADD.md";
    const roots = { repoRoot: temp, intrinsicRoot };
    const allRemove = {
      change_type: "remove",
      targets: [{ file: target, sections: { "TADD Intrinsic": "remove", "PTO 语义来源": "remove" } }],
    };
    assert.deepEqual(validateTargetSections(roots, allRemove), []);
    const mixed = {
      change_type: "remove",
      targets: [{ file: target, sections: { "TADD Intrinsic": "remove", "PTO 语义来源": "replace" } }],
    };
    assert.ok(validateTargetSections(roots, mixed).some((item) => item.includes("does not exist")));
    const content = {
      change_type: "content",
      targets: [{ file: target, sections: { "TADD Intrinsic": "remove" } }],
    };
    assert.ok(validateTargetSections(roots, content).some((item) => item.includes("does not exist")));
  } finally {
    fs.rmSync(temp, { recursive: true, force: true });
  }
});

test("remove handoff normalizes fully removed files out of managed targets", () => {
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), "handoff-remove-normalization-test-"));
  try {
    const handoffFile = path.join(temp, "remove.md");
    fs.writeFileSync(handoffFile, handoffText({
      change_type: "remove",
      targets: [
        { file: "isa/intrinsic/TADD.md", sections: { "TADD Intrinsic": "remove", "PTO 语义来源": "remove" } },
        { file: "isa/intrinsic/OTHER.md", sections: { "PTO 语义来源": "replace" } },
      ],
      allowed_files: ["isa/intrinsic/TADD.md", "isa/intrinsic/OTHER.md"],
      xlsx_ids: [],
    }));
    const handoff = readHandoff(handoffFile, { requireFrozen: true }).handoff;
    assert.deepEqual(handoff.targets.map((target) => target.file), ["isa/intrinsic/OTHER.md"]);
    assert.deepEqual(handoff.removed_targets.map((target) => target.file), ["isa/intrinsic/TADD.md"]);
  } finally {
    fs.rmSync(temp, { recursive: true, force: true });
  }
});

test("atomic Complete replacement preserves the previous site when preparation fails", () => {
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), "atomic-html-test-"));
  try {
    const destination = path.join(temp, "site");
    fs.mkdirSync(destination);
    fs.writeFileSync(path.join(destination, "old.html"), "old");
    assert.throws(() => replaceDirectoryAtomically(destination, path.join(temp, "missing")));
    assert.equal(fs.readFileSync(path.join(destination, "old.html"), "utf8"), "old");
    const prepared = path.join(temp, "prepared");
    fs.mkdirSync(prepared);
    fs.writeFileSync(path.join(prepared, "new.html"), "new");
    replaceDirectoryAtomically(destination, prepared);
    assert.equal(fs.readFileSync(path.join(destination, "new.html"), "utf8"), "new");
    assert.equal(fs.existsSync(path.join(destination, "old.html")), false);
  } finally {
    fs.rmSync(temp, { recursive: true, force: true });
  }
});
