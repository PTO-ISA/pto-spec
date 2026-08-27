import React, {useEffect, useState} from 'react';
import styles from './PtoWorkbench.module.css';

const steps = [
  {title: 'Released inputs', detail: 'Display build-generated operands and source identities.'},
  {title: 'Source-defined checks', detail: 'Highlight the preflight boundary owned by embedded ASL.'},
  {title: 'Source-defined access', detail: 'Visualize the access phase without redefining its contract.'},
  {title: 'Published result', detail: 'Show the source-defined success path or preserved prior state.'},
];

export default function TloadStateTransitionDemo(): React.JSX.Element {
  const [active, setActive] = useState(0);
  const [playing, setPlaying] = useState(false);

  useEffect(() => {
    if (!playing) return undefined;
    const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reducedMotion) {
      setPlaying(false);
      return undefined;
    }
    const timer = window.setTimeout(() => {
      setActive((current) => {
        if (current >= steps.length - 1) {
          setPlaying(false);
          return current;
        }
        return current + 1;
      });
    }, 900);
    return () => window.clearTimeout(timer);
  }, [active, playing]);

  return (
    <section className={styles.section} aria-labelledby="demo-heading">
      <h2 id="demo-heading">TLOAD state-transition walkthrough</h2>
      <details className={styles.walkthroughDetails}>
        <summary>Open optional interactive walkthrough</summary>
        <p>Step through input capture, preflight, access, and publication. The exact ASL definition is embedded immediately above.</p>
        <div className={styles.steps} aria-live="polite">
          {steps.map((step, index) => (
            <div className={`${styles.step} ${index === active ? styles.stepActive : ''} ${index < active ? styles.stepDone : ''}`} key={step.title} aria-current={index === active ? 'step' : undefined}>
              <span className={styles.label}>Step {index + 1}</span>
              <strong>{step.title}</strong>
              <small>{step.detail}</small>
            </div>
          ))}
        </div>
        <div className={styles.stepControls}>
          <button className={styles.button} type="button" onClick={() => setActive((value) => Math.max(0, value - 1))} disabled={active === 0}>Previous</button>
          <button className={styles.button} type="button" onClick={() => setPlaying((value) => !value)}>{playing ? 'Pause' : 'Play'}</button>
          <button className={styles.button} type="button" onClick={() => setActive((value) => Math.min(steps.length - 1, value + 1))} disabled={active === steps.length - 1}>Next</button>
          <span>Step {active + 1} of {steps.length}</span>
        </div>
      </details>
    </section>
  );
}
