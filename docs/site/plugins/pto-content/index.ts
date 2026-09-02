import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {existsSync, mkdirSync, readFileSync, readdirSync, statSync, writeFileSync} from 'node:fs';
import path from 'node:path';
import type {LoadContext, Plugin} from '@docusaurus/types';
import type {
  PtoAdrRecord,
  PtoArchitectureGuide,
  PtoArchitectureOwnerProjection,
  PtoArtifactEvidence,
  PtoDocumentationIdentity,
  PtoGraphEdge,
  PtoGraphEdgeKind,
  PtoGraphNode,
  PtoGraphNodeKind,
  PtoJsonValue,
  PtoInstructionComposition,
  PtoInstructionIndexData,
  PtoHighLevelAssembly,
  PtoNdfClause,
  PtoNdfCatalogData,
  PtoNdfDetailData,
  PtoNdfOwnerRoute,
  PtoNdfGraphData,
  PtoNdfIndexPageData,
  PtoNavigationData,
  PtoNavigationNode,
  PtoReleaseIdentity,
  PtoSemanticExecution,
  PtoSemanticIdentity,
  PtoReaderGuide,
  PtoReaderGuideBlock,
  PtoReaderGuideOwnerLink,
  PtoReaderGuideRole,
  PtoReaderInline,
  PtoReaderNode,
  PtoSearchData,
  PtoSearchEntry,
  PtoTestEvidence,
  PtoUnitEncoding,
  PtoUnitWorkbenchData,
} from '../../src/types/pto';
import {ndfOverviewSvg} from './ndfOverview';
import {legacyReferenceRoute, unitRoute} from './routes';

const TLOAD_ROUTE =
  '/instructions/tile/memory-and-data-movement/regular/TLOAD/';
const GITHUB_REPOSITORY = 'https://github.com/PTO-ISA/pto-spec';

interface TraceabilityUnit {
  id: string;
  mnemonic: string | null;
  source: string;
  documentation: string;
  surface: string;
  classification: string[];
  tests: string[];
  semantic_tests: string[];
  readiness_subjects: string[];
  instruction_contract?: Record<string, PtoJsonValue>;
}

interface TraceabilityRequirement {
  id: string;
  executable: boolean;
  owners: string[];
  tests: string[];
  readiness_subjects: string[];
}

interface TraceabilityTest {
  id: string;
  kind: string;
  path: string;
  sha256: string;
  source: string;
  requirements: string[];
}

interface TraceabilityData {
  sources: Record<string, string>;
  requirements: TraceabilityRequirement[];
  units: TraceabilityUnit[];
  tests: TraceabilityTest[];
}

interface AdrIndexRecord {
  id: string;
  title: string;
  title_zh: string;
  status: string;
  path: string;
  accepted: string | null;
  affected_ndf: string[];
  affected_units: string[];
  target_releases: string[];
  release_boundary?: boolean;
  interface_change?: boolean;
}

interface AdrIndexData {
  records: AdrIndexRecord[];
}

interface NdfSupplement {
  id: string;
  source_path: string;
  title: {en: string; 'zh-CN': string};
  summary: {en: string; 'zh-CN': string};
}

interface LoadedPtoContent {
  units: Array<{data: PtoUnitWorkbenchData; route: string}>;
  release: PtoReleaseIdentity;
  graph: PtoNdfGraphData;
  search: PtoSearchData;
  ndfIndexPages: PtoNdfIndexPageData[];
  adrDecisions: Record<string, PtoReaderNode[]>;
  instructionIndex: PtoInstructionIndexData;
  ndfCatalog: PtoNdfCatalogData;
  ndfDetails: PtoNdfDetailData[];
}

interface ArchitectureTopicDefinition {
  id: string;
  label: {en: string; 'zh-CN': string};
  primary: string;
  boundaryOwner?: string;
  related: Array<{id: string; label: {en: string; 'zh-CN': string}}>;
}

const ARCHITECTURE_ENTRY = 'PTO-ARCH-OVERVIEW-ARCHITECTURE';

const ARCHITECTURE_TOPICS: ArchitectureTopicDefinition[] = [
  {
    id: 'execution-model',
    label: {en: 'Programming and execution model', 'zh-CN': '编程与执行模型'},
    primary: 'PTO-ARCH-DISPATCH-TOP-LEVEL',
    boundaryOwner: 'PTO-ARCH-DISPATCH-TOP-LEVEL',
    related: [
      {id: 'PTO-ARCH-OVERVIEW-INSTRUCTION-CLASSIFICATION', label: {en: 'Instruction classes and Tile engines', 'zh-CN': '指令分类与 Tile 执行引擎'}},
      {id: 'PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY', label: {en: 'Core and PE topology', 'zh-CN': 'Core 与 PE 拓扑'}},
      {id: 'PTO-BLOCK-BSTART', label: {en: 'Block/bundle start and completion boundary', 'zh-CN': 'Block/bundle 开始与完成边界'}},
      {id: 'PTO-TILE-TLOAD', label: {en: 'Source-backed Tile bundle example', 'zh-CN': '源对齐的 Tile bundle 示例'}},
    ],
  },
  {
    id: 'architectural-state',
    label: {en: 'Architectural state', 'zh-CN': '架构状态'},
    primary: 'PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT',
    related: [
      {id: 'PTO-ARCH-STATE-DEFINEDNESS', label: {en: 'Definedness boundary', 'zh-CN': 'Definedness 边界'}},
      {id: 'PTO-ARCH-STATE-PROGRAM-COUNTER', label: {en: 'Program-control state', 'zh-CN': '程序控制状态'}},
      {id: 'PTO-ARCH-STATE-TRAP-CONTEXT', label: {en: 'Saved trap context', 'zh-CN': '保存的 trap context'}},
      {id: 'PTO-ARCH-GQM', label: {en: 'General queue state', 'zh-CN': '通用队列状态'}},
    ],
  },
  {
    id: 'registers',
    label: {en: 'Registers and Tile storage', 'zh-CN': '寄存器与 Tile 存储'},
    primary: 'PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY',
    related: [
      {id: 'PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS', label: {en: 'PE-private GPRs', 'zh-CN': 'PE 私有 GPR'}},
      {id: 'PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS', label: {en: 'Predicate registers', 'zh-CN': 'Predicate 寄存器'}},
      {id: 'PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS', label: {en: 'Local Tile registers', 'zh-CN': 'Local Tile 寄存器'}},
      {id: 'PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS', label: {en: 'Shared Tile registers', 'zh-CN': 'Shared Tile 寄存器'}},
      {id: 'PTO-ARCH-DATA-TYPES-SYSTEM-REGISTERS', label: {en: 'System-register namespace', 'zh-CN': 'System register 命名空间'}},
    ],
  },
  {
    id: 'memory-model',
    label: {en: 'Memory model', 'zh-CN': '内存模型'},
    primary: 'PTO-ARCH-MEMORY-MODEL-ORDERING',
    related: [
      {id: 'PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE', label: {en: 'Address space', 'zh-CN': '地址空间'}},
      {id: 'PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS', label: {en: 'Global Memory access', 'zh-CN': 'Global Memory 访问'}},
      {id: 'PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS', label: {en: 'Memory events', 'zh-CN': 'Memory event'}},
      {id: 'PTO-ARCH-MEMORY-MODEL-ATOMICITY', label: {en: 'Atomicity and coherence', 'zh-CN': 'Atomicity 与 coherence'}},
      {id: 'PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION', label: {en: 'Memory fault precision', 'zh-CN': '内存 fault 精确性'}},
    ],
  },
  {
    id: 'types-and-shape',
    label: {en: 'Types and shape model', 'zh-CN': '类型与 shape 模型'},
    primary: 'PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES',
    boundaryOwner: 'PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS',
    related: [
      {id: 'PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR', label: {en: 'Format descriptors', 'zh-CN': 'Format descriptor'}},
      {id: 'PTO-ARCH-STATE-TILE-DESCRIPTOR', label: {en: 'Tile descriptor state', 'zh-CN': 'Tile descriptor 状态'}},
      {id: 'PTO-ARCH-FEATURES-TILE-ALLOCATION', label: {en: 'Tile allocation and capacity', 'zh-CN': 'Tile allocation 与容量'}},
      {id: 'PTO-BLOCK-B-DIM', label: {en: 'B.DIM dimensions', 'zh-CN': 'B.DIM 维度'}},
      {id: 'PTO-TILE-TLOAD', label: {en: 'TLOAD shape consumer', 'zh-CN': 'TLOAD shape 消费者'}},
    ],
  },
  {
    id: 'faults',
    label: {en: 'Faults, exceptions, and diagnostics', 'zh-CN': 'Fault、exception 与 diagnostic'},
    primary: 'PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION',
    boundaryOwner: 'PTO-ARCH-DATA-TYPES-FAULT',
    related: [
      {id: 'PTO-ARCH-DATA-TYPES-FAULT', label: {en: 'Fault identities', 'zh-CN': 'Fault 标识'}},
      {id: 'PTO-ARCH-STATE-TRAP-CONTEXT', label: {en: 'Trap context state', 'zh-CN': 'Trap context 状态'}},
      {id: 'PTO-ARCH-PROFILE-TRAP-CONTEXT-RECOVERY', label: {en: 'Trap recovery profile path', 'zh-CN': 'Trap recovery profile 路径'}},
    ],
  },
  {
    id: 'versioning',
    label: {en: 'Version and compatibility', 'zh-CN': '版本与兼容性'},
    primary: 'PTO-ARCH-OVERVIEW-ARCHITECTURE',
    boundaryOwner: 'PTO-ARCH-PROFILE-APPLICABILITY',
    related: [
      {id: 'PTO-ARCH-PROFILE-APPLICABILITY', label: {en: 'Profile applicability', 'zh-CN': 'Profile 适用性'}},
      {id: 'PTO-ARCH-PROFILE-REFERENCE-PROFILE', label: {en: 'PTO v0 reference profile', 'zh-CN': 'PTO v0 reference profile'}},
      {id: 'PTO-ARCH-PROFILE-EXTENSION-FIRST-USE', label: {en: 'Extension first-use policy', 'zh-CN': '扩展首次使用策略'}},
      {id: 'PTO-ARCH-OVERVIEW-INSTRUCTION-CLASSIFICATION', label: {en: 'Compatibility aliases', 'zh-CN': '兼容 alias'}},
    ],
  },
];

interface ReaderPresentationBlock {
  block_id: string;
  role: string;
}

interface ReaderNodeDisposition {
  node_id: string;
  block_id: string;
  ast_path: string;
  node_kind: string;
  fragment_sha256: string;
}

interface ReaderGuideShard {
  unit_id: string;
  status: 'pending' | 'complete' | 'decision-gap';
  owner: {
    asl_path: string;
    documentation_path: string;
    ndf_clause: string | null;
  };
  presentation_blocks: ReaderPresentationBlock[];
  node_dispositions: ReaderNodeDisposition[];
  atomic_claims: Array<{claim_id: string}>;
}

interface TranslationShard {
  unit_id: string;
  status: 'pending' | 'complete' | 'retired';
  english_unit_shard_sha256: string;
  english_block_ids: string[];
  english_node_ids: string[];
  english_claim_ids: string[];
  locale_documentation_path: string | null;
  locale_guide_sha256: string | null;
  block_mappings: Array<{
    english_block_id: string;
    locale_block_id: string;
    locale_fragment_sha256: string;
  }>;
  node_mappings: Array<{
    english_node_id: string;
    locale_node_id: string;
    locale_fragment_sha256: string;
  }>;
  claim_mappings: Array<{english_claim_id: string; locale_node_id: string}>;
}

interface ReviewBatch {
  verdict: 'pending' | 'accepted' | 'rejected';
  unit_risks: Record<string, string>;
}

interface TranslationReviewBatch {
  verdict: 'pending' | 'accepted' | 'rejected';
  unit_ids: string[];
  translation_artifact_digests: Record<string, string>;
}

interface ReaderGuideContext {
  locale: string;
  defaultLocale: string;
  acceptedEnglishUnits: Set<string>;
  acceptedTranslations: Map<string, string>;
}

interface ParsedReaderNode {
  blockId: string;
  astPath: string;
  kind: ReaderNodeDisposition['node_kind'];
  fragmentSha256: string;
  node: PtoReaderNode;
}

interface RequirementSourceIdentity {
  sourcePath: string;
  sourceSha256: string;
  clauseSha256: string;
  startLine: number;
  endLine: number;
  sourceUrl: string;
}

function localizedRoute(context: LoadContext, route: string): string {
  const {currentLocale, defaultLocale} = context.i18n;
  return currentLocale === defaultLocale ? route : `/${currentLocale}${route}`;
}

function fail(message: string): never {
  throw new Error(`[pto-content] ${message}`);
}

function repositoryRoot(siteDir: string): string {
  const root = path.resolve(siteDir, '..', '..');
  if (!statSync(path.join(root, 'specification.toml')).isFile()) {
    fail(`expected repository root at ${root}`);
  }
  return root;
}

function readText(root: string, relativePath: string): string {
  const absolutePath = path.resolve(root, relativePath);
  const relative = path.relative(root, absolutePath);
  if (relative.startsWith('..') || path.isAbsolute(relative)) {
    fail(`path escapes repository root: ${relativePath}`);
  }
  return readFileSync(absolutePath, 'utf8');
}

function readJson<T>(root: string, relativePath: string): T {
  try {
    return JSON.parse(readText(root, relativePath)) as T;
  } catch (error) {
    fail(`cannot parse ${relativePath}: ${String(error)}`);
  }
}

function git(root: string, ...args: string[]): string {
  try {
    return execFileSync('git', args, {
      cwd: root,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'pipe'],
    }).trim();
  } catch (error) {
    fail(`git ${args.join(' ')} failed: ${String(error)}`);
  }
}

function releaseIdentity(root: string): PtoReleaseIdentity {
  const specification = readText(root, 'specification.toml');
  const architectureVersion = specification.match(
    /^architecture_version\s*=\s*"([^"]+)"\s*$/m,
  )?.[1];
  if (architectureVersion === undefined) fail('specification release has no architecture_version');
  const publicationVersion = specification.match(
    /^publication_version\s*=\s*"([^"]+)"\s*$/m,
  )?.[1];
  if (publicationVersion === undefined) fail('specification release has no publication_version');
  if (
    !/^\d+\.\d+\.\d+\.\d+$/.test(publicationVersion) ||
    publicationVersion.split('.').slice(0, 3).join('.') !== architectureVersion
  ) {
    fail('publication_version must revise the current architecture_version');
  }

  const commit = git(root, 'rev-parse', 'HEAD');
  const tag = `v${publicationVersion}`;
  let tagged = false;
  try {
    tagged = commit === git(root, 'rev-parse', `${tag}^{commit}`);
  } catch {
    tagged = false;
  }
  const clean = git(root, 'status', '--porcelain=v1', '--untracked-files=all') === '';
  const releaseEligible = tagged && clean;
  const requireRelease = process.env.PTO_SITE_REQUIRE_RELEASE === '1';
  const requireClean = requireRelease || process.env.PTO_SITE_REQUIRE_CLEAN === '1';
  if (requireClean && !clean) {
    fail(`site validity requires a clean worktree at commit ${commit}`);
  }
  if (requireRelease && !tagged) {
    fail(
      `release publication requires HEAD ${commit} to equal the ${tag} commit`,
    );
  }

  return {
    architectureVersion,
    publicationVersion,
    commit,
    tag,
    tagged,
    releaseEligible,
  };
}

function sha256(text: string): string {
  return createHash('sha256').update(text, 'utf8').digest('hex');
}

function sourceUrl(
  commit: string,
  sourcePath: string,
  line?: number,
  endLine?: number,
): string {
  const fragment =
    line === undefined ? '' : `#L${line}${endLine === undefined ? '' : `-L${endLine}`}`;
  return `${GITHUB_REPOSITORY}/blob/${commit}/${sourcePath}${fragment}`;
}

const READER_BLOCK =
  /^<!-- PTO-READER-BLOCK: ([a-z0-9][a-z0-9-]*) role=([a-z0-9][a-z0-9-]*) -->$/;
const READER_ROLES = new Set<PtoReaderGuideRole>([
  'purpose',
  'mechanism',
  'inputs-outputs',
  'effects',
  'constraints',
  'example',
  'purpose-scope',
  'concepts-state',
  'rules-interactions',
  'boundaries',
  'example-usage',
  'related-owners-navigation',
]);

function supplementaryBody(markdown: string, documentationPath: string): string {
  const begin = '<!-- SUPPLEMENTARY-BEGIN -->';
  const end = '<!-- SUPPLEMENTARY-END -->';
  if (markdown.split(begin).length !== 2 || markdown.split(end).length !== 2) {
    fail(`${documentationPath} must contain exactly one supplementary region`);
  }
  const start = markdown.indexOf(begin) + begin.length;
  const finish = markdown.indexOf(end);
  if (start > finish) fail(`reversed supplementary markers in ${documentationPath}`);
  return markdown.slice(start, finish).replace(/^\n+|\n+$/g, '');
}

function canonicalReaderFragment(kind: string, text: string): string {
  const normalized =
    kind === 'code-block'
      ? text.replace(/\r\n?/g, '\n').normalize('NFC')
      : kind === 'table-row'
        ? text
            .trim()
            .replace(/^\||\|$/g, '')
            .split('|')
            .map((cell) => cell.normalize('NFC').trim().split(/\s+/).join(' '))
            .join('|')
        : text.normalize('NFC').trim().split(/\s+/).join(' ');
  return JSON.stringify({kind, text: normalized});
}

