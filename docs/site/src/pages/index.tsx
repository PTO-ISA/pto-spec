import type {ReactNode} from 'react';
import clsx from 'clsx';
import Head from '@docusaurus/Head';
import Link from '@docusaurus/Link';
import Translate, {translate} from '@docusaurus/Translate';
import {usePluginData} from '@docusaurus/useGlobalData';
import type {PtoReleaseIdentity} from '@site/src/types/pto';
import {useLocalizedPath} from '@site/src/components/releasePresentation';
import PortalShell from '@site/src/components/PortalShell';

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
};

type SurfaceIntroduction = {
  number: string;
  surface: Exclude<SurfaceName, 'arch'>;
  title: ReactNode;
  description: ReactNode;
  families: ReactNode;
  to: string;
  action: ReactNode;
};

const surfaceIntroductions: SurfaceIntroduction[] = [
  {
    number: '01',
    surface: 'scalar',
    title: <Translate id="homepage.surface.scalar.title">Scalar</Translate>,
    description: (
      <Translate id="homepage.surface.scalar.description">
        Begin with the scalar instruction surface and its architectural operands, control flow, memory access, arithmetic, and system forms.
      </Translate>
    ),
    families: (
      <Translate id="homepage.surface.scalar.families">
        AGU · ALU · AMO · BRU · FSU · SYS
      </Translate>
    ),
    to: '/instructions/?surface=scalar',
    action: <Translate id="homepage.surface.scalar.action">Browse Scalar units</Translate>,
  },
  {
    number: '02',
    surface: 'block',
    title: <Translate id="homepage.surface.block.title">Block</Translate>,
    description: (
      <Translate id="homepage.surface.block.description">
        Continue with the explicit Block and command surface: lifecycle, execution descriptors, operands, attributes, and control state.
      </Translate>
    ),
    families: (
      <Translate id="homepage.surface.block.families">
        Lifecycle · Execution · Attributes · Operands · Encoding
      </Translate>
    ),
    to: '/instructions/?surface=block',
    action: <Translate id="homepage.surface.block.action">Browse Block units</Translate>,
  },
  {
    number: '03',
    surface: 'tile',
    title: <Translate id="homepage.surface.tile.title">Tile</Translate>,
    description: (
      <Translate id="homepage.surface.tile.description">
        Then read the direct Tile operation surface, organized by computation, reduction, layout, matrix, and data-movement families.
      </Translate>
    ),
    families: (
      <Translate id="homepage.surface.tile.families">
        Elementwise · Reduce/expand · Layout · Matrix · Memory/data movement
      </Translate>
    ),
    to: '/instructions/?surface=tile',
    action: <Translate id="homepage.surface.tile.action">Browse Tile units</Translate>,
  },
];

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
  const {release, surfaceCounts, recordCounts} = usePluginData(
    'pto-content',
  ) as PtoPluginData;
  const releaseUrl = `${REPOSITORY_URL}/releases/tag/${release.tag}`;
  const architectureRoute = useLocalizedPath(
    '/architecture/',
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
                    One released architecture, read in order through Scalar, Block, and direct Tile instruction surfaces.
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
                  Read the architecture owner first. Use the three surface chapters below as navigation, then open each unit's embedded source and evidence when implementation detail is needed.
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

        <section className={styles.surfaceSection} aria-labelledby="surface-title">
          <div className="container">
            <div className={styles.sectionHeading}>
              <p><Translate id="homepage.surface.kicker">Read the instruction surfaces</Translate></p>
              <h2 id="surface-title">
                <Translate id="homepage.surface.title">Scalar, then Block, then Tile</Translate>
              </h2>
            </div>
            <div className={styles.surfaceList}>
              {surfaceIntroductions.map((surface) => {
                const count = surfaceCounts[surface.surface];
                return (
                  <article className={styles.surfaceCard} key={surface.surface}>
                    <div className={styles.surfaceNumber} aria-hidden="true">{surface.number}</div>
                    <div>
                      <p className={styles.surfaceInventory}>
                        {count.mnemonics} <Translate id="homepage.surface.mnemonics">mnemonics</Translate>
                        {' · '}{count.units} <Translate id="homepage.surface.units">ASL units</Translate>
                      </p>
                      <h3>{surface.title}</h3>
                      <p>{surface.description}</p>
                      <small>{surface.families}</small>
                    </div>
                    <Link to={surface.to}>{surface.action} <span aria-hidden="true">→</span></Link>
                  </article>
                );
              })}
            </div>
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
