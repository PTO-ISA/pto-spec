import React from 'react';
import Link from '@docusaurus/Link';
import {useLocation} from '@docusaurus/router';
import type {PtoNdfDetailData} from '@site/src/types/pto';
import PortalShell from '@site/src/components/PortalShell';
import NdfClause from '@site/src/components/NdfClause';
import EvidenceIndex from '@site/src/components/EvidenceIndex';
import styles from '@site/src/components/CatalogIndex.module.css';

export default function NdfDetail({detail}: {detail: PtoNdfDetailData}): React.JSX.Element {
  const chinese = useLocation().pathname.startsWith('/zh-CN/');
  return (
    <PortalShell
      title={`${detail.clause.id} · ${detail.clause.title[chinese ? 'zh-CN' : 'en']}`}
      description={detail.clause.summary[chinese ? 'zh-CN' : 'en']}
      currentPageLabel={detail.clause.id}>
      <main className={styles.page}>
        <header className={styles.hero}>
          <div>
            <div className={styles.kicker}>NDF · {detail.clause.kind} · {detail.clause.status}</div>
            <h1>{detail.clause.id}</h1>
            <p>{chinese ? '以下正文直接来自 canonical NDF owner。' : 'The body below comes directly from the canonical NDF owner.'}</p>
          </div>
          <div className={styles.count}>{detail.owners.length} {chinese ? '个 owner' : 'owners'}</div>
        </header>
        <NdfClause clauses={[detail.clause]} release={detail.release} chinese={chinese} />
        <section className={styles.detailOwners} aria-labelledby="ndf-owner-pages">
          <h2 id="ndf-owner-pages">{chinese ? '对应 instruction / unit 页面' : 'Instruction and unit pages'}</h2>
          <ul>
            {detail.owners.map((owner) => (
              <li key={owner.id}>
                <Link to={owner.route}>{owner.mnemonic ?? owner.id}</Link>
                <code>{owner.id}</code>
                <code>{owner.sourcePath}</code>
              </li>
            ))}
          </ul>
        </section>
        <section className={styles.detailOwners} aria-labelledby="ndf-relationships">
          <h2 id="ndf-relationships">{chinese ? '本地关系邻域' : 'Local relationship neighborhood'}</h2>
          {detail.relationships.length > 0 ? (
            <ul>
              {detail.relationships.map((relationship) => (
                <li key={`${relationship.kind}-${relationship.direction}-${relationship.node.id}`}>
                  <span>{relationship.kind} · {relationship.direction}</span>{' '}
                  {relationship.external
                    ? <a href={relationship.href}>{relationship.node.label}</a>
                    : <Link to={relationship.href}>{relationship.node.label}</Link>}
                  <code>{relationship.node.id}</code>
                </li>
              ))}
            </ul>
          ) : (
            <p>{chinese ? '此条款没有可显示的本地关系。' : 'No local relationships are available for this clause.'}</p>
          )}
          <p><Link to={detail.relationshipFallbackRoute}>{chinese ? '打开完整 NDF 关系浏览器' : 'Open the complete NDF relationship explorer'}</Link></p>
        </section>
        <EvidenceIndex tests={detail.tests} adrs={detail.adrs} evidence={detail.evidence} />
        <section className={styles.provenance} aria-label={chinese ? 'NDF 来源' : 'NDF source'}>
          <details>
            <summary>{chinese ? '显示 canonical path 与 hash' : 'Show canonical path and hashes'}</summary>
            <p><a href={detail.clause.githubUrl}>{detail.clause.sourcePath}:{detail.clause.startLine}</a></p>
            <p>Source SHA-256: <code>{detail.clause.sourceSha256}</code></p>
            <p>Clause SHA-256: <code>{detail.clause.clauseSha256}</code></p>
          </details>
        </section>
      </main>
    </PortalShell>
  );
}
