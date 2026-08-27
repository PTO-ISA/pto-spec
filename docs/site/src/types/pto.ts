export type PtoJsonPrimitive = string | number | boolean | null;

export type PtoJsonValue =
  | PtoJsonPrimitive
  | PtoJsonValue[]
  | { [key: string]: PtoJsonValue };

export interface PtoReleaseIdentity {
  architectureVersion: string;
  publicationVersion: string;
  commit: string;
  tag: string;
  tagged: boolean;
  releaseEligible: boolean;
}

export interface PtoSourceIdentity {
  path: string;
  sha256: string;
  text: string;
  githubUrl: string;
}

/** A generated documentation projection never carries its complete Markdown in route data. */
export interface PtoDocumentationIdentity {
  path: string;
  sha256: string;
  githubUrl: string;
  locale: string;
  contentLocale: string;
  referenceRoute: string;
  localized: boolean;
}

export type PtoReaderGuideStatus = 'complete' | 'fallback' | 'pending';

export type PtoReaderGuideRole =
  | 'purpose'
  | 'mechanism'
  | 'inputs-outputs'
  | 'effects'
  | 'constraints'
  | 'example'
  | 'purpose-scope'
  | 'concepts-state'
  | 'rules-interactions'
  | 'boundaries'
  | 'example-usage'
  | 'related-owners-navigation';

export type PtoReaderInline =
  | {kind: 'text'; text: string}
  | {kind: 'code'; text: string}
  | {kind: 'strong'; children: PtoReaderInline[]}
  | {kind: 'emphasis'; children: PtoReaderInline[]}
  | {kind: 'link'; href: string; children: PtoReaderInline[]};

export type PtoReaderNode =
  | {kind: 'heading'; level: number; children: PtoReaderInline[]}
  | {kind: 'paragraph'; children: PtoReaderInline[]}
  | {kind: 'callout'; tone: 'note' | 'tip' | 'important' | 'warning'; children: PtoReaderInline[]}
  | {kind: 'list-item'; ordered: boolean; children: PtoReaderInline[]}
  | {kind: 'table-row'; cells: PtoReaderInline[][]}
  | {kind: 'code-block'; language: string | null; text: string};

export interface PtoSemanticIdentityFacet {
  role: 'namespace' | 'surface' | 'owner' | 'category' | 'case' | 'decision';
  label: string;
}

export interface PtoSemanticIdentity {
  fullId: string;
  kind: 'ndf' | 'avs' | 'adr';
  anchor: string;
  facets: PtoSemanticIdentityFacet[];
}

export interface PtoReaderGuideBlock {
  id: string;
  role: PtoReaderGuideRole;
  nodes: PtoReaderNode[];
}

export interface PtoReaderGuideOwnerLink {
  id: string;
  kind: 'asl' | 'ndf';
  path: string;
  href: string;
}

export interface PtoReaderGuide {
  status: PtoReaderGuideStatus;
  target: boolean;
  locale: string;
  contentLocale: string;
  sha256: string | null;
  blocks: PtoReaderGuideBlock[];
  owners: PtoReaderGuideOwnerLink[];
}

export interface PtoArchitectureOwnerProjection {
  id: string;
  label: string;
  route: string;
  referenceRoute: string;
  sourcePath: string;
  sourceSha256: string;
  sourceUrl: string;
  guideStatus: PtoReaderGuideStatus;
  guideSha256: string;
  contentLocale: string;
  blocks: PtoReaderGuideBlock[];
}

export interface PtoArchitectureBoundGuideBlock {
  ownerId: string;
  sourcePath: string;
  sourceSha256: string;
  guideSha256: string;
  block: PtoReaderGuideBlock;
}

export interface PtoArchitectureTopicProjection {
  id: string;
  label: string;
  scenario: PtoArchitectureBoundGuideBlock;
  sourceBoundary: PtoArchitectureBoundGuideBlock | null;
  primary: PtoArchitectureOwnerProjection;
  related: PtoArchitectureOwnerProjection[];
}

export interface PtoArchitectureGuide {
  schema: 'pto.site-architecture-guide.v1';
  locale: string;
  release: PtoReleaseIdentity;
  entry: PtoArchitectureOwnerProjection;
  topics: PtoArchitectureTopicProjection[];
}

export interface PtoNdfClause {
  id: string;
  kind: string;
  level: string;
  layer: string;
  status: string;
  text: string;
  sourcePath: string;
  startLine: number;
  endLine: number;
  sourceSha256: string;
  clauseSha256: string;
  githubUrl: string;
  affectedUnits: string[];
  identity: PtoSemanticIdentity;
}

export interface PtoTestEvidence {
  id: string;
  kind: string;
  path: string;
  sha256: string;
  source: string;
  requirements: string[];
  summary: string | null;
  passCondition: string | null;
  /** Build-only until stripped from route data; exact source is fetched on demand. */
  sourceText?: string;
  sourceAssetUrl: string;
  githubUrl: string;
  identity: PtoSemanticIdentity;
  ownerId: string;
  ownerMnemonic: string | null;
  surface: string;
}

export interface PtoAdrRecord {
  id: string;
  title: string;
  status: string;
  path: string;
  accepted: string | null;
  affectedNdf: string[];
  affectedUnits: string[];
  targetReleases: string[];
  decisionAssetUrl: string;
  githubUrl: string;
  sourceSha256: string;
  identity: PtoSemanticIdentity;
}

export interface PtoArtifactEvidence {
  id: string;
  path: string;
  role: string;
  status: string;
  sha256: string;
  githubUrl: string;
}

