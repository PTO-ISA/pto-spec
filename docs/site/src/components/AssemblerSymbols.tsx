import React from 'react';
import type {PtoAssemblerSymbol} from '@site/src/types/pto';
import styles from './PtoWorkbench.module.css';

export default function AssemblerSymbols({
  symbols,
  chinese,
}: {
  symbols: PtoAssemblerSymbol[];
  chinese: boolean;
}): React.JSX.Element {
  return (
    <section className={styles.section} aria-labelledby="assembler-symbols-heading">
      <h2 id="assembler-symbols-heading">{chinese ? '汇编符号' : 'Assembler symbols'}</h2>
      {symbols.length === 0 ? (
        <p>{chinese
          ? '该指令没有编码操作数字段；此项不适用。'
          : 'This instruction has no encoded operand fields; assembler symbols are not applicable.'}</p>
      ) : <div className={styles.symbolsViewport} tabIndex={0}>
        <table className={styles.symbolsTable} tabIndex={0}>
          <caption>{chinese ? '汇编字段与架构角色' : 'Assembly fields and architectural roles'}</caption>
          <thead>
            <tr>
              <th>{chinese ? '字段' : 'Field'}</th>
              <th>{chinese ? '位宽' : 'Bits'}</th>
              <th>{chinese ? '有符号性' : 'Signedness'}</th>
              <th>{chinese ? '架构角色' : 'Architectural role'}</th>
              <th>{chinese ? '编码零' : 'Encoded zero'}</th>
            </tr>
          </thead>
          <tbody>
            {symbols.map((row) => (
              <tr key={row.field}>
                <th scope="row"><code>{row.field}</code></th>
                <td>{row.width}</td>
                <td>{row.signedness}</td>
                <td>{row.role}</td>
                <td>{row.zeroMeaning}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>}
    </section>
  );
}