export function isCommonMarkFenceClose(line: string, opener: string): boolean {
  if (!/^`{3,}$|^~{3,}$/.test(opener)) return false;
  const candidate = line.trim();
  if (candidate.length < opener.length) return false;
  return [...candidate].every((character) => character === opener[0]);
}

function referenceRoute(documentationPath: string, locale: string, defaultLocale: string): string {
  const route = legacyReferenceRoute(documentationPath);
  return locale === defaultLocale ? route : `/${locale}${route}`;
}

function safeReaderHref(
  root: string,
  commit: string,
  documentationPath: string,
  href: string,
  locale: string,
  defaultLocale: string,
): string {
  const value = href.trim();
  if (!value || /[\u0000-\u001f\u007f]/.test(value) || /^(?:javascript|data|vbscript):/i.test(value)) {
    fail(`unsafe reader-guide link in ${documentationPath}`);
  }
  if (value.startsWith('#')) return value;
  if (value.startsWith('/')) {
    if (value.startsWith('//')) fail(`protocol-relative reader-guide link in ${documentationPath}`);
    return value;
  }
  if (value.startsWith(`${GITHUB_REPOSITORY}/`)) return value;
  if (/^[a-z][a-z0-9+.-]*:/i.test(value) || value.startsWith('//')) {
    fail(`unaudited external reader-guide link in ${documentationPath}: ${value}`);
  }

  const pathOnly = value.split(/[?#]/, 1)[0];
  const resolved = path.resolve(root, path.dirname(documentationPath), pathOnly);
  const relative = path.relative(root, resolved).replaceAll(path.sep, '/');
  if (!relative || relative.startsWith('../') || path.isAbsolute(relative) || !existsSync(resolved)) {
    fail(`reader-guide link does not resolve inside the repository: ${value}`);
  }
  const suffix = value.slice(pathOnly.length);
  if (relative.startsWith('docs/') && relative.endsWith('.md')) {
    return `${referenceRoute(relative, locale, defaultLocale)}${suffix.replace(/^\?/, '?')}`;
  }
  return `${sourceUrl(commit, relative)}${suffix}`;
}

function parseReaderInline(
  root: string,
  commit: string,
  documentationPath: string,
  text: string,
  locale: string,
  defaultLocale: string,
): PtoReaderInline[] {
  const result: PtoReaderInline[] = [];
  let rest = text;
  const parseChildren = (value: string): PtoReaderInline[] =>
    parseReaderInline(root, commit, documentationPath, value, locale, defaultLocale);

  while (rest.length > 0) {
    if (rest.startsWith('![')) {
      fail(`images are not permitted in reader guides: ${documentationPath}`);
    }
    const code = rest.match(/^`([^`\n]+)`/);
    if (code !== null) {
      result.push({kind: 'code', text: code[1]});
      rest = rest.slice(code[0].length);
      continue;
    }
    const link = rest.match(/^\[([^\]\n]+)]\(([^()\s]+)\)/);
    if (link !== null) {
      result.push({
        kind: 'link',
        href: safeReaderHref(
          root,
          commit,
          documentationPath,
          link[2],
          locale,
          defaultLocale,
        ),
        children: parseChildren(link[1]),
      });
      rest = rest.slice(link[0].length);
      continue;
    }
    const strong = rest.match(/^\*\*([^*\n]+)\*\*/);
    if (strong !== null) {
      result.push({kind: 'strong', children: parseChildren(strong[1])});
      rest = rest.slice(strong[0].length);
      continue;
    }
    const emphasis = rest.match(/^\*([^*\n]+)\*/);
    if (emphasis !== null) {
      result.push({kind: 'emphasis', children: parseChildren(emphasis[1])});
      rest = rest.slice(emphasis[0].length);
      continue;
    }
    const next = rest.slice(1).search(/[`\[*!]/);
    const length = next === -1 ? rest.length : next + 1;
    result.push({kind: 'text', text: rest.slice(0, length)});
    rest = rest.slice(length);
  }
  return result;
}

function renderedReaderSyntax(text: string): string {
  return text.replace(/`[^`\n]*`/g, '');
}

function parseReaderGuide(
  root: string,
  release: PtoReleaseIdentity,
  documentationPath: string,
  markdown: string,
  locale: string,
  defaultLocale: string,
  shard: ReaderGuideShard,
  linkBasePath: string = documentationPath,
): {blocks: PtoReaderGuideBlock[]; sha256: string} {
  const body = supplementaryBody(markdown, documentationPath);
  if (/!\[[^\]]*]\(/.test(body)) fail(`images are not permitted in ${documentationPath}`);
  const lines = body.replace(/\r\n?/g, '\n').split('\n');
  const blocks: PtoReaderGuideBlock[] = [];
  const parsedNodes: ParsedReaderNode[] = [];
  let current: PtoReaderGuideBlock | null = null;
  let paragraph: string[] = [];
  let fence: string[] | null = null;
  let fenceToken = '';
  let fenceLanguage: string | null = null;

  const inline = (value: string): PtoReaderInline[] =>
    parseReaderInline(
      root,
      release.commit,
      linkBasePath,
      value,
      locale,
      defaultLocale,
    );
  const addNode = (kind: ReaderNodeDisposition['node_kind'], text: string, node: PtoReaderNode): void => {
    if (current === null) fail(`reader content appears before a block marker in ${documentationPath}`);
    const index = parsedNodes.filter((entry) => entry.blockId === current!.id).length;
    parsedNodes.push({
      blockId: current.id,
      astPath: `/blocks/${blocks.length - 1}/nodes/${index}`,
      kind,
      fragmentSha256: sha256(canonicalReaderFragment(kind, text)),
      node,
    });
    current.nodes.push(node);
  };
  const flushParagraph = (): void => {
    if (paragraph.length === 0) return;
    const source = paragraph.join('\n');
    const quoted = paragraph.every((line) => line.trimStart().startsWith('>'));
    if (quoted) {
      const content = paragraph.map((line) => line.trimStart().replace(/^>\s?/, ''));
      const match = content[0]?.match(/^\[!(NOTE|TIP|IMPORTANT|WARNING)]\s*(.*)$/i);
      const tone = (match?.[1]?.toLocaleLowerCase('en-US') ?? 'note') as
        | 'note'
        | 'tip'
        | 'important'
        | 'warning';
      if (match !== null && match !== undefined) content[0] = match[2];
      addNode('paragraph', source, {kind: 'callout', tone, children: inline(content.join(' '))});
    } else {
      addNode('paragraph', source, {kind: 'paragraph', children: inline(source.replace(/\n/g, ' '))});
    }
    paragraph = [];
  };

  for (const line of [...lines, '']) {
    const marker = line.trim().match(READER_BLOCK);
    if (fence !== null) {
      if (isCommonMarkFenceClose(line, fenceToken)) {
        addNode('code-block', fence.join('\n'), {
          kind: 'code-block',
          language: fenceLanguage,
          text: fence.join('\n'),
        });
        fence = null;
        fenceToken = '';
        fenceLanguage = null;
      } else {
        fence.push(line);
      }
      continue;
    }
    if (marker !== null) {
      flushParagraph();
      const role = marker[2] as PtoReaderGuideRole;
      if (!READER_ROLES.has(role)) fail(`unsupported reader role ${marker[2]} in ${documentationPath}`);
      if (blocks.some((block) => block.id === marker[1])) {
        fail(`duplicate reader block ${marker[1]} in ${documentationPath}`);
      }
      current = {id: marker[1], role, nodes: []};
      blocks.push(current);
    } else if (/^(?:`{3,}|~{3,})/.test(line.trim())) {
      flushParagraph();
      if (current === null) fail(`code block appears before a reader marker in ${documentationPath}`);
      const opening = line.trim().match(/^(`{3,}|~{3,})(.*)$/);
      if (opening === null) fail(`malformed reader code fence in ${documentationPath}`);
      fenceToken = opening[1];
      fenceLanguage = opening[2].trim() || null;
      fence = [];
    } else if (/^\s*(?:[-*+] |\d+[.)] )/.test(line)) {
      flushParagraph();
      const ordered = /^\s*\d+[.)] /.test(line);
      const text = line.replace(/^\s*(?:[-*+] |\d+[.)] )/, '');
      addNode('list-item', text, {kind: 'list-item', ordered, children: inline(text)});
    } else if (line.trimStart().startsWith('|') && line.trimEnd().endsWith('|')) {
      flushParagraph();
      if (!/^[\s|:=-]+$/.test(line)) {
        const cells = line.trim().replace(/^\||\|$/g, '').split('|').map((cell) => inline(cell.trim()));
        addNode('table-row', line, {kind: 'table-row', cells});
      }
    } else if (!line.trim()) {
      flushParagraph();
    } else if (line.trimStart().startsWith('#')) {
      flushParagraph();
      const heading = line.match(/^\s*(#{1,6})\s+(.+)$/);
      if (heading === null) fail(`malformed reader heading in ${documentationPath}`);
      addNode('heading', heading[2], {
        kind: 'heading',
        level: Math.max(3, heading[1].length + 1),
        children: inline(heading[2]),
      });
    } else if (line.trimStart().startsWith('<!--')) {
      flushParagraph();
      if (!line.trimEnd().endsWith('-->')) fail(`unterminated reader comment in ${documentationPath}`);
    } else {
      const renderedSyntax = renderedReaderSyntax(line);
      if (/<\/?[A-Za-z][^>]*>/.test(renderedSyntax)) fail(`raw HTML is forbidden in ${documentationPath}`);
      if (/]\((?:https?:)?\/\//.test(renderedSyntax)) fail(`unaudited external URL in ${documentationPath}`);
      paragraph.push(line);
    }
  }
  if (fence !== null) fail(`unterminated reader code fence in ${documentationPath}`);

  const declarations = blocks.map((block) => ({block_id: block.id, role: block.role}));
  if (JSON.stringify(declarations) !== JSON.stringify(shard.presentation_blocks)) {
    fail(`reader blocks do not match reviewed evidence for ${shard.unit_id}`);
  }
  const expectedNodes = new Map(
    shard.node_dispositions.map((node) => [`${node.block_id}\n${node.ast_path}`, node]),
  );
  if (expectedNodes.size !== parsedNodes.length) {
    fail(`reader node count does not match reviewed evidence for ${shard.unit_id}`);
  }
  for (const node of parsedNodes) {
    const expected = expectedNodes.get(`${node.blockId}\n${node.astPath}`);
    if (
      expected === undefined ||
      expected.node_kind !== node.kind ||
      expected.fragment_sha256 !== node.fragmentSha256
    ) {
      fail(`reader node binding is stale for ${shard.unit_id}: ${node.astPath}`);
    }
  }
  return {blocks, sha256: sha256(body)};
}

function decisionSection(markdown: string, sourcePath: string): string {
  const normalized = markdown.replace(/\r\n?/g, '\n');
  const lines = normalized.split('\n');
  const separators = lines.flatMap((line, index) => line === '---' ? [index] : []);
  if (separators.length < 2) fail(`${sourcePath} has no complete ADR frontmatter`);
  const body = lines.slice(separators[1] + 1);
  const heading = body.findIndex((line) => /^#\s+/.test(line));
  if (heading < 0) fail(`${sourcePath} has no ADR title heading`);
  return body.slice(heading + 1).join('\n').trim();
}

function parseDecisionNodes(
  root: string,
  release: PtoReleaseIdentity,
  sourcePath: string,
  markdown: string,
): PtoReaderNode[] {
  const body = decisionSection(markdown, sourcePath);
  const lines = body.split('\n');
  const nodes: PtoReaderNode[] = [];
  let paragraph: string[] = [];
  let fence: string[] | null = null;
  let fenceToken = '';
  let fenceLanguage: string | null = null;
  const inline = (value: string): PtoReaderInline[] =>
    parseReaderInline(root, release.commit, sourcePath, value, 'en', 'en');
  const flushParagraph = (): void => {
    if (paragraph.length === 0) return;
    nodes.push({kind: 'paragraph', children: inline(paragraph.join(' '))});
    paragraph = [];
  };

  for (const line of [...lines, '']) {
    if (fence !== null) {
      if (isCommonMarkFenceClose(line, fenceToken)) {
        nodes.push({kind: 'code-block', language: fenceLanguage, text: fence.join('\n')});
        fence = null;
        fenceToken = '';
        fenceLanguage = null;
      } else {
        fence.push(line);
      }
      continue;
    }
    if (/^(?:`{3,}|~{3,})/.test(line.trim())) {
      flushParagraph();
      const opening = line.trim().match(/^(`{3,}|~{3,})(.*)$/);
      if (opening === null) fail(`malformed Decision code fence in ${sourcePath}`);
      fenceToken = opening[1];
      fenceLanguage = opening[2].trim() || null;
      fence = [];
    } else if (/^\s*(?:[-*+] |\d+[.)] )/.test(line)) {
      flushParagraph();
      const ordered = /^\s*\d+[.)] /.test(line);
      const text = line.replace(/^\s*(?:[-*+] |\d+[.)] )/, '');
      nodes.push({kind: 'list-item', ordered, children: inline(text)});
    } else if (line.trimStart().startsWith('|') && line.trimEnd().endsWith('|')) {
      flushParagraph();
      if (!/^[\s|:=-]+$/.test(line)) {
        const cells = line.trim().replace(/^\||\|$/g, '').split('|').map((cell) => inline(cell.trim()));
        nodes.push({kind: 'table-row', cells});
      }
    } else if (!line.trim()) {
      flushParagraph();
    } else if (line.trimStart().startsWith('#')) {
      flushParagraph();
      const heading = line.match(/^\s*(#{2,6})\s+(.+)$/);
      if (heading === null) fail(`malformed Decision heading in ${sourcePath}`);
      nodes.push({kind: 'heading', level: heading[1].length, children: inline(heading[2])});
    } else if (line.trimStart().startsWith('<!--')) {
      flushParagraph();
      if (!line.trimEnd().endsWith('-->')) fail(`unterminated Decision comment in ${sourcePath}`);
    } else {
      const renderedSyntax = renderedReaderSyntax(line);
      if (/<\/?[A-Za-z][^>]*>/.test(renderedSyntax)) fail(`raw HTML is forbidden in ${sourcePath}`);
      paragraph.push(line);
    }
  }
  if (fence !== null) fail(`unterminated Decision code fence in ${sourcePath}`);
  return nodes;
}

function approvedReaderGuides(root: string): {
  acceptedEnglishUnits: Set<string>;
  acceptedTranslations: Map<string, string>;
} {
  const evidenceRoot = path.join(root, 'spec/evidence/mnemonic-descriptions');
  const acceptedEnglishUnits = new Set<string>();
  const reviewsPath = path.join(evidenceRoot, 'reviews');
  if (existsSync(reviewsPath)) {
    for (const file of readdirSync(reviewsPath).filter((name) => name.endsWith('.json')).sort()) {
      const review = readJson<ReviewBatch>(root, path.relative(root, path.join(reviewsPath, file)));
      if (review.verdict !== 'accepted') continue;
      for (const unitId of Object.keys(review.unit_risks)) {
        if (acceptedEnglishUnits.has(unitId)) fail(`duplicate accepted reader-guide review for ${unitId}`);
        acceptedEnglishUnits.add(unitId);
      }
    }
  }
  const acceptedTranslations = new Map<string, string>();
  const translationsPath = path.join(evidenceRoot, 'translation-reviews/zh-CN');
  if (existsSync(translationsPath)) {
    for (const file of readdirSync(translationsPath).filter((name) => name.endsWith('.json')).sort()) {
      const review = readJson<TranslationReviewBatch>(
        root,
        path.relative(root, path.join(translationsPath, file)),
      );
      if (review.verdict !== 'accepted') continue;
      for (const unitId of review.unit_ids) {
        if (acceptedTranslations.has(unitId)) fail(`duplicate accepted zh-CN review for ${unitId}`);
        const digest = review.translation_artifact_digests[unitId];
        if (typeof digest !== 'string') fail(`accepted zh-CN review lacks ${unitId} digest`);
        acceptedTranslations.set(unitId, digest);
      }
    }
  }
  return {acceptedEnglishUnits, acceptedTranslations};
}

function readerGuideProjection(
  root: string,
  release: PtoReleaseIdentity,
  unit: TraceabilityUnit,
  source: {path: string; sha256: string; githubUrl: string},
  englishMarkdown: string,
  englishDocumentationSha256: string,
  guideContext: ReaderGuideContext,
  ndfOwners: PtoReaderGuideOwnerLink[],
): {documentation: PtoDocumentationIdentity; readerGuide: PtoReaderGuide} {
  const target = unit.surface === 'arch' || unit.mnemonic !== null;
  const englishDocumentation: PtoDocumentationIdentity = {
    path: unit.documentation,
    sha256: englishDocumentationSha256,
    githubUrl: sourceUrl(release.commit, unit.documentation),
    locale: guideContext.locale,
    contentLocale: guideContext.defaultLocale,
    referenceRoute: referenceRoute(unit.documentation, guideContext.locale, guideContext.defaultLocale),
    localized: guideContext.locale === guideContext.defaultLocale,
  };
  const owners: PtoReaderGuideOwnerLink[] = [
    {id: unit.id, kind: 'asl', path: source.path, href: source.githubUrl},
    ...ndfOwners,
  ];
  if (!target) {
    return {
      documentation: englishDocumentation,
      readerGuide: {
        status: guideContext.locale === guideContext.defaultLocale ? 'pending' : 'fallback',
        target: false,
        locale: guideContext.locale,
        contentLocale: guideContext.defaultLocale,
        sha256: null,
        blocks: [],
        owners,
      },
    };
  }

  const shardPath = `spec/evidence/mnemonic-descriptions/${unit.surface}/${unit.id}.json`;
  const shard = readJson<ReaderGuideShard>(root, shardPath);
  if (
    shard.unit_id !== unit.id ||
    shard.owner.asl_path !== unit.source ||
    shard.owner.documentation_path !== unit.documentation
  ) {
    fail(`reader-guide shard owner is stale for ${unit.id}`);
  }
  const englishComplete = shard.status === 'complete';
  if (englishComplete && !guideContext.acceptedEnglishUnits.has(unit.id)) {
    fail(`complete reader guide lacks an accepted independent review: ${unit.id}`);
  }
  const englishGuide = englishComplete
    ? parseReaderGuide(
        root,
        release,
        unit.documentation,
        englishMarkdown,
        guideContext.defaultLocale,
        guideContext.defaultLocale,
        shard,
      )
    : null;

  if (guideContext.locale === guideContext.defaultLocale) {
    return {
      documentation: englishDocumentation,
      readerGuide: {
        status: englishComplete ? 'complete' : 'pending',
        target,
        locale: guideContext.locale,
        contentLocale: guideContext.defaultLocale,
        sha256: englishGuide?.sha256 ?? null,
        blocks: englishGuide?.blocks ?? [],
        owners,
      },
    };
  }

  const translationPath =
    `spec/evidence/mnemonic-descriptions/translations/zh-CN/${unit.surface}/${unit.id}.json`;
  const translation = readJson<TranslationShard>(root, translationPath);
  if (translation.unit_id !== unit.id) fail(`stale zh-CN translation identity for ${unit.id}`);
  if (translation.english_unit_shard_sha256 !== sha256(readText(root, shardPath))) {
    fail(`English reader-guide change stales zh-CN translation: ${unit.id}`);
  }
  if (translation.status !== 'complete') {
    return {
      documentation: englishDocumentation,
      readerGuide: {
        status: englishComplete ? 'fallback' : 'pending',
        target,
        locale: guideContext.locale,
        contentLocale: guideContext.defaultLocale,
        sha256: englishGuide?.sha256 ?? null,
        blocks: englishGuide?.blocks ?? [],
        owners,
      },
    };
  }
  if (!englishComplete || englishGuide === null) {
    fail(`complete zh-CN translation has no complete English guide: ${unit.id}`);
  }
  const englishBlockIds = shard.presentation_blocks.map((block) => block.block_id);
  const englishNodeIds = shard.node_dispositions.map((node) => node.node_id);
  const englishClaimIds = shard.atomic_claims.map((claim) => claim.claim_id);
  const mappedBlockIds = translation.block_mappings.map((mapping) => mapping.english_block_id);
  const mappedNodeIds = translation.node_mappings.map((mapping) => mapping.english_node_id);
  const mappedClaimIds = translation.claim_mappings.map((mapping) => mapping.english_claim_id);
  if (
    JSON.stringify(translation.english_block_ids) !== JSON.stringify(englishBlockIds) ||
    JSON.stringify(translation.english_node_ids) !== JSON.stringify(englishNodeIds) ||
    JSON.stringify(translation.english_claim_ids) !== JSON.stringify(englishClaimIds) ||
    new Set(mappedBlockIds).size !== englishBlockIds.length ||
    !englishBlockIds.every((id) => mappedBlockIds.includes(id)) ||
    new Set(translation.block_mappings.map((mapping) => mapping.locale_block_id)).size !==
      englishBlockIds.length ||
    new Set(mappedNodeIds).size !== englishNodeIds.length ||
    !englishNodeIds.every((id) => mappedNodeIds.includes(id)) ||
    new Set(translation.node_mappings.map((mapping) => mapping.locale_node_id)).size !==
      englishNodeIds.length ||
    new Set(mappedClaimIds).size !== englishClaimIds.length ||
    !englishClaimIds.every((id) => mappedClaimIds.includes(id)) ||
    !translation.claim_mappings.every((mapping) =>
      translation.node_mappings.some((node) => node.locale_node_id === mapping.locale_node_id),
    )
  ) {
    fail(`complete zh-CN translation mapping is not a strict bijection: ${unit.id}`);
  }
  const expectedLocalizedPath =
    `docs/site/i18n/zh-CN/docusaurus-plugin-content-docs-reference/current/${unit.documentation.slice('docs/'.length)}`;
  if (translation.locale_documentation_path !== expectedLocalizedPath) {
    fail(`zh-CN documentation path is stale for ${unit.id}`);
  }
  const localizedMarkdown = readText(root, expectedLocalizedPath);
  const localizedDocumentationSha256 = sha256(localizedMarkdown);
  const translationShardSha256 = sha256(readText(root, translationPath));
  if (guideContext.acceptedTranslations.get(unit.id) !== translationShardSha256) {
    fail(`complete zh-CN translation lacks a current accepted review: ${unit.id}`);
  }
  const localizedGuide = parseReaderGuide(
    root,
    release,
    expectedLocalizedPath,
    localizedMarkdown,
    guideContext.locale,
    guideContext.defaultLocale,
    {
      ...shard,
      presentation_blocks: shard.presentation_blocks.map((block) => ({
        block_id:
          translation.block_mappings.find((mapping) => mapping.english_block_id === block.block_id)
            ?.locale_block_id ?? block.block_id,
        role: block.role,
      })),
      node_dispositions: shard.node_dispositions.map((node) => {
        const mapping = translation.node_mappings.find(
          (candidate) => candidate.english_node_id === node.node_id,
        );
        if (mapping === undefined) fail(`zh-CN node mapping is incomplete for ${unit.id}`);
        return {
          ...node,
          fragment_sha256: mapping.locale_fragment_sha256,
          block_id:
            translation.block_mappings.find((candidate) => candidate.english_block_id === node.block_id)
              ?.locale_block_id ?? node.block_id,
        };
      }),
    },
    unit.documentation,
  );
  if (translation.locale_guide_sha256 !== localizedGuide.sha256) {
    fail(`zh-CN supplementary guide hash is stale for ${unit.id}`);
  }
  const documentation: PtoDocumentationIdentity = {
    path: expectedLocalizedPath,
    sha256: localizedDocumentationSha256,
    githubUrl: sourceUrl(release.commit, expectedLocalizedPath),
    locale: guideContext.locale,
    contentLocale: guideContext.locale,
    referenceRoute: referenceRoute(unit.documentation, guideContext.locale, guideContext.defaultLocale),
    localized: true,
  };
  return {
    documentation,
    readerGuide: {
      status: 'complete',
      target,
      locale: guideContext.locale,
      contentLocale: guideContext.locale,
      sha256: localizedGuide.sha256,
      blocks: localizedGuide.blocks,
      owners,
    },
  };
}

function parseUnitMetadata(
  source: string,
  sourcePath: string,
): Record<string, PtoJsonValue> {
  const payload = source.match(/^\/\/ PTO-(?:INSTRUCTION|UNIT): (.+)$/m)?.[1];
  if (payload === undefined) {
    fail(`${sourcePath} has no PTO-INSTRUCTION or PTO-UNIT metadata`);
  }
  try {
    return JSON.parse(payload) as Record<string, PtoJsonValue>;
  } catch (error) {
    fail(`invalid unit metadata in ${sourcePath}: ${String(error)}`);
  }
}

interface SiteInstructionProjection {
  schema: string;
  unitId: string;
  ownerSource: string;
  ownerSourceSha256: string;
  composition?: unknown;
  semanticExecution?: unknown;
}

function loadSiteInstructionProjection(
  root: string,
  unit: TraceabilityUnit,
  ownerSourceText: string,
): {path: string; data: SiteInstructionProjection} | null {
  const projectionPath = `docs/site/data/instruction-projections/${unit.id}.json`;
  if (!existsSync(path.join(root, projectionPath))) return null;
  const data = readJson<SiteInstructionProjection>(root, projectionPath);
  if (
    data.schema !== 'pto.site-instruction-projection.v1' ||
    data.unitId !== unit.id ||
    data.ownerSource !== unit.source ||
    data.ownerSourceSha256 !== sha256(ownerSourceText)
  ) {
    fail(`${projectionPath} is stale or bound to the wrong owner`);
  }
  return {path: projectionPath, data};
}

function parseInstructionComposition(
  value: unknown,
  sourcePath: string,
  unitId: string,
  traceability: TraceabilityData,
  release: PtoReleaseIdentity,
): PtoInstructionComposition | null {
  if (value === undefined || value === null) return null;
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    fail(`${sourcePath} PTO-PAGE-COMPOSITION must be an object`);
  }
  const composition = value as PtoInstructionComposition;
  if (composition.owner !== unitId || !Array.isArray(composition.variants) || composition.variants.length === 0) {
    fail(`${sourcePath} PTO-PAGE-COMPOSITION owner or variants are invalid`);
  }
  const localized = (candidate: unknown, field: string): void => {
    if (
      candidate === null ||
      typeof candidate !== 'object' ||
      Array.isArray(candidate) ||
      typeof (candidate as Record<string, unknown>).en !== 'string' ||
      typeof (candidate as Record<string, unknown>)['zh-CN'] !== 'string' ||
      !(candidate as Record<string, string>).en.trim() ||
      !(candidate as Record<string, string>)['zh-CN'].trim()
    ) {
      fail(`${sourcePath} PTO-PAGE-COMPOSITION ${field} must contain en and zh-CN`);
    }
  };
  const commandUnits = new Map(
    traceability.units
      .filter((candidate) => candidate.mnemonic !== null)
      .map((candidate) => [candidate.mnemonic!, candidate]),
  );
  for (const variant of composition.variants) {
    if (
      typeof variant.id !== 'string' ||
      !Number.isInteger(variant.canonicalMinCommands) ||
      !Number.isInteger(variant.canonicalMaxCommands) ||
      variant.canonicalMinCommands < 1 ||
      variant.canonicalMaxCommands < variant.canonicalMinCommands ||
      !Array.isArray(variant.minimumSequence) ||
      variant.minimumSequence.length !== variant.canonicalMinCommands ||
      !Array.isArray(variant.completeSequence) ||
      variant.completeSequence.length !== variant.canonicalMaxCommands ||
      !Array.isArray(variant.relationships) ||
      !Array.isArray(variant.commands) ||
      variant.commands.length === 0
    ) {
      fail(`${sourcePath} has an invalid PTO-PAGE-COMPOSITION variant`);
    }
    localized(variant.label, `${variant.id}.label`);
    localized(variant.summary, `${variant.id}.summary`);
    localized(variant.canonicalCommandCount, `${variant.id}.canonicalCommandCount`);
    variant.relationships.forEach((relationship, index) =>
      localized(relationship, `${variant.id}.relationships[${index}]`));
    for (const command of variant.commands) {
      if (
        typeof command.mnemonic !== 'string' ||
        !Number.isInteger(command.minOccurrences) ||
        !Number.isInteger(command.maxOccurrences) ||
        command.minOccurrences < 0 ||
        command.maxOccurrences < command.minOccurrences ||
        typeof command.repeatable !== 'boolean' ||
        command.repeatable !== (command.maxOccurrences > 1) ||
        !['required', 'optional', 'conditional', 'forbidden'].includes(command.requirement) ||
        !Array.isArray(command.parameters)
      ) {
        fail(`${sourcePath} has an invalid PTO-PAGE-COMPOSITION command`);
      }
      localized(command.role, `${variant.id}.${command.mnemonic}.role`);
      for (const [index, parameter] of command.parameters.entries()) {
        if (typeof parameter.name !== 'string' || !parameter.name.trim()) {
          fail(`${sourcePath} has an invalid ${variant.id}.${command.mnemonic} parameter`);
        }
        localized(parameter.meaning, `${variant.id}.${command.mnemonic}.parameters[${index}].meaning`);
        if (parameter.omission !== undefined) {
          localized(parameter.omission, `${variant.id}.${command.mnemonic}.parameters[${index}].omission`);
        }
      }
      const referenceUnit = commandUnits.get(command.mnemonic);
      if (referenceUnit === undefined) {
        fail(`${sourcePath} composition command has no owning unit: ${command.mnemonic}`);
      }
      command.reference = {
        id: referenceUnit.id,
        route: unitRoute(referenceUnit),
        sourcePath: referenceUnit.source,
        sourceUrl: sourceUrl(release.commit, referenceUnit.source),
      };
    }
    const sequenceLines = [...variant.minimumSequence, ...variant.completeSequence];
    for (const line of sequenceLines) {
      if (
        typeof line !== 'string' ||
        !variant.commands.some((command) =>
          line === command.mnemonic || line.startsWith(`${command.mnemonic} `))
      ) {
        fail(`${sourcePath} has an unowned ${variant.id} sequence line: ${String(line)}`);
      }
    }
  }
  return composition;
}

