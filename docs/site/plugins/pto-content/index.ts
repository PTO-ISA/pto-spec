import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {existsSync, mkdirSync, readFileSync, readdirSync, statSync, writeFileSync} from 'node:fs';
import path from 'node:path';
import type {LoadContext, Plugin} from '@docusaurus/types';
import type {
  PtoAdrRecord,
  PtoArtifactEvidence,
  PtoDocumentationIdentity,
  PtoGraphEdge,
  PtoGraphEdgeKind,
  PtoGraphNode,
  PtoGraphNodeKind,
  PtoJsonValue,
  PtoNdfClause,
  PtoNdfGraphData,
  PtoNdfIndexPageData,
  PtoReleaseIdentity,
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
  status: string;
  path: string;
  accepted: string | null;
  affected_ndf: string[];
  affected_units: string[];
  target_releases: string[];
}

interface AdrIndexData {
  records: AdrIndexRecord[];
}

interface LoadedPtoContent {
  units: Array<{data: PtoUnitWorkbenchData; route: string}>;
  release: PtoReleaseIdentity;
  graph: PtoNdfGraphData;
  search: PtoSearchData;
  ndfIndexPages: PtoNdfIndexPageData[];
}

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
  if (!documentationPath.startsWith('docs/') || !documentationPath.endsWith('.md')) {
    fail(`cannot derive reference route for ${documentationPath}`);
  }
  let relative = documentationPath.slice('docs/'.length, -'.md'.length);
  if (relative.endsWith('/index')) relative = relative.slice(0, -'/index'.length);
  const route = `/reference/${relative}/`.replace(/\/+/g, '/');
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

function parseNdfClauses(source: string, sourcePath: string): PtoNdfClause[] {
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

    clauses.push({
      id,
      kind: metadata[1],
      level: metadata[2],
      layer: metadata[3],
      status: metadata[4],
      text: body.join('\n'),
      sourcePath,
      startLine: index + 1,
      endLine: endIndex + 1,
    });
    index = endIndex;
  }

  return clauses;
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
      return {
        ...test,
        summary: stringValue(metadata, 'summary'),
        passCondition: stringValue(metadata, 'pass_condition'),
        sourceText,
        sourceAssetUrl: `/evidence/test-sources/${digest}.asl`,
        githubUrl: sourceUrl(commit, test.path),
      };
    });
}

interface PtoCatalogs {
  commandForms: Record<string, PtoJsonValue>[];
  scalarForms: Record<string, PtoJsonValue>[];
  tileOperations: Record<string, PtoJsonValue>[];
}

function unitRoute(unit: TraceabilityUnit): string {
  if (unit.mnemonic === null) {
    return `/units/${encodeURIComponent(unit.id)}/`;
  }
  const stem = path.posix.basename(unit.source, '.asl');
  const segments = [
    'instructions',
    unit.surface,
    ...unit.classification,
    stem,
  ].map((segment) => encodeURIComponent(segment));
  return `/${segments.join('/')}/`;
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

function unitAdrs(
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
    .map((id) => publicAdr(release.commit, recordsById.get(id)!));
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

  const ndfClauses = parseNdfClauses(sourceText, unit.source);
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

  return {
    release,
    source,
    documentation: projection.documentation,
    readerGuide: projection.readerGuide,
    metadata,
    ndfClauses,
    unit: unit as unknown as Record<string, PtoJsonValue>,
    tests,
    adrs: unitAdrs(release, unit, requirementIds, requirementsById, adrIndex),
    evidence,
    encoding: catalogEncoding(unit, catalogs, metadata),
  };
}

function publicAdr(commit: string, record: AdrIndexRecord): PtoAdrRecord {
  return {
    id: record.id,
    title: record.title,
    status: record.status,
    path: record.path,
    accepted: record.accepted,
    affectedNdf: record.affected_ndf,
    affectedUnits: record.affected_units,
    targetReleases: record.target_releases,
    githubUrl: sourceUrl(commit, record.path),
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
      addEdge('adr-affects-ndf', record.id, id);
    }
    for (const id of record.affected_units) {
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
  const entries = new Map<string, PtoSearchEntry>();
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
    addEntry({
      id: requirement.id,
      label: requirement.id,
      kind: 'ndf',
      path: identity.sourcePath,
      url: identity.sourceUrl,
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
      label: record.title,
      kind: 'adr',
      path: record.path,
      url: sourceUrl(release.commit, record.path),
      keywords: [
        record.status,
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
            ),
          };
        });
      const tload = traceability.units.find((unit) => unit.mnemonic === 'TLOAD');
      if (tload === undefined || unitRoute(tload) !== TLOAD_ROUTE) {
        fail(`TLOAD route must remain ${TLOAD_ROUTE}`);
      }

      return {
        units,
        release,
        graph,
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
      });
      const unitModules = await Promise.all(
        content.units.map(async (unit, index) => {
          const publicData = {
            ...unit.data,
            tests: unit.data.tests.map(({sourceText: _sourceText, ...test}) => test),
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
    },
  };
}
