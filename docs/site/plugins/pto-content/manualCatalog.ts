import type {PtoInstructionIndexData, PtoJsonValue, PtoUnitWorkbenchData} from '../../src/types/pto';
import type {ManualIndexData, ManualSection} from '../../src/manual/sections';

type CatalogRecord = Record<string, PtoJsonValue>;
type InstructionSection = Exclude<ManualSection, 'encoding'>;
type EncodingGroup = Extract<ManualIndexData, {section: 'encoding'}>['groups'][number];
type EncodingRow = EncodingGroup['rows'][number];

export interface ManualCatalogs {
  commandForms: CatalogRecord[];
  scalarForms: CatalogRecord[];
  scopedScalarForms: CatalogRecord[];
  tileOperations: CatalogRecord[];
  reservations: CatalogRecord[];
  tileMacros: CatalogRecord[];
}

const wordFormats = ['C16', 'L32', 'HL48', 'L64', 'SCOPED64'];
const tileEngines = {CUBE: 'cube', VEC: 'vector', SFU: 'vector', TLSU: 'tma'} as const;

function textValue(value: PtoJsonValue | undefined): string {
  return typeof value === 'string' ? value : '';
}

function recordValue(value: PtoJsonValue): value is CatalogRecord {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function recordList(value: PtoJsonValue | undefined): CatalogRecord[] {
  return Array.isArray(value) ? value.filter(recordValue) : [];
}

function tileSection(engine: string): InstructionSection {
  const section = tileEngines[engine as keyof typeof tileEngines];
  if (section === undefined) throw new Error(`Unsupported Tile engine in instruction manual: ${engine}`);
  return section;
}

export function manualSection(
  surface: string,
  classification: string[],
  engine: string,
): InstructionSection {
  switch (surface) {
    case 'scalar': return classification[0] === 'fsu' ? 'float' : 'scalar';
    case 'block': return 'block';
    case 'tile': return tileSection(engine);
    default: throw new Error(`Unsupported surface in instruction manual: ${surface}`);
  }
}

export function manualTileAssembly(
  mnemonic: string,
  encoding: PtoUnitWorkbenchData['encoding'],
  catalogs: ManualCatalogs,
  commandRoutes: ReadonlyMap<string, string>,
) {
  if (!encoding?.tileOperation) return undefined;
  const macro = catalogs.tileMacros.find((operation) => operation.mnemonic === mnemonic);
  const macroFormat = textValue(macro?.macro_format);
  if (!macroFormat) throw new Error(`Tile operation ${mnemonic} has no canonical macro assembly`);
  const macros = [...new Set([
    macroFormat,
    ...recordList(macro?.forms).map((form) => textValue(form.macro_format)).filter(Boolean),
  ])];
  const carrier = textValue(encoding.tileOperation.command_mnemonic);
  return {
    macros,
    carrierHref: commandRoutes.get(carrier),
    commandHrefs: Object.fromEntries(commandRoutes),
  };
}

function patternRows(form: CatalogRecord): string[] {
  return recordList(form.encoding).map(({index, match, mask, width_bits}) =>
    `[${index}] ${width_bits}b ${match} / ${mask}`,
  );
}

function encodingRows(
  catalogs: ManualCatalogs,
  routes: ReadonlyMap<string, string>,
  chinese: boolean,
): EncodingGroup[] {
  const groups = new Map<string, EncodingGroup>();
  const add = (id: string, label: string, row: EncodingRow) => {
    const group = groups.get(id);
    if (group !== undefined) group.rows.push(row);
    else groups.set(id, {id, label, rows: [row]});
  };

  for (const [surface, forms] of [
    ['scalar', [...catalogs.scalarForms, ...catalogs.scopedScalarForms]],
    ['block', catalogs.commandForms],
    ['reserved', catalogs.reservations],
  ] as const) {
    for (const [index, form] of forms.entries()) {
      const mnemonic = textValue(form.mnemonic);
      const format = textValue(form.encoding_kind) || `${form.length_bits}b`;
      const status = textValue(form.status);
      const id = textValue(form.form_id) || `${surface}-${mnemonic}-${index}`;
      const href = routes.get(`${surface}:${mnemonic}`);
      if (!href && status === 'accepted') {
        throw new Error(`Accepted encoding ${id} has no manual instruction page`);
      }
      const reserved = surface === 'reserved' || status === 'reserved-in-pto';
      add(
        reserved ? 'reserved' : format.toLowerCase(),
        reserved ? (chinese ? '已声明的保留编码' : 'Declared reserved encodings') : format,
        {
          id, mnemonic, href, format, status,
          patterns: patternRows(form),
          variant: textValue(form.asm ?? form.owner),
          constraints: Array.isArray(form.constraints)
            ? form.constraints.map((constraint) => typeof constraint === 'string' ? constraint : JSON.stringify(constraint))
            : [],
        },
      );
    }
  }

  for (const operation of catalogs.tileOperations) {
    const mnemonic = textValue(operation.name);
    const engine = textValue(operation.engine);
    const carrier = textValue(operation.command_mnemonic);
    const href = routes.get(`tile:${mnemonic}`);
    if (!href) throw new Error(`Tile encoding ${mnemonic} has no manual instruction page`);
    tileSection(engine);
    const selector = [
      typeof operation.mode === 'number' ? `Mode=${operation.mode}` : '',
      typeof operation.function === 'number' ? `Function=${operation.function}` : '',
      typeof operation.selector === 'string' ? `Selector=${operation.selector}` : '',
    ].filter(Boolean);
    add(`tile-${engine.toLowerCase()}`, `${engine} · ${chinese ? 'Tile 选择器' : 'Tile selectors'}`, {
      id: `tile-${mnemonic}`,
      mnemonic,
      href,
      format: carrier,
      patterns: selector,
      status: textValue(operation.disposition),
    });
  }

  const groupOrder = [...wordFormats.map((format) => format.toLowerCase()), 'tile-cube', 'tile-vec', 'tile-sfu', 'tile-tlsu', 'reserved'];
  return [...groups.values()]
    .sort((left, right) => groupOrder.indexOf(left.id) - groupOrder.indexOf(right.id) || left.label.localeCompare(right.label))
    .map((group) => ({
      ...group,
      rows: group.rows.sort((left, right) => left.mnemonic.localeCompare(right.mnemonic) || left.id.localeCompare(right.id)),
    }));
}

export function buildManualIndexes(
  index: PtoInstructionIndexData,
  sectionById: ReadonlyMap<string, {section: InstructionSection; engine: string}>,
  catalogs: ManualCatalogs,
  chinese: boolean,
): ManualIndexData[] {
  const sections: InstructionSection[] = ['scalar', 'float', 'block', 'cube', 'vector', 'tma'];
  const routes = new Map(index.entries.map((entry) => [`${entry.surface}:${entry.mnemonic}`, entry.route]));
  const buckets = new Map(sections.map((section) => [section, [] as Array<{
    id: string;
    mnemonic: string;
    summary: string;
    group: string;
    href: string;
  }>]));
  const floatingHandlers = new Map(catalogs.scalarForms
    .filter((form) => form.semantic_family === 'FSU')
    .map((form) => [textValue(form.mnemonic), textValue(form.semantic_handler)]));
  for (const entry of index.entries) {
    const placement = sectionById.get(entry.id);
    if (!placement) throw new Error(`Missing manual section for ${entry.id}`);
    const [family = placement.section, subfamily = family] = entry.classification;
    const group = {
      scalar: family,
      float: floatingHandlers.get(entry.mnemonic) ?? 'fsu',
      block: family,
      cube: subfamily,
      vector: placement.engine,
      tma: subfamily,
    }[placement.section];
    buckets.get(placement.section)!.push({
      id: entry.id, mnemonic: entry.mnemonic, summary: entry.summary, group, href: entry.route,
    });
  }
  return [
    ...sections.map((section) => ({section, entries: buckets.get(section)!, release: index.release})),
    {section: 'encoding', groups: encodingRows(catalogs, routes, chinese), release: index.release},
  ];
}
