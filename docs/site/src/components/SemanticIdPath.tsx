import React, {useState} from 'react';
import type {PtoSemanticIdentity} from '@site/src/types/pto';
import styles from './PtoWorkbench.module.css';

const ROLE_LABELS: Record<PtoSemanticIdentity['facets'][number]['role'], string> = {
  namespace: 'namespace',
  surface: 'surface',
  owner: 'owner',
  category: 'category',
  case: 'case',
  decision: 'decision record',
};

export function CopyIdentityButton({
  identity,
  chinese = false,
}: {
  identity: PtoSemanticIdentity;
  chinese?: boolean;
}): React.JSX.Element {
  const [copied, setCopied] = useState(false);
  function copy(): void {
    void navigator.clipboard.writeText(identity.fullId).then(() => {
      setCopied(true);
      window.setTimeout(() => setCopied(false), 1800);
    });
  }
  return (
    <>
      <button
        className={styles.copyIdentity}
        type="button"
        onClick={copy}
        aria-label={`${chinese ? '复制完整稳定 ID' : 'Copy complete stable ID'} ${identity.fullId}`}
      >
        {copied ? (chinese ? '已复制' : 'Copied') : (chinese ? '复制 ID' : 'Copy ID')}
      </button>
      <span className={styles.srOnly} aria-live="polite">{copied ? `${identity.fullId} copied` : ''}</span>
    </>
  );
}

export default function SemanticIdPath({
  identity,
  chinese = false,
  copyable = true,
}: {
  identity: PtoSemanticIdentity;
  chinese?: boolean;
  copyable?: boolean;
}): React.JSX.Element {
  return (
    <div className={styles.semanticIdentityPath} title={identity.fullId}>
      <ol aria-label={`${identity.kind.toLocaleUpperCase('en-US')} identity ${identity.fullId}`}>
        {identity.facets.slice(-4).map((facet, index) => (
          <li className={styles[`identityFacet_${facet.role}`]} key={`${facet.role}-${facet.label}-${index}`}>
            <span>{ROLE_LABELS[facet.role]}</span>
            <strong>{facet.label}</strong>
          </li>
        ))}
      </ol>
      {copyable && <CopyIdentityButton identity={identity} chinese={chinese} />}
    </div>
  );
}
