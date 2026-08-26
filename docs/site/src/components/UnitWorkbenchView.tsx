import React from 'react';
import type {PtoUnitWorkbenchData} from '@site/src/types/pto';
import ASLViewer from './ASLViewer';
import AssemblerSymbols from './AssemblerSymbols';
import EncodingBitfield from './EncodingBitfield';
import EvidenceIndex from './EvidenceIndex';
import GeneratedMetadata from './GeneratedMetadata';
import InstructionOverview from './InstructionOverview';
import InstructionComposition from './InstructionComposition';
import InstructionContractSummary from './InstructionContractSummary';
import NdfClause from './NdfClause';
import ReaderGuide from './ReaderGuide';
import SemanticExecution from './SemanticExecution';
import SourceLedger from './SourceLedger';
import TloadStateTransitionDemo from './TloadStateTransitionDemo';
import {LanguageFallbackNotice} from './releasePresentation';
import styles from './PtoWorkbench.module.css';
import {firstText, record} from './data';

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
  const presentation = unitPresentation(unitData);

  return (
    <main className={styles.page}>
      <LanguageFallbackNotice guide={unitData.readerGuide} />
      <header className={styles.hero}>
        <div>
          <h1>{presentation.title}</h1>
          {presentation.summary && <p>{presentation.summary}</p>}
        </div>
        {presentation.identity && <code className={styles.badge}>{presentation.identity}</code>}
      </header>
      {!unitData.composition && (
        <InstructionOverview
          metadata={metadata}
          mnemonic={Boolean(presentation.mnemonic)}
          chinese={unitData.readerGuide.locale === 'zh-CN'}
        />
      )}
      {unitData.composition && (
        <InstructionComposition
          composition={unitData.composition}
          chinese={unitData.readerGuide.locale === 'zh-CN'}
          ownerSourceUrl={unitData.source.githubUrl}
          ndfClauses={unitData.ndfClauses}
          apiForms={Array.isArray(metadata.assembly)
            ? metadata.assembly.filter((value): value is string => typeof value === 'string')
            : []}
        />
      )}
      {presentation.mnemonic && (
        <AssemblerSymbols
          symbols={unitData.assemblerSymbols}
          chinese={unitData.readerGuide.locale === 'zh-CN'}
        />
      )}
      {unitData.encoding && unitData.encoding.catalogForms.length > 0 && (
        <EncodingBitfield
          encoding={unitData.encoding}
          entryOnly={Boolean(unitData.composition)}
          chinese={unitData.readerGuide.locale === 'zh-CN'}
        />
      )}
      {!unitData.semanticExecution && (
        <InstructionContractSummary
          metadata={metadata}
          chinese={unitData.readerGuide.locale === 'zh-CN'}
        />
      )}
      {unitData.semanticExecution ? (
        <SemanticExecution
          execution={unitData.semanticExecution}
          chinese={unitData.readerGuide.locale === 'zh-CN'}
        />
      ) : (
        <ASLViewer source={unitData.source} chinese={unitData.readerGuide.locale === 'zh-CN'} />
      )}
      <ReaderGuide guide={unitData.readerGuide} mnemonic={Boolean(presentation.mnemonic)} />
      {presentation.mnemonic === 'TLOAD' && <TloadStateTransitionDemo />}
      <NdfClause
        clauses={unitData.ndfClauses}
        release={unitData.release}
        chinese={unitData.readerGuide.locale === 'zh-CN'}
      />
      <EvidenceIndex tests={unitData.tests} adrs={unitData.adrs} evidence={unitData.evidence} />
      <GeneratedMetadata metadata={metadata} unit={unit} />
      <SourceLedger
        release={unitData.release}
        source={unitData.source}
        documentation={unitData.documentation}
        guide={unitData.readerGuide}
      />
    </main>
  );
}
