import React, {useMemo, useState} from 'react';
import Link from '@docusaurus/Link';
import {useHistory, useLocation} from '@docusaurus/router';
import type {PtoInstructionIndexData} from '@site/src/types/pto';
import PortalShell from '@site/src/components/PortalShell';
import styles from '@site/src/components/CatalogIndex.module.css';

type Surface = 'all' | 'scalar' | 'block' | 'tile';

function surfaceFromSearch(search: string): Surface {
  const surface = new URLSearchParams(search).get('surface');
  return surface === 'scalar' || surface === 'block' || surface === 'tile' ? surface : 'all';
}

export default function InstructionIndex({index}: {index: PtoInstructionIndexData}): React.JSX.Element {
  const history = useHistory();
  const location = useLocation();
  const chinese = location.pathname.startsWith('/zh-CN/');
  const surface = surfaceFromSearch(location.search);
  const [query, setQuery] = useState('');
  const selectSurface = (nextSurface: Surface): void => {
    const params = new URLSearchParams(location.search);
    if (nextSurface === 'all') {
      params.delete('surface');
    } else {
      params.set('surface', nextSurface);
    }
    const search = params.toString();
    history.push(`${location.pathname}${search ? `?${search}` : ''}`);
  };
  const entries = useMemo(() => {
    const normalized = query.trim().toLocaleLowerCase();
    return index.entries.filter((entry) =>
      (surface === 'all' || entry.surface === surface) &&
      (!normalized || [entry.mnemonic, entry.id, entry.sourcePath, ...entry.classification]
        .join(' ').toLocaleLowerCase().includes(normalized)),
    );
  }, [index.entries, query, surface]);
  const title = chinese ? '指令索引' : 'Instruction index';
  return (
    <PortalShell title={title} description={title} currentPageLabel={title}>
      <main className={styles.page}>
        <header className={styles.hero}>
          <div>
            <div className={styles.kicker}>{chinese ? '单一 canonical workbench' : 'One canonical workbench'}</div>
            <h1>{title}</h1>
            <p>{chinese
              ? '浏览全部已发布 Scalar、Block 与 Tile 指令；每个条目只进入一个融合 Markdown、ASL、NDF 和证据的页面。'
              : 'Browse every released Scalar, Block, and Tile instruction. Each entry opens one page that combines Markdown, ASL, NDF, and evidence.'}</p>
          </div>
          <div className={styles.count}>{index.entries.length}</div>
        </header>
        <section className={styles.controls} aria-label={chinese ? '指令筛选' : 'Instruction filters'}>
          <input
            type="search"
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder={chinese ? '搜索 mnemonic、ID、family 或源路径' : 'Search mnemonic, ID, family, or source path'}
            aria-label={chinese ? '搜索指令' : 'Search instructions'}
          />
          <div className={styles.filters}>
            {(['all', 'scalar', 'block', 'tile'] as const).map((value) => (
              <button key={value} type="button" aria-pressed={surface === value} onClick={() => selectSurface(value)}>
                {value === 'all' ? (chinese ? '全部' : 'All') : value[0].toLocaleUpperCase() + value.slice(1)}
              </button>
            ))}
          </div>
        </section>
        <p className={styles.resultLine} role="status">{entries.length} {chinese ? '条指令' : 'instructions'}</p>
        <section className={styles.grid} aria-label={title}>
          {entries.map((entry) => (
            <article className={styles.card} key={entry.id}>
              <div className={styles.identity}>{entry.id}</div>
              <h2><Link to={entry.route}>{entry.mnemonic}</Link></h2>
              <div className={styles.meta}>{entry.surface} · {entry.classification.join(' / ')}</div>
              {entry.summary && <p className={styles.summary}>{entry.summary}</p>}
              <code className={styles.meta}>{entry.sourcePath}</code>
            </article>
          ))}
        </section>
      </main>
    </PortalShell>
  );
}