function parseSemanticExecution(
  root: string,
  release: PtoReleaseIdentity,
  source: string,
  sourcePath: string,
  unitId: string,
): unknown {
  const matches = [...source.matchAll(
    /^\/\/ PTO-PAGE-SEMANTICS-BEGIN\s*$\n([\s\S]*?)^\/\/ PTO-PAGE-SEMANTICS-END\s*$/gm,
  )];
  if (matches.length === 0) return null;
  if (matches.length !== 1) fail(`${sourcePath} has duplicate PTO-PAGE-SEMANTICS metadata`);
  let raw: unknown;
  try {
    raw = JSON.parse(
      matches[0][1]
        .split(/\r?\n/)
        .map((line) => line.replace(/^\/\/(?: )?/, ''))
        .join('\n'),
    );
  } catch (error) {
    fail(`invalid PTO-PAGE-SEMANTICS metadata in ${sourcePath}: ${String(error)}`);
  }
  if (raw === null || typeof raw !== 'object' || Array.isArray(raw)) {
    fail(`${sourcePath} PTO-PAGE-SEMANTICS must be an object`);
  }
  const metadata = raw as Record<string, unknown>;
  if (metadata.owner !== unitId || !Array.isArray(metadata.stages) || metadata.stages.length === 0) {
    fail(`${sourcePath} PTO-PAGE-SEMANTICS owner or stages are invalid`);
  }
  const localized = (candidate: unknown, field: string): {en: string; 'zh-CN': string} => {
    if (
      candidate === null ||
      typeof candidate !== 'object' ||
      Array.isArray(candidate) ||
      typeof (candidate as Record<string, unknown>).en !== 'string' ||
      typeof (candidate as Record<string, unknown>)['zh-CN'] !== 'string'
    ) {
      fail(`${sourcePath} PTO-PAGE-SEMANTICS ${field} must contain en and zh-CN`);
    }
    return candidate as {en: string; 'zh-CN': string};
  };
  const region = (
    exactSourcePath: string,
    exactSource: string,
    regionName: string,
    marker: 'DOC' | 'PTO-SITE-REGION',
    id: string,
    label: {en: string; 'zh-CN': string},
    purpose: {en: string; 'zh-CN': string},
  ) => {
    if (!exactSourcePath.startsWith('asl/')) {
      fail(`${sourcePath} semantic region escapes ASL owners: ${exactSourcePath}`);
    }
    const begin = `// ${marker}-BEGIN: ${regionName}`;
    const end = `// ${marker}-END: ${regionName}`;
    const lines = exactSource.replace(/\r\n?/g, '\n').split('\n');
    const starts = lines.flatMap((line, index) => line.trim() === begin ? [index] : []);
    const finishes = lines.flatMap((line, index) => line.trim() === end ? [index] : []);
    if (starts.length !== 1 || finishes.length !== 1 || finishes[0] <= starts[0]) {
      fail(`${exactSourcePath} must contain one ordered ${marker} region ${regionName}`);
    }
    const text = lines.slice(starts[0] + 1, finishes[0]).join('\n');
    return {
      id,
      label,
      purpose,
      sourcePath: exactSourcePath,
      sourceUrl: sourceUrl(release.commit, exactSourcePath, starts[0] + 2, finishes[0]),
      sourceSha256: sha256(exactSource),
      fragmentSha256: sha256(text),
      startLine: starts[0] + 2,
      endLine: finishes[0],
      text,
    };
  };

  return {
    owner: unitId,
    stages: metadata.stages.map((stageValue, stageIndex) => {
      if (stageValue === null || typeof stageValue !== 'object' || Array.isArray(stageValue)) {
        fail(`${sourcePath} has invalid semantic stage ${stageIndex}`);
      }
      const stage = stageValue as Record<string, unknown>;
      if (
        typeof stage.id !== 'string' ||
        typeof stage.ownerRegion !== 'string' ||
        !Array.isArray(stage.sharedRegions)
      ) {
        fail(`${sourcePath} has invalid semantic stage ${stageIndex}`);
      }
      const label = localized(stage.label, `${stage.id}.label`);
      const summary = localized(stage.summary, `${stage.id}.summary`);
      return {
        id: stage.id,
        label,
        summary,
        ownerRegion: region(
          sourcePath,
          source,
          stage.ownerRegion,
          'DOC',
          `${stage.id}-owner`,
          label,
          summary,
        ),
        sharedRegions: stage.sharedRegions.map((sharedValue, sharedIndex) => {
          if (sharedValue === null || typeof sharedValue !== 'object' || Array.isArray(sharedValue)) {
            fail(`${sourcePath} has invalid ${stage.id} shared region ${sharedIndex}`);
          }
          const shared = sharedValue as Record<string, unknown>;
          if (typeof shared.sourcePath !== 'string' || typeof shared.region !== 'string') {
            fail(`${sourcePath} has invalid ${stage.id} shared region ${sharedIndex}`);
          }
          const sharedSource = readText(root, shared.sourcePath);
          return region(
            shared.sourcePath,
            sharedSource,
            shared.region,
            'PTO-SITE-REGION',
            `${stage.id}-shared-${sharedIndex + 1}`,
            localized(shared.label, `${stage.id}.shared[${sharedIndex}].label`),
            localized(shared.purpose, `${stage.id}.shared[${sharedIndex}].purpose`),
          );
        }),
      };
    }),
  };
}

