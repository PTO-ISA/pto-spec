import React, {useState} from 'react';
import type {PtoSourceIdentity} from '@site/src/types/pto';
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
  source: PtoSourceIdentity;
  chinese?: boolean;
}

export default function ASLViewer({source, chinese = false}: ASLViewerProps): React.JSX.Element {
  const [wrap, setWrap] = useState(false);
  if (source.inlineExcerpt) {
    return (
      <section className={`${styles.section} ${styles.aslDefinition}`} aria-labelledby="asl-source-heading">
        <h2 id="asl-source-heading">{chinese ? 'ASL 伪代码' : 'ASL pseudocode'}</h2>
        <p>
          <a href={source.inlineExcerpt.completeAssetUrl}>
            {chinese ? '查看完整 ASL 源文件和 TileOp 宏记录' : 'Open complete ASL and TileOp macro records'}
          </a>
        </p>
        {source.inlineExcerpt.sections.map((section) => {
          const endLine = section.startLine + section.text.split('\n').length - 1;
          return (
            <SourceCode
              key={section.startLine}
              wrap={wrap}
              region={{...section, name: 'owner excerpt', endLine}}
            />
          );
        })}
      </section>
    );
  }
  const data = record(source);
  const sourceText = firstText(data, ['text', 'content', 'source']);
  const operation = sourceRegion(sourceText, 'operation');
  const decode = sourceRegion(sourceText, 'decode');
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
      {decode ? (
        <>
          <h3>Decode ASL</h3>
          <SourceCode region={decode} wrap={wrap} />
          {operation && (
            <>
              <h3 className={styles.aslPhaseHeading}>Operation ASL</h3>
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
