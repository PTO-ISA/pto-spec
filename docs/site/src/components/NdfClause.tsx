import React from 'react';
import styles from './PtoWorkbench.module.css';
import {firstText, list, record, sourceHref} from './data';

export default function NdfClause({clauses, release}: {clauses: unknown; release?: unknown}): React.JSX.Element {
  const items = list(clauses).map(record);
  const commit = firstText(record(release), ['commit']);
  return (
    <section className={styles.section} aria-labelledby="ndf-heading">
      <span className={styles.eyebrow}>Normative · embedded verbatim</span>
      <h2 id="ndf-heading">NDF clauses</h2>
      {items.length === 0 ? <p>No NDF clause is attached to this unit.</p> : (
        <ul className={styles.clauseList}>
          {items.map((clause, index) => {
            const id = firstText(clause, ['id'], `Clause ${index + 1}`);
            const body = firstText(clause, ['body', 'text', 'content']);
            const sourcePath = firstText(clause, ['sourcePath', 'path']);
            const startLine = firstText(clause, ['startLine']);
            const endLine = firstText(clause, ['endLine']);
            const generatedHref = commit && sourcePath
              ? `https://github.com/PTO-ISA/pto-spec/blob/${encodeURIComponent(commit)}/${sourcePath}#L${startLine || '1'}${endLine ? `-L${endLine}` : ''}`
              : '';
            const href = sourceHref(record(clause.source)) || sourceHref(clause) || generatedHref;
            const meta = [firstText(clause, ['kind']), firstText(clause, ['level']), firstText(clause, ['status'])].filter(Boolean).join(' · ');
            return (
              <li className={styles.clause} key={id}>
                <details>
                  <summary>{id}{meta ? ` — ${meta}` : ''}</summary>
                  <p>{body}</p>
                  {href && <a href={href}>Open exact clause source ↗</a>}
                </details>
              </li>
            );
          })}
        </ul>
      )}
    </section>
  );
}