export interface PtoUnitEncoding {
  /** First catalog form retained for the original workbench renderer. */
  commandForm: Record<string, PtoJsonValue>;
  /** Every matching form from command-forms.json or scalar-forms.json. */
  catalogForms: Record<string, PtoJsonValue>[];
  /** Present only for mnemonic tile-operation units. */
  tileOperation?: Record<string, PtoJsonValue>;
}

export interface PtoAssemblerSymbol {
  field: string;
  width: string;
  signedness: string;
  role: string;
  zeroMeaning: string;
}

export interface PtoLocalizedText {
  en: string;
  'zh-CN': string;
}

export interface PtoInstructionCompositionParameter {
  name: string;
  meaning: PtoLocalizedText;
  omission?: PtoLocalizedText;
}

export interface PtoInstructionCompositionReference {
  id: string;
  route: string;
  sourcePath: string;
  sourceUrl: string;
}

export interface PtoInstructionCompositionCommand {
  mnemonic: string;
  minOccurrences: number;
  maxOccurrences: number;
  repeatable: boolean;
  requirement: 'required' | 'optional' | 'conditional' | 'forbidden';
  role: PtoLocalizedText;
  parameters: PtoInstructionCompositionParameter[];
  reference?: PtoInstructionCompositionReference;
}

export interface PtoInstructionCompositionVariant {
  id: string;
  label: PtoLocalizedText;
  summary: PtoLocalizedText;
  canonicalCommandCount: PtoLocalizedText;
  canonicalMinCommands: number;
  canonicalMaxCommands: number;
  minimumSequence: string[];
  completeSequence: string[];
  relationships: PtoLocalizedText[];
  commands: PtoInstructionCompositionCommand[];
}

export interface PtoInstructionComposition {
  owner: string;
  variants: PtoInstructionCompositionVariant[];
}

export interface PtoSemanticSourceRegion {
  id: string;
  label: PtoLocalizedText;
  purpose: PtoLocalizedText;
  sourcePath: string;
  sourceUrl: string;
  sourceSha256: string;
  fragmentSha256: string;
  startLine: number;
  endLine: number;
  text?: string;
  sourceAssetUrl?: string;
}

export interface PtoSemanticExecutionStage {
  id: string;
  label: PtoLocalizedText;
  summary: PtoLocalizedText;
  status: 'complete' | 'source-gap';
  gap?: PtoLocalizedText;
  facts: Array<{
    kind: 'inputs' | 'checks' | 'faults' | 'reads' | 'writes' | 'commit';
    label: PtoLocalizedText;
    items: PtoLocalizedText[];
  }>;
  ownerRegions: PtoSemanticSourceRegion[];
  sharedRegions: PtoSemanticSourceRegion[];
}

export interface PtoSemanticExecution {
  owner: string;
  stages: PtoSemanticExecutionStage[];
}

export interface PtoUnitWorkbenchData {
  release: PtoReleaseIdentity;
  source: PtoSourceIdentity;
  documentation: PtoDocumentationIdentity;
  readerGuide: PtoReaderGuide;
  metadata: Record<string, PtoJsonValue>;
  ndfClauses: PtoNdfClause[];
  unit: Record<string, PtoJsonValue>;
  tests: PtoTestEvidence[];
  adrs: PtoAdrRecord[];
  evidence: PtoArtifactEvidence[];
  encoding: PtoUnitEncoding;
  assemblerSymbols: PtoAssemblerSymbol[];
  composition: PtoInstructionComposition | null;
  semanticExecution: PtoSemanticExecution | null;
}

/** Compatibility name for the first TLOAD workbench implementation. */
export type PtoInstructionWorkbenchData = PtoUnitWorkbenchData;

export type PtoGraphNodeKind = 'adr' | 'ndf' | 'asl' | 'avs';

export interface PtoGraphNode {
  id: string;
  kind: PtoGraphNodeKind;
  label: string;
  x: number;
  y: number;
  sourcePath: string | null;
  sourceUrl: string | null;
  sourceSha256: string | null;
  clauseSha256: string | null;
  startLine: number | null;
  endLine: number | null;
  status: string | null;
}

export type PtoGraphEdgeKind =
  | 'adr-affects-ndf'
  | 'adr-affects-asl'
  | 'ndf-owned-by-asl'
  | 'ndf-covered-by-avs'
  | 'asl-covered-by-avs';

export interface PtoGraphEdge {
  id: string;
  kind: PtoGraphEdgeKind;
  source: string;
  target: string;
}

export interface PtoNdfGraphData {
  release: PtoReleaseIdentity;
  nodes: PtoGraphNode[];
  edges: PtoGraphEdge[];
  counts: Record<PtoGraphNodeKind, number>;
}

export interface PtoNdfIndexRelationship {
  kind: PtoGraphEdgeKind;
  direction: 'incoming' | 'outgoing';
  otherId: string;
}

export interface PtoNdfIndexEntry {
  node: PtoGraphNode;
  relationships: PtoNdfIndexRelationship[];
}

export interface PtoNdfIndexPageData {
  release: PtoReleaseIdentity;
  page: number;
  pageCount: number;
  total: number;
  entries: PtoNdfIndexEntry[];
}

export type PtoSearchEntryKind = 'adr' | 'ndf' | 'asl' | 'avs';

export interface PtoSearchEntry {
  id: string;
  label: string;
  kind: PtoSearchEntryKind;
  path: string;
  url: string;
  surface?: 'arch' | 'block' | 'scalar' | 'tile';
  sha256?: string;
  startLine?: number;
  endLine?: number;
  keywords: string[];
}

export interface PtoSearchData {
  release: PtoReleaseIdentity;
  entries: PtoSearchEntry[];
}
