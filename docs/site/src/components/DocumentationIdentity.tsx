import React from 'react';
import type {PtoDocumentationIdentity} from '@site/src/types/pto';
import styles from './PtoWorkbench.module.css';

export default function DocumentationIdentity({documentation}: {documentation: PtoDocumentationIdentity}): React.JSX.Element {
  return (
    <section className={styles.documentationIdentity} aria-label="Generated documentation projection identity">
      <div>
        <span className={styles.label}>Generated Markdown mirror</span>
        <p>Derived projection; the original ASL source remains normative.</p>
      </div>
      <div>
        <span className={styles.label}>Projection path</span>
        <a href={documentation.githubUrl}>{documentation.path}</a>
        <span>Embedded in the canonical workbench above</span>
      </div>
      <div>
        <span className={styles.label}>Projection SHA-256</span>
        <code title={documentation.sha256}>{documentation.sha256}</code>
      </div>
    </section>
  );
}
