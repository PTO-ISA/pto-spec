export interface UnitRouteInput {
  id: string;
  mnemonic: string | null;
  source: string;
  surface: string;
  classification: string[];
  documentation: string;
}

export function unitRoute(unit: UnitRouteInput): string {
  if (unit.mnemonic === null) {
    return `/units/${encodeURIComponent(unit.id)}/`;
  }
  const sourceName = unit.source.split('/').at(-1) ?? unit.mnemonic;
  const stem = sourceName.endsWith('.asl') ? sourceName.slice(0, -4) : sourceName;
  const segments = ['instructions', unit.surface, ...unit.classification, stem]
    .map((segment) => encodeURIComponent(segment));
  return `/${segments.join('/')}/`;
}

export function legacyReferenceRoute(documentationPath: string): string {
  if (!documentationPath.startsWith('docs/') || !documentationPath.endsWith('.md')) {
    throw new TypeError(`cannot derive reference route for ${documentationPath}`);
  }
  let relative = documentationPath.slice('docs/'.length, -'.md'.length);
  if (relative.endsWith('/index')) relative = relative.slice(0, -'/index'.length);
  return `/reference/${relative}/`.replace(/\/+/g, '/');
}