function extractAslFunctionRegion(
  release: PtoReleaseIdentity,
  sourcePath: string,
  sourceText: string,
  symbol: string,
  id: string,
  label: {en: string; 'zh-CN': string},
  purpose: {en: string; 'zh-CN': string},
) {
  const lines = sourceText.replace(/\r\n?/g, '\n').split('\n');
  const declaration = new RegExp(`^(?:(?:pure|readonly|impdef) )?func ${symbol.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\b`);
  const starts = lines.flatMap((line, index) => declaration.test(line) ? [index] : []);
  if (starts.length !== 1) {
    fail(`${sourcePath} must define exactly one top-level function ${symbol}`);
  }
  const nextFunction = /^(?:(?:pure|readonly|impdef) )?func [A-Za-z_][A-Za-z0-9_]*\b/;
  let end = lines.findIndex((line, index) => index > starts[0] && nextFunction.test(line));
  if (end < 0) end = lines.length;
  while (end > starts[0] + 1 && !lines[end - 1].trim()) end -= 1;
  const text = lines.slice(starts[0], end).join('\n');
  return {
    id,
    label,
    purpose,
    sourcePath,
    sourceUrl: sourceUrl(release.commit, sourcePath, starts[0] + 1, end),
    sourceSha256: sha256(sourceText),
    fragmentSha256: sha256(text),
    startLine: starts[0] + 1,
    endLine: end,
    text,
  };
}

function parseSemanticExecutionProjection(
  root: string,
  release: PtoReleaseIdentity,
  raw: unknown,
  projectionPath: string,
  unit: TraceabilityUnit,
  ownerSourceText: string,
): PtoSemanticExecution | null {
  if (raw === undefined || raw === null) return null;
  if (typeof raw !== 'object' || Array.isArray(raw)) {
    fail(`${projectionPath} semanticExecution must be an object`);
  }
  const metadata = raw as Record<string, unknown>;
  if (metadata.owner !== unit.id || !Array.isArray(metadata.stages) || metadata.stages.length === 0) {
    fail(`${projectionPath} semanticExecution owner or stages are invalid`);
  }
  const localized = (candidate: unknown, field: string): {en: string; 'zh-CN': string} => {
    if (
      candidate === null || typeof candidate !== 'object' || Array.isArray(candidate) ||
      typeof (candidate as Record<string, unknown>).en !== 'string' ||
      typeof (candidate as Record<string, unknown>)['zh-CN'] !== 'string'
    ) fail(`${projectionPath} ${field} must contain en and zh-CN`);
    return candidate as {en: string; 'zh-CN': string};
  };
  const combineRegions = (
    regions: ReturnType<typeof extractAslFunctionRegion>[],
    id: string,
    label: {en: string; 'zh-CN': string},
    purpose: {en: string; 'zh-CN': string},
  ) => {
    if (regions.length === 0) fail(`${projectionPath} region ${id} has no symbols`);
    const sourcePath = regions[0].sourcePath;
    if (!regions.every((region) =>
      region.sourcePath === sourcePath &&
      region.sourceSha256 === regions[0].sourceSha256)) {
      fail(`${projectionPath} region ${id} mixes source owners`);
    }
    const text = regions.map((region) => region.text).join('\n\n');
    const startLine = Math.min(...regions.map((region) => region.startLine));
    const endLine = Math.max(...regions.map((region) => region.endLine));
    return {
      id,
      label,
      purpose,
      sourcePath,
      sourceUrl: sourceUrl(release.commit, sourcePath, startLine, endLine),
      sourceSha256: regions[0].sourceSha256,
      fragmentSha256: sha256(text),
      startLine,
      endLine,
      text,
    };
  };
  return {
    owner: unit.id,
    stages: metadata.stages.map((stageValue, stageIndex) => {
      if (stageValue === null || typeof stageValue !== 'object' || Array.isArray(stageValue)) {
        fail(`${projectionPath} has invalid semantic stage ${stageIndex}`);
      }
      const stage = stageValue as Record<string, unknown>;
      if (
        typeof stage.id !== 'string' ||
        !['complete', 'source-gap'].includes(String(stage.status)) ||
        !Array.isArray(stage.facts) ||
        !Array.isArray(stage.ownerSymbols) ||
        !Array.isArray(stage.sharedRegions)
      ) fail(`${projectionPath} has invalid semantic stage ${stageIndex}`);
      const label = localized(stage.label, `${stage.id}.label`);
      const summary = localized(stage.summary, `${stage.id}.summary`);
      const status = stage.status as 'complete' | 'source-gap';
      const gap = stage.gap === null || stage.gap === undefined
        ? undefined
        : localized(stage.gap, `${stage.id}.gap`);
      if ((status === 'source-gap') !== (gap !== undefined)) {
        fail(`${projectionPath} ${stage.id} gap status is inconsistent`);
      }
      const facts = stage.facts.map((factValue, factIndex) => {
        if (factValue === null || typeof factValue !== 'object' || Array.isArray(factValue)) {
          fail(`${projectionPath} has invalid ${stage.id} fact ${factIndex}`);
        }
        const fact = factValue as Record<string, unknown>;
        if (
          !['inputs', 'checks', 'faults', 'reads', 'writes', 'commit'].includes(String(fact.kind)) ||
          !Array.isArray(fact.items) || fact.items.length === 0
        ) fail(`${projectionPath} has invalid ${stage.id} fact ${factIndex}`);
        return {
          kind: fact.kind as 'inputs' | 'checks' | 'faults' | 'reads' | 'writes' | 'commit',
          label: localized(fact.label, `${stage.id}.facts[${factIndex}].label`),
          items: fact.items.map((item, itemIndex) =>
            localized(item, `${stage.id}.facts[${factIndex}].items[${itemIndex}]`)),
        };
      });
      const ownerSymbols = stage.ownerSymbols.map((symbol) => {
        if (typeof symbol !== 'string') fail(`${projectionPath} has invalid owner symbol`);
        return extractAslFunctionRegion(
          release, unit.source, ownerSourceText, symbol,
          `${stage.id}-owner-symbol-${symbol}`, label, summary,
        );
      });
      const ownerRegions = ownerSymbols.length === 0 ? [] : [
        combineRegions(ownerSymbols, `${stage.id}-owner`, label, summary),
      ];
      const sharedRegions = stage.sharedRegions.map((sharedValue, sharedIndex) => {
        if (sharedValue === null || typeof sharedValue !== 'object' || Array.isArray(sharedValue)) {
          fail(`${projectionPath} has invalid shared region`);
        }
        const shared = sharedValue as Record<string, unknown>;
        if (typeof shared.sourcePath !== 'string' || !shared.sourcePath.startsWith('asl/') || !Array.isArray(shared.symbols)) {
          fail(`${projectionPath} shared source is invalid or outside ASL`);
        }
        const sharedSource = readText(root, shared.sourcePath);
        const sharedLabel = localized(shared.label, `${stage.id}.shared[${sharedIndex}].label`);
        const purpose = localized(shared.purpose, `${stage.id}.shared[${sharedIndex}].purpose`);
        const regions = shared.symbols.map((symbol) => {
          if (typeof symbol !== 'string') fail(`${projectionPath} has invalid shared symbol`);
          return extractAslFunctionRegion(
            release, shared.sourcePath as string, sharedSource, symbol,
            `${stage.id}-shared-symbol-${sharedIndex + 1}-${symbol}`,
            sharedLabel, purpose,
          );
        });
        return combineRegions(
          regions,
          `${stage.id}-shared-${sharedIndex + 1}`,
          sharedLabel,
          purpose,
        );
      });
      if (ownerRegions.length === 0 && sharedRegions.length === 0) {
        fail(`${projectionPath} stage ${stage.id} has no exact source region`);
      }
      return {id: stage.id, label, summary, status, ...(gap ? {gap} : {}), facts, ownerRegions, sharedRegions};
    }),
  };
}

function ndfIdentity(id: string, unit?: TraceabilityUnit): PtoSemanticIdentity {
  const facets: PtoSemanticIdentity['facets'] = [];
  if (unit !== undefined) {
    facets.push({role: 'surface', label: unit.surface.toLocaleUpperCase('en-US')});
    facets.push({role: 'owner', label: unit.mnemonic ?? unit.id});
    const ownerSlug = (unit.mnemonic ?? unit.id)
      .toLocaleUpperCase('en-US')
      .replace(/[^A-Z0-9]+/g, '-');
    const instructionPrefix = `PTO-INST-${unit.surface.toLocaleUpperCase('en-US')}-${ownerSlug}`;
    const ownerPrefix = `PTO-${ownerSlug}-`;
    let remainder = id === instructionPrefix ? 'INSTRUCTION' :
      id.startsWith(ownerPrefix) ? id.slice(ownerPrefix.length) : id.slice('PTO-'.length);
    const caseMatch = remainder.match(/-(\d{3})$/);
    if (caseMatch !== null) remainder = remainder.slice(0, -caseMatch[0].length);
    facets.push({role: 'category', label: remainder});
    if (caseMatch !== null) facets.push({role: 'case', label: caseMatch[1]});
  } else {
    facets.push({role: 'category', label: id.slice('PTO-'.length)});
  }
  return {fullId: id, kind: 'ndf', anchor: `ndf-${id.toLocaleLowerCase('en-US')}`, facets};
}

function parseNdfClauses(
  source: string,
  sourcePath: string,
  release?: PtoReleaseIdentity,
  unit?: TraceabilityUnit,
  supplements?: Map<string, NdfSupplement>,
): PtoNdfClause[] {
  const lines = source.split(/\r?\n/);
  const clauses: PtoNdfClause[] = [];

  for (let index = 0; index < lines.length; index += 1) {
    const begin = lines[index].match(/^\/\/ NDF-BEGIN: (\S+)$/);
    if (begin === null) continue;

    const id = begin[1];
    const metadataLine = lines[index + 1] ?? '';
    const metadata = metadataLine.match(
      /^\/\/ ndf: kind=(\S+) level=(\S+) layer=(\S+) status=(\S+)$/,
    );
    if (metadata === null) {
      fail(`invalid NDF metadata for ${id} in ${sourcePath}`);
    }

    const body: string[] = [];
    let endIndex = index + 2;
    while (
      endIndex < lines.length &&
      lines[endIndex] !== `// NDF-END: ${id}`
    ) {
      const bodyLine = lines[endIndex].match(/^\/\/(?: (.*))?$/);
      if (bodyLine === null) {
        fail(`non-comment content inside NDF clause ${id}`);
      }
      body.push(bodyLine[1] ?? '');
      endIndex += 1;
    }
    if (endIndex === lines.length) {
      fail(`unterminated NDF clause ${id}`);
    }

    const text = body.join('\n');
    const supplement = supplements?.get(id);
    if (supplements !== undefined && supplement === undefined) {
      fail(`missing bilingual NDF supplement for ${id}`);
    }
    clauses.push({
      id,
      title: supplement?.title ?? {en: id, 'zh-CN': id},
      summary: supplement?.summary ?? {en: text, 'zh-CN': text},
      kind: metadata[1],
      level: metadata[2],
      layer: metadata[3],
      status: metadata[4],
      text,
      sourcePath,
      startLine: index + 1,
      endLine: endIndex + 1,
      sourceSha256: sha256(source),
      clauseSha256: sha256(text),
      githubUrl: release === undefined
        ? ''
        : sourceUrl(release.commit, sourcePath, index + 1, endIndex + 1),
      affectedUnits: unit === undefined ? [] : [unit.id],
      identity: ndfIdentity(id, unit),
    });
    index = endIndex;
  }

  return clauses;
}

function loadNdfSupplements(root: string): Map<string, NdfSupplement> {
  const directory = path.join(root, 'docs/ndf/supplements');
  const result = new Map<string, NdfSupplement>();
  for (const name of readdirSync(directory).filter((value) => value.endsWith('.json')).sort()) {
    const document = readJson<{
      schema: string;
      non_normative: boolean;
      entries: NdfSupplement[];
    }>(root, `docs/ndf/supplements/${name}`);
    if (document.schema !== 'pto.ndf-supplements.v1' || document.non_normative !== true) {
      fail(`invalid NDF supplement document ${name}`);
    }
    for (const entry of document.entries) {
      if (result.has(entry.id)) fail(`duplicate bilingual NDF supplement ${entry.id}`);
      result.set(entry.id, entry);
    }
  }
  return result;
}

function requirementSourceIndex(
  root: string,
  release: PtoReleaseIdentity,
  traceability: TraceabilityData,
): Map<string, RequirementSourceIdentity> {
  const explicit = new Map<string, PtoNdfClause>();
  const sourceTexts = new Map<string, string>();
  const instructionOwners = new Map<string, string>();
  for (const unit of traceability.units) {
    const instructionClause = unit.instruction_contract?.ndf_clause;
    if (typeof instructionClause !== 'string') continue;
    if (instructionOwners.has(instructionClause)) {
      fail(`duplicate instruction-contract NDF identity ${instructionClause}`);
    }
    instructionOwners.set(instructionClause, unit.source);
  }
  for (const [sourcePath, expectedSha] of Object.entries(traceability.sources)) {
    if (!sourcePath.startsWith('asl/')) continue;
    const source = readText(root, sourcePath);
    if (sha256(source) !== expectedSha) {
      fail(`traceability source hash mismatch for ${sourcePath}`);
    }
    sourceTexts.set(sourcePath, source);
    for (const clause of parseNdfClauses(source, sourcePath)) {
      const existing = explicit.get(clause.id);
      if (existing !== undefined) {
        fail(
          `duplicate NDF clause ${clause.id}: ${existing.sourcePath}:${existing.startLine} and ${clause.sourcePath}:${clause.startLine}`,
        );
      }
      explicit.set(clause.id, clause);
    }
  }

  const result = new Map<string, RequirementSourceIdentity>();
  for (const requirement of traceability.requirements) {
    const clause = explicit.get(requirement.id);
    const instructionOwner = instructionOwners.get(requirement.id);
    if (clause === undefined && instructionOwner === undefined) {
      fail(
        `requirement ${requirement.id} has neither an NDF region nor an instruction-contract identity`,
      );
    }
    const sourcePath = clause?.sourcePath ?? instructionOwner;
    if (sourcePath === undefined || !requirement.owners.includes(sourcePath)) {
      fail(`requirement ${requirement.id} has no exact owning ASL source`);
    }
    const source = sourceTexts.get(sourcePath);
    const sourceSha256 = traceability.sources[sourcePath];
    if (source === undefined || sourceSha256 === undefined) {
      fail(`requirement ${requirement.id} owner ${sourcePath} is not hashed`);
    }
    const startLine = clause?.startLine ?? 1;
    const endLine = clause?.endLine ?? 1;
    const sourceLines = source.split(/\r?\n/).slice(startLine - 1, endLine);
    result.set(requirement.id, {
      sourcePath,
      sourceSha256,
      clauseSha256: sha256(sourceLines.join('\n')),
      startLine,
      endLine,
      sourceUrl: sourceUrl(release.commit, sourcePath, startLine, endLine),
    });
  }
  return result;
}

function parseTestMetadata(source: string, testPath: string): Record<string, PtoJsonValue> {
  const payload = source.match(/^\/\/ PTO-TEST: (.+)$/m)?.[1];
  if (payload === undefined) fail(`${testPath} has no PTO-TEST metadata`);
  try {
    return JSON.parse(payload) as Record<string, PtoJsonValue>;
  } catch (error) {
    fail(`invalid PTO-TEST metadata in ${testPath}: ${String(error)}`);
  }
}

function stringValue(
  record: Record<string, PtoJsonValue>,
  key: string,
): string | null {
  const value = record[key];
  return typeof value === 'string' ? value : null;
}

