import BrowserOnly from '@docusaurus/BrowserOnly';
import Link from '@docusaurus/Link';
import {useLocation} from '@docusaurus/router';
import React, {useEffect, useMemo, useRef, useState} from 'react';
import type {PtoNdfGraphData} from '@site/src/types/pto';
import styles from './PtoWorkbench.module.css';
import {firstText, list, record, sourceHref, text, type UnknownRecord} from './data';
import {useLocalizedPath} from './releasePresentation';

declare const require: (moduleId: string) => unknown;

interface PlotlyApi {
  react(element: HTMLDivElement, data: unknown[], layout: UnknownRecord, config: UnknownRecord): Promise<void>;
  purge(element: HTMLDivElement): void;
}

type PlotlyModule = PlotlyApi & {default?: PlotlyApi};

interface PlotlyElement extends HTMLDivElement {
  on(event: 'plotly_click', listener: (event: {points?: Array<{customdata?: number}>}) => void): void;
  removeListener?(event: 'plotly_click', listener: (event: {points?: Array<{customdata?: number}>}) => void): void;
}

function supportsFullGraph(): boolean {
  if (window.matchMedia('(max-width: 996px)').matches) return false;
  try {
    const canvas = document.createElement('canvas');
    return Boolean(canvas.getContext('webgl2') || canvas.getContext('webgl'));
  } catch {
    return false;
  }
}

function nodeId(node: UnknownRecord, index: number): string {
  return firstText(node, ['id', 'clauseId', 'name'], `node-${index}`);
}

function NodeDetails({node, relationships = []}: {node?: UnknownRecord; relationships?: UnknownRecord[]}): React.JSX.Element {
  if (!node) return <p>Select a node from the graph or index to inspect its released identity.</p>;
  const id = firstText(node, ['id', 'clauseId', 'name']);
  const kind = firstText(node, ['kind', 'type', 'layer']);
  const body = firstText(node, ['body', 'text', 'summary', 'label']);
  const path = firstText(node, ['path', 'sourcePath']);
  const sourceSha = firstText(node, ['sourceSha256']);
  const clauseSha = firstText(node, ['clauseSha256']);
  const startLine = Number(node.startLine ?? 0);
  const endLine = Number(node.endLine ?? 0);
  const href = sourceHref(record(node.source)) || sourceHref(node);
  return (
    <>
      <span className={styles.eyebrow}>Selected released node</span>
      <h2>{id}</h2>
      {kind && <p><strong>Kind:</strong> {kind}</p>}
      {body && <p>{body}</p>}
      {path && <p><code>{path}{startLine > 0 ? `:${startLine}${endLine > startLine ? `-${endLine}` : ''}` : ''}</code></p>}
      {sourceSha && <p>Source SHA-256: <code>{sourceSha}</code></p>}
      {clauseSha && <p>Clause SHA-256: <code>{clauseSha}</code></p>}
      {href && <a href={href}>Open exact source ↗</a>}
      <details>
        <summary>{relationships.length} relationships</summary>
        <ul>
          {relationships.slice(0, 100).map((relationship, index) => (
            <li key={`${firstText(relationship, ['id', 'kind'])}-${index}`}>
              <code>{firstText(relationship, ['source'])}</code> →{' '}
              <code>{firstText(relationship, ['target'])}</code>{' '}
              ({firstText(relationship, ['kind'])})
            </li>
          ))}
        </ul>
        {relationships.length > 100 && <p>Showing 100 of {relationships.length} relationships.</p>}
      </details>
    </>
  );
}

