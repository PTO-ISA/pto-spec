import {createHash} from 'node:crypto';
import {readFileSync, readdirSync} from 'node:fs';
import path from 'node:path';

export interface ManualAslRelease {
  commit: string;
}

export interface ManualAslText {
  en: string;
  'zh-CN': string;
}

export type ManualAslPhase = 'decode' | 'operation';

export interface ManualAslFunctionRegion {
  symbol: string;
  phase: ManualAslPhase;
  role: 'owner' | 'shared';
  label: ManualAslText;
  purpose: ManualAslText;
  sourcePath: string;
  sourceUrl: string;
  sourceAssetUrl: string;
  sourceSha256: string;
  fragmentSha256: string;
  startLine: number;
  endLine: number;
  text: string;
}

export interface ManualAslReference {
  symbol: string;
  sourcePath: string;
  sourceUrl: string;
  sourceAssetUrl: string;
  fragmentSha256: string;
  startLine: number;
  endLine: number;
  text?: string;
}

export interface ManualAslProjection {
  owner: string;
  status: 'complete' | 'source-gap';
  functions: ManualAslFunctionRegion[];
  references: ManualAslReference[];
  missingSymbols: string[];
}

interface IndexedFunction {
  symbol: string;
  sourcePath?: string;
  startLine: number;
  endLine: number;
  text: string;
}

