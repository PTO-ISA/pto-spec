import React, {useState} from 'react';
import styles from './PtoWorkbench.module.css';
import {firstText, record} from './data';
import AslCode from './AslCode';

interface SourceRegion {
  name: string;
  text: string;
  startLine: number;
  endLine: number;
}

function sourceRegion(sourceText: string, name: string): SourceRegion | null {
  const lines = sourceText.split('\n');
  const start = lines.findIndex((line) => line.trim() === `// DOC-BEGIN: ${name}`);
  if (start < 0) return null;
  const end = lines.findIndex(
    (line, index) => index > start && line.trim() === `// DOC-END: ${name}`,
  );
  if (end < 0) return null;
  return {
    name,
    text: lines.slice(start + 1, end).join('\n'),
    startLine: start + 2,
    endLine: end,
  };
}

function isInstructionSelection(region: SourceRegion): boolean {
  return (
    /InstructionContractOperation_/.test(region.text) &&
    !/\b(?:let|var|if|case|assert)\b/.test(region.text)
  );
}

function SourceCode({region, wrap}: {region: SourceRegion; wrap: boolean}): React.JSX.Element {
  return (
    <div className={`${styles.source} ${wrap ? styles.sourceWrap : ''}`} tabIndex={0}>
      <AslCode
        text={region.text}
        startLine={region.startLine}
        label={`${region.name} ASL source, lines ${region.startLine} to ${region.endLine}`}
      />
    </div>
  );
}

export interface ASLViewerProps {
  source: unknown;
  chinese?: boolean;
}

export default function ASLViewer({source, chinese = false}: ASLViewerProps): React.JSX.Element {
  const [wrap, setWrap] = useState(false);
  const data = record(source);
  const sourceText = firstText(data, ['text', 'content', 'source']);
  const operation = sourceRegion(sourceText, 'operation');
  const decode = sourceRegion(sourceText, 'decode');
  const selectionOnly = decode !== null && isInstructionSelection(decode);
  const pageShapedDecode = decode !== null && !selectionOnly;
  const operationBindingOnly = operation !== null &&
    !/\bExecuteDecoded_[A-Za-z0-9_]+\s*\(/.test(operation.text) &&
    /InstructionContractHandler_/.test(operation.text);
  const fullSource: SourceRegion = {
    name: 'complete owner',
    text: sourceText || (chinese ? '此发布制品未包含源文本。' : 'Source text is not present in this release artifact.'),
    startLine: 1,
    endLine: Math.max(1, sourceText.split('\n').length),
  };
  const primary = operation ?? fullSource;

  return (
    <section className={`${styles.section} ${styles.aslDefinition}`} aria-labelledby="asl-source-heading">
      <header className={styles.sourceHeader}>
        <div>
          <h2 id="asl-source-heading">{chinese ? 'ASL 伪代码' : 'ASL pseudocode'}</h2>
        </div>
        <button className={styles.button} type="button" onClick={() => setWrap((value) => !value)}>
          {wrap
            ? (chinese ? '保持源代码行' : 'Keep source lines')
            : (chinese ? '自动换行' : 'Wrap long lines')}
        </button>
      </header>
      <p className={styles.aslIntroduction}>
        {chinese
          ? pageShapedDecode
            ? 'Decode 与 Operation 均直接来自指令所有者，并按执行阶段分开显示。'
            : operation ? '下面是该指令所有者中的 Operation；页面没有重写这段行为。' : '下面直接显示完整的 ASL 所有者。'
          : pageShapedDecode
            ? 'Decode and Operation come directly from the instruction owner and remain separated by execution phase.'
            : operation ? 'This Operation comes directly from the instruction owner; the page does not rewrite its behavior.' : 'The complete ASL owner is shown directly below.'}
      </p>
      {selectionOnly && (
        <aside className={styles.semanticGap} role="note">
          <strong>{chinese ? 'Decode 源缺口' : 'Decode source gap'}</strong>
          <p>{chinese
            ? '当前 owner 只公开真实的指令选择绑定，没有操作数绑定 Decode 过程；页面不会伪造。'
            : 'The current owner exposes the real instruction-selection binding but no operand-binding Decode procedure; the page does not invent one.'}</p>
        </aside>
      )}
      {operationBindingOnly && (
        <aside className={styles.semanticGap} role="note">
          <strong>{chinese ? 'Operation 源缺口' : 'Operation source gap'}</strong>
          <p>{chinese
            ? '当前 owner 公开真实 handler/helper 绑定，但没有 mnemonic-specific ExecuteDecoded 过程。'
            : 'The current owner exposes real handler/helper bindings but no mnemonic-specific ExecuteDecoded procedure.'}</p>
        </aside>
      )}
      {decode ? (
        <>
          <h3>{selectionOnly
            ? (chinese ? 'Decode 源绑定' : 'Decode source binding')
            : 'Decode ASL'}</h3>
          <SourceCode region={{...decode, name: selectionOnly ? 'decode source binding' : decode.name}} wrap={wrap} />
          {operation && (
            <>
              <h3 className={styles.aslPhaseHeading}>{operationBindingOnly
                ? (chinese ? 'Operation 源绑定' : 'Operation source binding')
                : 'Operation ASL'}</h3>
              <SourceCode region={operation} wrap={wrap} />
            </>
          )}
        </>
      ) : (
        <SourceCode region={primary} wrap={wrap} />
      )}
      {operation && (
        <details className={styles.sourceDisclosure}>
          <summary>{chinese ? '查看完整 ASL 所有者' : 'View the complete ASL owner'}</summary>
          <SourceCode region={fullSource} wrap={wrap} />
        </details>
      )}
    </section>
  );
}
