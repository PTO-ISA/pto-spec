// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FAULT","surface":"arch","classification":["data-types","fault"],"depends_on":["PTO-ARCH-DATA-TYPES-INTEGER"]}
type FaultCode of enumeration {
    Fault_None,
    Fault_ExecutionStateCheck,
    Fault_IllegalInstruction,
    Fault_InstructionPC,
    Fault_InstructionPage,
    Fault_DataAlignment,
    Fault_DataPage,
    Fault_SoftwareBreakpoint,
    Fault_HardwareBreakpoint,
    Fault_HardwareWatchpoint,
    Fault_Assert,
    Fault_TileLegality,
    Fault_TileAllocation,
    Fault_BundleControl,
    Fault_BundlePostCommit,
    Fault_ServiceRequest
};
