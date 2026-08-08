<!-- GENERATED FROM: asl/arch/data-types/fault.asl -->
# Fault

**Normative ASL source:** `asl/arch/data-types/fault.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FAULT}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/fault.asl -->
```asl
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
    Fault_ServiceRequest
};
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
