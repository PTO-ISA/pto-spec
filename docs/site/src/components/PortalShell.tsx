import React, {type ReactNode} from 'react';
import Layout from '@theme/Layout';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import SpecNavigation from './SpecNavigation';
import styles from './PortalShell.module.css';

export default function PortalShell({
  title,
  description,
  currentPageLabel,
  children,
}: {
  title: string;
  description: string;
  currentPageLabel?: string;
  children: ReactNode;
}): React.JSX.Element {
  const {i18n} = useDocusaurusContext();
  const chinese = i18n.currentLocale === 'zh-CN';
  return (
    <Layout title={title} description={description}>
      <div className={styles.shell}>
        <aside className={styles.desktopRail} aria-label={chinese ? '左侧规范导航' : 'Left specification navigation'}>
          <SpecNavigation currentPageLabel={currentPageLabel ?? title} />
        </aside>
        <div className={styles.mobileNavigation}>
          <details>
            <summary>{chinese ? '浏览规范' : 'Browse specification'}</summary>
            <SpecNavigation currentPageLabel={currentPageLabel ?? title} />
          </details>
        </div>
        <div className={styles.content}>{children}</div>
      </div>
    </Layout>
  );
}