const GITHUB_REPOSITORY = 'https://github.com/PTO-ISA/pto-spec';
const FUNCTION_DECLARATION = /^(?:(?:pure|readonly|impdef) )?func ([A-Za-z_][A-Za-z0-9_]*)\b/;
const FUNCTION_CALL = /\b([A-Za-z_][A-Za-z0-9_]*)\s*(?:\{[^{}]*\})?\s*\(/g;
const functionIndexCache = new Map<string, ReadonlyMap<string, readonly Required<IndexedFunction>[]>>();

function sha256(value: string): string {
  return createHash('sha256').update(value, 'utf8').digest('hex');
}

function regionLines(lines: string[], phase: ManualAslPhase): {start: number; end: number} | null {
  const begin = lines.findIndex((line) => line.trim() === `// DOC-BEGIN: ${phase}`);
  if (begin < 0) return null;
  const end = lines.findIndex(
    (line, index) => index > begin && line.trim() === `// DOC-END: ${phase}`,
  );
  return end < 0 ? null : {start: begin + 1, end};
}

function functionEnd(lines: string[], declaration: number, limit: number): number | null {
  for (let index = limit - 1; index > declaration; index -= 1) {
    if (lines[index].trim() === 'end;') return index + 1;
  }
  return null;
}

function functionsInRegion(lines: string[], region: {start: number; end: number}): IndexedFunction[] {
  const declarations = lines.flatMap((line, index) => {
    if (index < region.start || index >= region.end) return [];
    const match = FUNCTION_DECLARATION.exec(line);
    return match === null ? [] : [{symbol: match[1], index}];
  });
  return declarations.flatMap((declaration, position) => {
    const limit = declarations[position + 1]?.index ?? region.end;
    const end = functionEnd(lines, declaration.index, limit);
    if (end === null) return [];
    return [{
      symbol: declaration.symbol,
      startLine: declaration.index + 1,
      endLine: end,
      text: lines.slice(declaration.index, end).join('\n'),
    }];
  });
}

function aslFiles(directory: string): string[] {
  return readdirSync(directory, {withFileTypes: true}).flatMap((entry) => {
    const absolute = path.join(directory, entry.name);
    if (entry.isDirectory()) return aslFiles(absolute);
    return entry.isFile() && entry.name.endsWith('.asl') ? [absolute] : [];
  });
}

function functionIndex(root: string): ReadonlyMap<string, readonly Required<IndexedFunction>[]> {
  const canonicalRoot = path.resolve(root);
  const cached = functionIndexCache.get(canonicalRoot);
  if (cached !== undefined) return cached;

  const index = new Map<string, Required<IndexedFunction>[]>();
  for (const absolutePath of aslFiles(path.join(canonicalRoot, 'asl'))) {
    const sourcePath = path.relative(canonicalRoot, absolutePath).split(path.sep).join('/');
    const lines = readFileSync(absolutePath, 'utf8').replace(/\r\n?/g, '\n').split('\n');
    const declarations = lines.flatMap((line, lineIndex) => {
      const match = FUNCTION_DECLARATION.exec(line);
      return match === null ? [] : [{symbol: match[1], lineIndex}];
    });
    declarations.forEach((declaration, position) => {
      const limit = declarations[position + 1]?.lineIndex ?? lines.length;
      const end = functionEnd(lines, declaration.lineIndex, limit);
      if (end === null) return;
      const definition = {
        symbol: declaration.symbol,
        sourcePath,
        startLine: declaration.lineIndex + 1,
        endLine: end,
        text: lines.slice(declaration.lineIndex, end).join('\n'),
      };
      const matches = index.get(declaration.symbol) ?? [];
      matches.push(definition);
      index.set(declaration.symbol, matches);
    });
  }
  functionIndexCache.set(canonicalRoot, index);
  return index;
}

function readableLabel(symbol: string): string {
  return symbol
    .replaceAll('_', ' ')
    .replace(/([a-z0-9])([A-Z])/g, '$1 $2')
    .replace(/([A-Z]+)([A-Z][a-z])/g, '$1 $2')
    .replace(/\s+/g, ' ')
    .trim();
}

function floatingFusedExecution(
  index: ReadonlyMap<string, readonly Required<IndexedFunction>[]>,
  ownerFunctions: ManualAslFunctionRegion[],
): Required<IndexedFunction> | null | undefined {
  const selectsFusedHandler = ownerFunctions.some((definition) =>
    /return\s+ScalarHandler_FloatingFused\s*;/.test(definition.text),
  );
  if (!selectsFusedHandler) return undefined;

  const operation = ownerFunctions
    .map((definition) => definition.text.match(/return\s+ScalarOperation_([A-Z0-9_]+)\s*;/)?.[1])
    .find((value): value is string => value !== undefined);
  if (operation === undefined) return null;

  const dispatch = new RegExp(
    `when\\s+ScalarOperation_${operation}\\s*=>\\s*([A-Za-z_][A-Za-z0-9_]*)\\s*\\(`,
  );
  const dispatcher = index.get('ExecuteDecodedFSUForm') ?? [];
  if (dispatcher.length !== 1 ||
      dispatcher[0].sourcePath !== 'asl/scalar/model/dispatch/fsu.asl') return null;
  const calledSymbol = dispatcher[0].text.match(dispatch)?.[1];
  if (calledSymbol === undefined) return null;
  const definitions = index.get(calledSymbol) ?? [];
  return definitions.length === 1 ? definitions[0] : null;
}

export function projectManualAsl(
  root: string,
  release: ManualAslRelease,
  ownerId: string,
  ownerSourcePath: string,
): ManualAslProjection {
  const sourceText = readFileSync(path.join(root, ownerSourcePath), 'utf8').replace(/\r\n?/g, '\n');
  const sourceSha256 = sha256(sourceText);
  const lines = sourceText.split('\n');
  const missingSymbols: string[] = [];
  const functions: ManualAslFunctionRegion[] = [];

  for (const phase of ['decode', 'operation'] as const) {
    const region = regionLines(lines, phase);
    if (region === null) {
      missingSymbols.push(`${phase} DOC region`);
      continue;
    }
    const definitions = functionsInRegion(lines, region);
    if (definitions.length === 0) {
      missingSymbols.push(`${phase} function`);
      continue;
    }
    for (const definition of definitions) {
      const fragmentSha256 = sha256(definition.text);
      const label = readableLabel(definition.symbol);
      functions.push({
        symbol: definition.symbol,
        phase,
        role: 'owner',
        label: {en: label, 'zh-CN': label},
        purpose: {
          en: `Exact ${phase} definition from the instruction owner.`,
          'zh-CN': `来自指令 owner 的精确 ${phase} 定义。`,
        },
        sourcePath: ownerSourcePath,
        sourceUrl: `${GITHUB_REPOSITORY}/blob/${release.commit}/${ownerSourcePath}` +
          `#L${definition.startLine}-L${definition.endLine}`,
        sourceAssetUrl: `/evidence/asl-fragments/${fragmentSha256}.asl`,
        sourceSha256,
        fragmentSha256,
        startLine: definition.startLine,
        endLine: definition.endLine,
        text: definition.text,
      });
    }
  }

  const index = functionIndex(root);
  const sharedExecution = floatingFusedExecution(index, functions);
  if (sharedExecution === null) {
    missingSymbols.push('shared fused execution in the scalar FSU dispatcher');
  } else if (sharedExecution !== undefined) {
    const fragmentSha256 = sha256(sharedExecution.text);
    const label = readableLabel(sharedExecution.symbol);
    functions.push({
      symbol: sharedExecution.symbol,
      phase: 'operation',
      role: 'shared',
      label: {en: label, 'zh-CN': label},
      purpose: {
        en: 'Exact shared execution selected for this instruction by the scalar dispatcher.',
        'zh-CN': 'Scalar dispatcher 为该指令选择的精确共享执行定义。',
      },
      sourcePath: sharedExecution.sourcePath,
      sourceUrl: `${GITHUB_REPOSITORY}/blob/${release.commit}/${sharedExecution.sourcePath}` +
        `#L${sharedExecution.startLine}-L${sharedExecution.endLine}`,
      sourceAssetUrl: `/evidence/asl-fragments/${fragmentSha256}.asl`,
      sourceSha256: sha256(readFileSync(path.join(root, sharedExecution.sourcePath), 'utf8')),
      fragmentSha256,
      startLine: sharedExecution.startLine,
      endLine: sharedExecution.endLine,
      text: sharedExecution.text,
    });
  }

  const ownerSymbols = new Set(functions.map((definition) => definition.symbol));
  const referencedSymbols = new Set(functions.flatMap((definition) =>
    [...definition.text.matchAll(FUNCTION_CALL)].map((match) => match[1]),
  ));
  const references: ManualAslReference[] = [...referencedSymbols]
    .filter((symbol) => !ownerSymbols.has(symbol))
    .flatMap((symbol) => {
      const matches = index.get(symbol) ?? [];
      if (matches.length !== 1) return [];
      const definition = matches[0];
      const fragmentSha256 = sha256(definition.text);
      return [{
        symbol,
        sourcePath: definition.sourcePath,
        sourceUrl: `${GITHUB_REPOSITORY}/blob/${release.commit}/${definition.sourcePath}` +
          `#L${definition.startLine}-L${definition.endLine}`,
        sourceAssetUrl: `/evidence/asl-fragments/${fragmentSha256}.asl`,
        fragmentSha256,
        startLine: definition.startLine,
        endLine: definition.endLine,
        text: definition.text,
      }];
    })
    .sort((left, right) => left.symbol.localeCompare(right.symbol));

  return {
    owner: ownerId,
    status: missingSymbols.length === 0 ? 'complete' : 'source-gap',
    functions,
    references,
    missingSymbols,
  };
}
