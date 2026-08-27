import React from 'react';
import type {PtoSearchData} from '@site/src/types/pto';
import SearchWorkbench from '@site/src/components/SearchWorkbench';
import styles from '@site/src/components/PtoWorkbench.module.css';
import {LanguageFallbackNotice, releaseStatus} from '@site/src/components/releasePresentation';
import PortalShell from '@site/src/components/PortalShell';

export interface SearchRouteProps {
  search: PtoSearchData;
}

export default function Search({search}: SearchRouteProps): React.JSX.Element {
  return (
    <PortalShell title="Search the formal specification" description="Search released PTO ASL, NDF, AVS, and ADR identities.">
      <main className={styles.page}>
        <LanguageFallbackNotice />
        <header className={styles.hero}>
          <div>
            <span className={styles.eyebrow}>{releaseStatus(search.release)} · local static index</span>
            <h1>Specification search</h1>
            <p>Move from a stable identity to its workbench, generated documentation, relationship explorer, or exact released source.</p>
          </div>
          <span className={styles.badge}>{search.entries.length} identities</span>
        </header>
        <SearchWorkbench search={search} />
      </main>
    </PortalShell>
  );
}
