import React from 'react';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import type {PtoReaderGuide, PtoReleaseIdentity} from '@site/src/types/pto';

export function releaseStatus(release: PtoReleaseIdentity): string {
  return release.releaseEligible
    ? 'Latest verified release'
    : 'Unpublished release preview';
}

export function useLocalizedPath(path: string): string {
  const {i18n} = useDocusaurusContext();
  if (!path.startsWith('/') || i18n.currentLocale === i18n.defaultLocale) {
    return path;
  }
  if (path === `/${i18n.currentLocale}` || path.startsWith(`/${i18n.currentLocale}/`)) {
    return path;
  }
  return `/${i18n.currentLocale}${path}`;
}

export function LanguageFallbackNotice({guide}: {guide?: PtoReaderGuide} = {}): React.JSX.Element | null {
  const {i18n} = useDocusaurusContext();
  if (
    i18n.currentLocale === i18n.defaultLocale ||
    (guide !== undefined && guide.contentLocale === i18n.currentLocale)
  ) return null;
  return (
    <div className="alert alert--info" role="note">
      页面框架已切换为简体中文。尚未完成本地化的交互标签暂时使用英文；ASL/NDF
      源、稳定标识和证据在所有语言中保持原文。
    </div>
  );
}
