import React from 'react';
import Layout from '@theme/Layout';
import type {PtoNdfGraphData} from '@site/src/types/pto';
import NdfGlobalExplorer from '@site/src/components/NdfGlobalExplorer';
import styles from '@site/src/components/PtoWorkbench.module.css';
import {list, record} from '@site/src/components/data';
import {LanguageFallbackNotice, releaseStatus} from '@site/src/components/releasePresentation';

export interface NdfExplorerRouteProps {
  graph: PtoNdfGraphData;
}

export default function NdfExplorer({graph}: NdfExplorerRouteProps): React.JSX.Element {
  const data = record(graph);
  const nodeCount = list(data.nodes).length;
  const edgeCount = list(data.edges).length;
  return (
    <Layout title="NDF relationship explorer" description="Explore released NDF, ASL, ADR, and AVS relationships.">
      <main className={styles.page}>
        <LanguageFallbackNotice />
        <header className={styles.hero}>
          <div>
            <span className={styles.eyebrow}>{releaseStatus(graph.release)} · interactive projection</span>
            <h1>NDF relationship explorer</h1>
            <p>Navigate build-generated relationships, then open exact source identities. The graph does not define or infer specification meaning.</p>
          </div>
          <span className={styles.badge}>{nodeCount} nodes · {edgeCount} edges</span>
        </header>
        <section className={styles.section} aria-label="NDF graph explorer">
          <NdfGlobalExplorer graph={graph} />
        </section>
      </main>
    </Layout>
  );
}
