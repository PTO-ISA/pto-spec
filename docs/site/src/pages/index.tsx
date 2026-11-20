import type {ReactNode} from 'react';
import clsx from 'clsx';
import Head from '@docusaurus/Head';
import Link from '@docusaurus/Link';
import Translate, {translate} from '@docusaurus/Translate';
import {usePluginData} from '@docusaurus/useGlobalData';
import type {PtoReleaseIdentity} from '@site/src/types/pto';
import {useLocalizedPath} from '@site/src/components/releasePresentation';
import PortalShell from '@site/src/components/PortalShell';
import ManualNav from '@site/src/components/ManualNav';

import styles from './index.module.css';

const REPOSITORY_URL = 'https://github.com/PTO-ISA/pto-spec';

type SurfaceName = 'arch' | 'scalar' | 'block' | 'tile';

type SurfaceCount = {
  units: number;
  mnemonics: number;
};

type PtoPluginData = {
  release: PtoReleaseIdentity;
  surfaceCounts: Record<SurfaceName, SurfaceCount>;
  recordCounts: {
    adr: number;
    ndf: number;
    avs: number;
  };
  graphCounts: {
    nodes: number;
    relationships: number;
    adr: number;
    ndf: number;
    asl: number;
    avs: number;
  };
};

function SearchPanel(): ReactNode {
  const searchPath = useLocalizedPath('/search/');
  const placeholder = translate({
    id: 'homepage.search.placeholder',
    message: 'Search mnemonic, NDF ID, unit, test, field, engine, family, or source path',
  });
  const label = translate({
    id: 'homepage.search.label',
    message: 'Search the PTO formal specification',
  });

  return (
    <form
      className={styles.search}
      action={searchPath}
      method="get"
      role="search">
      <label className={styles.srOnly} htmlFor="spec-search">
        {label}
      </label>
      <span className={styles.searchPrompt} aria-hidden="true">/</span>
      <input
        id="spec-search"
        name="q"
        type="search"
        autoComplete="off"
        placeholder={placeholder}
      />
      <button type="submit">
        <Translate id="homepage.search.submit">Search specification</Translate>
      </button>
    </form>
  );
}

