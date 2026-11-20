import React from 'react';
import Link from '@docusaurus/Link';
import {useLocation} from '@docusaurus/router';
import type {
  ManualCategoryEntry,
  ManualEncodingSection,
  ManualIndexData,
} from '@site/src/manual/sections';
import {manualSectionCopy} from '@site/src/manual/sections';
import ManualNav from './ManualNav';
import styles from './ArmManual.module.css';

export type {ManualIndexData} from '@site/src/manual/sections';

function instructionGroups(entries: ManualCategoryEntry[]): Array<{label: string; entries: ManualCategoryEntry[]}> {
  const groups = new Map<string, ManualCategoryEntry[]>();
  for (const entry of entries) {
    const group = groups.get(entry.group);
    if (group === undefined) {
      groups.set(entry.group, [entry]);
    } else {
      group.push(entry);
    }
  }
  return Array.from(groups, ([label, groupedEntries]) => ({label, entries: groupedEntries}));
}

function groupId(label: string): string {
  return label.toLocaleLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

const GROUP_LABELS: Record<string, {en: string; zh: string}> = {
  agu: {en: 'Address and memory', zh: '地址与访存'},
  alu: {en: 'Integer and logic', zh: '整数与逻辑'},
  amo: {en: 'Atomic memory', zh: '原子访存'},
  bru: {en: 'Control flow', zh: '控制流'},
  fsu: {en: 'Floating-point', zh: '浮点'},
  FloatingBinary: {en: 'Arithmetic', zh: '浮点算术'},
  FloatingFused: {en: 'Fused operations', zh: '融合运算'},
  FloatingCompare: {en: 'Comparison', zh: '比较'},
  ConvertFloatingEncoding: {en: 'Conversions', zh: '转换'},
  FloatingUnary: {en: 'Unary and special functions', zh: '一元与特殊函数'},
  sys: {en: 'System', zh: '系统'},
  lifecycle: {en: 'Lifecycle', zh: '生命周期'},
  execution: {en: 'Execution entry', zh: '执行入口'},
  attributes: {en: 'Attributes', zh: '属性'},
  operands: {en: 'Operand binding', zh: '操作数绑定'},
  encoding: {en: 'Encoding commands', zh: '编码命令'},
  'matrix-and-matrix-vector': {en: 'Matrix and matrix-vector', zh: '矩阵与矩阵向量'},
  'matrix-matrix': {en: 'Matrix multiply', zh: '矩阵乘'},
  'matrix-vector': {en: 'Matrix-vector multiply', zh: '矩阵向量乘'},
  regular: {en: 'Loads, stores, and prefetch', zh: '加载、存储与预取'},
  irregular: {en: 'Indexed gather and scatter', zh: '索引 Gather 与 Scatter'},
  'pe-movement': {en: 'PE data movement', zh: 'PE 间数据搬运'},
  layout: {en: 'Tile data movement', zh: 'Tile 数据搬运'},
  VEC: {en: 'VEC elementwise operations', zh: 'VEC 逐元素操作'},
  SFU: {en: 'SFU specialized operations', zh: 'SFU 专用操作'},
  'memory-and-data-movement': {en: 'Memory and data movement', zh: '访存与数据搬运'},
  'layout-and-rearrangement': {en: 'Layout and rearrangement', zh: '布局与重排'},
};

function displayGroupLabel(label: string, chinese: boolean): string {
  const known = GROUP_LABELS[label];
  if (known !== undefined) return chinese ? known.zh : known.en;
  return label
    .split('-')
    .filter(Boolean)
    .map((word) => word[0]?.toLocaleUpperCase() + word.slice(1))
    .join(' ');
}

function InstructionGroups({entries, chinese}: {entries: ManualCategoryEntry[]; chinese: boolean}): React.JSX.Element {
  return (
    <>
      {instructionGroups(entries).map((group) => (
        <section className={styles.manualGroup} id={groupId(group.label)} key={group.label}>
          <header className={styles.manualGroupHeader}>
            <h2>{displayGroupLabel(group.label, chinese)}</h2>
          </header>
          <div className={styles.manualTableViewport} tabIndex={0}>
            <table className={styles.manualTable}>
              <thead>
                <tr>
                  <th>{chinese ? '助记符' : 'Mnemonic'}</th>
                  <th>{chinese ? '说明' : 'Description'}</th>
                </tr>
              </thead>
              <tbody>
                {group.entries.map((entry) => (
                  <tr key={entry.id}>
                    <th scope="row"><Link to={entry.href}><code>{entry.mnemonic}</code></Link></th>
                    <td>{entry.summary}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      ))}
    </>
  );
}

function EncodingGroups({sections, chinese}: {sections: ManualEncodingSection[]; chinese: boolean}): React.JSX.Element {
  return (
    <>
      <nav className={styles.encodingGroups} aria-label={chinese ? '编码分组' : 'Encoding groups'}>
        {sections.map(({id, label}) => <a href={`#${id}`} key={id}>{label}</a>)}
      </nav>
      {sections.map((section) => (
        <section className={styles.manualGroup} id={section.id} key={section.id}>
          <header className={styles.manualGroupHeader}>
            <h2>{section.label}</h2>
          </header>
          <div className={styles.manualTableViewport} tabIndex={0}>
            <table className={`${styles.manualTable} ${styles.encodingTable}`}>
              <thead>
                <tr>
                  <th>{chinese ? '格式' : 'Format'}</th>
                  <th>{chinese ? '编码模式' : 'Pattern'}</th>
                  <th>{chinese ? '指令' : 'Instruction'}</th>
                  <th>{chinese ? '变体 / 约束' : 'Variant / constraints'}</th>
                  <th>{chinese ? '状态' : 'Status'}</th>
                </tr>
              </thead>
              <tbody>
                {section.rows.map((entry) => (
                  <tr key={entry.id}>
                    <td><code>{entry.format}</code></td>
                    <td>{entry.patterns.map((pattern) => <code className={styles.manualPattern} key={pattern}>{pattern}</code>)}</td>
                    <th scope="row">
                      {entry.href
                        ? <Link to={entry.href}><code>{entry.mnemonic}</code></Link>
                        : <code>{entry.mnemonic}</code>}
                    </th>
                    <td>
                      {entry.variant && <span>{entry.variant}</span>}
                      {entry.constraints && entry.constraints.length > 0 && (
                        <span className={styles.manualEntryDetail}>{entry.constraints.join('; ')}</span>
                      )}
                    </td>
                    <td>{entry.status}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      ))}
    </>
  );
}

export default function ManualIndex({index}: {index: ManualIndexData}): React.JSX.Element {
  const location = useLocation();
  const chinese = location.pathname.startsWith('/zh-CN/');
  const total = index.section === 'encoding'
    ? index.groups.reduce((count, section) => count + section.rows.length, 0)
    : index.entries.length;
  const copy = manualSectionCopy[index.section];
  const title = chinese ? copy.zhTitle : copy.title;
  const description = chinese ? copy.zhDescription : copy.description;

  return (
    <main className={styles.manualPage}>
      <ManualNav active={index.section} />
      <header className={styles.manualHero}>
        <div>
          <p className={styles.manualKicker}>{chinese ? 'PTO指令集架构手册' : 'PTO instruction set manual'}</p>
          <h1>{title}</h1>
          <p>{description}</p>
        </div>
        <div className={styles.manualCount}>{total}</div>
      </header>
      {(index.section === 'encoding' ? index.groups.length === 0 : index.entries.length === 0)
        ? <p className={styles.manualEmpty}>{chinese ? '此分类尚无已发布条目。' : 'No released entries in this category.'}</p>
        : index.section === 'encoding'
          ? <EncodingGroups sections={index.groups} chinese={chinese} />
          : <InstructionGroups entries={index.entries} chinese={chinese} />}
    </main>
  );
}
