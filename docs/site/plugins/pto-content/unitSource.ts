import type {PtoSourceIdentity} from '../../src/types/pto';

const TILE_MACRO_RECORD = /^\/\/ PTO-TILEOP-MACRO(?:-CONTRACT)?: /;

export function inlineUnitSource(source: PtoSourceIdentity): PtoSourceIdentity {
  const lines = source.text.split('\n');
  if (!lines.some((line) => TILE_MACRO_RECORD.test(line))) return source;

  const sections: {text: string; startLine: number}[] = [];
  let start = 0;
  const append = (end: number) => {
    const text = lines.slice(start, end).join('\n');
    if (text.trim()) sections.push({text, startLine: start + 1});
  };
  for (const [index, line] of lines.entries()) {
    if (TILE_MACRO_RECORD.test(line)) {
      append(index);
      start = index + 1;
    }
  }
  append(lines.length);
  return {
    ...source,
    text: '',
    inlineExcerpt: {
      sections,
      completeAssetUrl: `/evidence/asl-fragments/${source.sha256}.asl`,
    },
  };
}
