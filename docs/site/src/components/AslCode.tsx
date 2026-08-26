import React from 'react';
import {Highlight, type PrismTheme} from 'prism-react-renderer';
import '@site/src/theme/aslPrism';
import styles from './PtoWorkbench.module.css';

const ASL_THEME: PrismTheme = {
  plain: {color: 'var(--pto-asl-plain)', backgroundColor: 'transparent'},
  styles: [
    {types: ['comment'], style: {color: 'var(--pto-asl-comment)', fontStyle: 'italic'}},
    {types: ['keyword'], style: {color: 'var(--pto-asl-keyword)', fontWeight: '600'}},
    {types: ['boolean'], style: {color: 'var(--pto-asl-boolean)', fontWeight: '600'}},
    {types: ['number'], style: {color: 'var(--pto-asl-number)'}},
    {types: ['string'], style: {color: 'var(--pto-asl-string)'}},
    {types: ['builtin'], style: {color: 'var(--pto-asl-builtin)'}},
    {types: ['function'], style: {color: 'var(--pto-asl-function)'}},
    {types: ['operator'], style: {color: 'var(--pto-asl-operator)'}},
    {types: ['punctuation'], style: {color: 'var(--pto-asl-punctuation)'}},
  ],
};

export default function AslCode({
  text,
  startLine = 1,
  label,
  lineNumbers = true,
}: {
  text: string;
  startLine?: number;
  label: string;
  lineNumbers?: boolean;
}): React.JSX.Element {
  return (
    <Highlight
      code={text}
      language="asl"
      theme={ASL_THEME}
    >
      {({className, tokens, getLineProps, getTokenProps}) => (
        <pre aria-label={label}>
          <code className={`${className} language-asl`}>
            {tokens.map((line, index) => {
              const lineProps = getLineProps({line});
              return (
                <span
                  {...lineProps}
                  className={`${lineProps.className} ${styles.sourceLine}`}
                  key={startLine + index}
                >
                  {lineNumbers && (
                    <span className={styles.sourceLineNumber} aria-hidden="true">
                      {startLine + index}
                    </span>
                  )}
                  <span className={styles.sourceLineText}>
                    {line.map((token, tokenIndex) => (
                      <span {...getTokenProps({token})} key={tokenIndex} />
                    ))}
                  </span>
                </span>
              );
            })}
          </code>
        </pre>
      )}
    </Highlight>
  );
}
