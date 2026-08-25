import React from 'react';
import type {PtoUnitWorkbenchData} from '@site/src/types/pto';
import ASLViewer from './ASLViewer';
import DocumentationIdentity from './DocumentationIdentity';
import EncodingBitfield from './EncodingBitfield';
import EvidenceIndex from './EvidenceIndex';
import GeneratedMetadata from './GeneratedMetadata';
import NdfClause from './NdfClause';
import ReaderGuide from './ReaderGuide';
import SourceIdentity from './SourceIdentity';
import TloadStateTransitionDemo from './TloadStateTransitionDemo';
import {LanguageFallbackNotice, releaseStatus} from './releasePresentation';
import styles from './PtoWorkbench.module.css';
import {firstText, list, record} from './data';

export interface UnitPresentation {
  title: string;
  identity: string;
  summary: string;
  mnemonic: string;
}

function basename(path: string): string {
  const segment = path.split('/').filter(Boolean).at(-1) ?? '';
  return segment.endsWith('.asl') ? segment.slice(0, -4) : segment;
}

export function unitPresentation(unitData: PtoUnitWorkbenchData): UnitPresentation {
  const data = record(unitData);
  const metadata = record(data.metadata);
  const unit = record(data.unit);
  const source = record(data.source);
  const mnemonic = firstText(metadata, ['mnemonic'], firstText(unit, ['mnemonic']));
  const identity = firstText(metadata, ['id', 'unitId'], firstText(unit, ['id']));
  const sourceName = basename(firstText(source, ['path']));
  const title = mnemonic || firstText(metadata, ['name'], firstText(unit, ['name'])) || identity || sourceName || 'ASL unit';
  const summary = firstText(metadata, ['summary', 'description'], firstText(unit, ['summary', 'description']));
  return {title, identity, summary, mnemonic};
}

export default function UnitWorkbenchView({unitData}: {unitData: PtoUnitWorkbenchData}): React.JSX.Element {
  const data = record(unitData);
  const metadata = record(data.metadata) as PtoUnitWorkbenchData['metadata'];
  const unit = record(data.unit) as PtoUnitWorkbenchData['unit'];
  const tests = list(data.tests).map(record);
  const presentation = unitPresentation(unitData);

  return (
    <main className={styles.page}>
      <LanguageFallbackNotice guide={unitData.readerGuide} />
      <header className={styles.hero}>
        <div>
          <span className={styles.eyebrow}>ASL unit workbench · {releaseStatus(unitData.release)}</span>
          <h1>{presentation.title}</h1>
          {presentation.summary && <p>{presentation.summary}</p>}
        </div>
        {presentation.identity && <code className={styles.badge}>{presentation.identity}</code>}
      </header>
      <SourceIdentity release={unitData.release} source={unitData.source} />
      <DocumentationIdentity documentation={unitData.documentation} />
      <ReaderGuide guide={unitData.readerGuide} mnemonic={Boolean(presentation.mnemonic)} />
      <div className={styles.grid}>
        <div className={styles.stack}>
          {unitData.encoding && unitData.encoding.catalogForms.length > 0 && (
            <EncodingBitfield encoding={unitData.encoding} />
          )}
          <ASLViewer source={unitData.source} />
          {presentation.mnemonic === 'TLOAD' && (
            <TloadStateTransitionDemo
              sourceUrl={firstText(record(unitData.source), ['githubUrl'])}
              evidenceIds={tests.map((test) => firstText(test, ['id'])).filter(Boolean)}
            />
          )}
          <GeneratedMetadata metadata={metadata} unit={unit} />
        </div>
        <aside className={styles.stack} aria-label="Normative clauses and release evidence">
          <NdfClause clauses={unitData.ndfClauses} release={unitData.release} />
          <EvidenceIndex tests={unitData.tests} adrs={unitData.adrs} evidence={unitData.evidence} />
        </aside>
      </div>
    </main>
  );
}
