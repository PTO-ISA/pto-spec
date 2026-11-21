import React from 'react';
import Link from '@docusaurus/Link';
import {useLocation} from '@docusaurus/router';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import {
  manualSections,
  manualSectionPath,
  type ManualSection,
} from '@site/src/manual/sections';
import styles from './ArmManual.module.css';

const LABELS: Record<ManualSection, {en: string; zh: string}> = {
  scalar: {en: 'Scalar', zh: 'Scalar'},
  float: {en: 'Float', zh: 'Float'},
  block: {en: 'Block', zh: 'Block'},
  cube: {en: 'Cube', zh: 'Cube'},
  vector: {en: 'Vector', zh: 'Vector'},
  tma: {en: 'TMA', zh: 'TMA'},
  encoding: {en: 'Encoding Table', zh: '编码表'},
};

export default function ManualNav({active}: {active?: ManualSection}): React.JSX.Element {
  const location = useLocation();
  const {i18n} = useDocusaurusContext();
  const chinese = i18n.currentLocale === 'zh-CN';
  const localize = (path: string): string => i18n.currentLocale === i18n.defaultLocale
    ? path
    : `/${i18n.currentLocale}${path}`;

  return (
    <nav className={styles.manualNav} aria-label={chinese ? '指令手册分类' : 'Instruction manual categories'}>
      <ul>
        {manualSections.map((section) => {
          const route = localize(manualSectionPath(section));
          const current = active === section || location.pathname === route;
          return (
            <li key={section}>
              <Link
                aria-current={current ? 'page' : undefined}
                className={current ? styles.manualNavActive : undefined}
                to={route}
              >
                {chinese ? LABELS[section].zh : LABELS[section].en}
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