function instructionTests(
  root: string,
  commit: string,
  traceability: TraceabilityData,
  testIds: Set<string>,
): PtoTestEvidence[] {
  const unitBySource = new Map(traceability.units.map((unit) => [unit.source, unit]));
  return traceability.tests
    .filter((test) => testIds.has(test.id))
    .sort((left, right) => left.id.localeCompare(right.id))
    .map((test) => {
      if (!test.path.startsWith('tests/asl/')) {
        fail(`unit evidence is outside tests/asl: ${test.path}`);
      }
      const sourceText = readText(root, test.path);
      const digest = sha256(sourceText);
      if (digest !== test.sha256) {
        fail(`traceability hash mismatch for ${test.path}`);
      }
      const metadata = parseTestMetadata(sourceText, test.path);
      if (stringValue(metadata, 'id') !== test.id) {
        fail(`test ID mismatch for ${test.path}`);
      }
      if (stringValue(metadata, 'source') !== test.source) {
        fail(`test source mismatch for ${test.path}`);
      }
      const owner = unitBySource.get(test.source);
      if (owner === undefined) fail(`test source has no owning unit: ${test.source}`);
      const caseMatch = test.id.match(/-(\d{3})$/);
      if (caseMatch === null) fail(`AVS identity has no case index: ${test.id}`);
      const identity: PtoSemanticIdentity = {
        fullId: test.id,
        kind: 'avs',
        anchor: `avs-${test.id.toLocaleLowerCase('en-US')}`,
        facets: [
          {role: 'surface', label: owner.surface.toLocaleUpperCase('en-US')},
          {role: 'owner', label: owner.mnemonic ?? owner.id},
          {role: 'category', label: test.kind.toLocaleUpperCase('en-US')},
          {role: 'case', label: caseMatch[1]},
        ],
      };
      return {
        ...test,
        summary: stringValue(metadata, 'summary'),
        passCondition: stringValue(metadata, 'pass_condition'),
        sourceText,
        sourceAssetUrl: `/evidence/test-sources/${digest}.asl`,
        githubUrl: sourceUrl(commit, test.path),
        identity,
        ownerId: owner.id,
        ownerMnemonic: owner.mnemonic,
        surface: owner.surface,
      };
    });
}

interface PtoCatalogs {
  commandForms: Record<string, PtoJsonValue>[];
  scalarForms: Record<string, PtoJsonValue>[];
  tileOperations: Record<string, PtoJsonValue>[];
}

function architectureGuide(
  context: LoadContext,
  release: PtoReleaseIdentity,
  units: Array<{data: PtoUnitWorkbenchData; route: string}>,
): PtoArchitectureGuide {
  const locale = context.i18n.currentLocale;
  const chinese = locale === 'zh-CN';
  const unitsById = new Map(
    units.map((unit) => [String(unit.data.unit.id ?? unit.data.metadata.id), unit]),
  );
  const owner = (
    id: string,
    label: string,
    includeGuide: boolean,
  ): PtoArchitectureOwnerProjection => {
    const unit = unitsById.get(id);
    if (unit === undefined) fail(`architecture landing references missing unit ${id}`);
    const guide = unit.data.readerGuide;
    if (guide.blocks.length === 0) {
      fail(`architecture landing owner has no reviewed reader guide: ${id}`);
    }
    if (locale !== context.i18n.defaultLocale && guide.contentLocale !== locale) {
      fail(`architecture landing owner lacks ${locale} projection: ${id}`);
    }
    if (guide.sha256 === null) {
      fail(`architecture landing owner has no reviewed guide hash: ${id}`);
    }
    const blocks = includeGuide
      ? guide.blocks.filter((block) => block.role !== 'example-usage')
      : [];
    if (includeGuide && blocks.length === 0) {
      fail(`architecture landing owner has no reader-facing contract blocks: ${id}`);
    }
    return {
      id,
      label,
      route: localizedRoute(context, unit.route),
      referenceRoute: unit.data.documentation.referenceRoute,
      sourcePath: unit.data.source.path,
      sourceSha256: unit.data.source.sha256,
      sourceUrl: unit.data.source.githubUrl,
      guideStatus: guide.status,
      guideSha256: guide.sha256,
      contentLocale: guide.contentLocale,
      blocks,
    };
  };
  const boundBlock = (
    id: string,
    role: PtoReaderGuideRole,
  ) => {
    const unit = unitsById.get(id);
    if (unit === undefined) fail(`architecture block binding references missing unit ${id}`);
    const guide = unit.data.readerGuide;
    if (guide.sha256 === null) fail(`architecture block binding has no guide hash: ${id}`);
    const matches = guide.blocks.filter((block) => block.role === role);
    if (matches.length !== 1) {
      fail(`architecture block binding ${id}/${role} resolves ${matches.length} blocks`);
    }
    return {
      ownerId: id,
      sourcePath: unit.data.source.path,
      sourceSha256: unit.data.source.sha256,
      guideSha256: guide.sha256,
      block: matches[0],
    };
  };
  const entry = owner(
    ARCHITECTURE_ENTRY,
    chinese ? '架构所有者' : 'Architecture owner',
    true,
  );
  return {
    schema: 'pto.site-architecture-guide.v1',
    locale,
    release,
    entry,
    topics: ARCHITECTURE_TOPICS.map((topic) => ({
      id: topic.id,
      label: chinese ? topic.label['zh-CN'] : topic.label.en,
      scenario: boundBlock(topic.primary, 'example-usage'),
      sourceBoundary: topic.boundaryOwner === undefined
        ? null
        : boundBlock(topic.boundaryOwner, 'boundaries'),
      primary: owner(
        topic.primary,
        chinese ? topic.label['zh-CN'] : topic.label.en,
        true,
      ),
      related: topic.related.map((related) => owner(
        related.id,
        chinese ? related.label['zh-CN'] : related.label.en,
        false,
      )),
    })),
  };
}

function highLevelAssembly(
  unit: TraceabilityUnit,
  metadata: Record<string, PtoJsonValue>,
): PtoHighLevelAssembly | null {
  if (unit.surface !== 'tile' || unit.mnemonic === null) return null;
  const contractValue = metadata.contract;
  if (contractValue === null || typeof contractValue !== 'object' || Array.isArray(contractValue)) {
    fail(`${unit.id} has no contract for high-level Tile assembly`);
  }
  const contract = contractValue as Record<string, PtoJsonValue>;
  const contractBlockLines = (Array.isArray(contract.block_composition) ? contract.block_composition : [])
    .filter((value): value is string => typeof value === 'string');
  const metadataBlockLines = (Array.isArray(metadata.block) ? metadata.block : [])
    .filter((value): value is string => typeof value === 'string');
  const blockLines = [...new Set([...contractBlockLines, ...metadataBlockLines])];
  if (blockLines.length === 0) fail(`${unit.id} has no block composition for high-level Tile assembly`);
  const parameters: PtoHighLevelAssembly['parameters'] = [];
  const seenParameters = new Set<string>();
  const addParameter = (display: string, source: string, role: string): void => {
    if (seenParameters.has(display)) return;
    seenParameters.add(display);
    parameters.push({display, source, role});
  };
  const dimensionBindings = new Map<string, {semantic: string | null; source: string}>();
  for (const line of blockLines.filter((value) => value.startsWith('B.DIM'))) {
    const body = line.slice('B.DIM'.length).trim();
    const compact = body.match(
      /^LB([0-2])\/([A-Za-z][A-Za-z0-9_]*),\s*LB([0-2])\/([A-Za-z][A-Za-z0-9_]*),\s*LB([0-2])\/([A-Za-z][A-Za-z0-9_]*)(?:\s+\([^)]*\))?$/,
    );
    const compactAssigned = body.match(
      /^LB([0-2])\s*=\s*([A-Za-z][A-Za-z0-9_]*),\s*LB([0-2])\s*=\s*([A-Za-z][A-Za-z0-9_]*),\s*LB([0-2])\s*=\s*([A-Za-z][A-Za-z0-9_]*)(?:\s+\([^)]*\))?$/,
    );
    const single = body.match(
      /^LB([0-2])(?:\s*=\s*|\s+)([A-Za-z][A-Za-z0-9_]*)(?:\s+or\s+cooperative\s+group_M)?(?:\s+\([^)]*\))?$/,
    );
    const groupedBare = body.match(
      /^LB([0-2])\/LB([0-2])\/LB([0-2])(?:\s+\(optional\))?$/,
    );
    const bare = body.match(/^LB([0-2])(?:\s+\(optional\))?$/);
    const candidates: Array<[string, string | null]> = compact !== null
      ? [[compact[1], compact[2]], [compact[3], compact[4]], [compact[5], compact[6]]]
      : compactAssigned !== null
        ? [[compactAssigned[1], compactAssigned[2]], [compactAssigned[3], compactAssigned[4]], [compactAssigned[5], compactAssigned[6]]]
        : single !== null
          ? [[single[1], single[2] === 'group_M' ? 'M' : single[2]]]
          : groupedBare !== null
            ? [[groupedBare[1], null], [groupedBare[2], null], [groupedBare[3], null]]
            : bare !== null
              ? [[bare[1], null]]
              : [];
    if (candidates.length === 0) {
      fail(`${unit.id} has non-structured B.DIM projection: ${line}`);
    }
    for (const [slot, semantic] of candidates) {
      const key = `LB${slot}`;
      const previous = dimensionBindings.get(key);
      if (previous !== undefined && previous.semantic !== semantic) {
        fail(`${unit.id} assigns ${key} to conflicting high-level dimensions`);
      }
      dimensionBindings.set(key, {semantic, source: line});
    }
  }
  for (const [slot, binding] of [...dimensionBindings.entries()].sort()) {
    addParameter(
      binding.semantic === null ? slot : `${slot}:${binding.semantic}`,
      binding.source,
      'dimension',
    );
  }
  const parameterPatterns: Array<[RegExp, string, string]> = [
    [/\bAType\b/, 'DataTypeA', 'left data type'],
    [/\bBType\b/, 'DataTypeB', 'right data type'],
    [/\bDataType\b/, 'DataType', 'data type'],
    [/\bLayout\b/, 'Layout', 'layout'],
    [/\bPadValue\b/, 'PadValue', 'padding value'],
    [/\bByteId\b/, 'ByteId', 'byte selector'],
    [/\bDstDataType\b/, 'DstDataType', 'destination data type'],
  ];
  for (const [pattern, display, role] of parameterPatterns) {
    const source = blockLines.find((line) => pattern.test(line));
    if (source !== undefined) addParameter(display, source, role);
  }
  const operandValues = Array.isArray(contract.operands) ? contract.operands : [];
  const operands = operandValues.map((value, index) => {
    if (value === null || typeof value !== 'object' || Array.isArray(value)) {
      fail(`${unit.id} contract.operands[${index}] is malformed`);
    }
    const operand = value as Record<string, PtoJsonValue>;
    const field = stringValue(operand, 'field');
    const role = stringValue(operand, 'role');
    if (field === null || role === null) fail(`${unit.id} contract.operands[${index}] lacks field or role`);
    return {field, role, index};
  });
  const outputOperands = operands.filter(({field}) => /^destination\d+$/.test(field));
  const displayField = (field: string, output: boolean): string => {
    const indexed = field.match(/^(source|destination|scalar|natural|positive|flag)(\d+)$/);
    if (indexed !== null) {
      const [, kind, index] = indexed;
      if (kind === 'source') return `SrcTile${index}`;
      if (kind === 'destination') return outputOperands.length === 1 ? 'DstTile' : `DstTile${index}`;
      return `${kind[0].toLocaleUpperCase()}${kind.slice(1)}${index}`;
    }
    const named: Record<string, string> = {
      address: 'Address',
      comparison: 'Comparison',
      diagonal: 'Diagonal',
      numeric_control: 'NumericControl',
      selected_byte: 'SelectedByte',
      sort_width: 'SortWidth',
    };
    const display = named[field];
    if (display === undefined || output) fail(`${unit.id} has unsupported high-level operand field ${field}`);
    return display;
  };
  const inputs = operands
    .filter((operand) => !outputOperands.includes(operand))
    .map(({field, role, index}) => ({
      display: displayField(field, false),
      source: `contract.operands[${index}].${field}`,
      role,
    }));
  const outputs = outputOperands.map(({field, role, index}) => ({
    display: displayField(field, true),
    source: `contract.operands[${index}].${field}`,
    role,
  }));
  const parameterText = parameters.length > 0
    ? ` <${parameters.map(({display}) => display).join(', ')}>`
    : '';
  const inputText = inputs.length > 0 ? ` ${inputs.map(({display}) => display).join(', ')}` : '';
  const outputText = outputs.length > 0 ? ` -> ${outputs.map(({display}) => display).join(', ')}` : '';
  const attributes = blockLines.map((line, index) => ({
    display: line.match(/\b(B(?:START)?(?:\.[A-Z0-9]+)+)\b/)?.[1] ?? `BundleRule${index + 1}`,
    source: line,
    role: 'ASL-owned block composition',
  }));
  return {
    form: `${unit.mnemonic}${parameterText}${inputText}${outputText}`,
    parameters,
    inputs,
    outputs,
    attributes,
    basis: [...new Set([
      ...blockLines,
      ...operands.map(({index}) => `contract.operands[${index}]`),
    ])],
  };
}

function instructionIndexData(
  context: LoadContext,
  release: PtoReleaseIdentity,
  units: Array<{data: PtoUnitWorkbenchData; route: string}>,
): PtoInstructionIndexData {
  const entries = units
    .filter(({data}) => typeof data.unit.mnemonic === 'string')
    .map(({data, route}) => {
      const surface = String(data.unit.surface ?? data.metadata.surface);
      if (!['scalar', 'block', 'tile'].includes(surface)) {
        fail(`instruction index has unsupported surface ${surface}`);
      }
      const classification = Array.isArray(data.unit.classification)
        ? data.unit.classification.filter((value): value is string => typeof value === 'string')
        : [];
      return {
        id: String(data.unit.id ?? data.metadata.id),
        mnemonic: String(data.unit.mnemonic),
        surface: surface as 'scalar' | 'block' | 'tile',
        classification,
        route: localizedRoute(context, route),
        summary: stringValue(data.metadata, 'summary') ?? stringValue(data.unit, 'summary') ?? '',
        sourcePath: data.source.path,
        sourceSha256: data.source.sha256,
      };
    })
    .sort(
      (left, right) =>
        left.surface.localeCompare(right.surface) ||
        left.mnemonic.localeCompare(right.mnemonic) ||
        left.id.localeCompare(right.id),
    );
  return {release, entries};
}

interface NavigationLeafInput {
  id: string;
  label: string;
  kind: 'unit' | 'ndf' | 'adr';
  route: string;
  segments: string[];
}

function humanizeNavigationSegment(value: string): string {
  const acronyms = new Set(['adr', 'agu', 'alu', 'amo', 'asl', 'avs', 'bru', 'fsu', 'ndf', 'sys']);
  return value
    .split('-')
    .filter(Boolean)
    .map((word, index) => {
      const lower = word.toLocaleLowerCase();
      if (acronyms.has(lower)) return lower.toLocaleUpperCase();
      return index === 0 ? lower[0].toLocaleUpperCase() + lower.slice(1) : lower;
    })
    .join(' ');
}

function navigationLeaf(entry: NavigationLeafInput): PtoNavigationNode {
  return {
    id: `${entry.kind}:${entry.id}`,
    label: entry.label,
    kind: entry.kind,
    route: entry.route,
    count: null,
    children: [],
  };
}

function navigationLeafCount(node: PtoNavigationNode): number {
  return node.kind === 'branch'
    ? node.children.reduce((total, child) => total + navigationLeafCount(child), 0)
    : 1;
}

function navigationBranch(
  id: string,
  label: string,
  route: string | null,
  children: PtoNavigationNode[],
): PtoNavigationNode {
  const node: PtoNavigationNode = {id, label, kind: 'branch', route, count: 0, children};
  node.count = navigationLeafCount(node);
  return node;
}

function navigationPage(id: string, label: string, route: string): PtoNavigationNode {
  return {id, label, kind: 'page', route, count: null, children: []};
}

function navigationHierarchyChildren(
  prefix: string,
  entries: NavigationLeafInput[],
  depth = 0,
): PtoNavigationNode[] {
  const direct = entries
    .filter((entry) => entry.segments.length <= depth)
    .sort((left, right) => left.label.localeCompare(right.label) || left.id.localeCompare(right.id))
    .map(navigationLeaf);
  const grouped = new Map<string, NavigationLeafInput[]>();
  for (const entry of entries) {
    const segment = entry.segments[depth];
    if (segment === undefined) continue;
    grouped.set(segment, [...(grouped.get(segment) ?? []), entry]);
  }
  const branches = [...grouped.entries()]
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([segment, children]) => navigationBranch(
      `${prefix}:${segment}`,
      humanizeNavigationSegment(segment),
      null,
      navigationHierarchyChildren(`${prefix}:${segment}`, children, depth + 1),
    ));
  return [...branches, ...direct];
}

