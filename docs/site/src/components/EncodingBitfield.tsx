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
      ...(field.value ? {attr: field.value} : {}),
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

export default function EncodingBitfield({encoding}: {encoding: unknown}): React.JSX.Element {
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
      <span className={styles.eyebrow}>Generated from released catalog</span>
      <h2 id="encoding-heading">Encoding</h2>
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
                      <thead><tr><th>Field</th><th>Bit range</th><th>Fixed value</th></tr></thead>
                      <tbody>
                        {word.fields.map((field, index) => (
                          <tr key={`accessible-${field.name}-${field.bits}-${index}`}>
                            <td>{field.name || `Field ${index + 1}`}</td>
                            <td>{field.bits || 'not specified'}</td>
                            <td>{field.value || 'variable'}</td>
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