function Home(): ReactNode {
  const {release, surfaceCounts, recordCounts, graphCounts} = usePluginData(
    'pto-content',
  ) as PtoPluginData;
  const releaseUrl = `${REPOSITORY_URL}/releases/tag/${release.tag}`;
  const architectureRoute = useLocalizedPath(
    '/architecture/',
  );
  const ndfExplorerRoute = useLocalizedPath('/explore/ndf/');
  const ndfOverviewAsset = useLocalizedPath('/pto-ndf-overview.svg');
  const graphAlt = translate(
    {
      id: 'homepage.ndf.overview.alt',
      message: 'Complete NDF relationship overview with {nodeCount} nodes and {relationshipCount} relationships',
    },
    {
      nodeCount: graphCounts.nodes,
      relationshipCount: graphCounts.relationships,
    },
  );

  return (
    <PortalShell
      title={`${release.tag} Architecture`}
      description="Read the Architecture, Scalar, Block, and Tile surfaces, then trace ADR and NDF records to exact released sources."
      currentPageLabel={translate({id: 'portal.current.home', message: 'Home'})}>
      <Head>
        <meta property="og:type" content="website" />
      </Head>

      <main>
        <section className={styles.surfaceSection} aria-labelledby="surface-title">
          <div className="container">
            <h2 id="surface-title">
              <Translate id="homepage.surface.title">Instruction reference</Translate>
            </h2>
            <ManualNav />
          </div>
        </section>

        <section className={styles.hero}>
          <div className="container">
            <div className={styles.releaseLine}>
              <span className={styles.releaseStatus}>
                {release.releaseEligible ? (
                  <Translate id="homepage.release.status">Latest verified release</Translate>
                ) : (
                  <Translate id="homepage.release.candidateStatus">Release candidate</Translate>
                )}
              </span>
              <a href={releaseUrl}>{release.tag}</a>
              <span aria-hidden="true">·</span>
              <span>
                <Translate id="homepage.release.scope">Production reflects releases only</Translate>
              </span>
              <span aria-hidden="true">·</span>
              <a
                className={styles.commitLink}
                href={`${REPOSITORY_URL}/commit/${release.commit}`}
                title={release.commit}>
                {release.commit.slice(0, 12)}
              </a>
            </div>

            <div className={styles.heroGrid}>
              <div>
                <p className={styles.kicker}>PTO ISA / FORMAL SPECIFICATION</p>
                <h1>
                  <Translate id="homepage.hero.title">Architecture</Translate>
                </h1>
                <p className={styles.lede}>
                  <Translate id="homepage.hero.subtitle">
                    The PTO instruction reference and the architecture contracts behind each instruction.
                  </Translate>
                </p>
                <div className={styles.heroActions}>
                  <Link className="button button--primary button--lg" to={architectureRoute}>
                    <Translate id="homepage.hero.action">Start with the architecture owner</Translate>
                  </Link>
                  <a className="button button--outline button--secondary button--lg" href={`${REPOSITORY_URL}/blob/${release.commit}/asl/arch/overview/architecture.asl`}>
                    <Translate id="homepage.hero.sourceAction">Open original ASL source</Translate>
                  </a>
                </div>
              </div>

              <aside className={styles.sourceBoundary} aria-labelledby="source-boundary-title">
                <p id="source-boundary-title">
                  <Translate id="homepage.source.title">Normative ownership</Translate>
                </p>
                <code>asl/&#123;arch,scalar,block,tile&#125; + embedded NDF</code>
                <span aria-hidden="true">↓</span>
                <code>generated Markdown + catalogs</code>
                <span aria-hidden="true">↓</span>
                <code>AVS + commit-scoped evidence</code>
                <small>
                  <Translate id="homepage.source.note">
                    This page is a reading map. Exact meaning remains in the released ASL/NDF owners.
                  </Translate>
                </small>
              </aside>
            </div>
          </div>
        </section>

        <section className={clsx('container', styles.architectureSection)} aria-labelledby="architecture-title">
          <div className={styles.sectionHeading}>
            <p><Translate id="homepage.architecture.kicker">Start with the whole</Translate></p>
            <h2 id="architecture-title">
              <Translate id="homepage.architecture.title">One architecture, three instruction surfaces</Translate>
            </h2>
          </div>
          <div className={styles.architectureGrid}>
            <div className={styles.architectureNarrative}>
              <p>
                <Translate id="homepage.architecture.description">
                  PTO defines one architecture-visible contract. Its released source tree separates shared architecture state and rules from the Scalar, Block, and Tile instruction surfaces that use them.
                </Translate>
              </p>
              <p>
                <Translate id="homepage.architecture.guidance">
                  Use the instruction reference below to find a mnemonic or its encoding. Each instruction page links to the owning ASL and its evidence.
                </Translate>
              </p>
              <Link to={architectureRoute}>
                <Translate id="homepage.architecture.action">Read the architecture workbench →</Translate>
              </Link>
            </div>
            <dl className={styles.architectureFacts}>
              <div><dt>{surfaceCounts.arch.units}</dt><dd><Translate id="homepage.architecture.units">architecture units</Translate></dd></div>
              <div><dt>{surfaceCounts.scalar.mnemonics + surfaceCounts.block.mnemonics + surfaceCounts.tile.mnemonics}</dt><dd><Translate id="homepage.architecture.mnemonics">released mnemonics</Translate></dd></div>
              <div><dt>{recordCounts.avs}</dt><dd><Translate id="homepage.architecture.avs">executable AVS identities</Translate></dd></div>
            </dl>
          </div>
        </section>

        <section className={clsx('container', styles.recordsSection)} aria-labelledby="records-title">
          <div className={styles.sectionHeading}>
            <p><Translate id="homepage.records.kicker">Then inspect the records</Translate></p>
            <h2 id="records-title">
              <Translate id="homepage.records.title">ADR explains why. NDF points to what is current.</Translate>
            </h2>
          </div>
          <div className={styles.recordGrid}>
            <article className={styles.recordCard}>
              <div><span>ADR</span><strong>{recordCounts.adr}</strong></div>
              <h3><Translate id="homepage.records.adr.title">Architecture Decision Records</Translate></h3>
              <p>
                <Translate id="homepage.records.adr.description">
                  ADRs preserve reviewed decisions, rationale, status, and affected owners. They are history—not a replacement for current ASL/NDF meaning.
                </Translate>
              </p>
              <Link to="/reference/governance/adr-process/">
                <Translate id="homepage.records.adr.action">Read the ADR process →</Translate>
              </Link>
            </article>
            <article className={styles.recordCard}>
              <div><span>NDF</span><strong>{recordCounts.ndf}</strong></div>
              <h3><Translate id="homepage.records.ndf.title">Normative Design Framework clauses</Translate></h3>
              <p>
                <Translate id="homepage.records.ndf.description">
                  NDF identities are embedded in their owning ASL sources. The explorer connects clauses to owners, tests, and ADR history without inventing new semantics.
                </Translate>
              </p>
              <Link to="/ndf/">
                <Translate id="homepage.records.ndf.action">Explore NDF relationships →</Translate>
              </Link>
            </article>
          </div>
        </section>

        <section className={styles.ndfOverviewSection} aria-labelledby="ndf-overview-title">
          <div className="container">
            <div className={styles.ndfOverviewHeader}>
              <div className={styles.sectionHeading}>
                <p><Translate id="homepage.ndf.overview.kicker">Trace the current contract</Translate></p>
                <h2 id="ndf-overview-title">
                  <Translate id="homepage.ndf.overview.title">NDF relationships at a glance</Translate>
                </h2>
                <p>
                  <Translate id="homepage.ndf.overview.description">
                    This complete build-generated overview connects ADR history, current NDF clauses, owning ASL units, and executable AVS evidence. Open the explorer to inspect exact identities and sources.
                  </Translate>
                </p>
              </div>
              <Link className="button button--primary" to={ndfExplorerRoute}>
                <Translate id="homepage.ndf.overview.action">Open the interactive NDF explorer</Translate>
              </Link>
            </div>
            <Link
              className={styles.ndfOverviewGraphic}
              to={ndfExplorerRoute}
              aria-label={translate({
                id: 'homepage.ndf.overview.graphAction',
                message: 'Open the interactive NDF explorer from the relationship overview',
              })}>
              <img src={ndfOverviewAsset} alt={graphAlt} />
            </Link>
            <dl className={styles.ndfLegend} aria-label={translate({
              id: 'homepage.ndf.overview.legend',
              message: 'NDF relationship overview legend',
            })}>
              <div data-kind="adr"><dt>ADR</dt><dd>{graphCounts.adr}</dd></div>
              <div data-kind="ndf"><dt>NDF</dt><dd>{graphCounts.ndf}</dd></div>
              <div data-kind="asl"><dt>ASL</dt><dd>{graphCounts.asl}</dd></div>
              <div data-kind="avs"><dt>AVS</dt><dd>{graphCounts.avs}</dd></div>
              <div data-kind="relationships"><dt><Translate id="homepage.ndf.overview.relationships">Relationships</Translate></dt><dd>{graphCounts.relationships}</dd></div>
            </dl>
          </div>
        </section>

        <section className={styles.searchSection} aria-labelledby="search-title">
          <div className="container">
            <div className={styles.searchIntro}>
              <p className={styles.sectionKicker}>
                <Translate id="homepage.search.kicker">Move from reading to implementation</Translate>
              </p>
              <h2 id="search-title">
                <Translate id="homepage.search.title">Open an exact unit, clause, test, or decision</Translate>
              </h2>
              <p>
                <Translate id="homepage.search.description">
                  Search after choosing the architectural context, or jump directly to a stable released identity.
                </Translate>
              </p>
            </div>
            <SearchPanel />
            <p className={styles.searchHint}>
              <Translate id="homepage.search.hint">
                Try ADD, BSTART.TEPL, TLOAD, an NDF identity, or an exact source path.
              </Translate>
            </p>
          </div>
        </section>
      </main>
    </PortalShell>
  );
}

export default Home;