function GraphIndex({nodes, selected, onSelect, initialQuery = ''}: {nodes: UnknownRecord[]; selected?: string; onSelect: (node: UnknownRecord) => void; initialQuery?: string}): React.JSX.Element {
  const staticIndexPath = useLocalizedPath('/explore/ndf/index/1/');
  const [query, setQuery] = useState(initialQuery);
  const normalized = query.trim().toLocaleLowerCase();
  const matches = normalized
    ? nodes.filter((node, index) => `${nodeId(node, index)} ${firstText(node, ['kind', 'type', 'layer', 'path', 'sourcePath'])}`.toLocaleLowerCase().includes(normalized))
    : nodes;
  return (
    <div className={styles.fallback}>
      <label htmlFor="ndf-node-search"><strong>NDF node index</strong></label>
      <input id="ndf-node-search" type="search" value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search clause ID, layer, path…" />
      <p role="status" aria-live="polite">{matches.length} nodes</p>
      <ul className={styles.nodeList}>
        {matches.slice(0, 250).map((node, index) => {
          const id = nodeId(node, index);
          const href = sourceHref(node);
          return (
            <li className={styles.nodeRow} key={`${id}-${index}`}>
              <button className={styles.nodeButton} type="button" aria-current={selected === id ? 'true' : undefined} onClick={() => onSelect(node)}>
                <code>{id}</code>
                <span>{firstText(node, ['kind', 'type', 'layer'])}</span>
              </button>
              {href && <a href={href} aria-label={`Open exact source for ${id}`}>Source ↗</a>}
            </li>
          );
        })}
      </ul>
      {matches.length > 250 && <p>Showing the first 250 entries. Refine the filter to inspect the remaining {matches.length - 250} nodes.</p>}
      <p><Link to={staticIndexPath}>Browse the complete static relationship index →</Link></p>
    </div>
  );
}

