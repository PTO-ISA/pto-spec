import React from 'react';
import type {PtoInstructionWorkbenchData, PtoUnitWorkbenchData} from '@site/src/types/pto';
import UnitWorkbench from './UnitWorkbench';

export interface InstructionWorkbenchRouteProps {
  instruction: PtoInstructionWorkbenchData;
}

export default function InstructionWorkbench({instruction}: InstructionWorkbenchRouteProps): React.JSX.Element {
  return <UnitWorkbench unitData={instruction as PtoUnitWorkbenchData} />;
}
