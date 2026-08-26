import React from 'react';
import type {PtoJsonValue} from '@site/src/types/pto';
import styles from './PtoWorkbench.module.css';
import {list, record, text} from './data';

function stringList(value: unknown): string[] {
  return list(value).map((item) => text(item)).filter(Boolean);
}

function assemblyForms(metadata: Record<string, PtoJsonValue>): string[] {
  const contract = record(metadata.contract);
  const canonical = stringList(contract.canonical_assembly);
  return canonical.length > 0 ? canonical : stringList(metadata.assembly);
}

export default function InstructionOverview({
  metadata,
  mnemonic,
  chinese,
}: {
  metadata: Record<string, PtoJsonValue>;
  mnemonic: boolean;
  chinese: boolean;
}): React.JSX.Element | null {
  const assembly = assemblyForms(metadata);
  const rawBlock = stringList(metadata.block).filter((line) => !line.startsWith('#'));
  const contract = record(metadata.contract);
  const bundleRules = stringList(contract.block_composition);
  const examples = stringList(contract.examples);
  if (!mnemonic) return null;

  const requirement = (line: string): 'optional' | 'conditional' | 'required' => {
    if (/optional|omitted/i.test(line)) return 'optional';
    if (/only when|requires|if selected|depending on/i.test(line)) return 'conditional';
    return 'required';
  };
  const expandSegment = (segment: string): string[] => {
    const optionalGroup = segment.match(/^optional\s+(B\.[A-Z0-9.]+(?:\/B\.[A-Z0-9.]+)+)(.*)$/i);
    if (optionalGroup === null) return [segment];
    return optionalGroup[1].split('/').map((mnemonic) => `optional ${mnemonic}${optionalGroup[2]}`);
  };
  const inlineVariants = rawBlock.some((line) => /^[^;]+:\s*BSTART\b/.test(line) && line.includes(';'));
  const bundleVariants = inlineVariants
    ? rawBlock.map((line, index) => {
        const segments = line.split(';').map((segment) => segment.trim()).filter(Boolean);
        const first = segments.shift() ?? '';
        const colon = first.indexOf(':');
        const label = colon > 0 ? first.slice(0, colon).trim() : `Form ${index + 1}`;
        const firstCommand = colon > 0 ? first.slice(colon + 1).trim() : first;
        return {label, lines: [firstCommand, ...segments].flatMap(expandSegment).filter(Boolean)};
      })
    : [{label: '', lines: rawBlock.flatMap(expandSegment)}];
  const block = bundleVariants.flatMap((variant) => variant.lines);
  const commandKey = (line: string): string =>
    line.trim().replace(/^optional\s+/i, '').split(/\s+/, 1)[0] ?? line;

  return (
    <section className={styles.section} aria-labelledby="assembly-syntax-heading">
      <h2 id="assembly-syntax-heading">{chinese ? '汇编格式' : 'Assembly syntax'}</h2>
      {block.length > 0 && <h3>{chinese ? '1. 高层 / API 调用形式' : '1. High-level / API form'}</h3>}
      {assembly.length > 0 ? (
        <div className={styles.assemblyForms}>
          {assembly.map((form) => <code key={form}>{form}</code>)}
        </div>
      ) : (
        <p>{chinese ? '该条目没有独立的汇编格式。' : 'This entry has no standalone assembly form.'}</p>
      )}
      {block.length > 0 && (
        <>
          <div className={styles.genericBundleHeading}>
            <h3>{chinese ? '2. 完整 Bundle Assembly' : '2. Complete Bundle Assembly'}</h3>
            <span>{chinese ? '直接来自 owner metadata' : 'Exact owner metadata'}</span>
          </div>
          {bundleVariants.map((variant, variantIndex) => {
            const counts = new Map<string, number>();
            for (const line of variant.lines) {
              const key = commandKey(line);
              counts.set(key, (counts.get(key) ?? 0) + 1);
            }
            const minimum = variant.lines.filter((line) => requirement(line) !== 'optional');
            return (
              <article className={styles.genericBundleVariant} key={`${variant.label}-${variantIndex}`}>
                {variant.label && <h4>{variant.label}</h4>}
                <ol className={styles.genericBundleSequence}>
                  {variant.lines.map((line, index) => (
                    <li key={`${line}-${index}`}>
                      <span>{index + 1}</span>
                      <code>{line}</code>
                      <em className={styles[`bundleRequirement_${requirement(line)}`]}>
                        {requirement(line) === 'optional'
                          ? (chinese ? '可选' : 'Optional')
                          : requirement(line) === 'conditional'
                            ? (chinese ? '条件必选' : 'Conditional')
                            : (chinese ? '必选' : 'Required')}
                      </em>
                      {(counts.get(commandKey(line)) ?? 0) > 1 && (
                        <em className={styles.bundleRequirement_repeatable}>{chinese ? '可重复' : 'Repeatable'}</em>
                      )}
                      {/\bor\b|replace|mutually/i.test(line) && (
                        <em className={styles.bundleRequirement_mutual}>{chinese ? '互斥' : 'Mutually exclusive'}</em>
                      )}
                    </li>
                  ))}
                </ol>
                <h5>{chinese ? '最短 source-declared bundle' : 'Minimum source-declared bundle'}</h5>
                <div className={styles.minimumBundleSequence}>
                  {minimum.map((line, index) => <code key={`${line}-${index}`}>{line}</code>)}
                </div>
              </article>
            );
          })}
          {bundleRules.length > rawBlock.length && (
            <aside className={styles.semanticGap} role="note">
              <strong>{chinese ? 'Bundle source gap' : 'Bundle source gap'}</strong>
              <p>{chinese
                ? 'owner contract 声明了额外合法变体或关系，但 block sequence metadata 没有把它们展开成可直接照读的命令序列；页面保留原规则，不推测缺失汇编。'
                : 'The owner contract declares additional legal variants or relationships that its block-sequence metadata does not expand into directly readable commands. The page preserves the exact rules and does not invent missing assembly.'}</p>
            </aside>
          )}
          {(bundleRules.length > 0 || examples.length > 0) && (
            <details className={styles.genericBundleDetails}>
              <summary>{chinese ? '展开 Bundle 规则、互斥关系与示例' : 'Show bundle rules, relationships, and examples'}</summary>
              {bundleRules.length > 0 && <ul>{bundleRules.map((rule, index) => <li key={index}>{rule}</li>)}</ul>}
              {examples.length > 0 && (
                <div className={styles.assemblyForms}>
                  {examples.map((example) => <code key={example}>{example}</code>)}
                </div>
              )}
            </details>
          )}
        </>
      )}
    </section>
  );
}
