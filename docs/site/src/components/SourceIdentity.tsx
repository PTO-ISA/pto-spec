import React from 'react';
import styles from './PtoWorkbench.module.css';
import {firstText, record, sourceHref} from './data';

export interface SourceIdentityProps {
  release: unknown;
  source: unknown;
}

export default function SourceIdentity({release, source}: SourceIdentityProps): React.JSX.Element {
  const releaseData = record(release);
  const sourceData = record(source);
  const href = sourceHref(sourceData);
  const path = firstText(sourceData, ['path'], 'Source path unavailable');
  const lineRange = firstText(sourceData, ['lineRange', 'lines']);
  const commit = firstText(releaseData, ['commit', 'commitSha', 'sha'], 'unavailable');
  const version = firstText(releaseData, ['architectureVersion', 'version', 'tag', 'name'], 'latest release');
  const hash = firstText(sourceData, ['sha256', 'hash', 'contentHash'], 'unavailable');

  return (
    <section className={styles.identity} aria-label="Normative source identity">
      <div className={styles.identityItem}>
        <span className={styles.label}>Release</span>
        <code>{version}</code>
      </div>
      <div className={styles.identityItem}>
        <span className={styles.label}>Commit</span>
        <code title={commit}>{commit}</code>
      </div>
      <div className={styles.identityItem}>
        <span className={styles.label}>Original ASL source</span>
        {href ? <a href={href}>{path}{lineRange ? `:${lineRange}` : ''}</a> : <code>{path}</code>}
      </div>
      <div className={styles.identityItem}>
        <span className={styles.label}>Content hash</span>
        <code title={hash}>{hash}</code>
      </div>
    </section>
  );
}
