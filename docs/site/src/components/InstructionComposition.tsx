import React, {useState} from 'react';
import type {
  PtoInstructionComposition,
  PtoInstructionCompositionCommand,
  PtoLocalizedText,
  PtoNdfClause,
} from '@site/src/types/pto';
import styles from './PtoWorkbench.module.css';

function localize(value: PtoLocalizedText, chinese: boolean): string {
  return chinese ? value['zh-CN'] : value.en;
}

function localizedRoute(route: string, chinese: boolean): string {
  return chinese ? `/zh-CN${route}` : route;
}

function occurrenceLabel(command: PtoInstructionCompositionCommand, chinese: boolean): string {
  if (command.maxOccurrences === 0) return chinese ? '不允许出现' : 'not permitted';
  if (command.minOccurrences === command.maxOccurrences) {
    return chinese ? `恰好 ${command.minOccurrences} 条` : `exactly ${command.minOccurrences}`;
  }
  return chinese
    ? `${command.minOccurrences}–${command.maxOccurrences} 条`
    : `${command.minOccurrences}–${command.maxOccurrences}`;
}

function commandForLine(
  commands: PtoInstructionCompositionCommand[],
  line: string,
): PtoInstructionCompositionCommand | undefined {
  return commands.find((command) => line === command.mnemonic || line.startsWith(`${command.mnemonic} `));
}

