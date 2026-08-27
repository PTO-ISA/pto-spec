import React from 'react';
import type {
  PtoDocumentationIdentity,
  PtoReaderGuide,
  PtoReleaseIdentity,
  PtoSourceIdentity,
} from '@site/src/types/pto';
import styles from './PtoWorkbench.module.css';

function LedgerItem({label, children}: {label: string; children: React.ReactNode}): React.JSX.Element {
  return (
    <div className={styles.ledgerItem}>
      <dt>{label}</dt>
      <dd>{children}</dd>
    </div>
  );
}

export default function SourceLedger({
  release,
  source,
  documentation,
  guide,
}: {
  release: PtoReleaseIdentity;
  source: PtoSourceIdentity;
  documentation: PtoDocumentationIdentity;
  guide: PtoReaderGuide;
}): React.JSX.Element {
  const chinese = guide.locale === 'zh-CN';
  const releaseLabel = release.releaseEligible
    ? (chinese ? '已验证发布' : 'Verified release')
    : (chinese ? '候选发布' : 'Release candidate');

  return (
    <section className={`${styles.section} ${styles.sourceLedger}`} aria-labelledby="source-ledger-heading">
      <h2 id="source-ledger-heading">{chinese ? '来源与发布信息' : 'Sources and release identity'}</h2>
      <details className={styles.sourceLedgerDetails}>
        <summary>
          {chinese
            ? '展开 commit、路径、hash、版本和规范所有者'
            : 'Show commit, paths, hashes, version, and canonical owners'}
        </summary>
        <dl className={styles.ledgerGrid}>
          <LedgerItem label={chinese ? '发布' : 'Release'}>
            <code>{release.architectureVersion}</code> · {releaseLabel}
          </LedgerItem>
          <LedgerItem label="Commit"><code title={release.commit}>{release.commit}</code></LedgerItem>
          <LedgerItem label={chinese ? '原始 ASL' : 'Original ASL'}>
            <a href={source.githubUrl}>{source.path}</a>
          </LedgerItem>
          <LedgerItem label="ASL SHA-256"><code title={source.sha256}>{source.sha256}</code></LedgerItem>
          <LedgerItem label={chinese ? '生成文档' : 'Generated documentation'}>
            <a href={documentation.githubUrl}>{documentation.path}</a>{' · '}
            <span>{chinese ? '已融合到当前页面' : 'embedded in this page'}</span>
          </LedgerItem>
          <LedgerItem label={chinese ? '文档 SHA-256' : 'Documentation SHA-256'}>
            <code title={documentation.sha256}>{documentation.sha256}</code>
          </LedgerItem>
        </dl>
        <div className={styles.ownerLedger}>
          <h3>{chinese ? '精确所有者' : 'Exact owners'}</h3>
          <ul>
            {guide.owners.map((owner) => (
              <li key={`${owner.kind}-${owner.id}`}>
                <span>{owner.kind.toUpperCase()}</span>{' '}
                <a href={owner.href}>{owner.id}</a>{' '}
                <code>{owner.path}</code>
              </li>
            ))}
          </ul>
        </div>
      </details>
    </section>
  );
}
