import React from 'react';
import type {
  PtoAssemblerSymbol,
  PtoLocalizedText,
  PtoUnitWorkbenchData,
} from '@site/src/types/pto';
import AslCode from './AslCode';
import HighLevelAssembly from './HighLevelAssembly';
import InstructionComposition from './InstructionComposition';
import SemanticExecution from './SemanticExecution';
import {parseEncodingForm, type EncodingWordModel} from './encodingModel';
import {firstText, list, record, text} from './data';
import styles from './ArmInstructionReference.module.css';

type SourcePhase = 'decode' | 'operation';

type ManualData = NonNullable<PtoUnitWorkbenchData['manual']>;

interface LocalSourceRegion {
  name: SourcePhase;
  text: string;
  startLine: number;
  endLine: number;
}

function strings(value: unknown): string[] {
  return list(value).map((item) => text(item)).filter(Boolean);
}

function localize(value: PtoLocalizedText, chinese: boolean): string {
  return chinese ? value['zh-CN'] : value.en;
}

function slug(value: string): string {
  return value.toLocaleLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

function escapeRegExp(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function commandReferences(
  value: string,
  routes: Record<string, string> | undefined,
): Array<{mnemonic: string; href: string}> {
  if (routes === undefined) return [];
  return Object.entries(routes)
    .filter(([mnemonic]) => new RegExp(`(^|[^A-Za-z0-9.])${escapeRegExp(mnemonic)}($|[^A-Za-z0-9.])`).test(value))
    .map(([mnemonic, href]) => ({mnemonic, href}))
    .sort((left, right) => left.mnemonic.localeCompare(right.mnemonic));
}

function sourceRegion(sourceText: string, name: SourcePhase): LocalSourceRegion | null {
  const lines = sourceText.split('\n');
  const start = lines.findIndex((line) => line.trim() === `// DOC-BEGIN: ${name}`);
  if (start < 0) return null;
  const end = lines.findIndex(
    (line, index) => index > start && line.trim() === `// DOC-END: ${name}`,
  );
  if (end < 0) return null;
  return {name, text: lines.slice(start + 1, end).join('\n'), startLine: start + 2, endLine: end};
}

function InstructionText({value, symbols}: {value: string; symbols: PtoAssemblerSymbol[]}): React.JSX.Element {
  const names = symbols.map((symbol) => symbol.field).sort((left, right) => right.length - left.length);
  if (names.length === 0) return <code>{value}</code>;
  const matcher = new RegExp(`(${names.map(escapeRegExp).join('|')})`, 'g');
  return (
    <code>{value.split(matcher).map((part, index) => {
      const symbol = symbols.find((candidate) => candidate.field === part);
      return symbol
        ? <a href={`#field-${slug(symbol.field)}`} key={`${part}-${index}`}>{part}</a>
        : <React.Fragment key={`${part}-${index}`}>{part}</React.Fragment>;
    })}</code>
  );
}

function EncodingWord({word, label}: {word: EncodingWordModel; label: string}): React.JSX.Element {
  const grid = {
    gridTemplateColumns: `repeat(${word.width}, minmax(0, 1fr))`,
    minWidth: word.width * 25 + 2,
  };
  return (
    <section className={styles.encodingWord} tabIndex={0} aria-label={`${label}, word ${word.index + 1}`}>
      <div className={styles.bitNumbers} style={grid} aria-hidden="true">
        {Array.from({length: word.width}, (_, index) => <span key={index}>{word.offset + word.width - index - 1}</span>)}
      </div>
      <div className={styles.bitFields} style={grid}>
        {word.fields.map((field, index) => {
          const body = <><strong>{field.name}</strong><small>{field.bits}</small></>;
          const className = field.kind === 'field'
            ? styles.variableField
            : field.kind === 'constant' ? styles.constantField : styles.unspecifiedField;
          const size = {gridColumn: `span ${field.width}`};
          return field.fieldName ? (
            <a className={className} href={`#field-${slug(field.fieldName)}`} key={`${field.bits}-${index}`} style={size}>{body}</a>
          ) : (
            <span className={className} key={`${field.bits}-${index}`} style={size}>{body}</span>
          );
        })}
      </div>
      <table className={styles.encodingTable}>
        <caption>{label}, word {word.index + 1}</caption>
        <thead><tr><th>Bits</th><th>Field</th><th>Value</th></tr></thead>
        <tbody>{word.fields.map((field, index) => (
          <tr key={`${field.bits}-${index}`}>
            <td>{field.bits}</td>
            <td>{field.fieldName ? <a href={`#field-${slug(field.fieldName)}`}>{field.name}</a> : field.name}</td>
            <td>{field.kind === 'field' ? 'variable' : field.value ?? 'unspecified'}</td>
          </tr>
        ))}</tbody>
      </table>
    </section>
  );
}

function EncodingForms({unitData, chinese}: {unitData: PtoUnitWorkbenchData; chinese: boolean}): React.JSX.Element | null {
  if (unitData.encoding.catalogForms.length === 0) {
    const alias = unitData.manual?.alias;
    return alias === undefined ? null : (
      <section className={styles.section} id="encoding">
        <h2>{chinese ? '指令编码' : 'Instruction encoding'}</h2>
        <p>{chinese ? '该拼写复用' : 'This spelling reuses'}{' '}
          {alias.href ? <a href={alias.href}><code>{alias.owner}</code></a> : <code>{alias.owner}</code>}
          {chinese ? ' 所有的精确编码。' : "'s exact encoding."}
        </p>
        {alias.engine && <p>{chinese ? '规范执行引擎' : 'Canonical execution engine'}: <code>{alias.engine}</code></p>}
      </section>
    );
  }
  const operation = record(unitData.encoding.tileOperation);
  return (
    <section className={styles.section} id="encoding">
      <h2>{chinese ? '指令编码' : 'Instruction encoding'}</h2>
      {Object.keys(operation).length > 0 && (
        <dl className={styles.selectorStrip}>
          {[
            ['command_mnemonic', chinese ? '编码载体' : 'Encoding carrier'],
            ['mode', 'Mode'],
            ['function', 'Function'],
            ['selector', 'Selector'],
          ].flatMap(([key, label]) => {
            const value = operation[key];
            if (typeof value !== 'string' && typeof value !== 'number') return [];
            const href = key === 'command_mnemonic' ? unitData.manual?.tile?.carrierHref : undefined;
            return [<div key={key}><dt>{label}</dt><dd>{href
              ? <a href={href}><code>{value}</code></a>
              : <code>{value}</code>}</dd></div>];
          })}
        </dl>
      )}
      {unitData.encoding.catalogForms.map((form, formIndex) => {
        const formRecord = record(form);
        const assembly = firstText(formRecord, ['asm', 'mnemonic'], `Form ${formIndex + 1}`);
        return (
          <article className={styles.encodingForm} key={`${assembly}-${formIndex}`}>
            <h3>{assembly}</h3>
            {parseEncodingForm(form).map((word) => <EncodingWord key={word.index} word={word} label={assembly} />)}
          </article>
        );
      })}
    </section>
  );
}

function AssemblyForms({unitData, chinese, manual}: {unitData: PtoUnitWorkbenchData; chinese: boolean; manual?: ManualData}): React.JSX.Element {
  const metadata = record(unitData.metadata);
  const contract = record(metadata.contract);
  const canonical = strings(contract.canonical_assembly);
  const assembly = canonical.length > 0 ? canonical : strings(metadata.assembly);
  const block = strings(metadata.block).filter((line) => !line.startsWith('#'));
  const macroForms = manual?.tile?.macros ?? [];
  if (unitData.composition !== null && unitData.highLevelAssembly !== null) {
    return (
      <>
        {macroForms.length > 0 && (
          <section className={styles.section} aria-labelledby="tileop-assembly-heading">
            <h2 id="tileop-assembly-heading">{chinese ? 'TileOp 汇编' : 'TileOp assembly'}</h2>
            <div className={styles.assemblyForms}>
              {macroForms.map((form) => <InstructionText key={form} value={form} symbols={unitData.assemblerSymbols} />)}
            </div>
          </section>
        )}
        <InstructionComposition
          apiForms={assembly}
          chinese={chinese}
          composition={unitData.composition}
          highLevelAssembly={unitData.highLevelAssembly}
          ndfClauses={unitData.ndfClauses}
          ownerSourceUrl={unitData.source.githubUrl}
        />
      </>
    );
  }
  return (
    <section className={styles.section} id="assembly-syntax-heading">
      <h2>{chinese ? '汇编格式' : 'Assembler syntax'}</h2>
      <div className={styles.assemblyForms}>
        {macroForms.map((form) => <InstructionText key={form} value={form} symbols={unitData.assemblerSymbols} />)}
        {macroForms.length === 0 && unitData.highLevelAssembly !== null && (
          <InstructionText value={unitData.highLevelAssembly.form} symbols={unitData.assemblerSymbols} />
        )}
        {assembly.map((form) => <InstructionText key={form} value={form} symbols={unitData.assemblerSymbols} />)}
      </div>
      {macroForms.length > 0 && unitData.highLevelAssembly !== null && (
        <details className={styles.legacyAssembly}>
          <summary>{chinese ? '高层操作数到 owning ASL 的映射' : 'High Level Assembly operand mapping'}</summary>
          <HighLevelAssembly assembly={unitData.highLevelAssembly} chinese={chinese} />
        </details>
      )}
      {block.length > 0 ? (
        <section className={styles.bundle}>
          <h3>{chinese ? '物理 Bundle' : 'Physical bundle'}</h3>
          <ol>{block.map((line, index) => {
            const references = commandReferences(line, manual?.tile?.commandHrefs);
            return <li key={`${line}-${index}`}>
              <InstructionText value={line} symbols={unitData.assemblerSymbols} />
              {references.map(({mnemonic, href}) => <React.Fragment key={mnemonic}> · <a href={href}>
                <code>{mnemonic}</code> {chinese ? '定义' : 'definition'}
              </a></React.Fragment>)}
            </li>;
          })}</ol>
        </section>
      ) : null}
    </section>
  );
}

function AssemblerSymbols({symbols, chinese}: {symbols: PtoAssemblerSymbol[]; chinese: boolean}): React.JSX.Element | null {
  if (symbols.length === 0) return null;
  return (
    <section className={styles.section} id="assembler-symbols">
      <h2>{chinese ? '汇编符号' : 'Assembler symbols'}</h2>
      <table className={styles.symbolTable} tabIndex={0}>
        <thead><tr><th>{chinese ? '符号' : 'Symbol'}</th><th>{chinese ? '编码' : 'Encoding'}</th><th>{chinese ? '含义' : 'Meaning'}</th><th>{chinese ? '零值' : 'Zero value'}</th></tr></thead>
        <tbody>{symbols.map((symbol) => (
          <tr id={`field-${slug(symbol.field)}`} key={symbol.field}>
            <th scope="row"><code>{symbol.field}</code></th>
            <td>{symbol.width === '—' ? symbol.signedness : `${symbol.width} bits · ${symbol.signedness}`}</td>
            <td>{symbol.role}</td><td>{symbol.zeroMeaning}</td>
          </tr>
        ))}</tbody>
      </table>
    </section>
  );
}

function Contract({metadata, chinese}: {metadata: Record<string, unknown>; chinese: boolean}): React.JSX.Element | null {
  const contract = record(metadata.contract);
  const groups = [
    {id: 'defaults', title: chinese ? '缺省值' : 'Defaults', values: strings(contract.defaults)},
    {id: 'legality', title: chinese ? '合法性与 Fault' : 'Legality and faults', values: [...strings(contract.legality), ...strings(contract.exceptions)]},
    {id: 'effects', title: chinese ? '操作与架构效果' : 'Operation and architectural effects', values: [...strings(contract.state_effects), ...strings(contract.memory_effects), ...strings(contract.ordering)]},
    {id: 'examples', title: chinese ? '示例' : 'Examples', values: strings(contract.examples)},
  ].filter((group) => group.values.length > 0);
  if (groups.length === 0) return null;
  return (
    <section className={styles.section} id="instruction-contract">
      <h2>{chinese ? '指令契约' : 'Instruction contract'}</h2>
      <div className={styles.contractGrid}>{groups.map((group) => (
        <section key={group.id}><h3>{group.title}</h3>{group.id === 'examples'
          ? <div className={styles.examples}>{group.values.map((value) => <code key={value}>{value}</code>)}</div>
          : <ul>{group.values.map((value, index) => <li key={index}>{value}</li>)}</ul>}</section>
      ))}</div>
    </section>
  );
}

function ManualAsl({manual, unitData, chinese, phase}: {manual?: ManualData; unitData: PtoUnitWorkbenchData; chinese: boolean; phase?: SourcePhase}): React.JSX.Element | null {
  const projected = manual?.asl;
  const fallback = (['decode', 'operation'] as SourcePhase[])
    .filter((candidate) => phase === undefined || candidate === phase)
    .map((phase) => sourceRegion(unitData.source.text, phase))
    .filter((region): region is LocalSourceRegion => region !== null);
  const symbolLinks = new Map<string, string>(projected?.functions.map((fn) =>
    [fn.symbol, `#${fn.phase}-${slug(fn.symbol)}`] as const,
  ));
  for (const reference of projected?.references ?? []) {
    symbolLinks.set(
      reference.symbol,
      unitData.release.releaseEligible ? reference.sourceUrl : reference.sourceAssetUrl,
    );
  }
  const projectedFunctions = projected?.functions.filter((fn) => phase === undefined || fn.phase === phase) ?? [];
  if (projectedFunctions.length === 0 && fallback.length === 0 && !projected?.missingSymbols.length) return null;
  const sectionTitle = phase === 'decode'
    ? 'Decode'
    : phase === 'operation'
      ? 'Operation'
      : chinese ? 'ASL 伪代码' : 'ASL pseudocode';
  return (
    <section className={styles.section} id={phase === undefined ? 'asl-pseudocode' : `${phase}-pseudocode`}>
      <h2>{sectionTitle}</h2>
      <p>{chinese ? '函数按 Decode 与 Operation 分组；标题说明职责，代码保留正式函数身份。' : 'Functions are grouped into Decode and Operation. Labels explain responsibility while source names retain formal identity.'}</p>
      {projected?.missingSymbols.length && (phase === undefined || phase === 'decode') ? <aside className={styles.sourceGap} role="note"><strong>{chinese ? '源投影缺口' : 'Source projection gap'}</strong><p>{projected.missingSymbols.join(', ')}</p></aside> : null}
      {(['decode', 'operation'] as SourcePhase[]).map((phase) => {
        const functions = projectedFunctions.filter((fn) => fn.phase === phase);
        if (functions.length === 0) return null;
        return (
          <section className={styles.aslPhase} id={phase} key={phase}>
            <h3>{phase === 'decode' ? 'Decode' : 'Operation'}</h3>
            {functions.map((fn) => (
              <section className={styles.sourceRegion} id={`${fn.phase}-${slug(fn.symbol)}`} key={`${fn.phase}-${fn.symbol}-${fn.sourcePath}`}>
                <header><div><span>{fn.role}</span><h3>{localize(fn.label, chinese)}</h3><p>{localize(fn.purpose, chinese)}</p></div><a href={unitData.release.releaseEligible ? fn.sourceUrl : fn.sourceAssetUrl}><code>{fn.symbol}</code> ↗</a></header>
                <AslCode
                  label={`${fn.symbol}, ${fn.sourcePath} lines ${fn.startLine} to ${fn.endLine}`}
                  startLine={fn.startLine}
                  text={fn.text}
                  tabIndex={0}
                  symbolLinks={new Map(Array.from(symbolLinks).filter(([symbol]) => symbol !== fn.symbol))}
                />
              </section>
            ))}
          </section>
        );
      })}
      {projected === undefined && fallback.map((region) => (
        <section className={styles.sourceRegion} id={region.name} key={region.name}><h3>{region.name === 'decode' ? 'Decode' : 'Operation'}</h3><AslCode label={`${region.name} ASL lines ${region.startLine} to ${region.endLine}`} startLine={region.startLine} text={region.text} tabIndex={0} /></section>
      ))}
    </section>
  );
}

export default function ArmInstructionReference({unitData}: {unitData: PtoUnitWorkbenchData}): React.JSX.Element {
  const metadata = record(unitData.metadata);
  const unit = record(unitData.unit);
  const manual = unitData.manual;
  const chinese = unitData.readerGuide.locale === 'zh-CN';
  const mnemonic = firstText(metadata, ['mnemonic'], firstText(unit, ['mnemonic']));
  const identity = firstText(metadata, ['id'], firstText(unit, ['id']));
  const summary = firstText(metadata, ['summary'], firstText(unit, ['summary']));
  const surface = firstText(metadata, ['surface'], firstText(unit, ['surface']));
  const classification = strings(metadata.classification);
  const engine = firstText(metadata, ['engine']);
  const armOrder = surface === 'scalar' || surface === 'block';
  return (
    <article className={styles.reference} data-layout-contract="arm-style-v1">
      <header className={styles.hero}><p className={styles.breadcrumb}>{[text(metadata.surface), ...classification, engine].filter(Boolean).join(' / ')}</p><h1>{mnemonic}</h1>{summary && <p>{summary}</p>}{identity && <code>{identity}</code>}</header>
      {armOrder ? <EncodingForms chinese={chinese} unitData={unitData} /> : <AssemblyForms chinese={chinese} manual={manual} unitData={unitData} />}
      {armOrder ? <AssemblyForms chinese={chinese} manual={manual} unitData={unitData} /> : <EncodingForms chinese={chinese} unitData={unitData} />}
      {armOrder && <ManualAsl chinese={chinese} manual={manual} phase="decode" unitData={unitData} />}
      <AssemblerSymbols chinese={chinese} symbols={unitData.assemblerSymbols} />
      <Contract chinese={chinese} metadata={metadata} />
      {armOrder ? <ManualAsl chinese={chinese} manual={manual} phase="operation" unitData={unitData} /> : (
        <>
          {unitData.semanticExecution && <SemanticExecution chinese={chinese} execution={unitData.semanticExecution} />}
          <ManualAsl chinese={chinese} manual={manual} unitData={unitData} />
        </>
      )}
    </article>
  );
}
