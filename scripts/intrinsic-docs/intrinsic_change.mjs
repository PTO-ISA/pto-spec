import fs from "node:fs";
import path from "node:path";
import {
  PROFILE,
  loadDocuments,
  parseFrontmatter,
  projectionForDocument,
  sha256,
  toPosix,
  walk,
} from "./intrinsic_docs_lib.mjs";

const CHANGE_TYPES = new Set(["content", "add", "remove", "tooling"]);
const HANDOFF_STATES = new Set(["draft", "frozen"]);
const SECTION_ACTIONS = new Set(["add", "replace", "remove", "review"]);
const SNAPSHOT_EXTRAS = [".github/workflows/ci.yml", ".pre-commit-config.yaml"];

function safeRelative(value, field) {
  if (typeof value !== "string" || !value.trim()) throw new Error(`${field}: expected a non-empty repository-relative path`);
  const normalized = toPosix(path.posix.normalize(value.trim()));
  if (path.posix.isAbsolute(normalized) || normalized === ".." || normalized.startsWith("../")) throw new Error(`${field}: path must stay inside the repository: ${value}`);
  return normalized.replace(/^\.\//, "");
}

function stringArray(value, field) {
  if (!Array.isArray(value) || value.some((item) => typeof item !== "string" || !item.trim())) throw new Error(`${field}: expected an array of non-empty strings`);
  return [...new Set(value.map((item) => item.trim()))];
}

function allTargets(handoff) {
  return [...(handoff.targets || []), ...(handoff.removed_targets || [])];
}

export function readHandoff(filePath, { requireFrozen = false } = {}) {
  const absolute = path.resolve(filePath);
  if (!fs.existsSync(absolute)) throw new Error(`Handoff does not exist: ${absolute}`);
  const parsed = parseFrontmatter(fs.readFileSync(absolute, "utf8"), absolute);
  const handoff = parsed.metadata;
  const errors = [];
  if (!handoff || handoff.handoff_version !== 1) errors.push("handoff_version must be 1");
  if (!handoff || typeof handoff.change_id !== "string" || !/^[a-z0-9][a-z0-9._-]*$/.test(handoff.change_id)) errors.push("change_id must use lowercase letters, digits, dot, underscore, or dash");
  if (!HANDOFF_STATES.has(handoff?.status)) errors.push("status must be draft or frozen");
  if (requireFrozen && handoff?.status !== "frozen") errors.push("implementation requires status: frozen");
  if (handoff?.profile !== PROFILE) errors.push(`profile must be ${PROFILE}`);
  if (!CHANGE_TYPES.has(handoff?.change_type)) errors.push("change_type must be content, add, remove, or tooling");
  try { handoff.allowed_files = stringArray(handoff?.allowed_files, "allowed_files").map((item) => safeRelative(item, "allowed_files")); } catch (error) { errors.push(error.message); }
  try { handoff.mechanical_files = stringArray(handoff?.mechanical_files || [], "mechanical_files").map((item) => safeRelative(item, "mechanical_files")); } catch (error) { errors.push(error.message); }
  try { handoff.forbidden_prefixes = stringArray(handoff?.forbidden_prefixes || [], "forbidden_prefixes").map((item) => safeRelative(item, "forbidden_prefixes")); } catch (error) { errors.push(error.message); }
  try { handoff.xlsx_ids = stringArray(handoff?.xlsx_ids || [], "xlsx_ids"); } catch (error) { errors.push(error.message); }
  try { handoff.html_expectations = stringArray(handoff?.html_expectations || [], "html_expectations"); } catch (error) { errors.push(error.message); }
  try { handoff.unresolved_questions = stringArray(handoff?.unresolved_questions || [], "unresolved_questions"); } catch (error) { errors.push(error.message); }
  try { handoff.non_goals = stringArray(handoff?.non_goals || [], "non_goals"); } catch (error) { errors.push(error.message); }
  if (requireFrozen && handoff?.unresolved_questions?.length) errors.push("a frozen handoff cannot contain unresolved_questions");
  if (!Array.isArray(handoff?.targets) || handoff.targets.length === 0) errors.push("targets must contain at least one Markdown target");
  else {
    handoff.targets = handoff.targets.map((target, index) => {
      try {
        const file = safeRelative(target?.file, `targets[${index}].file`);
        if (!file.startsWith("isa/intrinsic/") || !file.endsWith(".md")) errors.push(`targets[${index}].file must be a Markdown file under isa/intrinsic`);
        if (!target?.sections || typeof target.sections !== "object" || Array.isArray(target.sections) || Object.keys(target.sections).length === 0) errors.push(`targets[${index}].sections must map headings to actions`);
        else for (const [heading, action] of Object.entries(target.sections)) {
          if (!heading.trim()) errors.push(`targets[${index}].sections contains an empty heading`);
          if (!SECTION_ACTIONS.has(action)) errors.push(`targets[${index}].sections.${heading}: invalid action ${action}`);
        }
        return { ...target, file };
      } catch (error) {
        errors.push(error.message);
        return target;
      }
    });
  }
  const declared = new Set([...(handoff?.allowed_files || []), ...(handoff?.mechanical_files || [])]);
  const targetFiles = new Set((handoff?.targets || []).map((target) => target?.file).filter(Boolean));
  for (const target of handoff?.targets || []) if (target?.file && !declared.has(target.file)) errors.push(`${target.file}: target is absent from allowed_files/mechanical_files`);
  for (const file of handoff?.allowed_files || []) if (file.endsWith(".md") && !targetFiles.has(file)) errors.push(`${file}: allowed Markdown files must also be declared as targets`);
  for (const file of declared) for (const prefix of handoff?.forbidden_prefixes || []) if (file.startsWith(prefix)) errors.push(`${file}: overlaps forbidden prefix ${prefix}`);
  if (handoff?.change_type !== "tooling" && [...declared].some((file) => file.startsWith("isa/intrinsic/tools/"))) errors.push("content handoffs cannot modify isa/intrinsic/tools; use change_type: tooling");
  const requiredBodySections = [
    ["Final decisions", "最终规范结论"],
    ["Per-section content", "分章节发布内容"],
    ["Background and rationale", "背景与理由"],
    ["Open questions", "未决问题"],
    ["Non-goals", "非目标"],
  ];
  for (const alternatives of requiredBodySections) {
    if (!parsed.body.split("\n").some((line) => /^#{1,6}\s+/.test(line) && alternatives.includes(line.replace(/^#{1,6}\s+/, "").trim()))) errors.push(`handoff body is missing section: ${alternatives.join(" / ")}`);
  }
  if (errors.length) throw new Error(`Invalid handoff:\n${errors.join("\n")}`);
  if (handoff.change_type === "remove") {
    handoff.removed_targets = handoff.targets.filter((target) => Object.values(target.sections).every((action) => action === "remove"));
    handoff.targets = handoff.targets.filter((target) => !handoff.removed_targets.includes(target));
  } else {
    handoff.removed_targets = [];
  }
  handoff._filePath = absolute;
  return { filePath: absolute, body: parsed.body, handoff };
}

export function changeStateDir(roots, handoff) {
  return path.join(roots.repoRoot, "build", "intrinsic-changes", handoff.change_id);
}

function snapshotPaths(roots) {
  const intrinsic = walk(roots.intrinsicRoot, (file) => fs.statSync(file).isFile())
    .map((file) => toPosix(path.relative(roots.repoRoot, file)));
  return [...new Set([...intrinsic, ...SNAPSHOT_EXTRAS.filter((file) => fs.existsSync(path.join(roots.repoRoot, file)))])].sort();
}

function projectionSnapshot(roots, handoff) {
  const ids = new Set(handoff.xlsx_ids);
  const result = {};
  for (const doc of loadDocuments(roots.intrinsicRoot)) {
    if (!ids.has(doc.metadata?.id) && !ids.has(doc.metadata?.opcode)) continue;
    result[doc.metadata.id] = projectionForDocument(doc);
  }
  return result;
}

export function beginChange(roots, handoff) {
  const targetPaths = new Set(allTargets(handoff).map((target) => target.file.replace(/^isa\/intrinsic\//, "")));
  for (const doc of loadDocuments(roots.intrinsicRoot).filter((item) => targetPaths.has(item.relativePath) && item.metadata?.xlsx?.include)) {
    if (!handoff.xlsx_ids.includes(doc.metadata.id) && !handoff.xlsx_ids.includes(doc.metadata.opcode)) throw new Error(`${doc.relativePath}: projected target requires its stable id in xlsx_ids`);
  }
  const files = Object.fromEntries(snapshotPaths(roots).map((relativePath) => {
    const bytes = fs.readFileSync(path.join(roots.repoRoot, relativePath));
    return [relativePath, sha256(bytes)];
  }));
  const baseline = {
    version: 1,
    change_id: handoff.change_id,
    handoff_sha256: sha256(fs.readFileSync(handoff._filePath)),
    files,
    xlsx_projections: projectionSnapshot(roots, handoff),
  };
  const stateDir = changeStateDir(roots, handoff);
  fs.mkdirSync(stateDir, { recursive: true });
  fs.writeFileSync(path.join(stateDir, "baseline.json"), `${JSON.stringify(baseline, null, 2)}\n`);
  return { baselinePath: path.join(stateDir, "baseline.json"), fileCount: Object.keys(files).length };
}

export function inspectChangeScope(roots, handoff) {
  const baselinePath = path.join(changeStateDir(roots, handoff), "baseline.json");
  if (!fs.existsSync(baselinePath)) throw new Error(`Missing change baseline; run change-begin first: ${baselinePath}`);
  const baseline = JSON.parse(fs.readFileSync(baselinePath, "utf8"));
  if (baseline.handoff_sha256 !== sha256(fs.readFileSync(handoff._filePath))) throw new Error("Handoff changed after change-begin; review it and create a new baseline");
  const currentPaths = snapshotPaths(roots);
  const current = Object.fromEntries(currentPaths.map((relativePath) => [relativePath, sha256(fs.readFileSync(path.join(roots.repoRoot, relativePath)))]));
  const changed = [...new Set([...Object.keys(baseline.files), ...Object.keys(current)])]
    .filter((file) => baseline.files[file] !== current[file]).sort();
  const allowed = new Set([...handoff.allowed_files, ...handoff.mechanical_files]);
  const violations = changed.filter((file) => !allowed.has(file) || handoff.forbidden_prefixes.some((prefix) => file.startsWith(prefix)));
  const currentProjections = projectionSnapshot(roots, handoff);
  const xlsxProjectionChanged = JSON.stringify(baseline.xlsx_projections) !== JSON.stringify(currentProjections);
  return { baselinePath, changed, violations, xlsxProjectionChanged, xlsxIds: handoff.xlsx_ids };
}

export function validateTargetSections(roots, handoff) {
  const errors = [];
  for (const target of allTargets(handoff)) {
    const filePath = path.join(roots.repoRoot, target.file);
    if (!fs.existsSync(filePath)) {
      const actions = Object.values(target.sections);
      if (handoff.change_type === "remove" && actions.length > 0 && actions.every((action) => action === "remove")) continue;
      errors.push(`${target.file}: target does not exist after the change`);
      continue;
    }
    const body = parseFrontmatter(fs.readFileSync(filePath, "utf8"), target.file).body;
    for (const [heading, action] of Object.entries(target.sections)) {
      const present = body.split("\n").some((line) => /^#{1,6}\s+/.test(line) && line.replace(/^#{1,6}\s+/, "").trim() === heading);
      if (action === "remove" ? present : !present) errors.push(`${target.file}: heading ${heading} must be ${action === "remove" ? "removed" : "present"}`);
    }
  }
  return errors;
}
