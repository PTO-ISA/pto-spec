import React from 'react';
import type {PtoJsonValue} from '@site/src/types/pto';
import styles from './PtoWorkbench.module.css';

export interface GeneratedMetadataProps {
  metadata: Record<string, PtoJsonValue>;
  unit: Record<string, PtoJsonValue>;
}

function metadataValue(value: PtoJsonValue): string {
  if (typeof value === 'string' || typeof value === 'number' || typeof value === 'boolean') {
    return String(value);
  }
  if (value === null) return 'null';
  return JSON.stringify(value, null, 2);
}

export default function GeneratedMetadata({metadata, unit}: GeneratedMetadataProps): React.JSX.Element {
  const entries = Object.entries(metadata);

  return (
    <section className={styles.section} aria-labelledby="generated-metadata-heading">
      <h2 id="generated-metadata-heading">Unit metadata</h2>
      {entries.length === 0 ? <p>No generated metadata is attached to this unit.</p> : (
        <details className={styles.generatedRecord}>
          <summary>Open {entries.length} generated metadata fields</summary>
          <dl className={styles.metadataList}>
            {entries.map(([key, value]) => (
              <div className={styles.metadataItem} key={key}>
                <dt><code>{key}</code></dt>
                <dd><pre tabIndex={0} aria-label={`Generated metadata value for ${key}`}>{metadataValue(value)}</pre></dd>
              </div>
            ))}
          </dl>
        </details>
      )}
      <details className={styles.generatedRecord}>
        <summary>Open generated traceability record</summary>
        <pre tabIndex={0} aria-label="Generated traceability record JSON"><code className="language-json">{JSON.stringify(unit, null, 2)}</code></pre>
      </details>
    </section>
  );
}
