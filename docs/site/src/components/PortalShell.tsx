import React, {type ReactNode, useRef, useState} from 'react';
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
  const [mobileNavigationOpen, setMobileNavigationOpen] = useState(false);
  const mobileToggle = useRef<HTMLButtonElement>(null);
  const closeMobileNavigation = (): void => {
    setMobileNavigationOpen(false);
    mobileToggle.current?.focus();
  };
  return (
    <Layout title={title} description={description}>
      <div className={styles.shell}>
        <aside className={styles.navigationRail} aria-label={chinese ? '左侧规范导航' : 'Left specification navigation'}>
          <button
            ref={mobileToggle}
            className={styles.mobileNavigationToggle}
            type="button"
            aria-controls="pto-specification-navigation"
            aria-expanded={mobileNavigationOpen}
            onClick={() => setMobileNavigationOpen((open) => !open)}>
            {chinese ? '浏览规范' : 'Browse specification'}
          </button>
          <div
            id="pto-specification-navigation"
            className={styles.navigationPanel}
            data-mobile-open={mobileNavigationOpen ? 'true' : 'false'}
            onKeyDown={(event) => {
              if (event.key === 'Escape') closeMobileNavigation();
            }}>
            <SpecNavigation currentPageLabel={currentPageLabel ?? title} />
          </div>
        </aside>
        <div className={styles.content}>{children}</div>
      </div>
    </Layout>
  );
}
