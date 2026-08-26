import React from 'react';
import type {PtoJsonValue} from '@site/src/types/pto';
import styles from './PtoWorkbench.module.css';

function object(value: PtoJsonValue | undefined): Record<string, PtoJsonValue> {
  return value !== null && typeof value === 'object' && !Array.isArray(value)
    ? value as Record<string, PtoJsonValue> : {};
}

function strings(value: PtoJsonValue | undefined): string[] {
  return Array.isArray(value)
    ? value.filter((item): item is string => typeof item === 'string')
    : [];
}

export default function InstructionContractSummary({
  metadata,
  chinese,
}: {
  metadata: Record<string, PtoJsonValue>;
  chinese: boolean;
}): React.JSX.Element | null {
  const contract = object(metadata.contract);
  const operands = Array.isArray(contract.operands)
    ? contract.operands.map(object).filter((operand) =>
        typeof operand.field === 'string' && typeof operand.role === 'string')
    : [];
  const constraints = [...strings(contract.legality), ...strings(contract.exceptions)];
  const effects = [
    ...strings(contract.state_effects),
    ...strings(contract.memory_effects),
    ...strings(contract.ordering),
  ];
  if (operands.length === 0 && constraints.length === 0 && effects.length === 0) return null;
  return (
    <section className={`${styles.section} ${styles.contractSummary}`} aria-labelledby="contract-summary-heading">
      <h2 id="contract-summary-heading">{chinese ? '指令契约' : 'Instruction contract'}</h2>
      <div className={styles.contractSummaryGrid}>
        <article>
          <h3>{chinese ? '操作数与参数' : 'Operands and parameters'}</h3>
          {operands.length === 0 ? <p>—</p> : (
            <dl className={styles.contractOperands}>
              {operands.map((operand) => (
                <React.Fragment key={String(operand.field)}>
                  <dt><code>{String(operand.field)}</code></dt>
                  <dd>{String(operand.role)}</dd>
                </React.Fragment>
              ))}
            </dl>
          )}
        </article>
        <article>
          <h3>{chinese ? '约束、检查与 Fault' : 'Constraints, checks, and faults'}</h3>
          {constraints.length === 0 ? <p>—</p> : <ul>{constraints.map((item, index) => <li key={index}>{item}</li>)}</ul>}
        </article>
        <article>
          <h3>{chinese ? '状态读取、写入与结果' : 'State reads, writes, and result'}</h3>
          {effects.length === 0 ? <p>—</p> : <ul>{effects.map((item, index) => <li key={index}>{item}</li>)}</ul>}
        </article>
      </div>
    </section>
  );
}