function navigationData(
  context: LoadContext,
  content: LoadedPtoContent,
): PtoNavigationData {
  const chinese = context.i18n.currentLocale === 'zh-CN';
  const localePath = (route: string): string => localizedRoute(context, route);
  const unitEntries = (surface: 'arch' | 'scalar' | 'block' | 'tile'): NavigationLeafInput[] =>
    content.units
      .filter(({data}) => String(data.unit.surface ?? data.metadata.surface) === surface)
      .map(({data, route}) => {
        const classification = Array.isArray(data.unit.classification)
          ? data.unit.classification.filter((value): value is string => typeof value === 'string')
          : [];
        const mnemonic = typeof data.unit.mnemonic === 'string' ? data.unit.mnemonic : null;
        const unitId = String(data.unit.id ?? data.metadata.id);
        return {
          id: unitId,
          label: mnemonic ?? unitId,
          kind: 'unit',
          route: localePath(route),
          segments: classification.length > 0 ? classification : ['other'],
        };
      });
  const architecture = navigationBranch(
    'architecture',
    chinese ? '架构' : 'Architecture',
    localePath('/architecture/'),
    navigationHierarchyChildren('architecture', unitEntries('arch')),
  );
  const surface = (name: 'scalar' | 'block' | 'tile'): PtoNavigationNode => navigationBranch(
    name,
    name[0].toLocaleUpperCase() + name.slice(1),
    localePath(`/instructions/?surface=${name}`),
    navigationHierarchyChildren(`instructions:${name}`, unitEntries(name)),
  );
  const instructions = navigationBranch(
    'instructions',
    chinese ? '指令与执行单元' : 'Instructions and execution units',
    localePath('/instructions/'),
    [surface('scalar'), surface('block'), surface('tile')],
  );
  const ndfEntries: NavigationLeafInput[] = content.ndfCatalog.entries.map((entry) => ({
    id: entry.id,
    label: entry.id,
    kind: 'ndf',
    route: entry.route,
    segments: [entry.layer, entry.kind, entry.level],
  }));
  const ndf = navigationBranch(
    'ndf',
    'NDF',
    localePath('/ndf/'),
    navigationHierarchyChildren('ndf', ndfEntries),
  );
  const adrEntries: NavigationLeafInput[] = content.search.entries
    .filter((entry) => entry.kind === 'adr')
    .map((entry) => ({
      id: entry.id,
      label: entry.label.startsWith(entry.id) ? entry.label : `${entry.id} · ${entry.label}`,
      kind: 'adr',
      route: entry.url,
      segments: [],
    }));
  const decisions = navigationBranch(
    'decisions',
    chinese ? 'Decision / ADR' : 'Decisions / ADR',
    localePath('/reference/governance/adr-process/'),
    navigationHierarchyChildren('decisions', adrEntries),
  );
  const records = navigationBranch(
    'records',
    chinese ? '规范记录' : 'Specification records',
    null,
    [
      ndf,
      navigationPage('ndf-explorer', chinese ? 'NDF 关系图' : 'NDF graph', localePath('/explore/ndf/')),
      decisions,
    ],
  );
  const project = navigationBranch(
    'project',
    chinese ? '项目' : 'Project',
    null,
    [
      navigationPage('getting-started', chinese ? '开始使用' : 'Getting started', localePath('/reference/development/getting-started/')),
      navigationPage('repository-layout', chinese ? '仓库结构' : 'Repository layout', localePath('/reference/development/repository-layout/')),
      navigationPage('adr-process', chinese ? 'ADR 流程' : 'ADR process', localePath('/reference/governance/adr-process/')),
      navigationPage('validation', chinese ? '验证流程' : 'Validation', localePath('/reference/governance/validation/')),
      navigationPage('releases', chinese ? '发布记录' : 'Releases', localePath('/reference/releases/')),
    ],
  );
  const sections = [
    navigationPage('home', chinese ? '首页' : 'Home', localePath('/')),
    architecture,
    instructions,
    records,
    project,
    navigationPage('search', chinese ? '搜索' : 'Search', localePath('/search/')),
  ];
  return {
    totalLeaves: sections.reduce((total, section) => total + navigationLeafCount(section), 0),
    sections,
  };
}

function ndfCatalogData(
  root: string,
  context: LoadContext,
  release: PtoReleaseIdentity,
  traceability: TraceabilityData,
  adrIndex: AdrIndexData,
  graph: PtoNdfGraphData,
  requirementSources: Map<string, RequirementSourceIdentity>,
  evidence: PtoArtifactEvidence[],
  units: Array<{data: PtoUnitWorkbenchData; route: string}>,
): {catalog: PtoNdfCatalogData; details: PtoNdfDetailData[]} {
  const unitsById = new Map(
    units.map((unit) => [String(unit.data.unit.id ?? unit.data.metadata.id), unit]),
  );
  const clauses = new Map<string, PtoNdfClause>();
  const occurrenceOwners = new Map<string, Set<string>>();
  for (const unit of units) {
    const unitId = String(unit.data.unit.id ?? unit.data.metadata.id);
    for (const clause of unit.data.ndfClauses) {
      const previous = clauses.get(clause.id);
      if (previous !== undefined && (
        previous.clauseSha256 !== clause.clauseSha256 ||
        previous.sourceSha256 !== clause.sourceSha256 ||
        previous.text !== clause.text
      )) {
        fail(`NDF catalog has inconsistent duplicate clause ${clause.id}`);
      }
      clauses.set(clause.id, clause);
      occurrenceOwners.set(clause.id, new Set([
        ...(occurrenceOwners.get(clause.id) ?? []),
        unitId,
      ]));
    }
  }
  const instructionContracts = new Map(
    traceability.units
      .filter((unit) => typeof unit.instruction_contract?.ndf_clause === 'string')
      .map((unit) => [unit.instruction_contract?.ndf_clause as string, unit]),
  );
  const expectedIds = traceability.requirements
    .map((requirement) => requirement.id)
    .sort();
  const actualIds = [...new Set([...clauses.keys(), ...instructionContracts.keys()])].sort();
  if (JSON.stringify(actualIds) !== JSON.stringify(expectedIds)) {
    fail(`NDF catalog does not equal release requirements: ${actualIds.length}/${expectedIds.length}`);
  }
  const ownerRoute = (unitId: string): PtoNdfOwnerRoute => {
    const unit = unitsById.get(unitId);
    if (unit === undefined) fail(`NDF catalog references missing affected unit ${unitId}`);
    return {
      id: unitId,
      mnemonic: typeof unit.data.unit.mnemonic === 'string' ? unit.data.unit.mnemonic : null,
      surface: String(unit.data.unit.surface ?? unit.data.metadata.surface),
      route: localizedRoute(context, unit.route),
      sourcePath: unit.data.source.path,
    };
  };
  const graphNodes = new Map(graph.nodes.map((node) => [node.id, node]));
  const relationships = new Map<string, PtoNdfDetailData['relationships']>();
  const relationshipHref = (node: PtoGraphNode): {href: string; external: boolean} => {
    if (node.kind === 'asl') {
      const owner = unitsById.get(node.id);
      if (owner === undefined) fail(`NDF relationship references missing ASL unit ${node.id}`);
      return {href: localizedRoute(context, owner.route), external: false};
    }
    if (node.kind === 'ndf') {
      const instructionOwner = instructionContracts.get(node.id);
      if (instructionOwner !== undefined) {
        const owner = unitsById.get(instructionOwner.id);
        if (owner === undefined) fail(`NDF relationship references missing instruction unit ${instructionOwner.id}`);
        return {href: localizedRoute(context, owner.route), external: false};
      }
      return {href: localizedRoute(context, `/ndf/${encodeURIComponent(node.id)}/`), external: false};
    }
    if (node.sourceUrl === null) fail(`NDF relationship ${node.id} has no source URL`);
    return {href: node.sourceUrl, external: true};
  };
  for (const edge of graph.edges) {
    const addRelationship = (
      center: string,
      otherId: string,
      direction: 'incoming' | 'outgoing',
    ): void => {
      const node = graphNodes.get(otherId);
      if (node === undefined) fail(`NDF relationship references missing graph node ${otherId}`);
      relationships.set(center, [
        ...(relationships.get(center) ?? []),
        {kind: edge.kind, direction, node, ...relationshipHref(node)},
      ]);
    };
    addRelationship(edge.source, edge.target, 'outgoing');
    addRelationship(edge.target, edge.source, 'incoming');
  }
  const requirementsById = new Map(
    traceability.requirements.map((requirement) => [requirement.id, requirement]),
  );
  const adrRecordsById = new Map(adrIndex.records.map((record) => [record.id, record]));
  const details = [...clauses.keys()].sort().map((id) => {
    const clause = clauses.get(id);
    if (clause === undefined) fail(`NDF catalog lost ${id}`);
    const requirement = requirementsById.get(id);
    if (requirement === undefined) fail(`NDF detail references missing requirement ${id}`);
    const ownerIds = [...new Set([
      ...(occurrenceOwners.get(id) ?? []),
      ...clause.affectedUnits,
    ])].sort();
    const adrIds = new Set(requirement.readiness_subjects);
    for (const record of adrIndex.records) {
      if (record.affected_ndf.includes(id)) adrIds.add(record.id);
    }
    const missingAdrs = [...adrIds].filter((adrId) => !adrRecordsById.has(adrId));
    if (missingAdrs.length > 0) fail(`NDF detail ${id} references missing ADRs: ${missingAdrs.join(', ')}`);
    return {
      release,
      clause,
      owners: ownerIds.map(ownerRoute),
      adrs: [...adrIds].sort().map((adrId) => publicAdr(root, release, adrRecordsById.get(adrId)!)),
      tests: instructionTests(root, release.commit, traceability, new Set(requirement.tests))
        .map(({sourceText: _sourceText, ...test}) => test),
      evidence,
      relationships: (relationships.get(id) ?? []).sort(
        (left, right) => left.node.id.localeCompare(right.node.id) || left.kind.localeCompare(right.kind),
      ),
      relationshipFallbackRoute: localizedRoute(context, '/explore/ndf/'),
    };
  });
  const detailsById = new Map(details.map((detail) => [detail.clause.id, detail]));
  const entries = expectedIds.map((id): PtoNdfCatalogData['entries'][number] => {
    const detail = detailsById.get(id);
    if (detail !== undefined) {
      const {clause, owners} = detail;
      return {
        id,
        entryKind: 'clause',
        kind: clause.kind,
        level: clause.level,
        layer: clause.layer,
        status: clause.status,
        text: clause.text,
        title: clause.title,
        summary: clause.summary,
        route: localizedRoute(context, `/ndf/${encodeURIComponent(id)}/`),
        sourcePath: clause.sourcePath,
        sourceSha256: clause.sourceSha256,
        clauseSha256: clause.clauseSha256,
        owners,
      };
    }
    const instructionOwner = instructionContracts.get(id);
    const identity = requirementSources.get(id);
    if (instructionOwner === undefined || identity === undefined) {
      fail(`NDF catalog cannot resolve instruction-contract identity ${id}`);
    }
    const owner = ownerRoute(instructionOwner.id);
    return {
      id,
      entryKind: 'instruction-contract',
      kind: 'instruction-contract',
      level: instructionOwner.surface,
      layer: 'instruction',
      status: requirementsById.get(id)?.executable ? 'executable' : 'contract',
      text: null,
      title: null,
      summary: null,
      route: owner.route,
      sourcePath: identity.sourcePath,
      sourceSha256: identity.sourceSha256,
      clauseSha256: identity.clauseSha256,
      owners: [owner],
    };
  });
  return {catalog: {release, entries}, details};
}

function catalogEncoding(
  unit: TraceabilityUnit,
  catalogs: PtoCatalogs,
  metadata: Record<string, PtoJsonValue>,
): PtoUnitEncoding {
  if (unit.mnemonic === null) {
    return {commandForm: {}, catalogForms: []};
  }

  if (unit.surface === 'block') {
    const catalogForms = catalogs.commandForms.filter(
      (form) => form.mnemonic === unit.mnemonic,
    );
    if (catalogForms.length === 0) {
      const contract = metadata.contract;
      const encodingClass =
        contract !== null && typeof contract === 'object' && !Array.isArray(contract)
          ? stringValue(contract, 'encoding_class')
          : null;
      if (encodingClass === 'encoding-alias' && stringValue(metadata, 'alias_of')) {
        return {commandForm: {}, catalogForms: []};
      }
      fail(`command form catalog is missing ${unit.mnemonic}`);
    }
    return {commandForm: catalogForms[0], catalogForms};
  }
  if (unit.surface === 'scalar') {
    const catalogForms = catalogs.scalarForms.filter(
      (form) => form.mnemonic === unit.mnemonic,
    );
    if (catalogForms.length === 0) {
      fail(`scalar catalog is missing ${unit.mnemonic}`);
    }
    return {commandForm: catalogForms[0], catalogForms};
  }
  if (unit.surface === 'tile') {
    const tileOperation = catalogs.tileOperations.find(
      (operation) => operation.name === unit.mnemonic,
    );
    if (tileOperation === undefined) {
      fail(`tile operation catalog is missing ${unit.mnemonic}`);
    }
    const commandMnemonic = stringValue(tileOperation, 'command_mnemonic');
    const catalogForms = catalogs.commandForms.filter(
      (form) => form.mnemonic === commandMnemonic,
    );
    if (catalogForms.length === 0) {
      fail(
        `command form catalog is missing ${commandMnemonic ?? 'the command'} for ${unit.mnemonic}`,
      );
    }
    return {commandForm: catalogForms[0], catalogForms, tileOperation};
  }
  fail(`mnemonic unit ${unit.id} has unsupported surface ${unit.surface}`);
}

function assemblerSymbols(
  metadata: Record<string, PtoJsonValue>,
  encoding: PtoUnitEncoding,
): PtoUnitWorkbenchData['assemblerSymbols'] {
  const contract = metadata.contract;
  const contractRecord =
    contract !== null && typeof contract === 'object' && !Array.isArray(contract)
      ? contract as Record<string, PtoJsonValue>
      : {};
  const roles = new Map<string, string>();
  if (Array.isArray(contractRecord.operands)) {
    for (const value of contractRecord.operands) {
      if (value === null || typeof value !== 'object' || Array.isArray(value)) continue;
      const operand = value as Record<string, PtoJsonValue>;
      const field = stringValue(operand, 'field');
      const role = stringValue(operand, 'role');
      if (field && role) roles.set(field, role);
    }
  }
  const zeroMeanings =
    contractRecord.field_zero_meanings !== null &&
    typeof contractRecord.field_zero_meanings === 'object' &&
    !Array.isArray(contractRecord.field_zero_meanings)
      ? contractRecord.field_zero_meanings as Record<string, PtoJsonValue>
      : {};
  const symbols = new Map<string, PtoUnitWorkbenchData['assemblerSymbols'][number]>();
  for (const form of encoding.catalogForms) {
    const fields = Array.isArray(form.fields) ? form.fields : [];
    for (const value of fields) {
      if (value === null || typeof value !== 'object' || Array.isArray(value)) continue;
      const field = value as Record<string, PtoJsonValue>;
      const name = stringValue(field, 'name');
      if (!name || symbols.has(name)) continue;
      symbols.set(name, {
        field: name,
        width: field.width === undefined ? '—' : String(field.width),
        signedness: stringValue(field, 'signedness') ?? '—',
        role: roles.get(name) ?? '—',
        zeroMeaning: stringValue(zeroMeanings, name) ?? '—',
      });
    }
  }
  for (const [field, role] of roles) {
    if (symbols.has(field)) continue;
    symbols.set(field, {
      field,
      width: '—',
      signedness: '—',
      role,
      zeroMeaning: stringValue(zeroMeanings, field) ?? '—',
    });
  }
  return [...symbols.values()];
}

function unitAdrs(
  root: string,
  release: PtoReleaseIdentity,
  unit: TraceabilityUnit,
  requirementIds: Set<string>,
  requirementsById: Map<string, TraceabilityRequirement>,
  adrIndex: AdrIndexData,
): PtoAdrRecord[] {
  const requested = new Set(unit.readiness_subjects);
  for (const requirementId of requirementIds) {
    const requirement = requirementsById.get(requirementId);
    if (requirement === undefined) {
      fail(`unit ${unit.id} references missing requirement ${requirementId}`);
    }
    for (const id of requirement.readiness_subjects) requested.add(id);
  }
  for (const record of adrIndex.records) {
    if (
      record.affected_units.includes(unit.id) ||
      record.affected_ndf.some((id) => requirementIds.has(id))
    ) {
      requested.add(record.id);
    }
  }
  const recordsById = new Map(adrIndex.records.map((record) => [record.id, record]));
  const missing = [...requested].filter((id) => !recordsById.has(id));
  if (missing.length > 0) {
    fail(`ADR index is missing ${unit.id} links: ${missing.join(', ')}`);
  }
  return [...requested]
    .sort((left, right) => left.localeCompare(right))
    .map((id) => publicAdr(root, release, recordsById.get(id)!));
}

