import React from 'react';
import Link from '@docusaurus/Link';
import type {PtoNdfIndexPageData} from '@site/src/types/pto';
import styles from '@site/src/components/PtoWorkbench.module.css';
import {
  LanguageFallbackNotice,
  releaseStatus,
  useLocalizedPath,
} from '@site/src/components/releasePresentation';
import PortalShell from '@site/src/components/PortalShell';

export default function NdfIndexPage({
  index,
}: {
  index: PtoNdfIndexPageData;
}): React.JSX.Element {
  const firstPage = useLocalizedPath('/explore/ndf/index/1/');
  const previous = useLocalizedPath(`/explore/ndf/index/${index.page - 1}/`);
  const next = useLocalizedPath(`/explore/ndf/index/${index.page + 1}/`);
  return (
    <PortalShell
      title={`Static relationship index ${index.page}`}
      description="No-JavaScript index of released PTO NDF, ASL, AVS, and ADR relationships.">
      <main className={styles.page}>
        <LanguageFallbackNotice />
        <header className={styles.hero}>
          <div>
            <span className={styles.eyebrow}>{releaseStatus(index.release)} · static fallback</span>
            <h1>Relationship index</h1>
            <p>
              Complete, paginated released identities and adjacency data. This
              index remains navigable without JavaScript or WebGL.
            </p>
          </div>
          <span className={styles.badge}>Page {index.page} of {index.pageCount}</span>
        </header>
        <nav className={styles.toolbar} aria-label="Relationship index pages">
          {index.page > 1 ? <Link to={previous}>← Previous</Link> : <span>← Previous</span>}
          <Link to={firstPage}>{index.total} total identities</Link>
          {index.page < index.pageCount ? <Link to={next}>Next →</Link> : <span>Next →</span>}
        </nav>
        <section className={styles.section} aria-label="Released relationship identities">
          {index.entries.map(({node, relationships}) => (
            <article className={styles.staticIndexEntry} key={node.id} id={node.id}>
              <h2><code>{node.id}</code></h2>
              <p>{node.kind} · {node.status ?? 'status not applicable'}</p>
              {node.sourcePath && <p><code>{node.sourcePath}:{node.startLine ?? 1}</code></p>}
              {node.sourceSha256 && <p>Source SHA-256: <code>{node.sourceSha256}</code></p>}
              {node.clauseSha256 && <p>Clause SHA-256: <code>{node.clauseSha256}</code></p>}
              {node.sourceUrl && <p><a href={node.sourceUrl}>Open exact source ↗</a></p>}
              <details>
                <summary>{relationships.length} relationships</summary>
                {relationships.length === 0 ? <p>No recorded graph relationships.</p> : (
                  <ul>
                    {relationships.map((relationship, relationshipIndex) => (
                      <li key={`${relationship.kind}-${relationship.direction}-${relationship.otherId}-${relationshipIndex}`}>
                        <code>{relationship.otherId}</code> · {relationship.kind} · {relationship.direction}
                      </li>
                    ))}
                  </ul>
                )}
              </details>
            </article>
          ))}
        </section>
      </main>
    </PortalShell>
  );
}
