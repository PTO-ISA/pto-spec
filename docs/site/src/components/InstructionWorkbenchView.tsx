import React from 'react';
import type {PtoInstructionWorkbenchData, PtoUnitWorkbenchData} from '@site/src/types/pto';
import UnitWorkbenchView from './UnitWorkbenchView';

export default function InstructionWorkbenchView({instruction}: {instruction: PtoInstructionWorkbenchData}): React.JSX.Element {
  return <UnitWorkbenchView unitData={instruction as PtoUnitWorkbenchData} />;
}
