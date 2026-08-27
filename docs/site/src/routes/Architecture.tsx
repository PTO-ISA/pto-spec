import React from 'react';
import Link from '@docusaurus/Link';
import type {
  PtoArchitectureGuide,
  PtoArchitectureOwnerProjection,
} from '@site/src/types/pto';
import PortalShell from '@site/src/components/PortalShell';
import {ReaderNodes} from '@site/src/components/ReaderGuide';
import styles from '@site/src/components/ArchitectureOverview.module.css';

function OwnerActions({owner, chinese}: {
  owner: PtoArchitectureOwnerProjection;
  chinese: boolean;
}): React.JSX.Element {
  return (
    <div className={styles.ownerActions}>
      <Link to={owner.route}>{chinese ? '阅读 owner workbench' : 'Read owner workbench'}</Link>
      <a href={owner.sourceUrl}>{chinese ? '查看原始 ASL ↗' : 'Open original ASL ↗'}</a>
    </div>
  );
}

export default function Architecture({
  architecture,
}: {
  architecture: PtoArchitectureGuide;
}): React.JSX.Element {
  const chinese = architecture.locale === 'zh-CN';
  const title = chinese ? '架构' : 'Architecture';
  const sources = [
    architecture.entry,
    ...architecture.topics.flatMap((topic) => [topic.primary, ...topic.related]),
  ].filter((owner, index, all) => all.findIndex((candidate) => candidate.id === owner.id) === index);

  return (
    <PortalShell
      title={title}
      description={chinese
        ? 'PTO 编程模型、架构状态、寄存器、内存、类型、fault 与兼容性的源对齐阅读入口。'
        : 'A source-aligned reading entry for the PTO programming model, state, registers, memory, types, faults, and compatibility.'}>
      <main className={styles.page}>
        <header className={styles.hero}>
          <div>
            <p className={styles.kicker}>{chinese ? '从心智模型进入精确 owner' : 'From mental model to exact owners'}</p>
            <h1>{title}</h1>
            <p>
              {chinese
                ? '先建立 Scalar、Block/bundle、Tile、状态与内存之间的阅读关系，再进入对应 ASL/NDF owner。这里不创建第二套语义。'
                : 'Build the reading relationship between Scalar, Block/bundle, Tile, state, and memory first; then enter the exact ASL/NDF owner. This page does not create a second semantic source.'}
            </p>
          </div>
          <div className={styles.versionBadge}>
            <span>{chinese ? '发布' : 'Release'}</span>
            <strong>{architecture.release.tag}</strong>
          </div>
        </header>

        <section className={styles.section} aria-labelledby="architecture-mental-model">
          <div className={styles.sectionHeading}>
            <p>{chinese ? '第一步' : 'First'}</p>
            <h2 id="architecture-mental-model">{chinese ? '架构心智模型' : 'Architecture mental model'}</h2>
          </div>
          <div className={styles.entrySummary}>
            {architecture.entry.blocks.slice(0, 3).map((block) => (
              <article key={block.id} className={styles.sourceExcerpt}>
                <ReaderNodes nodes={block.nodes} />
              </article>
            ))}
            <OwnerActions owner={architecture.entry} chinese={chinese} />
          </div>
          <ol className={styles.readingRail} aria-label={chinese ? '架构阅读路径' : 'Architecture reading path'}>
            {architecture.topics.map((topic, index) => (
              <li key={topic.id}>
                <a href={`#${topic.id}`}>
                  <span>{String(index + 1).padStart(2, '0')}</span>
                  <strong>{topic.label}</strong>
                  <code>{topic.primary.id}</code>
                </a>
              </li>
            ))}
          </ol>
        </section>

        <section className={styles.section} aria-labelledby="architecture-source-map">
          <div className={styles.sectionHeading}>
            <p>{chinese ? '阅读关系' : 'Reading relationships'}</p>
            <h2 id="architecture-source-map">{chinese ? '主题与规范所有者' : 'Topics and specification owners'}</h2>
          </div>
          <div className={styles.tableViewport} tabIndex={0}>
            <table>
              <caption>{chinese ? '架构主题到当前 owner 的 source map' : 'Source map from architecture topics to current owners'}</caption>
              <thead>
                <tr>
                  <th scope="col">{chinese ? '主题' : 'Topic'}</th>
                  <th scope="col">{chinese ? '主要 owner' : 'Primary owner'}</th>
                  <th scope="col">{chinese ? '交叉链接' : 'Cross-links'}</th>
                  <th scope="col">{chinese ? '源状态' : 'Source status'}</th>
                </tr>
              </thead>
              <tbody>
                {architecture.topics.map((topic) => (
                  <tr key={topic.id}>
                    <td><a href={`#${topic.id}`}>{topic.label}</a></td>
                    <td><code>{topic.primary.id}</code></td>
                    <td>{topic.related.length}</td>
                    <td>{topic.sourceBoundary === null ? (chinese ? '当前 owner 已定位' : 'Current owners located') : (chinese ? '显示 owner 声明的边界' : 'Owner-declared boundary shown')}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>

        <section className={styles.topicList} aria-label={chinese ? '架构主题' : 'Architecture topics'}>
          {architecture.topics.map((topic) => (
            <article className={styles.topic} id={topic.id} key={topic.id}>
              <div className={styles.topicHeader}>
                <div>
                  <p>{chinese ? '典型阅读场景' : 'Typical reading scenario'}</p>
                  <h2>{topic.label}</h2>
                  <div
                    className={styles.scenario}
                    data-source-owner={topic.scenario.ownerId}
                    data-guide-sha256={topic.scenario.guideSha256}>
                    <ReaderNodes nodes={topic.scenario.block.nodes} />
                  </div>
                </div>
                <code>{topic.primary.id}</code>
              </div>
              {topic.sourceBoundary !== null && (
                <aside
                  className={styles.sourceGap}
                  role="note"
                  data-source-owner={topic.sourceBoundary.ownerId}
                  data-source-sha256={topic.sourceBoundary.sourceSha256}
                  data-guide-sha256={topic.sourceBoundary.guideSha256}>
                  <strong>{chinese ? '当前 owner 声明的边界' : 'Current owner-declared boundary'}</strong>
                  <ReaderNodes nodes={topic.sourceBoundary.block.nodes} />
                </aside>
              )}
              <div className={styles.primaryContract}>
                {topic.primary.blocks.map((block) => (
                  <section key={block.id} className={styles.sourceExcerpt}>
                    <ReaderNodes nodes={block.nodes} />
                  </section>
                ))}
                <OwnerActions owner={topic.primary} chinese={chinese} />
              </div>
              <div className={styles.relatedOwners}>
                <h3>{chinese ? '继续阅读这些 owner' : 'Continue with these owners'}</h3>
                <ul>
                  {topic.related.map((owner) => (
                    <li key={owner.id}>
                      <div>
                        <strong>{owner.label}</strong>
                        <code>{owner.id}</code>
                      </div>
                      <div className={styles.relatedActions}>
                        <Link to={owner.route}>{chinese ? 'Workbench' : 'Workbench'}</Link>
                        <a href={owner.sourceUrl}>ASL ↗</a>
                      </div>
                    </li>
                  ))}
                </ul>
              </div>
            </article>
          ))}
        </section>

        <section className={styles.provenance} aria-label={chinese ? '来源与发布身份' : 'Sources and release identity'}>
          <details>
            <summary>{chinese ? '显示 commit、路径、hash 与全部 owner' : 'Show commit, paths, hashes, and all owners'}</summary>
            <dl>
              <div><dt>{chinese ? '发布版本' : 'Publication'}</dt><dd>{architecture.release.publicationVersion}</dd></div>
              <div><dt>Commit</dt><dd><code>{architecture.release.commit}</code></dd></div>
            </dl>
            <ul>
              {sources.map((owner) => (
                <li key={owner.id}>
                  <code>{owner.id}</code>
                  <a href={owner.sourceUrl}>{owner.sourcePath}</a>
                  <code>sha256:{owner.sourceSha256}</code>
                </li>
              ))}
            </ul>
          </details>
        </section>
      </main>
    </PortalShell>
  );
}
