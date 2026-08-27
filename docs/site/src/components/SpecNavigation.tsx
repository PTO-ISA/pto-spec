import React, {useMemo, useState} from 'react';
import BrowserOnly from '@docusaurus/BrowserOnly';
import Link from '@docusaurus/Link';
import {useLocation} from '@docusaurus/router';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import {usePluginData} from '@docusaurus/useGlobalData';
import type {PtoNavigationData, PtoNavigationNode} from '@site/src/types/pto';
import styles from './PortalShell.module.css';

type PtoPluginData = {
  navigation: PtoNavigationData;
};

function routeParts(route: string): {pathname: string; search: string} {
  const query = route.indexOf('?');
  return query === -1
    ? {pathname: route, search: ''}
    : {pathname: route.slice(0, query), search: route.slice(query)};
}

function instructionSurface(search: string): string | null {
  return new URLSearchParams(search).get('surface');
}

function routeCurrent(node: PtoNavigationNode, pathname: string, search: string): boolean {
  if (node.route === null) return false;
  const target = routeParts(node.route);
  if (node.id === 'scalar' || node.id === 'block' || node.id === 'tile') {
    return pathname.includes(`/instructions/${node.id}/`) ||
      (pathname.endsWith('/instructions/') && instructionSurface(search) === node.id);
  }
  if (node.id === 'instructions') {
    return pathname === target.pathname && instructionSurface(search) === null;
  }
  if (node.kind === 'ndf' && !target.pathname.includes('/ndf/')) {
    return false;
  }
  return pathname === target.pathname && (!target.search || target.search === search);
}

function collectBranchIds(nodes: PtoNavigationNode[]): Set<string> {
  const ids = new Set<string>();
  const visit = (node: PtoNavigationNode): void => {
    if (node.kind === 'branch') ids.add(node.id);
    node.children.forEach(visit);
  };
  nodes.forEach(visit);
  return ids;
}

function collectCurrentBranchIds(
  nodes: PtoNavigationNode[],
  pathname: string,
  search: string,
): Set<string> {
  const ids = new Set<string>();
  const visit = (node: PtoNavigationNode): boolean => {
    const current = routeCurrent(node, pathname, search);
    const descendantCurrent = node.children.map(visit).some(Boolean);
    if (node.kind === 'branch' && (current || descendantCurrent)) ids.add(node.id);
    return current || descendantCurrent;
  };
  nodes.forEach(visit);
  return ids;
}

function filterNavigationNode(node: PtoNavigationNode, query: string): PtoNavigationNode | null {
  if (!query) return node;
  const matches = `${node.id} ${node.label}`.toLocaleLowerCase().includes(query);
  if (matches) return node;
  const children = node.children
    .map((child) => filterNavigationNode(child, query))
    .filter((child): child is PtoNavigationNode => child !== null);
  return children.length > 0 ? {...node, children} : null;
}

function sourceIdentity(node: PtoNavigationNode): string {
  const prefix = `${node.kind}:`;
  return node.id.startsWith(prefix) ? node.id.slice(prefix.length) : node.id;
}

function NavigationLeaf({
  node,
  pathname,
  search,
}: {
  node: PtoNavigationNode;
  pathname: string;
  search: string;
}): React.JSX.Element {
  const current = routeCurrent(node, pathname, search);
  const identity = sourceIdentity(node);
  return (
    <li>
      <Link
        className={current ? styles.navLinkActive : styles.navLink}
        to={node.route ?? '#'}
        title={identity}
        aria-current={current ? 'page' : undefined}
        data-section-current={current ? 'true' : undefined}
        data-navigation-id={node.kind === 'page' ? node.id : undefined}
        data-navigation-unit-id={node.kind === 'unit' ? identity : undefined}
        data-navigation-ndf-id={node.kind === 'ndf' ? identity : undefined}
        data-navigation-adr-id={node.kind === 'adr' ? identity : undefined}>
        {node.label}
      </Link>
    </li>
  );
}

function NavigationBranch({
  node,
  pathname,
  search,
  chinese,
  expanded,
  collapsed,
  currentBranchIds,
  defaultOpen,
  forceOpen,
  onToggle,
}: {
  node: PtoNavigationNode;
  pathname: string;
  search: string;
  chinese: boolean;
  expanded: Set<string>;
  collapsed: Set<string>;
  currentBranchIds: Set<string>;
  defaultOpen: boolean;
  forceOpen: boolean;
  onToggle: (id: string, open: boolean, defaultOpen: boolean) => void;
}): React.JSX.Element {
  const branchCurrent = currentBranchIds.has(node.id);
  const exactCurrent = routeCurrent(node, pathname, search);
  const open = forceOpen || branchCurrent || expanded.has(node.id) ||
    (defaultOpen && !collapsed.has(node.id));
  return (
    <li
      className={styles.hierarchyBranch}
      data-navigation-branch={node.id}
      data-open={open ? 'true' : 'false'}>
      <button
        type="button"
        className={branchCurrent ? styles.branchSummaryActive : styles.branchSummary}
        aria-expanded={open}
        onClick={() => {
          if (!forceOpen && !branchCurrent) onToggle(node.id, !open, defaultOpen);
        }}>
        <span className={styles.branchDisclosure} aria-hidden="true">›</span>
        <span className={styles.branchLabel}>{node.label}</span>
        <span className={styles.branchCount}>{node.count}</span>
      </button>
      {node.route !== null && (
        <Link
          className={exactCurrent ? styles.branchOverviewActive : styles.branchOverview}
          to={node.route}
          aria-current={exactCurrent ? 'page' : undefined}
          data-navigation-id={node.id}
          data-section-current={branchCurrent ? 'true' : undefined}>
          {chinese ? '概览' : 'Overview'}
        </Link>
      )}
      {open && (
        <div className={styles.branchContent}>
          <ul>
            {node.children.map((child) => child.kind === 'branch'
              ? (
                <NavigationBranch
                  key={child.id}
                  node={child}
                  pathname={pathname}
                  search={search}
                  chinese={chinese}
                  expanded={expanded}
                  collapsed={collapsed}
                  currentBranchIds={currentBranchIds}
                  defaultOpen={false}
                  forceOpen={forceOpen}
                  onToggle={onToggle}
                />
              )
              : <NavigationLeaf key={child.id} node={child} pathname={pathname} search={search} />)}
          </ul>
        </div>
      )}
    </li>
  );
}

