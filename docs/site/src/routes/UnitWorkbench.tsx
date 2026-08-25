import React from 'react';
import Layout from '@theme/Layout';
import type {PtoUnitWorkbenchData} from '@site/src/types/pto';
import UnitWorkbenchView, {unitPresentation} from '@site/src/components/UnitWorkbenchView';

export interface UnitWorkbenchRouteProps {
  unitData: PtoUnitWorkbenchData;
}

export default function UnitWorkbench({unitData}: UnitWorkbenchRouteProps): React.JSX.Element {
  const presentation = unitPresentation(unitData);
  const description = `ASL, NDF, and evidence for ${presentation.title}.`;
  return (
    <Layout title={`${presentation.title} ASL unit`} description={description}>
      <UnitWorkbenchView unitData={unitData} />
    </Layout>
  );
}