function buildUnitData(
  root: string,
  release: PtoReleaseIdentity,
  traceability: TraceabilityData,
  unit: TraceabilityUnit,
  requirementsById: Map<string, TraceabilityRequirement>,
  adrIndex: AdrIndexData,
  catalogs: PtoCatalogs,
  evidence: PtoArtifactEvidence[],
  guideContext: ReaderGuideContext,
  requirementSources: Map<string, RequirementSourceIdentity>,
  ndfSupplements: Map<string, NdfSupplement>,
): PtoUnitWorkbenchData {
  const sourceText = readText(root, unit.source);
  const sourceDigest = sha256(sourceText);
  if (traceability.sources[unit.source] !== sourceDigest) {
    fail(`traceability source hash mismatch for ${unit.source}`);
  }
  const documentationText = readText(root, unit.documentation);
  const documentationDigest = sha256(documentationText);
  if (traceability.sources[unit.documentation] !== documentationDigest) {
    fail(`traceability documentation hash mismatch for ${unit.documentation}`);
  }

  const metadata = parseUnitMetadata(sourceText, unit.source);
  if (stringValue(metadata, 'id') !== unit.id) {
    fail(`metadata and traceability unit IDs disagree for ${unit.source}`);
  }
  if (stringValue(metadata, 'surface') !== unit.surface) {
    fail(`metadata and traceability surfaces disagree for ${unit.source}`);
  }
  if (unit.mnemonic !== null && stringValue(metadata, 'mnemonic') !== unit.mnemonic) {
    fail(`metadata and traceability mnemonics disagree for ${unit.source}`);
  }

  const ndfClauses = parseNdfClauses(
    sourceText, unit.source, release, unit, ndfSupplements,
  );
  const requirementIds = new Set(ndfClauses.map((clause) => clause.id));
  for (const clause of ndfClauses) {
    const requirement = requirementsById.get(clause.id);
    if (requirement === undefined || !requirement.owners.includes(unit.source)) {
      fail(`traceability requirement ${clause.id} does not point to ${unit.source}`);
    }
  }
  const instructionClause = unit.instruction_contract?.ndf_clause;
  if (unit.mnemonic !== null && typeof instructionClause !== 'string') {
    fail(`mnemonic unit ${unit.id} has no instruction-contract NDF clause`);
  }
  if (typeof instructionClause === 'string') requirementIds.add(instructionClause);

  const testIds = new Set([...unit.tests, ...unit.semantic_tests]);
  for (const requirementId of requirementIds) {
    const requirement = requirementsById.get(requirementId);
    if (requirement === undefined) {
      fail(`unit ${unit.id} references missing requirement ${requirementId}`);
    }
    for (const testId of requirement.tests) testIds.add(testId);
  }
  if (testIds.size === 0) fail(`unit ${unit.id} has no linked test evidence`);
  const knownTests = new Set(traceability.tests.map((test) => test.id));
  const missingTests = [...testIds].filter((id) => !knownTests.has(id));
  if (missingTests.length > 0) {
    fail(`traceability inventory is missing ${unit.id} tests: ${missingTests.join(', ')}`);
  }
  const tests = instructionTests(root, release.commit, traceability, testIds);
  const directTestIds = new Set([...unit.tests, ...unit.semantic_tests]);
  for (const test of tests) {
    if (directTestIds.has(test.id) && test.source !== unit.source) {
      fail(`test ${test.id} links ${test.source}, expected ${unit.source}`);
    }
  }

  const source = {
    path: unit.source,
    sha256: sourceDigest,
    text: sourceText,
    githubUrl: sourceUrl(release.commit, unit.source),
  };
  const projection = readerGuideProjection(
    root,
    release,
    unit,
    source,
    documentationText,
    documentationDigest,
    guideContext,
    [...requirementIds]
      .sort((left, right) => left.localeCompare(right))
      .map((id) => {
        const identity = requirementSources.get(id);
        if (identity === undefined) fail(`reader guide cannot locate exact NDF owner ${id}`);
        return {
          id,
          kind: 'ndf' as const,
          path: identity.sourcePath,
          href: identity.sourceUrl,
        };
      }),
  );

  const encoding = catalogEncoding(unit, catalogs, metadata);
  const siteProjection = loadSiteInstructionProjection(root, unit, sourceText);
  return {
    release,
    source,
    documentation: projection.documentation,
    readerGuide: projection.readerGuide,
    metadata,
    ndfClauses,
    unit: unit as unknown as Record<string, PtoJsonValue>,
    tests,
    adrs: unitAdrs(root, release, unit, requirementIds, requirementsById, adrIndex),
    evidence,
    encoding,
    assemblerSymbols: assemblerSymbols(metadata, encoding),
    composition: parseInstructionComposition(
      siteProjection?.data.composition,
      siteProjection?.path ?? unit.source,
      unit.id,
      traceability,
      release,
    ),
    semanticExecution: parseSemanticExecutionProjection(
      root,
      release,
      siteProjection?.data.semanticExecution,
      siteProjection?.path ?? unit.source,
      unit,
      sourceText,
    ),
    highLevelAssembly: highLevelAssembly(unit, metadata),
  };
}

function publicAdr(root: string, release: PtoReleaseIdentity, record: AdrIndexRecord): PtoAdrRecord {
  if (!record.path.startsWith('docs/status/decisions/')) {
    fail(`ADR source is outside canonical decision owners: ${record.path}`);
  }
  const source = readText(root, record.path);
  const decisionIdentity = record.id.match(/^ADR-([A-Z]+)-(\d{4})$/);
  if (decisionIdentity === null) fail(`invalid ADR identity ${record.id}`);
  const [, decisionType, decisionNumber] = decisionIdentity;
  return {
    id: record.id,
    title: record.title,
    titleZh: record.title_zh,
    status: record.status,
    path: record.path,
    accepted: record.accepted,
    affectedNdf: record.affected_ndf,
    affectedUnits: record.affected_units,
    targetReleases: record.target_releases,
    interfaceChange: record.interface_change === true,
    decisionAssetUrl: `/evidence/decisions/${record.id}.json`,
    githubUrl: sourceUrl(release.commit, record.path),
    sourceSha256: sha256(source),
    identity: {
      fullId: record.id,
      kind: 'adr',
      anchor: `adr-${record.id.toLocaleLowerCase('en-US')}`,
      facets: [
        {role: 'decision', label: 'ADR'},
        {role: 'category', label: decisionType},
        {role: 'case', label: decisionNumber},
      ],
    },
  };
}

function evidenceArtifact(
  root: string,
  commit: string,
  id: string,
  relativePath: string,
  role: string,
  statusPath: string[],
): PtoArtifactEvidence {
  const source = readText(root, relativePath);
  const payload = JSON.parse(source) as Record<string, unknown>;
  let value: unknown = payload;
  for (const key of statusPath) {
    value =
      typeof value === 'object' && value !== null
        ? (value as Record<string, unknown>)[key]
        : undefined;
  }
  if (typeof value !== 'string' || value.length === 0) {
    fail(`${relativePath} has no string status at ${statusPath.join('.')}`);
  }
  return {
    id,
    path: relativePath,
    role,
    status: value,
    sha256: sha256(source),
    githubUrl: sourceUrl(commit, relativePath),
  };
}

function graphData(
  release: PtoReleaseIdentity,
  traceability: TraceabilityData,
  adrIndex: AdrIndexData,
  requirementSources: Map<string, RequirementSourceIdentity>,
): PtoNdfGraphData {
  const nodes = new Map<string, Omit<PtoGraphNode, 'x' | 'y'>>();
  const edges = new Map<string, PtoGraphEdge>();
  const unitBySource = new Map(
    traceability.units.map((unit) => [unit.source, unit]),
  );

  const addNode = (node: Omit<PtoGraphNode, 'x' | 'y'>): void => {
    const existing = nodes.get(node.id);
    if (existing !== undefined && existing.kind !== node.kind) {
      fail(`graph identity ${node.id} has conflicting node kinds`);
    }
    nodes.set(node.id, node);
  };
  const addEdge = (
    kind: PtoGraphEdgeKind,
    source: string,
    target: string,
  ): void => {
    if (!nodes.has(source) || !nodes.has(target)) {
      fail(`graph edge ${kind} references missing node ${source} -> ${target}`);
    }
    const id = `${kind}:${source}:${target}`;
    edges.set(id, {id, kind, source, target});
  };

  for (const record of adrIndex.records) {
    addNode({
      id: record.id,
      kind: 'adr',
      label: record.title,
      sourcePath: record.path,
      sourceUrl: sourceUrl(release.commit, record.path),
      sourceSha256: null,
      clauseSha256: null,
      startLine: null,
      endLine: null,
      status: record.status,
    });
  }
  for (const requirement of traceability.requirements) {
    const identity = requirementSources.get(requirement.id);
    if (identity === undefined) fail(`missing source identity for ${requirement.id}`);
    addNode({
      id: requirement.id,
      kind: 'ndf',
      label: requirement.id,
      sourcePath: identity.sourcePath,
      sourceUrl: identity.sourceUrl,
      sourceSha256: identity.sourceSha256,
      clauseSha256: identity.clauseSha256,
      startLine: identity.startLine,
      endLine: identity.endLine,
      status: requirement.executable ? 'executable' : 'contract',
    });
  }
  for (const unit of traceability.units) {
    addNode({
      id: unit.id,
      kind: 'asl',
      label: unit.mnemonic ?? unit.id,
      sourcePath: unit.source,
      sourceUrl: sourceUrl(release.commit, unit.source),
      sourceSha256: traceability.sources[unit.source] ?? null,
      clauseSha256: null,
      startLine: 1,
      endLine: 1,
      status: null,
    });
  }
  for (const test of traceability.tests) {
    addNode({
      id: test.id,
      kind: 'avs',
      label: test.id,
      sourcePath: test.path,
      sourceUrl: sourceUrl(release.commit, test.path),
      sourceSha256: test.sha256,
      clauseSha256: null,
      startLine: 1,
      endLine: 1,
      status: test.kind,
    });
  }

  for (const record of adrIndex.records) {
    for (const id of record.affected_ndf) {
      if (!nodes.has(id) && record.release_boundary === true) continue;
      addEdge('adr-affects-ndf', record.id, id);
    }
    for (const id of record.affected_units) {
      if (!nodes.has(id) && record.release_boundary === true) continue;
      addEdge('adr-affects-asl', record.id, id);
    }
  }
  for (const requirement of traceability.requirements) {
    for (const owner of requirement.owners) {
      const unit = unitBySource.get(owner);
      if (unit === undefined) {
        fail(`requirement ${requirement.id} has no ASL unit for owner ${owner}`);
      }
      addEdge('ndf-owned-by-asl', requirement.id, unit.id);
    }
    for (const test of requirement.tests) {
      addEdge('ndf-covered-by-avs', requirement.id, test);
    }
  }
  for (const unit of traceability.units) {
    for (const test of unit.tests) {
      addEdge('asl-covered-by-avs', unit.id, test);
    }
  }

  const kindOrder: PtoGraphNodeKind[] = ['adr', 'ndf', 'asl', 'avs'];
  const xByKind: Record<PtoGraphNodeKind, number> = {
    adr: 0,
    ndf: 1,
    asl: 2,
    avs: 3,
  };
  const positioned: PtoGraphNode[] = [];
  for (const kind of kindOrder) {
    const layer = [...nodes.values()]
      .filter((node) => node.kind === kind)
      .sort((left, right) => left.id.localeCompare(right.id));
    const midpoint = (layer.length - 1) / 2;
    layer.forEach((node, index) => {
      positioned.push({
        ...node,
        x: xByKind[kind],
        y: index - midpoint,
      });
    });
  }

  return {
    release,
    nodes: positioned,
    edges: [...edges.values()].sort((left, right) => left.id.localeCompare(right.id)),
    counts: {
      adr: positioned.filter((node) => node.kind === 'adr').length,
      ndf: positioned.filter((node) => node.kind === 'ndf').length,
      asl: positioned.filter((node) => node.kind === 'asl').length,
      avs: positioned.filter((node) => node.kind === 'avs').length,
    },
  };
}

function ndfIndexPages(graph: PtoNdfGraphData): PtoNdfIndexPageData[] {
  const pageSize = 250;
  const nodes = [...graph.nodes].sort((left, right) => left.id.localeCompare(right.id));
  const relationships = new Map<
    string,
    Array<{kind: PtoGraphEdgeKind; direction: 'incoming' | 'outgoing'; otherId: string}>
  >();
  for (const edge of graph.edges) {
    relationships.set(edge.source, [
      ...(relationships.get(edge.source) ?? []),
      {kind: edge.kind, direction: 'outgoing', otherId: edge.target},
    ]);
    relationships.set(edge.target, [
      ...(relationships.get(edge.target) ?? []),
      {kind: edge.kind, direction: 'incoming', otherId: edge.source},
    ]);
  }
  for (const values of relationships.values()) {
    values.sort(
      (left, right) =>
        left.otherId.localeCompare(right.otherId) ||
        left.kind.localeCompare(right.kind) ||
        left.direction.localeCompare(right.direction),
    );
  }
  const pageCount = Math.ceil(nodes.length / pageSize);
  return Array.from({length: pageCount}, (_, index) => ({
    release: graph.release,
    page: index + 1,
    pageCount,
    total: nodes.length,
    entries: nodes.slice(index * pageSize, (index + 1) * pageSize).map((node) => ({
      node,
      relationships: relationships.get(node.id) ?? [],
    })),
  }));
}

function searchData(
  context: LoadContext,
  release: PtoReleaseIdentity,
  traceability: TraceabilityData,
  adrIndex: AdrIndexData,
  requirementSources: Map<string, RequirementSourceIdentity>,
): PtoSearchData {
  const chinese = context.i18n.currentLocale === 'zh-CN';
  const entries = new Map<string, PtoSearchEntry>();
  const instructionContracts = new Map(
    traceability.units
      .filter((unit) => typeof unit.instruction_contract?.ndf_clause === 'string')
      .map((unit) => [unit.instruction_contract?.ndf_clause as string, unit]),
  );
  const addEntry = (entry: PtoSearchEntry): void => {
    if (entries.has(entry.id)) {
      fail(`search index contains duplicate identity ${entry.id}`);
    }
    entries.set(entry.id, {
      ...entry,
      keywords: [...new Set(entry.keywords.filter(Boolean))].sort((left, right) =>
        left.localeCompare(right),
      ),
    });
  };

  for (const unit of traceability.units) {
    addEntry({
      id: unit.id,
      label: unit.mnemonic ?? unit.id,
      kind: 'asl',
      path: unit.source,
      url: localizedRoute(context, unitRoute(unit)),
      surface: unit.surface as 'arch' | 'block' | 'scalar' | 'tile',
      keywords: [
        unit.surface,
        unit.documentation,
        ...unit.classification,
        ...(unit.mnemonic === null ? [] : [unit.mnemonic]),
      ],
    });
  }
  for (const requirement of traceability.requirements) {
    const identity = requirementSources.get(requirement.id);
    if (identity === undefined) fail(`missing search source for ${requirement.id}`);
    const instructionOwner = instructionContracts.get(requirement.id);
    addEntry({
      id: requirement.id,
      label: requirement.id,
      kind: 'ndf',
      path: identity.sourcePath,
      url: localizedRoute(
        context,
        instructionOwner === undefined
          ? `/ndf/${encodeURIComponent(requirement.id)}/`
          : unitRoute(instructionOwner),
      ),
      sha256: identity.clauseSha256,
      startLine: identity.startLine,
      endLine: identity.endLine,
      keywords: [
        requirement.executable ? 'executable' : 'contract',
        ...requirement.owners,
      ],
    });
  }
  for (const test of traceability.tests) {
    addEntry({
      id: test.id,
      label: test.id,
      kind: 'avs',
      path: test.path,
      url: sourceUrl(release.commit, test.path),
      keywords: [test.kind, test.source, ...test.requirements],
    });
  }
  for (const record of adrIndex.records) {
    addEntry({
      id: record.id,
      label: chinese ? record.title_zh : record.title,
      kind: 'adr',
      path: record.path,
      url: sourceUrl(release.commit, record.path),
      keywords: [
        record.status,
        record.title,
        record.title_zh,
        ...record.target_releases,
        ...record.affected_ndf,
        ...record.affected_units,
      ],
    });
  }

  const kindOrder = {adr: 0, ndf: 1, asl: 2, avs: 3} as const;
  return {
    release,
    entries: [...entries.values()].sort(
      (left, right) =>
        kindOrder[left.kind] - kindOrder[right.kind] ||
        left.id.localeCompare(right.id),
    ),
  };
}

