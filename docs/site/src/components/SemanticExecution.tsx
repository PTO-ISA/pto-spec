import React, {useState} from 'react';
import type {
  PtoLocalizedText,
  PtoSemanticExecution,
  PtoSemanticSourceRegion,
} from '@site/src/types/pto';
import AslCode from './AslCode';
import styles from './PtoWorkbench.module.css';

function localize(value: PtoLocalizedText, chinese: boolean): string {
  return chinese ? value['zh-CN'] : value.en;
}

function SourceRegion({
  region,
  chinese,
  owner,
}: {
  region: PtoSemanticSourceRegion;
  chinese: boolean;
  owner: boolean;
}): React.JSX.Element {
  const [sourceText, setSourceText] = useState<string | null>(region.text ?? null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  function loadSource(event: React.SyntheticEvent<HTMLDetailsElement>): void {
    if (!event.currentTarget.open || sourceText !== null || loading || !region.sourceAssetUrl) return;
    setLoading(true);
    setError(null);
    void fetch(region.sourceAssetUrl)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.text();
      })
      .then(setSourceText)
      .catch((reason: unknown) => setError(`Exact ASL fragment could not be loaded: ${String(reason)}`))
      .finally(() => setLoading(false));
  }
  if (owner && sourceText === null) throw new TypeError(`owner semantic region ${region.id} has no source text`);
  const body = (
    <>
      <header className={styles.semanticSourceHeader}>
        <div>
          {owner ? (
            <>
              <span>{chinese ? 'TLOAD 所有者' : 'TLOAD owner'}</span>
              <h4>{localize(region.label, chinese)}</h4>
              <p>{localize(region.purpose, chinese)}</p>
            </>
          ) : (
            <code>{region.sourcePath}</code>
          )}
        </div>
        <a href={region.sourceUrl}>{chinese ? '精确源代码' : 'Exact source'} ↗</a>
      </header>
      {loading && <p role="status">Loading exact ASL fragment…</p>}
      {error && <p role="alert">{error}</p>}
      {sourceText !== null && (
        <div className={styles.source} tabIndex={0}>
          <AslCode
            text={sourceText}
            startLine={region.startLine}
            label={`${region.sourcePath} lines ${region.startLine} to ${region.endLine}`}
          />
        </div>
      )}
      <details className={styles.semanticProvenance}>
        <summary>{chinese ? '来源身份' : 'Source identity'}</summary>
        <dl>
          <dt>{chinese ? '路径' : 'Path'}</dt><dd><code>{region.sourcePath}</code></dd>
          <dt>{chinese ? '源 SHA-256' : 'Source SHA-256'}</dt><dd><code>{region.sourceSha256}</code></dd>
          <dt>{chinese ? '片段 SHA-256' : 'Fragment SHA-256'}</dt><dd><code>{region.fragmentSha256}</code></dd>
          <dt>{chinese ? '行号' : 'Lines'}</dt><dd>{region.startLine}–{region.endLine}</dd>
        </dl>
      </details>
    </>
  );
  if (owner) return <section className={styles.semanticOwner}>{body}</section>;
  return (
    <details className={styles.semanticShared} onToggle={loadSource}>
      <summary>
        <span>{chinese ? '展开共享 ASL：' : 'Show shared ASL: '}</span>
        <strong>{localize(region.label, chinese)}</strong>
        <small>{localize(region.purpose, chinese)}</small>
      </summary>
      {body}
    </details>
  );
}

export default function SemanticExecution({
  execution,
  chinese,
}: {
  execution: PtoSemanticExecution;
  chinese: boolean;
}): React.JSX.Element {
  return (
    <section className={`${styles.section} ${styles.semanticExecution}`} aria-labelledby="semantic-execution-heading">
      <h2 id="semantic-execution-heading">{chinese ? 'ASL 执行路径' : 'ASL execution path'}</h2>
      <p>
        {chinese
          ? '每一阶段都直接显示 TLOAD owning ASL；共享语义显示其实际执行模块的精确片段。页面不维护第二份伪代码。'
          : 'Every stage shows the TLOAD owning ASL directly. Shared behavior shows exact fragments from the modules that execute it; the page maintains no second pseudocode copy.'}
      </p>
      <nav className={styles.semanticStageNav} aria-label={chinese ? 'TLOAD 执行阶段' : 'TLOAD execution stages'}>
        {execution.stages.map((stage) => <a key={stage.id} href={`#semantic-stage-${stage.id}`}>{localize(stage.label, chinese)}</a>)}
      </nav>
      <div className={styles.semanticStages}>
        {execution.stages.map((stage) => (
          <article className={styles.semanticStage} id={`semantic-stage-${stage.id}`} key={stage.id}>
            <header>
              <h3>{localize(stage.label, chinese)}</h3>
              <p>{localize(stage.summary, chinese)}</p>
            </header>
            <div className={styles.semanticFacts}>
              {stage.facts.map((fact) => (
                <section className={`${styles.semanticFact} ${styles[`semanticFact_${fact.kind}`]}`} key={`${stage.id}-${fact.kind}`}>
                  <h4>{localize(fact.label, chinese)}</h4>
                  <ul>
                    {fact.items.map((item, index) => <li key={index}>{localize(item, chinese)}</li>)}
                  </ul>
                </section>
              ))}
            </div>
            {stage.status === 'source-gap' && stage.gap && (
              <aside className={styles.semanticGap} role="note">
                <strong>{chinese ? '当前源缺口' : 'Current source gap'}</strong>
                <p>{localize(stage.gap, chinese)}</p>
              </aside>
            )}
            {stage.ownerRegions.map((region) => (
              <SourceRegion key={region.id} region={region} chinese={chinese} owner />
            ))}
            {stage.sharedRegions.map((region) => (
              <SourceRegion key={region.id} region={region} chinese={chinese} owner={false} />
            ))}
          </article>
        ))}
      </div>
    </section>
  );
}
