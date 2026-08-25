import Link from '@docusaurus/Link';
import {useLocation} from '@docusaurus/router';
import React, {useEffect, useMemo, useState} from 'react';
import type {PtoSearchData, PtoSearchEntryKind} from '@site/src/types/pto';
import styles from './PtoWorkbench.module.css';
import {useLocalizedPath} from './releasePresentation';

type SearchKind = 'all' | PtoSearchEntryKind;
type SearchSurface = 'all' | 'arch' | 'scalar' | 'block' | 'tile';

const kindLabels: Record<SearchKind, string> = {
  all: 'All identities',
  asl: 'ASL units',
  ndf: 'NDF clauses',
  avs: 'AVS evidence',
  adr: 'ADRs',
};

const surfaceLabels: Record<SearchSurface, string> = {
  all: 'All surfaces',
  arch: 'Architecture',
  scalar: 'Scalar',
  block: 'Block',
  tile: 'Tile',
};

function ResultLink({url, children}: {url: string; children: React.ReactNode}): React.JSX.Element {
  const localizedUrl = useLocalizedPath(url);
  return /^https?:\/\//.test(url)
    ? <a href={url}>{children}</a>
    : <Link to={localizedUrl}>{children}</Link>;
}

export default function SearchWorkbench({search}: {search: PtoSearchData}): React.JSX.Element {
  const location = useLocation();
  const [query, setQuery] = useState('');
  const [kind, setKind] = useState<SearchKind>('all');
  const [surface, setSurface] = useState<SearchSurface>('all');
  const searchPath = useLocalizedPath('/search/');
  const tloadPath = useLocalizedPath(
    '/instructions/tile/memory-and-data-movement/regular/TLOAD/',
  );
  const ndfExplorerPath = useLocalizedPath('/explore/ndf/');

  useEffect(() => {
    const params = new URLSearchParams(location.search);
    setQuery(params.get('q') ?? '');
    const requestedKind = params.get('kind');
    setKind(requestedKind && requestedKind in kindLabels ? requestedKind as SearchKind : 'all');
    const requestedSurface = params.get('surface');
    setSurface(
      requestedSurface && requestedSurface in surfaceLabels
        ? requestedSurface as SearchSurface
        : 'all',
    );
  }, [location.search]);

  const normalized = query.trim().toLocaleLowerCase();
  const hasCriteria = Boolean(normalized) || kind !== 'all' || surface !== 'all';
  const results = useMemo(() => {
    if (!hasCriteria) return [];
    return search.entries.filter((entry) => {
      if (kind !== 'all' && entry.kind !== kind) return false;
      if (surface !== 'all' && entry.surface !== surface) return false;
      if (!normalized) return true;
      const haystack = [entry.id, entry.label, entry.path, ...entry.keywords].join(' ').toLocaleLowerCase();
      return haystack.includes(normalized);
    });
  }, [hasCriteria, kind, normalized, search.entries, surface]);
  const visibleResults = results.slice(0, 100);

  return (
    <section className={styles.section} aria-labelledby="search-workbench-heading">
      <h2 id="search-workbench-heading">Search released identities</h2>
      <p>Search the build-generated release index by mnemonic, NDF identity, ASL unit, AVS test, ADR, engine, family, or exact source path.</p>
      <form className={styles.searchForm} action={searchPath} method="get" role="search">
        <label htmlFor="spec-search-query">Identity, mnemonic, or source path</label>
        <div className={styles.searchRow}>
          <input
            id="spec-search-query"
            name="q"
            type="search"
            autoComplete="off"
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder="Try TLOAD, PTO-TLOAD-MEMORY-001, TLSU…"
          />
          <label className={styles.srOnly} htmlFor="spec-search-kind">Filter result kind</label>
          <select id="spec-search-kind" name="kind" value={kind} onChange={(event) => setKind(event.target.value as SearchKind)}>
            {Object.entries(kindLabels).map(([value, label]) => <option value={value} key={value}>{label}</option>)}
          </select>
          <label className={styles.srOnly} htmlFor="spec-search-surface">Filter ASL surface</label>
          <select id="spec-search-surface" name="surface" value={surface} onChange={(event) => setSurface(event.target.value as SearchSurface)}>
            {Object.entries(surfaceLabels).map(([value, label]) => <option value={value} key={value}>{label}</option>)}
          </select>
          <button className={styles.button} type="submit">Search</button>
        </div>
      </form>
      <noscript>
        <div className="alert alert--info">JavaScript enables local filtering. You can still open the <a href={tloadPath}>TLOAD workbench</a> or browse exact released sources on GitHub.</div>
      </noscript>
      {!hasCriteria && (
        <div className={styles.fallback}>
          <strong>Start with a stable identity.</strong>
          <p>The search index is generated from the same release commit as the ASL, NDF, AVS, and ADR artifacts. Results never create replacement specification text.</p>
          <Link to={tloadPath}>Open the TLOAD demonstration →</Link>
        </div>
      )}
      {hasCriteria && (
        <>
          <p role="status" aria-live="polite">{results.length} matching {results.length === 1 ? 'identity' : 'identities'} in {kindLabels[kind]} · {surfaceLabels[surface]}</p>
          {results.length === 0 ? <div className={styles.fallback}>No released identity matches this query. Check the spelling or search all identity kinds.</div> : (
            <ol className={styles.searchResults}>
              {visibleResults.map((entry) => (
                <li className={styles.searchResult} key={`${entry.kind}-${entry.id}`}>
                  <div>
                    <span className={styles.badge}>{entry.kind}</span>
                    <h3><ResultLink url={entry.url}>{entry.label}</ResultLink></h3>
                    <code>{entry.id}</code>
                    <p>{entry.path}</p>
                  </div>
                  <div className={styles.resultActions}>
                    <ResultLink url={entry.url}>{entry.kind === 'asl' && entry.label === 'TLOAD' ? 'Open workbench' : 'Open exact source'} ↗</ResultLink>
                    {entry.kind === 'ndf' && <Link to={`${ndfExplorerPath}?q=${encodeURIComponent(entry.id)}`}>Explore relationships →</Link>}
                  </div>
                </li>
              ))}
            </ol>
          )}
          {results.length > visibleResults.length && <p>Showing the first {visibleResults.length} identities. Refine the query or kind filter to inspect the remaining {results.length - visibleResults.length}.</p>}
        </>
      )}
    </section>
  );
}
