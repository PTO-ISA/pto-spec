export type UnknownRecord = Record<string, unknown>;

export function record(value: unknown): UnknownRecord {
  return value !== null && typeof value === 'object' && !Array.isArray(value)
    ? (value as UnknownRecord)
    : {};
}

export function list(value: unknown): unknown[] {
  return Array.isArray(value) ? value : [];
}

export function text(value: unknown, fallback = ''): string {
  return typeof value === 'string' || typeof value === 'number'
    ? String(value)
    : fallback;
}

export function bool(value: unknown): boolean {
  return value === true;
}

export function firstText(source: UnknownRecord, keys: string[], fallback = ''): string {
  for (const key of keys) {
    const value = text(source[key]);
    if (value) return value;
  }
  return fallback;
}

export function sourceHref(source: UnknownRecord): string {
  return firstText(source, ['githubUrl', 'permalink', 'url', 'sourceUrl', 'href']);
}

export function itemSearchText(item: UnknownRecord): string {
  return Object.values(item)
    .filter((value) => typeof value === 'string' || typeof value === 'number')
    .join(' ')
    .toLocaleLowerCase();
}
