import React, {useEffect, useMemo, useState} from 'react';
import styles from './PtoWorkbench.module.css';
import {firstText, itemSearchText, list, record, sourceHref, type UnknownRecord} from './data';
import AslCode from './AslCode';
import {ReaderNodes} from './ReaderGuide';
import SemanticIdPath, {CopyIdentityButton} from './SemanticIdPath';
import type {PtoReaderNode, PtoSemanticIdentity} from '@site/src/types/pto';

interface EvidenceGroup {
  id: string;
  label: string;
  items: UnknownRecord[];
}

function DecisionRecord({id, url}: {id: string; url: string}): React.JSX.Element {
  const [nodes, setNodes] = useState<PtoReaderNode[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let active = true;
    void fetch(url)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json() as Promise<PtoReaderNode[]>;
      })
      .then((value) => {
        if (!Array.isArray(value)) throw new TypeError('Decision asset must be an array');
        if (active) setNodes(value);
      })
      .catch((reason: unknown) => {
        if (active) setError(`Decision record could not be loaded: ${String(reason)}`);
      });
    return () => { active = false; };
  }, [url]);

  return (
    <div className={styles.decisionBody}>
      <h4>Decision record</h4>
      {nodes === null && error === null && <p role="status">Loading {id}…</p>}
      {error && <p role="alert">{error}</p>}
      {nodes !== null && <ReaderNodes nodes={nodes} />}
    </div>
  );
}

export interface EvidenceIndexProps {
  tests?: unknown;
  adrs?: unknown;
  evidence?: unknown;
}

const PAGE_SIZE = 50;

function EvidenceSource({id, url}: {id: string; url: string}): React.JSX.Element {
  const [source, setSource] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  function loadSource(event: React.SyntheticEvent<HTMLDetailsElement>): void {
    if (!event.currentTarget.open || source !== null || loading) return;
    setLoading(true);
    setError(null);
    void fetch(url)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.text();
      })
      .then((value) => setSource(value))
      .catch((reason: unknown) => setError(`Exact source could not be loaded: ${String(reason)}`))
      .finally(() => setLoading(false));
  }

  return (
    <details className={styles.evidenceSource} onToggle={loadSource}>
      <summary>Show exact test source</summary>
      {loading && <p role="status">Loading exact commit-scoped source…</p>}
      {error && <p role="alert">{error}</p>}
      {source !== null && (
        <div className={styles.source} tabIndex={0}>
          <AslCode text={source} label={`Exact test source for ${id}`} />
        </div>
      )}
    </details>
  );
}