export default function InstructionComposition({
  composition,
  chinese,
  ownerSourceUrl,
  ndfClauses,
  apiForms,
}: {
  composition: PtoInstructionComposition;
  chinese: boolean;
  ownerSourceUrl: string;
  ndfClauses: PtoNdfClause[];
  apiForms: string[];
}): React.JSX.Element {
  const [selectedId, setSelectedId] = useState(composition.variants[0]?.id ?? '');
  const selected = composition.variants.find((variant) => variant.id === selectedId)
    ?? composition.variants[0];
  if (selected === undefined) throw new TypeError('instruction composition has no variants');

  const labels = chinese ? {
    title: '汇编格式',
    apiLayer: '1. 高层 / API 调用形式',
    bundleLayer: '2. 完整 Bundle Assembly',
    mappingLayer: '3. Bundle 操作数与参数语义',
    dataFlow: '二维数据流',
    intro: 'TLOAD 不是一条独立编码。BSTART.TLOAD 只选择入口和 DataType；后续 B.xxx 命令共同形成一个在 BSTOP 提交的 bundle。',
    count: '命令数量',
    minimum: '最短合法组合',
    complete: '包含全部可选输入的完整组合',
    command: '命令',
    presence: '约束',
    purpose: '作用',
    parameters: '参数来源与缺省',
    omission: '省略时',
    required: '必选',
    optional: '可选',
    conditional: '条件必选',
    forbidden: '禁止',
    repeatable: '可重复',
    relationships: '组合关系',
    detail: '指令详情',
    source: 'ASL 源',
    owner: 'TLOAD owning ASL',
  } : {
    title: 'Assembly syntax',
    apiLayer: '1. High-level / API form',
    bundleLayer: '2. Complete Bundle Assembly',
    mappingLayer: '3. Bundle operand and parameter semantics',
    dataFlow: 'Two-dimensional data flow',
    intro: 'TLOAD is not one standalone encoding. BSTART.TLOAD selects the entry and DataType; the following B.xxx commands form one bundle committed by BSTOP.',
    count: 'Command count',
    minimum: 'Minimum legal bundle',
    complete: 'Complete bundle with every optional input',
    command: 'Command',
    presence: 'Constraint',
    purpose: 'Purpose',
    parameters: 'Parameter source and defaults',
    omission: 'When omitted',
    required: 'Required',
    optional: 'Optional',
    conditional: 'Conditionally required',
    forbidden: 'Forbidden',
    repeatable: 'Repeatable',
    relationships: 'Composition relationships',
    detail: 'Instruction page',
    source: 'ASL source',
    owner: 'TLOAD owning ASL',
  };

  const sequence = (lines: string[], label: string): React.JSX.Element => (
    <section className={styles.bundleExample} aria-label={label}>
      <h4>{label}</h4>
      <ol className={styles.bundleRail}>
        {lines.map((line, index) => {
          const command = commandForLine(selected.commands, line);
          return (
            <li key={`${line}-${index}`}>
              <span className={styles.bundleStepNumber}>{index + 1}</span>
              <div>
                <code>{line}</code>
                {command?.reference && (
                  <span className={styles.bundleStepLinks}>
                    <a href={localizedRoute(command.reference.route, chinese)}>{labels.detail}</a>
                    <a href={command.reference.sourceUrl}>{labels.source} ↗</a>
                  </span>
                )}
              </div>
            </li>
          );
        })}
      </ol>
    </section>
  );

  const flowGroups = [
    {
      id: 'address',
      label: chinese ? 'GM 地址' : 'GM address',
      commands: selected.commands.filter((command) => command.mnemonic === 'B.IOR'),
      items: [],
    },
    {
      id: 'shape',
      label: chinese ? '二维形状' : '2D shape',
      commands: selected.commands.filter((command) => command.mnemonic === 'B.DIM'),
      items: [],
    },
    {
      id: 'format',
      label: chinese ? '格式与类型' : 'Format and type',
      commands: selected.commands.filter((command) =>
        command.mnemonic === 'BSTART.TLOAD' || command.mnemonic === 'B.DATR'),
      items: [],
    },
    {
      id: 'checks',
      label: chinese ? '组合检查' : 'Bundle checks',
      commands: [],
      items: selected.relationships,
    },
    {
      id: 'destination',
      label: chinese ? '目的 Tile' : 'Destination Tile',
      commands: selected.commands.filter((command) =>
        (command.mnemonic === 'B.IOT' || command.mnemonic === 'B.IOS') &&
        command.maxOccurrences > 0),
      items: [],
    },
  ].filter((group) => group.commands.length > 0 || group.items.length > 0);

  return (
    <section className={`${styles.section} ${styles.composition}`} aria-labelledby="assembly-syntax-heading">
      <header className={styles.compositionHeader}>
        <div>
          <h2 id="assembly-syntax-heading">{labels.title}</h2>
          <p>{labels.intro}</p>
        </div>
        <div className={styles.compositionOwners}>
          <a href={ownerSourceUrl}>{labels.owner} ↗</a>
          {ndfClauses.map((clause) => <a key={clause.id} href={`#${clause.identity.anchor}`}>{clause.id}</a>)}
        </div>
      </header>
      <section className={styles.assemblyLayer} aria-labelledby="api-form-heading">
        <h3 id="api-form-heading">{labels.apiLayer}</h3>
        <div className={styles.assemblyForms}>
          {apiForms.map((form) => <code key={form}>{form}</code>)}
        </div>
      </section>
      <section className={styles.assemblyLayer} aria-labelledby="bundle-assembly-heading">
        <h3 id="bundle-assembly-heading">{labels.bundleLayer}</h3>
      <div className={styles.compositionTabs} role="tablist" aria-label={labels.title}>
        {composition.variants.map((variant) => (
          <button
            aria-controls={`composition-panel-${variant.id}`}
            aria-selected={variant.id === selected.id}
            className={variant.id === selected.id ? styles.compositionTabActive : styles.compositionTab}
            id={`composition-tab-${variant.id}`}
            key={variant.id}
            onClick={() => setSelectedId(variant.id)}
            role="tab"
            type="button"
          >
            {localize(variant.label, chinese)}
          </button>
        ))}
      </div>
      <div
        aria-labelledby={`composition-tab-${selected.id}`}
        className={styles.compositionPanel}
        id={`composition-panel-${selected.id}`}
        role="tabpanel"
      >
        <div className={styles.compositionLead}>
          <p>{localize(selected.summary, chinese)}</p>
          <p><strong>{labels.count}:</strong> {localize(selected.canonicalCommandCount, chinese)}</p>
        </div>
        <div className={styles.bundleExamples}>
          {sequence(selected.minimumSequence, labels.minimum)}
          {sequence(selected.completeSequence, labels.complete)}
        </div>
        <section className={styles.bundleRelationships}>
          <h4>{labels.relationships}</h4>
          <ul>{selected.relationships.map((item, index) => <li key={index}>{localize(item, chinese)}</li>)}</ul>
        </section>
      </div>
      </section>
      <section className={styles.assemblyLayer} aria-labelledby="bundle-mapping-heading">
        <h3 id="bundle-mapping-heading">{labels.mappingLayer}</h3>
        <section className={styles.bundleDataFlow} aria-labelledby="bundle-data-flow-heading">
          <h4 id="bundle-data-flow-heading">{labels.dataFlow}</h4>
          <div className={styles.bundleFlowTrack}>
            {flowGroups.map((group, groupIndex) => (
              <React.Fragment key={group.id}>
                <article className={styles.bundleFlowNode}>
                  <h5>{group.label}</h5>
                  {group.commands.map((command) => (
                    <div className={styles.bundleFlowCommand} key={command.mnemonic}>
                      <code>{command.mnemonic}</code>
                      <p>{localize(command.role, chinese)}</p>
                      {command.parameters.length > 0 && (
                        <ul>
                          {command.parameters.map((parameter) => (
                            <li key={parameter.name}>
                              <code>{parameter.name}</code>: {localize(parameter.meaning, chinese)}
                              {parameter.omission && <small><strong>{labels.omission}:</strong> {localize(parameter.omission, chinese)}</small>}
                            </li>
                          ))}
                        </ul>
                      )}
                    </div>
                  ))}
                  {group.items.length > 0 && (
                    <ul>
                      {group.items.map((item, index) => <li key={index}>{localize(item, chinese)}</li>)}
                    </ul>
                  )}
                </article>
                {groupIndex < flowGroups.length - 1 && <span className={styles.bundleFlowArrow} aria-hidden="true">→</span>}
              </React.Fragment>
            ))}
          </div>
        </section>
        <div className={styles.tableViewport} tabIndex={0}>
          <table className={styles.compositionTable}>
            <thead>
              <tr><th>{labels.command}</th><th>{labels.presence}</th><th>{labels.purpose}</th><th>{labels.parameters}</th></tr>
            </thead>
            <tbody>
              {selected.commands.map((command) => (
                <tr key={`${selected.id}-${command.mnemonic}`}>
                  <th scope="row">
                    <code>{command.mnemonic}</code>
                    {command.reference && (
                      <span className={styles.commandLinks}>
                        <a href={localizedRoute(command.reference.route, chinese)}>{labels.detail}</a>
                        <a href={command.reference.sourceUrl}>{labels.source} ↗</a>
                      </span>
                    )}
                  </th>
                  <td>
                    <span className={`${styles.requirement} ${styles[`requirement_${command.requirement}`]}`}>
                      {labels[command.requirement]}
                    </span>
                    {command.repeatable && <span className={styles.repeatable}>{labels.repeatable}</span>}
                    <small>{occurrenceLabel(command, chinese)}</small>
                  </td>
                  <td>{localize(command.role, chinese)}</td>
                  <td>
                    {command.parameters.length === 0 ? <span aria-label="none">—</span> : (
                      <dl className={styles.parameterList}>
                        {command.parameters.map((parameter) => (
                          <React.Fragment key={parameter.name}>
                            <dt><code>{parameter.name}</code></dt>
                            <dd>
                              {localize(parameter.meaning, chinese)}
                              {parameter.omission && <span><strong>{labels.omission}:</strong> {localize(parameter.omission, chinese)}</span>}
                            </dd>
                          </React.Fragment>
                        ))}
                      </dl>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </section>
  );
}