function WebGlExplorer({graph, initialQuery}: {graph: PtoNdfGraphData; initialQuery: string}): React.JSX.Element {
  const graphData = record(graph);
  const nodes = useMemo(() => list(graphData.nodes).map(record), [graphData.nodes]);
  const edges = useMemo(() => list(graphData.edges).map(record), [graphData.edges]);
  const [selected, setSelected] = useState<UnknownRecord | undefined>();
  const [enabled, setEnabled] = useState(false);
  const [capable, setCapable] = useState(false);
  const [error, setError] = useState('');
  const [theme, setTheme] = useState('light');
  const plotRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    setCapable(supportsFullGraph());
    setTheme(document.documentElement.dataset.theme ?? 'light');
    const observer = new MutationObserver(() => setTheme(document.documentElement.dataset.theme ?? 'light'));
    observer.observe(document.documentElement, {attributes: true, attributeFilter: ['data-theme']});
    return () => observer.disconnect();
  }, []);

  useEffect(() => {
    if (!enabled || !capable || !plotRef.current) return undefined;
    let alive = true;
    let api: PlotlyApi | undefined;
    const plotElement = plotRef.current;

    let select: ((event: {points?: Array<{customdata?: number}>}) => void) | undefined;
    // The effect runs only in the browser; the dynamic import also keeps the
    // reviewed gl2d bundle out of the server renderer and initial page chunk.
    void import('plotly.js').then((loaded) => {
      if (!alive) return;
      const coreModule = loaded as PlotlyModule;
      api = coreModule.default ?? coreModule;
      const byId = new Map(nodes.map((node, index) => [nodeId(node, index), node]));
      const x = nodes.map((node, index) => Number(node.x ?? index % 64));
      const y = nodes.map((node, index) => Number(node.y ?? Math.floor(index / 64)));
      const edgeX: Array<number | null> = [];
      const edgeY: Array<number | null> = [];
      for (const edge of edges) {
        const from = byId.get(firstText(edge, ['source', 'from', 'sourceId']));
        const to = byId.get(firstText(edge, ['target', 'to', 'targetId']));
        if (!from || !to) continue;
        edgeX.push(Number(from.x ?? x[nodes.indexOf(from)]), Number(to.x ?? x[nodes.indexOf(to)]), null);
        edgeY.push(Number(from.y ?? y[nodes.indexOf(from)]), Number(to.y ?? y[nodes.indexOf(to)]), null);
      }
      const dark = theme === 'dark';
      const themeStyle = getComputedStyle(document.documentElement);
      const cssColor = (name: string, fallback: string) => themeStyle.getPropertyValue(name).trim() || fallback;
      const colorByKind: Record<string, string> = {
        ndf: cssColor('--ifm-color-primary', '#1688b8'),
        asl: cssColor('--ifm-color-info-dark', '#486fd1'),
        avs: cssColor('--ifm-color-success-dark', '#2f8d60'),
        adr: cssColor('--ifm-color-warning-dark', '#98691d'),
      };
      const edgeColor = cssColor('--ifm-color-emphasis-400', dark ? '#526070' : '#bcc6d1');
      void api.react(plotElement, [
        {type: 'scattergl', mode: 'lines', x: edgeX, y: edgeY, hoverinfo: 'skip', line: {color: edgeColor, width: 1}},
        {
          type: 'scattergl', mode: 'markers', x, y,
          text: nodes.map((node, index) => `${nodeId(node, index)} · ${firstText(node, ['kind'], 'node')}`),
          customdata: nodes.map((_, index) => index),
          hovertemplate: '%{text}<extra></extra>',
          marker: {color: nodes.map((node) => colorByKind[firstText(node, ['kind'])] ?? '#13a8d2'), size: 7, opacity: .88},
        },
      ], {
        autosize: true, dragmode: 'pan', hovermode: 'closest', margin: {l: 16, r: 16, t: 16, b: 16},
        paper_bgcolor: 'rgba(0,0,0,0)', plot_bgcolor: 'rgba(0,0,0,0)',
        xaxis: {visible: false, fixedrange: false}, yaxis: {visible: false, fixedrange: false}, showlegend: false,
      }, {responsive: true, displaylogo: false, scrollZoom: true}).then(() => {
        if (!alive || !plotElement) return;
        select = (event) => {
          const index = event.points?.[0]?.customdata;
          if (typeof index === 'number') setSelected(nodes[index]);
        };
        (plotElement as PlotlyElement).on('plotly_click', select);
      }).catch((reason: unknown) => {
        if (alive) setError(reason instanceof Error ? reason.message : 'Unable to initialize WebGL explorer.');
      });
    }).catch((reason: unknown) => {
      if (alive) setError(reason instanceof Error ? reason.message : 'Unable to load the WebGL explorer.');
    });

    return () => {
      alive = false;
      if (select) (plotElement as PlotlyElement).removeListener?.('plotly_click', select);
      if (api && plotElement) api.purge(plotElement);
    };
  }, [capable, edges, enabled, nodes, theme]);

  const selectedId = selected ? nodeId(selected, nodes.indexOf(selected)) : undefined;
  const selectedRelationships = selectedId
    ? edges.filter(
        (edge) =>
          firstText(edge, ['source']) === selectedId ||
          firstText(edge, ['target']) === selectedId,
      )
    : [];
  return (
    <>
      <div className={styles.toolbar}>
        {capable && <button className={styles.button} type="button" onClick={() => setEnabled((value) => !value)}>{enabled ? 'Close WebGL graph' : 'Open WebGL graph'}</button>}
        <span>{capable ? 'Desktop WebGL available. The graph loads only on request.' : 'Index fallback active for this browser or viewport.'}</span>
      </div>
      {error && <div className="alert alert--warning" role="alert">WebGL view unavailable: {error}. The complete index remains available.</div>}
      <div className={styles.graphLayout}>
        {capable && enabled && <div ref={plotRef} className={styles.plot} role="img" aria-label={`Interactive NDF graph with ${nodes.length} nodes and ${edges.length} relationships`} />}
        {(!capable || !enabled) && <GraphIndex nodes={nodes} selected={selectedId} onSelect={setSelected} initialQuery={initialQuery} />}
        <aside className={styles.detailPanel} aria-live="polite"><NodeDetails node={selected} relationships={selectedRelationships} /></aside>
      </div>
      {capable && enabled && (
        <details className={styles.section}>
          <summary>Keyboard-accessible node index</summary>
          <GraphIndex nodes={nodes} selected={selectedId} onSelect={setSelected} initialQuery={initialQuery} />
        </details>
      )}
    </>
  );
}

export default function NdfGlobalExplorer({graph}: {graph: PtoNdfGraphData}): React.JSX.Element {
  const location = useLocation();
  const data = record(graph);
  const nodes = list(data.nodes).map(record);
  const initialQuery = new URLSearchParams(location.search).get('q') ?? '';
  return (
    <BrowserOnly fallback={<GraphIndex nodes={nodes} onSelect={() => undefined} initialQuery={initialQuery} />}>
      {() => <WebGlExplorer graph={graph} initialQuery={initialQuery} />}
    </BrowserOnly>
  );
}
