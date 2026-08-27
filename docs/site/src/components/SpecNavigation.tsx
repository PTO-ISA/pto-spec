import React from 'react';
import Link from '@docusaurus/Link';
import {useLocation} from '@docusaurus/router';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import styles from './PortalShell.module.css';

type NavigationItem = {
  id: string;
  label: string;
  path: string;
  active: (pathname: string, search: string) => boolean;
};

function routeActive(pathname: string, path: string): boolean {
  return pathname === path || (path !== '/' && pathname.startsWith(path));
}

export default function SpecNavigation({currentPageLabel}: {currentPageLabel: string}): React.JSX.Element {
  const location = useLocation();
  const {i18n} = useDocusaurusContext();
  const chinese = i18n.currentLocale === 'zh-CN';
  const localize = (path: string): string => {
    if (i18n.currentLocale === i18n.defaultLocale) return path;
    return `/${i18n.currentLocale}${path}`;
  };
  const home = localize('/');
  const architecture = localize('/architecture/');
  const scalar = localize('/search/?kind=asl&surface=scalar');
  const block = localize('/search/?kind=asl&surface=block');
  const tile = localize('/search/?kind=asl&surface=tile');
  const reference = localize('/reference/arch/overview/architecture/');
  const ndf = localize('/explore/ndf/');
  const decisions = localize('/reference/governance/adr-process/');
  const search = localize('/search/');
  const query = location.search;

  const primary: NavigationItem[] = [
    {
      id: 'home',
      label: chinese ? '首页' : 'Home',
      path: home,
      active: (pathname) => pathname === home,
    },
    {
      id: 'architecture',
      label: chinese ? '架构' : 'Architecture',
      path: architecture,
      active: (pathname) => routeActive(pathname, architecture) || pathname.includes('/units/PTO-ARCH-'),
    },
  ];
  const instructions: NavigationItem[] = [
    {
      id: 'scalar',
      label: 'Scalar',
      path: scalar,
      active: (pathname, currentSearch) => pathname.includes('/instructions/scalar/') ||
        (pathname.endsWith('/search/') && currentSearch.includes('surface=scalar')),
    },
    {
      id: 'block',
      label: 'Block',
      path: block,
      active: (pathname, currentSearch) => pathname.includes('/instructions/block/') ||
        (pathname.endsWith('/search/') && currentSearch.includes('surface=block')),
    },
    {
      id: 'tile',
      label: 'Tile',
      path: tile,
      active: (pathname, currentSearch) => pathname.includes('/instructions/tile/') ||
        (pathname.endsWith('/search/') && currentSearch.includes('surface=tile')),
    },
  ];
  const records: NavigationItem[] = [
    {
      id: 'reference',
      label: chinese ? '参考资料' : 'Reference',
      path: reference,
      active: (pathname) => pathname.includes('/reference/arch/') || pathname.includes('/reference/scalar/') ||
        pathname.includes('/reference/block/') || pathname.includes('/reference/tile/'),
    },
    {
      id: 'ndf',
      label: 'NDF',
      path: ndf,
      active: (pathname) => pathname.includes('/explore/ndf/'),
    },
    {
      id: 'decisions',
      label: chinese ? 'Decision / ADR' : 'Decisions / ADR',
      path: decisions,
      active: (pathname) => pathname.includes('/reference/governance/') ||
        pathname.includes('/reference/status/decisions/'),
    },
    {
      id: 'search',
      label: chinese ? '搜索' : 'Search',
      path: search,
      active: (pathname, currentSearch) => pathname.endsWith('/search/') && !currentSearch.includes('surface='),
    },
  ];

  const renderItems = (items: NavigationItem[]) => items.map((item) => {
    const active = item.active(location.pathname, query);
    return (
      <li key={item.id}>
        <Link
          className={active ? styles.navLinkActive : styles.navLink}
          to={item.path}
          data-section-current={active ? 'true' : undefined}
          data-navigation-id={item.id}>
          {item.label}
        </Link>
      </li>
    );
  });

  return (
    <nav className={styles.navigation} aria-label={chinese ? '规范导航' : 'Specification navigation'}>
      <div className={styles.currentPage}>
        <span>{chinese ? '当前位置' : 'Current page'}</span>
        <Link
          to={`${location.pathname}${location.search}`}
          aria-current="page"
          data-current-page="true">
          {currentPageLabel}
        </Link>
      </div>
      {[
        {id: 'reading-path', label: chinese ? '阅读路径' : 'Reading path', items: primary},
        {id: 'instructions', label: chinese ? '指令' : 'Instructions', items: instructions},
        {id: 'records', label: chinese ? '规范记录' : 'Specification records', items: records},
      ].map((group) => (
        <details className={styles.navigationGroup} open key={group.id}>
          <summary>{group.label}</summary>
          <ul aria-label={group.label}>{renderItems(group.items)}</ul>
        </details>
      ))}
    </nav>
  );
}
