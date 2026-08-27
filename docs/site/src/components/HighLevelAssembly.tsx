import React from 'react';
import type {PtoHighLevelAssembly} from '@site/src/types/pto';
import styles from './PtoWorkbench.module.css';

export default function HighLevelAssembly({
  assembly,
  chinese,
}: {
  assembly: PtoHighLevelAssembly;
  chinese: boolean;
}): React.JSX.Element {
  const bindings = [
    ...assembly.parameters.map((binding) => ({...binding, group: chinese ? '参数' : 'Parameter'})),
    ...assembly.inputs.map((binding) => ({...binding, group: chinese ? '输入' : 'Input'})),
    ...assembly.outputs.map((binding) => ({...binding, group: chinese ? '输出' : 'Output'})),
  ];
  return (
    <div className={styles.highLevelAssembly}>
      <code className={styles.highLevelAssemblyForm}>{assembly.form}</code>
      <details>
        <summary>{chinese ? '显示高层汇编 operand 到 owning ASL 的映射' : 'Show High Level Assembly operands mapped to the owning ASL'}</summary>
        <div className={styles.highLevelBindingViewport} tabIndex={0}>
          <table>
            <caption>{chinese ? '高层汇编 operand 的 source binding' : 'Source bindings for High Level Assembly operands'}</caption>
            <thead><tr><th>{chinese ? '分组' : 'Group'}</th><th>Operand</th><th>{chinese ? '含义' : 'Role'}</th><th>{chinese ? 'ASL 来源' : 'ASL source'}</th></tr></thead>
            <tbody>
              {bindings.map((binding, index) => (
                <tr key={`${binding.group}-${binding.display}-${index}`}>
                  <td>{binding.group}</td>
                  <td><code>{binding.display}</code></td>
                  <td>{binding.role}</td>
                  <td><code>{binding.source}</code></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </details>
    </div>
  );
}
