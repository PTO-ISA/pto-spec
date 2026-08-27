import React, {useMemo, useState} from 'react';
import Link from '@docusaurus/Link';
import {useLocation} from '@docusaurus/router';
import type {PtoNdfCatalogData} from '@site/src/types/pto';
import PortalShell from '@site/src/components/PortalShell';
import styles from '@site/src/components/CatalogIndex.module.css';

export default function NdfCatalog({catalog}: {catalog: PtoNdfCatalogData}): React.JSX.Element {
  const location = useLocation();
  const chinese = location.pathname.startsWith('/zh-CN/');
  const [query, setQuery] = useState('');
  const entries = useMemo(() => {
    const normalized = query.trim().toLocaleLowerCase();
    return catalog.entries.filter((entry) => !normalized || [
      entry.id,
      entry.kind,
      entry.level,
      entry.layer,
      entry.status,
      entry.text ?? '',
      entry.sourcePath,
      ...entry.owners.map((owner) => owner.mnemonic ?? owner.id),
    ].join(' ').toLocaleLowerCase().includes(normalized));
  }, [catalog.entries, query]);
  const title = chinese ? 'NDF 索引' : 'NDF index';
  return (
    <PortalShell title={title} description={title} currentPageLabel={title}>
      <main className={styles.page}>
        <header className={styles.hero}>
          <div>
            <div className={styles.kicker}>{chinese ? '原始条款与 owning unit' : 'Original clauses and owning units'}</div>
            <h1>{title}</h1>
            <p>{chinese
              ? '每个稳定 NDF ID 都有可读详情页、canonical source identity，以及对应 instruction/unit workbench 链接。'
              : 'Every stable NDF ID has a readable detail page, canonical source identity, and links to its instruction or unit workbenches.'}</p>
          </div>
          <div className={styles.count}>{catalog.entries.length}</div>
        </header>
        <section className={styles.controls} aria-label={chinese ? 'NDF 筛选' : 'NDF filters'}>
          <input
            type="search"
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder={chinese ? '搜索 ID、正文、owner 或源路径' : 'Search ID, body, owner, or source path'}
            aria-label={chinese ? '搜索 NDF' : 'Search NDF'}
          />
          <div className={styles.resultLine} role="status">{entries.length} / {catalog.entries.length}</div>
        </section>
        <section className={styles.grid} aria-label={title}>
          {entries.map((entry) => (
            <article className={styles.card} key={entry.id} id={`index-${entry.id.toLocaleLowerCase()}`}>
              <div className={styles.identity}>{entry.id}</div>
              <h2><Link to={entry.route}>{entry.kind}</Link></h2>
              <div className={styles.meta}>{entry.level} · {entry.layer} · {entry.status}</div>
              <p className={styles.summary}>{entry.text ?? (chinese
                ? '该稳定身份由 instruction contract 拥有；链接直接打开 canonical unit workbench。'
                : 'This stable identity is owned by an instruction contract; the link opens its canonical unit workbench directly.')}</p>
              <ul className={styles.owners} aria-label={chinese ? '相关 owner' : 'Related owners'}>
                {entry.owners.slice(0, 4).map((owner) => (
                  <li key={owner.id}><Link to={owner.route}>{owner.mnemonic ?? owner.id}</Link></li>
                ))}
              </ul>
            </article>
          ))}
        </section>
      </main>
    </PortalShell>
  );
}
