import React from 'react';
import styles from './PtoWorkbench.module.css';
import {firstText, record, sourceHref} from './data';

export interface ASLViewerProps {
  source: unknown;
  title?: string;
}

export default function ASLViewer({source, title = 'Embedded ASL source'}: ASLViewerProps): React.JSX.Element {
  const data = record(source);
  const sourceText = firstText(data, ['text', 'content', 'source']);
  const href = sourceHref(data);
  const path = firstText(data, ['path'], 'ASL owner');

  return (
    <section className={styles.section} aria-labelledby="asl-source-heading">
      <header className={styles.sourceHeader}>
        <div>
          <span className={styles.eyebrow}>Normative · embedded verbatim</span>
          <h2 id="asl-source-heading">{title}</h2>
        </div>
        {href && <a href={href} aria-label={`Open exact source for ${path}`}>Open exact source ↗</a>}
      </header>
      <div className={styles.source} tabIndex={0} aria-label={`${path} source code`}>
        <pre><code className="language-asl">{sourceText || 'Source text is not present in this release artifact.'}</code></pre>
      </div>
    </section>
  );
}