export default function EvidenceIndex({tests, adrs, evidence}: EvidenceIndexProps): React.JSX.Element {
  const [query, setQuery] = useState('');
  const [openGroups, setOpenGroups] = useState<Set<string>>(new Set(['adrs']));
  const [pages, setPages] = useState<Record<string, number>>({});
  const groups = useMemo<EvidenceGroup[]>(() => [
    {id: 'tests', label: 'Executable evidence', items: list(tests).map(record)},
    {id: 'evidence', label: 'Commit-scoped evidence', items: list(evidence).map(record)},
    {id: 'adrs', label: 'Decision history', items: list(adrs).map(record)},
  ].filter((group) => group.items.length > 0), [adrs, evidence, tests]);
  const normalized = query.trim().toLocaleLowerCase();
  const filtered = groups.map((group) => ({
    ...group,
    items: normalized ? group.items.filter((item) => itemSearchText(item).includes(normalized)) : group.items,
  }));
  const resultCount = filtered.reduce((sum, group) => sum + group.items.length, 0);

  useEffect(() => setPages({}), [normalized]);

  function setAll(open: boolean): void {
    setOpenGroups(open ? new Set(groups.map((group) => group.id)) : new Set());
  }

  function toggle(id: string, open: boolean): void {
    setOpenGroups((current) => {
      const next = new Set(current);
      if (open) next.add(id); else next.delete(id);
      return next;
    });
  }

  return (
    <section className={styles.section} aria-labelledby="evidence-heading">
      <h2 id="evidence-heading">Evidence index</h2>
      <div className={styles.toolbar} role="search">
        <label className={styles.srOnly} htmlFor="evidence-search">Search evidence by identity or path</label>
        <input id="evidence-search" type="search" value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search ID, path, status…" />
        <button className={styles.button} type="button" onClick={() => setAll(true)}>Expand groups</button>
        <button className={styles.button} type="button" onClick={() => setAll(false)}>Collapse groups</button>
      </div>
      <p role="status" aria-live="polite">{resultCount} matching {resultCount === 1 ? 'entry' : 'entries'}</p>
      {filtered.map((group) => (
        <details className={styles.group} key={group.id} open={openGroups.has(group.id)} onToggle={(event) => toggle(group.id, event.currentTarget.open)}>
          <summary className={styles.disclosureSummary}><span>{group.label}</span><span>{group.items.length}</span></summary>
          {group.items.length === 0 ? <p>No entries match this filter.</p> : (
            <>
            <ul className={styles.evidenceList}>
              {group.items.slice((pages[group.id] ?? 0) * PAGE_SIZE, ((pages[group.id] ?? 0) + 1) * PAGE_SIZE).map((item, index) => {
                const id = firstText(item, ['id', 'testId', 'title', 'name'], `${group.label} ${index + 1}`);
                const path = firstText(item, ['path', 'sourcePath', 'artifact'], 'Source path unavailable');
                const status = firstText(item, ['status', 'result', 'outcome']);
                const href = sourceHref(record(item.source)) || sourceHref(item);
                const title = firstText(item, ['title', 'summary']);
                const requirements = list(item.requirements).map((value) => firstText(record({value}), ['value'])).filter(Boolean);
                const passCondition = firstText(item, ['passCondition']);
                const sourceAssetUrl = firstText(item, ['sourceAssetUrl']);
                const role = firstText(item, ['role', 'kind']);
                const hash = firstText(item, ['sha256', 'sourceSha256']);
                const decisionAssetUrl = firstText(item, ['decisionAssetUrl']);
                const identity = item.identity as PtoSemanticIdentity | undefined;
                const affectedUnits = list(item.affectedUnits).map(String);
                const affectedNdf = list(item.affectedNdf).map(String);
                return (
                  <li className={styles.evidenceItem} id={identity?.anchor} key={`${group.id}-${id}-${index}`}>
                    <details className={styles.evidenceEntry} open={decisionAssetUrl && index === 0 ? true : undefined}>
                      <summary>
                        <span className={styles.evidenceSummary}>{title || path}{status ? ` · ${status}` : ''}</span>
                        {identity ? <SemanticIdPath identity={identity} copyable={false} /> : <code>{id}</code>}
                      </summary>
                      {identity && <div className={styles.evidenceIdentityAction}><CopyIdentityButton identity={identity} /></div>}
                      {decisionAssetUrl && <DecisionRecord id={id} url={decisionAssetUrl} />}
                      {sourceAssetUrl && <EvidenceSource id={id} url={sourceAssetUrl} />}
                      <details className={styles.recordProvenance}>
                        <summary>Sources and references</summary>
                        <dl className={styles.evidenceDetails}>
                          <dt>Complete stable ID</dt><dd><code>{id}</code></dd>
                          <dt>Path</dt><dd><code>{path}</code></dd>
                          {role && <><dt>Kind / role</dt><dd>{role}</dd></>}
                          {requirements.length > 0 && <><dt>Requirements</dt><dd>{requirements.join(', ')}</dd></>}
                          {affectedUnits.length > 0 && <><dt>Affected units</dt><dd>{affectedUnits.join(', ')}</dd></>}
                          {affectedNdf.length > 0 && <><dt>Affected NDF</dt><dd>{affectedNdf.join(', ')}</dd></>}
                          {passCondition && <><dt>Pass condition</dt><dd>{passCondition}</dd></>}
                          {hash && <><dt>SHA-256</dt><dd><code>{hash}</code></dd></>}
                        </dl>
                        {href && <a href={href}>{decisionAssetUrl ? 'Open exact decision source' : 'Open exact source'} ↗<span className={styles.srOnly}> for {id}</span></a>}
                      </details>
                    </details>
                  </li>
                );
              })}
            </ul>
            {group.items.length > PAGE_SIZE && (
              <nav className={styles.evidencePagination} aria-label={`${group.label} pages`}>
                <button
                  className={styles.button}
                  type="button"
                  disabled={(pages[group.id] ?? 0) === 0}
                  onClick={() => setPages((current) => ({...current, [group.id]: Math.max(0, (current[group.id] ?? 0) - 1)}))}
                >Previous</button>
                <span>Page {(pages[group.id] ?? 0) + 1} of {Math.ceil(group.items.length / PAGE_SIZE)}</span>
                <button
                  className={styles.button}
                  type="button"
                  disabled={(pages[group.id] ?? 0) >= Math.ceil(group.items.length / PAGE_SIZE) - 1}
                  onClick={() => setPages((current) => ({...current, [group.id]: Math.min(Math.ceil(group.items.length / PAGE_SIZE) - 1, (current[group.id] ?? 0) + 1)}))}
                >Next</button>
              </nav>
            )}
            </>
          )}
        </details>
      ))}
    </section>
  );
}
