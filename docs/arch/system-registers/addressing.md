<!-- GENERATED FROM: asl/arch/system-registers/addressing.asl -->
# Addressing

**Normative ASL source:** `asl/arch/system-registers/addressing.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/system-registers/addressing.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING","surface":"arch","classification":["system-registers","addressing"],"depends_on":["PTO-ARCH-DATA-TYPES-TRAP-CONTEXT"]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-SYSTEM-REGISTERS","classification":["architecture","system-registers"],"scope":"system","owner":"PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING","members":["_SystemRegisters"],"depends_on":[]}
type BaseSystemRegisterState of record {
    thread_ptr: Word,
    global_ptr: Word,
    core_state: Word,
    core_id: Word,
    thread_id: Word,
    vendor: Word,
    version: Word,
    core_feature: Word,
    core_feature_enable: Word,
    tile_capacity: Word,
    blocknum: Word,
    blockid: Word,
    cycle: Word
};

var _SystemRegisters : BaseSystemRegisterState;

impdef func ResetProfileState()
begin
    // Overridden by the active concrete profile.
    _CurrentACR = 0;
    _SystemRegisters.cycle = Zeros{PTO_XLEN};
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