function InteractiveHierarchy({
  navigation,
  chinese,
}: {
  navigation: PtoNavigationData;
  chinese: boolean;
}): React.JSX.Element {
  const location = useLocation();
  const allBranchIds = useMemo(() => collectBranchIds(navigation.sections), [navigation.sections]);
  const currentBranchIds = useMemo(
    () => collectCurrentBranchIds(navigation.sections, location.pathname, location.search),
    [location.pathname, location.search, navigation.sections],
  );
  const rootBranchIds = useMemo(
    () => new Set(navigation.sections.filter((node) => node.kind === 'branch').map((node) => node.id)),
    [navigation.sections],
  );
  const [expanded, setExpanded] = useState<Set<string>>(() => new Set(currentBranchIds));
  const [collapsed, setCollapsed] = useState<Set<string>>(() => new Set());
  const [query, setQuery] = useState('');
  const normalizedQuery = query.trim().toLocaleLowerCase();
  const sections = navigation.sections
    .map((node) => filterNavigationNode(node, normalizedQuery))
    .filter((node): node is PtoNavigationNode => node !== null);
  const setBranch = (id: string, open: boolean, defaultOpen: boolean): void => {
    setExpanded((previous) => {
      const next = new Set(previous);
      if (open) next.add(id);
      else next.delete(id);
      return next;
    });
    if (defaultOpen) {
      setCollapsed((previous) => {
        const next = new Set(previous);
        if (open) next.delete(id);
        else next.add(id);
        return next;
      });
    }
  };
  return (
    <>
      <div className={styles.hierarchyTools}>
        <label>
          <span>{chinese ? '筛选完整层级' : 'Filter full hierarchy'}</span>
          <input
            type="search"
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder={chinese ? '输入 ID、mnemonic 或分类' : 'ID, mnemonic, or category'}
          />
        </label>
        <div className={styles.hierarchyActions}>
          <button type="button" onClick={() => {
            setExpanded(new Set(allBranchIds));
            setCollapsed(new Set());
          }}>
            {chinese ? '展开完整层级' : 'Expand hierarchy'}
          </button>
          <button type="button" onClick={() => {
            setExpanded(new Set(currentBranchIds));
            setCollapsed(new Set(rootBranchIds));
          }}>
            {chinese ? '收起完整层级' : 'Collapse hierarchy'}
          </button>
        </div>
        <p data-navigation-count>{navigation.totalLeaves} {chinese ? '个可导航条目' : 'navigable entries'}</p>
      </div>
      <ul className={styles.hierarchyRoot} aria-label={chinese ? '完整规范层级' : 'Full specification hierarchy'}>
        {sections.map((node) => node.kind === 'branch'
          ? (
            <NavigationBranch
              key={node.id}
              node={node}
              pathname={location.pathname}
              search={location.search}
              chinese={chinese}
              expanded={expanded}
              collapsed={collapsed}
              currentBranchIds={currentBranchIds}
              defaultOpen
              forceOpen={Boolean(normalizedQuery)}
              onToggle={setBranch}
            />
          )
          : <NavigationLeaf key={node.id} node={node} pathname={location.pathname} search={location.search} />)}
      </ul>
    </>
  );
}

function StaticHierarchy({
  navigation,
  chinese,
}: {
  navigation: PtoNavigationData;
  chinese: boolean;
}): React.JSX.Element {
  return (
    <div className={styles.staticHierarchy}>
      <p>{chinese
        ? `完整层级包含 ${navigation.totalLeaves} 个条目；启用 JavaScript 后可筛选并展开到每个 owner。`
        : `The full hierarchy contains ${navigation.totalLeaves} entries. Enable JavaScript to filter and expand every owner.`}</p>
      <ul>
        {navigation.sections.map((node) => node.kind === 'branch'
          ? <li key={node.id}>{node.label} <span>{node.count}</span></li>
          : <li key={node.id}><Link to={node.route ?? '#'}>{node.label}</Link></li>)}
      </ul>
    </div>
  );
}

export default function SpecNavigation({currentPageLabel}: {currentPageLabel: string}): React.JSX.Element {
  const location = useLocation();
  const {i18n} = useDocusaurusContext();
  const chinese = i18n.currentLocale === 'zh-CN';
  const {navigation} = usePluginData('pto-content') as PtoPluginData;
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
      <BrowserOnly fallback={<StaticHierarchy navigation={navigation} chinese={chinese} />}>
        {() => <InteractiveHierarchy navigation={navigation} chinese={chinese} />}
      </BrowserOnly>
    </nav>
  );
}
