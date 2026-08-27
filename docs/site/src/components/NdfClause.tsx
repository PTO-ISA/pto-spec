import React, {useEffect, useMemo, useState} from 'react';
import type {PtoNdfClause} from '@site/src/types/pto';
import SemanticIdPath from './SemanticIdPath';
import styles from './PtoWorkbench.module.css';

export default function NdfClause({
  clauses,
  chinese = false,
}: {
  clauses: PtoNdfClause[];
  release?: unknown;
  chinese?: boolean;
}): React.JSX.Element {
  const canonicalIds = useMemo(() => clauses.map((clause) => clause.id), [clauses]);
  const byId = useMemo(() => new Map(clauses.map((clause) => [clause.id, clause])), [clauses]);
  const [order, setOrder] = useState(canonicalIds);
  const [dragging, setDragging] = useState<string | null>(null);
  const [announcement, setAnnouncement] = useState('');

  useEffect(() => setOrder(canonicalIds), [canonicalIds]);

  function move(id: string, delta: -1 | 1): void {
    setOrder((current) => {
      const from = current.indexOf(id);
      const to = from + delta;
      if (from < 0 || to < 0 || to >= current.length) return current;
      const next = [...current];
      [next[from], next[to]] = [next[to], next[from]];
      setAnnouncement(`${id} ${delta < 0 ? 'moved up' : 'moved down'} for this page session`);
      return next;
    });
  }

  function drop(target: string): void {
    if (dragging === null || dragging === target) return;
    setOrder((current) => {
      const next = current.filter((id) => id !== dragging);
      next.splice(next.indexOf(target), 0, dragging);
      return next;
    });
    setAnnouncement(`${dragging} moved before ${target} for this page session`);
    setDragging(null);
  }

  function reset(): void {
    setOrder(canonicalIds);
    setAnnouncement('NDF display order restored from canonical source order');
  }

  return (
    <section className={styles.section} aria-labelledby="ndf-heading">
      <header className={styles.ndfSectionHeader}>
        <div>
          <h2 id="ndf-heading">{chinese ? 'NDF 条款' : 'NDF clauses'}</h2>
          <p>{chinese ? '正文来自 owning ASL。拖拽或按钮只临时改变当前页面显示顺序。' : 'Bodies come from owning ASL. Dragging or buttons change only this page-session view order.'}</p>
        </div>
        <button className={styles.button} type="button" onClick={reset} disabled={order.join('\n') === canonicalIds.join('\n')}>
          {chinese ? '恢复默认顺序' : 'Restore default order'}
        </button>
      </header>
      <p className={styles.srOnly} aria-live="polite">{announcement}</p>
      {order.length === 0 ? <p>No NDF clause is attached to this unit.</p> : (
        <ul className={styles.clauseList}>
          {order.map((id, index) => {
            const clause = byId.get(id);
            if (clause === undefined) return null;
            const meta = [clause.kind, clause.level, clause.status].filter(Boolean).join(' · ');
            return (
              <li
                className={`${styles.clause} ${styles.clauseEmbedded}`}
                id={clause.identity.anchor}
                key={id}
                onDragOver={(event) => event.preventDefault()}
                onDrop={() => drop(id)}
              >
                <article aria-labelledby={`${clause.identity.anchor}-title`}>
                  <header className={styles.ndfCardHeader}>
                    <button
                      className={styles.dragHandle}
                      draggable
                      type="button"
                      onDragStart={() => setDragging(id)}
                      onDragEnd={() => setDragging(null)}
                      aria-label={`${chinese ? '拖动临时重排' : 'Drag to temporarily reorder'} ${id}`}
                      title={chinese ? '拖动临时重排；不会修改规范源' : 'Drag to reorder this view; canonical source is unchanged'}
                    >↕ {chinese ? '拖动排序' : 'Drag to reorder'}</button>
                    <div>
                      <SemanticIdPath identity={clause.identity} chinese={chinese} />
                      <h3 id={`${clause.identity.anchor}-title`}>{clause.kind === 'contract' ? (chinese ? '规范契约' : 'Normative contract') : clause.kind}</h3>
                    </div>
                    {meta && <span className={styles.ndfStatus}>{meta}</span>}
                  </header>
                  <p className={styles.ndfBody}>{clause.text}</p>
                  <div className={styles.ndfOrderControls} aria-label={`${id} temporary order controls`}>
                    <button type="button" onClick={() => move(id, -1)} disabled={index === 0}>{chinese ? '上移' : 'Move up'}</button>
                    <button type="button" onClick={() => move(id, 1)} disabled={index === order.length - 1}>{chinese ? '下移' : 'Move down'}</button>
                  </div>
                  <details className={styles.recordProvenance}>
                    <summary>{chinese ? '来源与引用' : 'Sources and references'}</summary>
                    <dl>
                      <dt>{chinese ? '完整稳定 ID' : 'Complete stable ID'}</dt><dd><code>{clause.id}</code></dd>
                      <dt>{chinese ? '来源路径' : 'Source path'}</dt><dd><code>{clause.sourcePath}</code></dd>
                      <dt>{chinese ? '适用单元' : 'Affected units'}</dt><dd>{clause.affectedUnits.join(', ')}</dd>
                      <dt>{chinese ? '源 SHA-256' : 'Source SHA-256'}</dt><dd><code>{clause.sourceSha256}</code></dd>
                      <dt>{chinese ? '条款 SHA-256' : 'Clause SHA-256'}</dt><dd><code>{clause.clauseSha256}</code></dd>
                    </dl>
                    <a href={clause.githubUrl}>{chinese ? '打开精确 canonical source' : 'Open exact canonical source'} ↗</a>
                  </details>
                </article>
              </li>
            );
          })}
        </ul>
      )}
    </section>
  );
}
