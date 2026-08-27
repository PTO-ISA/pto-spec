import React from 'react';
import styles from './PtoWorkbench.module.css';
import {firstText, record} from './data';
import {
  parseEncodingForm,
  type EncodingWordModel,
} from './encodingModel';
import WaveDromRegisterDiagram, {
  type WaveDromRegisterSource,
} from './WaveDromRegisterDiagram';

function waveDromSource(word: EncodingWordModel): WaveDromRegisterSource {
  return {
    reg: word.fields.slice().reverse().map((field) => ({
      bits: field.width,
      name: field.name,
      ...(field.kind === 'field' && field.value ? {attr: field.value} : {}),
    })),
    config: {
      bits: word.width,
      fontsize: 13,
      hspace: word.width <= 16 ? 640 : 900,
      lanes: word.width > 32 ? Math.ceil(word.width / 32) : 1,
      offset: word.offset,
    },
  };
}

export default function EncodingBitfield({
  encoding,
  entryOnly = false,
  chinese = false,
}: {
  encoding: unknown;
  entryOnly?: boolean;
  chinese?: boolean;
}): React.JSX.Element {
  const data = record(encoding);
  const operation = record(data.tileOperation);
  if (!Array.isArray(data.catalogForms) || data.catalogForms.length === 0) {
    throw new TypeError('encoding.catalogForms must be a non-empty array');
  }
  const forms = data.catalogForms.map((form, index) => {
    if (form === null || typeof form !== 'object' || Array.isArray(form)) {
      throw new TypeError(`encoding.catalogForms[${index}] must be an object`);
    }
    return form as Record<string, unknown>;
  });

  return (
    <section className={styles.section} aria-labelledby="encoding-heading">
      <h2 id="encoding-heading">
        {entryOnly
          ? (chinese ? '入口指令编码：BSTART' : 'Entry instruction encoding: BSTART')
          : (chinese ? '编码' : 'Encoding')}
      </h2>
      {entryOnly && (
        <p className={styles.encodingScopeNote}>
          {chinese
            ? '这里只编码 bundle 的 BSTART 入口，不是完整 TLOAD。完整语义还需要上面的 B.DATR、B.DIM、B.IOR、B.IOT/B.IOS 与 BSTOP。'
            : 'This encodes only the bundle-entry BSTART command, not the complete TLOAD. The complete operation also requires the B.DATR, B.DIM, B.IOR, B.IOT/B.IOS, and BSTOP structure shown above.'}
        </p>
      )}
      {forms.map((commandForm, formIndex) => {
        const words = parseEncodingForm(commandForm);
        const assembly = firstText(commandForm, ['asm', 'mnemonic'], firstText(operation, ['command_mnemonic']));
        return (
          <div className={styles.encodingForm} key={`${assembly}-${formIndex}`}>
            {forms.length > 1 && <h3>{assembly || `Form ${formIndex + 1}`}</h3>}
            {words.map((word, wordPosition) => (
              <div key={`encoding-word-${word.index}`}>
                {words.length > 1 && <h4>Encoding word {wordPosition + 1} · index {word.index}</h4>}
                <WaveDromRegisterDiagram
                  label={`WaveDrom encoding diagram${assembly ? ` for ${assembly}` : ''}${words.length > 1 ? `, word ${wordPosition + 1}` : ''}`}
                  source={waveDromSource(word)}
                />
                <details className={styles.encodingFallback}>
                  <summary>Encoding fields as an accessible table</summary>
                  <div className={styles.tableViewport} tabIndex={0}>
                    <table>
                      <caption>Generated encoding fields{assembly ? ` for ${assembly}` : ''}{words.length > 1 ? `, word ${wordPosition + 1}` : ''}</caption>
                      <thead><tr><th>Decoded item</th><th>Bit range</th><th>Value</th></tr></thead>
                      <tbody>
                        {word.fields.map((field, index) => (
                          <tr key={`accessible-${field.name}-${field.bits}-${index}`}>
                            <td>{field.kind === 'constant' ? 'Constant' : field.name || `Field ${index + 1}`}</td>
                            <td>{field.bits || 'not specified'}</td>
                            <td>{field.kind === 'constant' ? field.name : field.value || (field.kind === 'field' ? 'variable' : 'unspecified')}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </details>
                <details className={styles.waveJsonSource}>
                  <summary>WaveJSON source</summary>
                  <pre tabIndex={0}><code>{JSON.stringify(waveDromSource(word), null, 2)}</code></pre>
                </details>
              </div>
            ))}
            {assembly && <p><code>{assembly}</code></p>}
          </div>
        );
      })}
    </section>
  );
}
