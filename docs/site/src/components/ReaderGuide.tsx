import React from 'react';
import type {
  PtoReaderGuide,
  PtoReaderGuideBlock,
  PtoReaderInline,
  PtoReaderNode,
} from '@site/src/types/pto';
import styles from './PtoWorkbench.module.css';

function Inline({content}: {content: PtoReaderInline[]}): React.JSX.Element {
  return (
    <>
      {content.map((item, index) => {
        const key = `${item.kind}-${index}`;
        switch (item.kind) {
          case 'text':
            return <React.Fragment key={key}>{item.text}</React.Fragment>;
          case 'code':
            return <code key={key}>{item.text}</code>;
          case 'strong':
            return <strong key={key}><Inline content={item.children} /></strong>;
          case 'emphasis':
            return <em key={key}><Inline content={item.children} /></em>;
          case 'link':
            return <a key={key} href={item.href}><Inline content={item.children} /></a>;
        }
      })}
    </>
  );
}

function renderSingleNode(node: PtoReaderNode, key: string): React.ReactNode {
  switch (node.kind) {
    case 'heading':
      return React.createElement(
        `h${Math.min(6, Math.max(3, node.level))}`,
        {key},
        <Inline content={node.children} />,
      );
    case 'paragraph':
      return <p key={key}><Inline content={node.children} /></p>;
    case 'callout':
      return (
        <aside key={key} className={`${styles.readerCallout} ${styles[`readerCallout_${node.tone}`]}`}>
          <span className={styles.readerCalloutLabel}>{node.tone}</span>
          <p><Inline content={node.children} /></p>
        </aside>
      );
    case 'code-block':
      return (
        <pre key={key} className={styles.readerCode} tabIndex={0}>
          <code data-language={node.language ?? undefined}>{node.text}</code>
        </pre>
      );
    case 'list-item':
    case 'table-row':
      return null;
  }
}

function BlockBody({block}: {block: PtoReaderGuideBlock}): React.JSX.Element {
  const rendered: React.ReactNode[] = [];
  let index = 0;
  while (index < block.nodes.length) {
    const node = block.nodes[index];
    if (node.kind === 'list-item') {
      const ordered = node.ordered;
      const items: Extract<PtoReaderNode, {kind: 'list-item'}>[] = [];
      while (index < block.nodes.length) {
        const candidate = block.nodes[index];
        if (candidate.kind !== 'list-item' || candidate.ordered !== ordered) break;
        items.push(candidate);
        index += 1;
      }
      const List = ordered ? 'ol' : 'ul';
      rendered.push(
        <List key={`list-${index}`}>
          {items.map((item, itemIndex) => <li key={itemIndex}><Inline content={item.children} /></li>)}
        </List>,
      );
      continue;
    }
    if (node.kind === 'table-row') {
      const rows: Extract<PtoReaderNode, {kind: 'table-row'}>[] = [];
      while (index < block.nodes.length && block.nodes[index].kind === 'table-row') {
        rows.push(block.nodes[index] as Extract<PtoReaderNode, {kind: 'table-row'}>);
        index += 1;
      }
      const [header, ...body] = rows;
      rendered.push(
        <div key={`table-${index}`} className={styles.readerTableViewport} tabIndex={0}>
          <table>
            <caption>Reader guide comparison</caption>
            <thead><tr>{header.cells.map((cell, cellIndex) => <th key={cellIndex} scope="col"><Inline content={cell} /></th>)}</tr></thead>
            <tbody>
              {body.map((row, rowIndex) => (
                <tr key={rowIndex}>{row.cells.map((cell, cellIndex) => <td key={cellIndex}><Inline content={cell} /></td>)}</tr>
              ))}
            </tbody>
          </table>
        </div>,
      );
      continue;
    }
    rendered.push(renderSingleNode(node, `node-${index}`));
    index += 1;
  }
  return <>{rendered}</>;
}

const ZH_ROLE_LABELS: Record<PtoReaderGuideBlock['role'], string> = {
  purpose: '用途',
  mechanism: '工作机制',
  'inputs-outputs': '输入与输出',
  effects: '架构效果',
  constraints: '约束与非法情形',
  example: '非规范性示例',
  'purpose-scope': '目的与范围',
  'concepts-state': '概念与架构状态',
  'rules-interactions': '规则与交互',
  boundaries: '边界与未定义范围',
  'example-usage': '非规范性使用示例',
  'related-owners-navigation': '相关规范所有者',
};

export default function ReaderGuide({
  guide,
  mnemonic,
}: {
  guide: PtoReaderGuide;
  mnemonic: boolean;
}): React.JSX.Element {
  const chinese = guide.locale === 'zh-CN';
  const fallback = guide.status === 'fallback';
  const pending = guide.status === 'pending';
  return (
    <section className={`${styles.section} ${styles.readerGuide}`} aria-labelledby="reader-guide-title">
      <div className={styles.readerGuideHeader}>
        <div>
          <span className={styles.readerGuideBadge}>
            {chinese ? '读者指南 · 非规范性说明' : 'Reader guide · non-normative explanation'}
          </span>
          <h2 id="reader-guide-title">
            {chinese
              ? mnemonic ? '理解这条指令' : '理解这一架构条目'
              : mnemonic ? 'Understand this instruction' : 'Understand this architecture entry'}
          </h2>
        </div>
        <span className={styles.readerGuideStatus}>{guide.contentLocale}</span>
      </div>
      <p className={styles.readerGuideBoundary}>
        {chinese
          ? '本指南帮助阅读与实现，不定义指令语义。发生差异时，下面链接的 ASL/NDF 所有者始终优先。'
          : 'This guide supports reading and implementation; it does not define instruction semantics. The linked ASL/NDF owners below always take precedence.'}
      </p>
      {fallback && (
        <div className="alert alert--info" role="note">
          {guide.blocks.length > 0
            ? '当前中文翻译仍在审阅中；本页暂时显示已审阅的英文指南，稳定标识和规范源保持不翻译。'
            : '该内部模型单元不在双语读者指南迁移范围内；请直接阅读本页的 ASL/NDF 所有者与验证证据。'}
        </div>
      )}
      {pending && (
        <div className="alert alert--warning" role="status">
          {guide.target
            ? chinese
              ? '该条目的双语读者指南正在迁移和独立审阅中。规范 ASL、NDF 与验证证据仍可在本页阅读。'
              : 'The reader guide for this entry is being migrated and independently reviewed. Its normative ASL, NDF, and validation evidence remain available below.'
            : 'This internal model unit is documented through its normative ASL/NDF owners and validation evidence; it has no reader-guide migration target.'}
        </div>
      )}
      {guide.blocks.map((block) => (
        <article key={block.id} className={styles.readerBlock} aria-labelledby={`reader-block-${block.id}`}>
          <div className={styles.readerBlockRole} id={`reader-block-${block.id}`}>
            {chinese ? ZH_ROLE_LABELS[block.role] : block.role.replaceAll('-', ' ')}
          </div>
          <BlockBody block={block} />
        </article>
      ))}
      <div className={styles.readerOwners}>
        <h3>{chinese ? '精确规范所有者' : 'Exact normative owners'}</h3>
        <ul>
          {guide.owners.map((owner) => (
            <li key={`${owner.kind}-${owner.id}`}>
              <span>{owner.kind.toUpperCase()}</span>{' '}
              <a href={owner.href}>{owner.id}</a>{' '}
              <code>{owner.path}</code>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