export default function ptoContentPlugin(context: LoadContext): Plugin<LoadedPtoContent> {
  return {
    name: 'pto-content',
    async loadContent(): Promise<LoadedPtoContent> {
      const root = repositoryRoot(context.siteDir);
      const release = releaseIdentity(root);
      const traceability = readJson<TraceabilityData>(
        root,
        'spec/evidence/release-traceability-readiness.json',
      );
      const adrIndex = readJson<AdrIndexData>(root, 'spec/evidence/adr-index.json');
      const ndfSupplements = loadNdfSupplements(root);
      const requirementSources = requirementSourceIndex(root, release, traceability);
      const graph = graphData(release, traceability, adrIndex, requirementSources);
      const requirementsById = new Map(
        traceability.requirements.map((requirement) => [requirement.id, requirement]),
      );
      const catalogs: PtoCatalogs = {
        commandForms: readJson<{forms: Record<string, PtoJsonValue>[]}>(
          root,
          'spec/catalog/command-forms.json',
        ).forms,
        scalarForms: readJson<{forms: Record<string, PtoJsonValue>[]}>(
          root,
          'spec/catalog/scalar-forms.json',
        ).forms,
        tileOperations: readJson<{operations: Record<string, PtoJsonValue>[]}>(
          root,
          'spec/catalog/tile-operations.json',
        ).operations,
      };
      const evidence = [
        evidenceArtifact(
          root,
          release.commit,
          'PTO-EVIDENCE-RELEASE-TRACEABILITY',
          'spec/evidence/release-traceability-readiness.json',
          'ASL/NDF/documentation/AVS traceability',
          ['summary', 'status'],
        ),
        evidenceArtifact(
          root,
          release.commit,
          'PTO-EVIDENCE-INSTRUCTION-CONTRACT-CLOSURE',
          'spec/evidence/instruction-contract-closure.json',
          'mnemonic and encoding contract closure',
          ['summary', 'status'],
        ),
        evidenceArtifact(
          root,
          release.commit,
          'PTO-EVIDENCE-ARCHITECTURE-READINESS',
          'spec/evidence/architecture-readiness.json',
          'architecture maturity and blockers',
          ['summary', 'status'],
        ),
        evidenceArtifact(
          root,
          release.commit,
          'PTO-EVIDENCE-RELEASE-GATE-READINESS',
          'spec/evidence/release-gate-readiness.json',
          'exact-head gate readiness',
          ['summary', 'status'],
        ),
        evidenceArtifact(
          root,
          release.commit,
          'PTO-EVIDENCE-RELEASE-MANIFEST',
          'spec/release-manifest.json',
          'release content and encoding fingerprints',
          ['specification_status'],
        ),
      ];
      const approvals = approvedReaderGuides(root);
      const guideContext: ReaderGuideContext = {
        locale: context.i18n.currentLocale,
        defaultLocale: context.i18n.defaultLocale,
        ...approvals,
      };
      const unitIds = new Set<string>();
      const routes = new Set<string>();
      const units = [...traceability.units]
        .sort((left, right) => left.id.localeCompare(right.id))
        .map((unit) => {
          if (unitIds.has(unit.id)) fail(`duplicate traceability unit ID ${unit.id}`);
          unitIds.add(unit.id);
          const route = unitRoute(unit);
          if (routes.has(route)) fail(`duplicate unit workbench route ${route}`);
          routes.add(route);
          return {
            route,
            data: buildUnitData(
              root,
              release,
              traceability,
              unit,
              requirementsById,
              adrIndex,
              catalogs,
              evidence,
              guideContext,
              requirementSources,
              ndfSupplements,
            ),
          };
        });
      const tload = traceability.units.find((unit) => unit.mnemonic === 'TLOAD');
      if (tload === undefined || unitRoute(tload) !== TLOAD_ROUTE) {
        fail(`TLOAD route must remain ${TLOAD_ROUTE}`);
      }
      const instructionIndex = instructionIndexData(context, release, units);
      const {catalog: ndfCatalog, details: ndfDetails} = ndfCatalogData(
        root,
        context,
        release,
        traceability,
        adrIndex,
        graph,
        requirementSources,
        evidence,
        units,
      );

      return {
        units,
        release,
        graph,
        instructionIndex,
        ndfCatalog,
        ndfDetails,
        adrDecisions: Object.fromEntries(
          adrIndex.records.map((record) => [
            record.id,
            parseDecisionNodes(root, release, record.path, readText(root, record.path)),
          ]),
        ),
        search: searchData(
          context,
          release,
          traceability,
          adrIndex,
          requirementSources,
        ),
        ndfIndexPages: ndfIndexPages(graph),
      };
    },
    async contentLoaded({content, actions}): Promise<void> {
      const surfaces = ['arch', 'scalar', 'block', 'tile'] as const;
      const surfaceCounts = Object.fromEntries(
        surfaces.map((surface) => {
          const units = content.units.filter(
            ({data}) => String(data.unit.surface ?? data.metadata.surface) === surface,
          );
          return [
            surface,
            {
              units: units.length,
              mnemonics: units.filter(
                ({data}) => typeof data.unit.mnemonic === 'string',
              ).length,
            },
          ];
        }),
      );
      const recordCounts = {
        adr: content.graph.nodes.filter((node) => node.kind === 'adr').length,
        ndf: content.graph.nodes.filter((node) => node.kind === 'ndf').length,
        avs: content.graph.nodes.filter((node) => node.kind === 'avs').length,
      };
      actions.setGlobalData({
        release: content.release,
        surfaceCounts,
        recordCounts,
        graphCounts: {
          ...content.graph.counts,
          nodes: content.graph.nodes.length,
          relationships: content.graph.edges.length,
        },
        navigation: navigationData(context, content),
      });
      const unitModules = await Promise.all(
        content.units.map(async (unit, index) => {
          const publicData = {
            ...unit.data,
            tests: unit.data.tests.map(({sourceText: _sourceText, ...test}) => test),
            semanticExecution: unit.data.semanticExecution === null ? null : {
              ...unit.data.semanticExecution,
              stages: unit.data.semanticExecution.stages.map((stage) => ({
                ...stage,
                sharedRegions: stage.sharedRegions.map(({text: _text, ...region}) => ({
                  ...region,
                  sourceAssetUrl: `/evidence/asl-fragments/${region.fragmentSha256}.asl`,
                })),
              })),
            },
          };
          return {
            ...unit,
            module: await actions.createData(
              `unit-${String(index + 1).padStart(4, '0')}.json`,
              JSON.stringify(publicData),
            ),
          };
        }),
      );
      const architectureDataModule = await actions.createData(
        'architecture-guide.json',
        JSON.stringify(architectureGuide(context, content.release, content.units)),
      );
      const instructionIndexModule = await actions.createData(
        'instruction-index.json',
        JSON.stringify(content.instructionIndex),
      );
      const ndfCatalogModule = await actions.createData(
        'ndf-catalog.json',
        JSON.stringify(content.ndfCatalog),
      );
      const ndfDetailModules = await Promise.all(
        content.ndfDetails.map(async (detail, index) => ({
          detail,
          module: await actions.createData(
            `ndf-detail-${String(index + 1).padStart(4, '0')}.json`,
            JSON.stringify(detail),
          ),
        })),
      );
      const graphDataModule = await actions.createData(
        'ndf-graph.json',
        JSON.stringify(content.graph),
      );
      const searchDataModule = await actions.createData(
        'search-index.json',
        JSON.stringify(content.search),
      );
      const ndfIndexModules = await Promise.all(
        content.ndfIndexPages.map(async (page) => ({
          page,
          module: await actions.createData(
            `ndf-index-${page.page}.json`,
            JSON.stringify(page),
          ),
        })),
      );

      for (const unit of unitModules) {
        actions.addRoute({
          path: localizedRoute(context, unit.route),
          component: '@site/src/routes/UnitWorkbench',
          exact: true,
          modules: {unitData: unit.module},
        });
      }
      actions.addRoute({
        path: localizedRoute(context, '/architecture/'),
        component: '@site/src/routes/Architecture',
        exact: true,
        modules: {architecture: architectureDataModule},
      });
      actions.addRoute({
        path: localizedRoute(context, '/instructions/'),
        component: '@site/src/routes/InstructionIndex',
        exact: true,
        modules: {index: instructionIndexModule},
      });
      actions.addRoute({
        path: localizedRoute(context, '/ndf/'),
        component: '@site/src/routes/NdfCatalog',
        exact: true,
        modules: {catalog: ndfCatalogModule},
      });
      for (const entry of ndfDetailModules) {
        actions.addRoute({
          path: localizedRoute(context, `/ndf/${encodeURIComponent(entry.detail.clause.id)}/`),
          component: '@site/src/routes/NdfDetail',
          exact: true,
          modules: {detail: entry.module},
        });
      }
      actions.addRoute({
        path: localizedRoute(context, '/explore/ndf/'),
        component: '@site/src/routes/NdfExplorer',
        exact: true,
        modules: {graph: graphDataModule},
      });
      actions.addRoute({
        path: localizedRoute(context, '/search/'),
        component: '@site/src/routes/Search',
        exact: true,
        modules: {search: searchDataModule},
      });
      for (const entry of ndfIndexModules) {
        actions.addRoute({
          path: localizedRoute(context, `/explore/ndf/index/${entry.page.page}/`),
          component: '@site/src/routes/NdfIndexPage',
          exact: true,
          modules: {index: entry.module},
        });
      }
    },
    postBuild({content, outDir}): void {
      const locale = context.i18n.currentLocale;
      writeFileSync(
        path.join(outDir, 'pto-ndf-overview.svg'),
        ndfOverviewSvg(content.graph),
        'utf8',
      );
      const entries = content.units.map(({data, route}) => ({
        id: String(data.unit.id ?? data.metadata.id ?? ''),
        mnemonic:
          typeof data.unit.mnemonic === 'string' ? data.unit.mnemonic : null,
        route: localizedRoute(context, route),
        source: data.source.path,
        source_sha256: data.source.sha256,
        documentation: data.documentation.path,
        documentation_sha256: data.documentation.sha256,
        guide_locale: data.readerGuide.locale,
        guide_content_locale: data.readerGuide.contentLocale,
        guide_sha256: data.readerGuide.sha256,
        guide_status: data.readerGuide.status,
        localized_documentation:
          data.documentation.contentLocale === locale ? data.documentation.path : null,
        localized_documentation_sha256:
          data.documentation.contentLocale === locale ? data.documentation.sha256 : null,
        reference_route: data.documentation.referenceRoute,
      }));
      writeFileSync(
        path.join(outDir, 'pto-unit-routes.json'),
        `${JSON.stringify(
          {
            schema: 'pto.site-unit-routes.v1',
            locale,
            source_commit: content.release.commit,
            unit_count: entries.length,
            entries,
          },
          null,
          2,
        )}\n`,
        'utf8',
      );

      const instructionCoverage = content.units
        .filter(({data}) => typeof data.unit.mnemonic === 'string')
        .map(({data, route}) => {
          const docRegion = (name: string): string | null => {
            const match = data.source.text.match(
              new RegExp(`^// DOC-BEGIN: ${name}\\s*$\\n([\\s\\S]*?)^// DOC-END: ${name}\\s*$`, 'm'),
            );
            return match?.[1]?.trim() ?? null;
          };
          const decode = docRegion('decode');
          const operation = docRegion('operation');
          const contract = data.metadata.contract !== null &&
            typeof data.metadata.contract === 'object' &&
            !Array.isArray(data.metadata.contract)
            ? data.metadata.contract as Record<string, PtoJsonValue>
            : {};
          const assemblyCount = Array.isArray(data.metadata.assembly)
            ? data.metadata.assembly.length : 0;
          const bundleLines = Array.isArray(data.metadata.block)
            ? data.metadata.block.filter((line) => typeof line === 'string' && !line.startsWith('#')).length
            : 0;
          const bundleRuleCount = Array.isArray(contract.block_composition)
            ? contract.block_composition.length : 0;
          const exampleCount = Array.isArray(contract.examples) ? contract.examples.length : 0;
          const constraintCount = ['legality', 'exceptions'].reduce(
            (sum, key) => sum + (Array.isArray(contract[key]) ? contract[key].length : 0), 0,
          );
          const stateContractCount = ['operands', 'state_effects', 'memory_effects', 'ordering'].reduce(
            (sum, key) => sum + (Array.isArray(contract[key]) ? contract[key].length : 0), 0,
          );
          const encodedFieldCount = data.encoding.catalogForms.reduce(
            (sum, form) => sum + (Array.isArray(form.fields) ? form.fields.length : 0),
            0,
          );
          const decodeStatus = decode === null ? 'missing' :
            /\bDecode_[A-Za-z0-9_]+\s*\(/.test(decode) ? 'complete' : 'source-binding';
          const operationStatus = operation === null ? 'missing' :
            /\bExecuteDecoded_[A-Za-z0-9_]+\s*\(/.test(operation) ? 'complete' : 'source-binding';
          const explainedGaps: string[] = [];
          const unexplainedGaps: string[] = [];
          if (data.encoding.catalogForms.length === 0) {
            explainedGaps.push('owner is an encoding alias or has no standalone encoded form');
          }
          if (decodeStatus !== 'complete') {
            explainedGaps.push(decodeStatus === 'missing'
              ? 'owner has no DOC decode region'
              : 'owner exposes exact instruction-selection/source binding without an operand-binding Decode procedure');
          }
          if (operationStatus !== 'complete') {
            explainedGaps.push(operationStatus === 'missing'
              ? 'owner has no DOC operation region'
              : 'owner exposes exact handler/helper binding without a mnemonic-specific ExecuteDecoded procedure');
          }
          if (exampleCount === 0) explainedGaps.push('owner contract declares no example');
          if (constraintCount === 0) explainedGaps.push('owner contract declares no explicit legality or exception list');
          if (stateContractCount === 0) explainedGaps.push('owner contract declares no operand/effect/ordering list');
          const bundleStatus = String(data.unit.surface ?? data.metadata.surface) !== 'tile'
            ? 'not-applicable'
            : data.composition !== null
              ? 'complete'
              : bundleLines > 0 && bundleRuleCount <= bundleLines
                ? 'complete'
                : 'source-gap';
          if (bundleStatus === 'source-gap') {
            explainedGaps.push('owner bundle rules are not fully expanded by source block-sequence metadata');
          }
          if (assemblyCount === 0) unexplainedGaps.push('missing assembly metadata');
          if (encodedFieldCount > 0 && data.assemblerSymbols.length === 0) {
            unexplainedGaps.push('encoded fields lack assembler-symbol projection');
          }
          const localizedInstructionRoute = localizedRoute(context, route);
          const localePrefix = locale === context.i18n.defaultLocale ? '/' : `/${locale}/`;
          if (!localizedInstructionRoute.startsWith(localePrefix)) {
            unexplainedGaps.push('route escapes locale tree');
          }
          return {
            id: String(data.unit.id ?? data.metadata.id),
            mnemonic: String(data.unit.mnemonic),
            surface: String(data.unit.surface ?? data.metadata.surface),
            route: localizedInstructionRoute,
            layout_contract: 'UnitWorkbenchView.arm-style.v1',
            source: data.source.path,
            source_sha256: data.source.sha256,
            encoding: data.encoding.catalogForms.length > 0 ? 'complete' : 'explained-gap',
            syntax: assemblyCount > 0 ? 'complete' : 'missing',
            assembler_symbols: encodedFieldCount === 0 || data.assemblerSymbols.length > 0
              ? 'complete' : 'missing',
            decode_source: decodeStatus,
            operation_source: operationStatus,
            behavior: data.readerGuide.status,
            constraints_faults: constraintCount > 0 ? 'complete' : 'explained-gap',
            state_reads_writes_result: stateContractCount > 0 ? 'complete' : 'explained-gap',
            bundle_source: bundleLines > 0 ? 'owner-metadata' : 'not-applicable',
            bundle_status: bundleStatus,
            bundle_lines: bundleLines,
            bundle_rules: bundleRuleCount,
            decisions: data.adrs.length,
            ndf_owners: data.readerGuide.owners.filter((owner) => owner.kind === 'ndf').length,
            evidence: data.tests.length,
            source_records: data.readerGuide.owners.length > 0 && data.tests.length > 0
              ? 'complete' : 'explained-gap',
            examples: exampleCount,
            locale,
            content_locale: data.readerGuide.contentLocale,
            locale_status: data.readerGuide.status,
            specialized_projection: data.composition !== null || data.semanticExecution !== null,
            explained_gaps: explainedGaps,
            unexplained_gaps: unexplainedGaps,
          };
        });
      const surfaceTotals = Object.fromEntries(
        ['scalar', 'block', 'tile'].map((surface) => [surface,
          instructionCoverage.filter((entry) => entry.surface === surface).length]),
      );
      const unexplainedOmissions = instructionCoverage.reduce(
        (sum, entry) => sum + entry.unexplained_gaps.length, 0,
      );
      const matrix = {
        schema: 'pto.site-instruction-coverage.v1',
        locale,
        source_commit: content.release.commit,
        instruction_count: instructionCoverage.length,
        surface_totals: surfaceTotals,
        layout_contract: 'UnitWorkbenchView.arm-style.v1',
        unexplained_omissions: unexplainedOmissions,
        entries: instructionCoverage,
      };
      writeFileSync(
        path.join(outDir, 'pto-instruction-coverage.json'),
        `${JSON.stringify(matrix, null, 2)}\n`,
        'utf8',
      );
      if (unexplainedOmissions !== 0) {
        fail(`instruction coverage has ${unexplainedOmissions} unexplained omissions for ${locale}`);
      }

      const siteOutDir = locale === context.i18n.defaultLocale
        ? outDir
        : path.dirname(outDir);
      const sourceDirectory = path.join(siteOutDir, 'evidence/test-sources');
      mkdirSync(sourceDirectory, {recursive: true});
      const testSources = new Map<string, string>();
      for (const {data} of content.units) {
        for (const test of data.tests) {
          if (test.sourceText === undefined) {
            fail(`build content is missing exact source for ${test.id}`);
          }
          const previous = testSources.get(test.sha256);
          if (previous !== undefined && previous !== test.sourceText) {
            fail(`test source hash collision for ${test.id}`);
          }
          testSources.set(test.sha256, test.sourceText);
        }
      }
      for (const [digest, source] of testSources) {
        writeFileSync(path.join(sourceDirectory, `${digest}.asl`), source, 'utf8');
      }

      const fragmentDirectory = path.join(siteOutDir, 'evidence/asl-fragments');
      mkdirSync(fragmentDirectory, {recursive: true});
      const fragments = new Map<string, string>();
      for (const {data} of content.units) {
        for (const stage of data.semanticExecution?.stages ?? []) {
          for (const region of stage.sharedRegions) {
            if (region.text === undefined || sha256(region.text) !== region.fragmentSha256) {
              fail(`build content has stale shared ASL fragment ${region.id}`);
            }
            const previous = fragments.get(region.fragmentSha256);
            if (previous !== undefined && previous !== region.text) {
              fail(`shared ASL fragment hash collision for ${region.id}`);
            }
            fragments.set(region.fragmentSha256, region.text);
          }
        }
      }
      for (const [digest, source] of fragments) {
        writeFileSync(path.join(fragmentDirectory, `${digest}.asl`), source, 'utf8');
      }

      const decisionDirectory = path.join(siteOutDir, 'evidence/decisions');
      mkdirSync(decisionDirectory, {recursive: true});
      for (const [id, nodes] of Object.entries(content.adrDecisions)) {
        if (!/^ADR-(GOV|STATE|MEM|BLOCK|SCALAR|TILE|CUBE|NUM)-\d{4}$/.test(id)) {
          fail(`unsafe ADR asset identity ${id}`);
        }
        writeFileSync(
          path.join(decisionDirectory, `${id}.json`),
          `${JSON.stringify(nodes)}\n`,
          'utf8',
        );
      }
    },
  };
}
