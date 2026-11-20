import React from 'react';
import {useLocation} from '@docusaurus/router';
import PortalShell from '@site/src/components/PortalShell';
import ManualIndex from '@site/src/components/ManualIndex';
import {manualSectionCopy, type ManualIndexData} from '@site/src/manual/sections';

export default function ManualIndexRoute({index}: {index: ManualIndexData}): React.JSX.Element {
  const location = useLocation();
  const chinese = location.pathname.startsWith('/zh-CN/');
  const copy = manualSectionCopy[index.section];
  const title = chinese ? copy.zhTitle : copy.title;
  const description = chinese ? copy.zhDescription : copy.description;
  return (
    <PortalShell title={title} description={description} currentPageLabel={title}>
      <ManualIndex index={index} />
    </PortalShell>
  );
}
