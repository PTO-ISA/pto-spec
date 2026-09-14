<!-- GENERATED FROM: asl/arch/data-types/system-registers.asl -->
# System Registers

**Normative ASL source:** `asl/arch/data-types/system-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-SYSTEM-REGISTERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-system-register-types-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit defines the shared symbolic namespaces for base system registers, access classes, and cache/TLB maintenance operations.

It supplies typed identities; address mapping, access control, register state, and maintenance effects are owned elsewhere.

<!-- PTO-READER-BLOCK: arch-system-register-types-concepts-state role=concepts-state -->
## Concepts and visible state

- `SystemRegister` names thread/global pointers, time/cycle, core and thread identity, vendor/version/features, tile capacity, and block identity registers.
- `SystemRegisterAccess` distinguishes unknown, read-only, write-only, and read-write access classes.
- `MaintenanceOperation` names data-cache, instruction-cache, bundle-cache, and TLB invalidation or cleaning variants.

<!-- PTO-READER-BLOCK: arch-system-register-types-rules-interactions role=rules-interactions -->
## Rules and interactions

An enum member identifies a register or operation but does not assign its encoded address.

Access classification is separate from the current access-control ring and concrete read/write behavior.

Maintenance variants remain distinct, including whole-cache, virtual-address, and set/way forms where declared.

<!-- PTO-READER-BLOCK: arch-system-register-types-boundaries role=boundaries -->
## Architectural boundaries

This unit does not create the system-register file and does not state reset values. Follow the state and addressing owners for those contracts.

A declared maintenance identity does not by itself guarantee instruction availability or define epoch changes; the executing owner supplies those effects.

<!-- PTO-READER-BLOCK: arch-system-register-types-example-usage role=example-usage -->
## Non-normative reading example

`SystemRegister_TIME` names a system register.

The addressing and timer/state owners define its architectural address and value behavior.

`Maintenance_TLB_IALL` identifies the all-entry TLB operation.

The invoking instruction still owns legality, operands, and visible maintenance state changes.

<!-- PTO-READER-BLOCK: arch-system-register-types-related-owners role=related-owners-navigation -->
## Related owners

- [System-register addressing](../system-registers/addressing.md)
- [System-register access control](../system-registers/access-control.md)
- [Maintenance behavior](../system-registers/maintenance.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/system-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-SYSTEM-REGISTERS","surface":"arch","classification":["data-types","system-registers"],"depends_on":["PTO-ARCH-DATA-TYPES-MEMORY-OPERATIONS"],"catalog_projection":{"catalog":"system-registers","system_register_address_bits":24,"system_register_file_index_bits":16,"isa":"PTO Instruction Set Architecture","registers":[{"access":"RW","address":"0x0000","name":"THREAD_PTR","scope":"base"},{"access":"RW","address":"0x0001","name":"GLOBAL_PTR","scope":"base"},{"access":"RO","address":"0x0010","name":"TIME","scope":"base"},{"access":"RW","address":"0x0020","name":"CORE_STATE","scope":"base"},{"access":"RO","address":"0x0021","name":"CORE_ID","scope":"base"},{"access":"RO","address":"0x0022","name":"VENDOR","scope":"base"},{"access":"RO","address":"0x0023","name":"VERSION","scope":"base"},{"access":"RO","address":"0x0024","name":"CORE_FEATURE","scope":"base"},{"access":"RW","address":"0x0025","name":"CORE_FEATURE_ENABLE","scope":"base"},{"access":"RO","address":"0x0026","name":"THREAD_ID","scope":"base"},{"access":"RO","address":"0x0027","name":"TILE_CAPACITY","scope":"base"},{"access":"RO","address":"0x0050","name":"BLOCKNUM","scope":"base"},{"access":"RO","address":"0x0051","name":"BLOCKID","scope":"base"},{"access":"RO","address":"0x0C00","name":"CYCLE","scope":"base"},{"access":"RW","low_index":"0xF00","name":"ECSTATE_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF01","name":"EVBASE_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF02","name":"TRAPNO_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF03","name":"TRAPARG0_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF05","name":"ETEMP_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF06","name":"ETEMP0_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF07","name":"ECONFIG_ACRn","scope":"context-family"},{"access":"RO","low_index":"0xF08","name":"IPENDING_ACRn","scope":"context-family"},{"access":"RO","low_index":"0xF09","name":"TOPEI_ACRn","scope":"context-family"},{"access":"WO","low_index":"0xF0A","name":"EOIEI_ACRn","scope":"context-family"},{"access":"RW","fixed_context":1,"low_index":"0xF10","name":"TTBR0_ACR1","scope":"context-family"},{"access":"RW","fixed_context":1,"low_index":"0xF11","name":"TTBR1_ACR1","scope":"context-family"},{"access":"RW","fixed_context":1,"low_index":"0xF12","name":"TCR_ACR1","scope":"context-family"},{"access":"RW","fixed_context":1,"low_index":"0xF13","name":"MAIR_ACR1","scope":"context-family"},{"access":"RW","fixed_context":1,"low_index":"0xF14","name":"IOTTBR_ACR1","scope":"context-family"},{"access":"RW","fixed_context":1,"low_index":"0xF15","name":"IOTCR_ACR1","scope":"context-family"},{"access":"RW","fixed_context":1,"low_index":"0xF16","name":"IOMAIR_ACR1","scope":"context-family"},{"access":"RO","low_index":"0xF20","name":"TIMER_TIME_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF21","name":"TIMER_TIMECMP_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF30","name":"XBINFO_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF31","name":"ACR_PARAM_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF40","name":"EBARG0_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF41","name":"EBARG_BPC_CUR_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF42","name":"EBARG_BPC_TGT_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF43","name":"EBARG_TPC_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF44","name":"EBARG_LRA_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF45","name":"EBARG_TQ0_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF46","name":"EBARG_TQ1_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF47","name":"EBARG_TQ2_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF48","name":"EBARG_TQ3_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF49","name":"EBARG_UQ0_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF4A","name":"EBARG_UQ1_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF4B","name":"EBARG_UQ2_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF4C","name":"EBARG_UQ3_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF4D","name":"EBARG_LB_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF4E","name":"EBARG_LC_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF4F","name":"EBARG_EXTCTX_PTR_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF50","name":"EBARG_EXTCTX_META_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF51","name":"EBARG_TPLFLAGS_ACRn","scope":"context-family"},{"access":"RO","low_index":"0xF80","name":"DBGID_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF90","name":"DBCR0_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF92","name":"DBCR1_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF94","name":"DBCR2_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF96","name":"DBCR3_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF91","name":"DBVR0_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF93","name":"DBVR1_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF95","name":"DBVR2_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xF97","name":"DBVR3_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xFA0","name":"DCCR0_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xFA1","name":"DCVR0_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xFB0","name":"DWCR0_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xFB2","name":"DWCR1_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xFB4","name":"DWCR2_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xFB6","name":"DWCR3_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xFB1","name":"DWVR0_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xFB3","name":"DWVR1_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xFB5","name":"DWVR2_ACRn","scope":"context-family"},{"access":"RW","low_index":"0xFB7","name":"DWVR3_ACRn","scope":"context-family"}],"behavior_classes":[{"id":"base-pointer-storage","profile_status":"architectural-active","read":"stored-value","registers":["THREAD_PTR","GLOBAL_PTR"],"reset":"zero","side_effects":[],"write":"store-value"},{"id":"core-state-control","profile_status":"architectural-active","read":"stored-value","registers":["CORE_STATE"],"reset":"zero","side_effects":["write-selects-current-acr"],"write":"store-value"},{"id":"feature-enable-storage","profile_status":"architectural-active","read":"stored-value","registers":["CORE_FEATURE_ENABLE"],"reset":"zero","side_effects":[],"write":"store-value"},{"id":"architectural-time","profile_status":"architectural-active","read":"architectural-time","registers":["TIME","CYCLE"],"reset":"zero","side_effects":["advances-on-every-execution-attempt"],"write":"reject-read-only"},{"id":"zero-profile-identity","profile_status":"profile-constant","read":"profile-value","registers":["CORE_ID","VENDOR","CORE_FEATURE","THREAD_ID","BLOCKNUM","BLOCKID"],"reset":"zero","side_effects":[],"write":"reject-read-only"},{"id":"version-profile-identity","profile_status":"profile-constant","read":"profile-value","registers":["VERSION"],"reset":"one","side_effects":[],"write":"reject-read-only"},{"id":"tile-capacity-profile-limit","profile_status":"profile-constant","read":"profile-value","registers":["TILE_CAPACITY"],"reset":"pto-model-max-tile-capacity-bytes","side_effects":["limits-per-tile-and-aggregate-allocation"],"write":"reject-read-only"},{"id":"execution-context-state","profile_status":"architectural-active","read":"stored-value","registers":["ECSTATE_ACRn"],"reset":"zero","side_effects":["save-and-recovery-profile-state"],"write":"store-value"},{"id":"exception-vector-base","profile_status":"architectural-active","read":"stored-value","registers":["EVBASE_ACRn"],"reset":"zero","side_effects":["selects-trap-entry-tpc"],"write":"store-value"},{"id":"trap-status","profile_status":"architectural-active","read":"packed-trap-status","registers":["TRAPNO_ACRn"],"reset":"zero","side_effects":["reads-and-writes-trap-bank-fields"],"write":"unpack-trap-status"},{"id":"trap-argument","profile_status":"architectural-active","read":"trap-argument-zero","registers":["TRAPARG0_ACRn"],"reset":"zero","side_effects":["reads-and-writes-trap-bank-argument"],"write":"store-trap-argument-zero"},{"id":"exception-temporary-storage","profile_status":"architectural-active","read":"stored-value","registers":["ETEMP_ACRn","ETEMP0_ACRn"],"reset":"zero","side_effects":[],"write":"store-value"},{"id":"interrupt-configuration","profile_status":"architectural-active","read":"stored-value","registers":["ECONFIG_ACRn"],"reset":"external-and-timer-enabled","side_effects":["controls-external-and-timer-trap-entry"],"write":"store-value"},{"id":"interrupt-pending","profile_status":"architectural-active","read":"refresh-timer-then-pending-bitmap","registers":["IPENDING_ACRn"],"reset":"zero","side_effects":["reflects-external-and-timer-pending-sources"],"write":"reject-read-only"},{"id":"top-pending-interrupt","profile_status":"architectural-active","read":"refresh-timer-then-lowest-pending-id","registers":["TOPEI_ACRn"],"reset":"zero","side_effects":["priority-derived-from-pending-bitmap"],"write":"reject-read-only"},{"id":"end-of-interrupt","profile_status":"architectural-active","read":"reject-write-only","registers":["EOIEI_ACRn"],"reset":"zero","side_effects":["clears-selected-pending-id","clears-asynchronous-trap-status"],"write":"acknowledge-interrupt-id"},{"id":"translation-configuration-storage","profile_status":"pto-v0-storage-only","read":"stored-value","registers":["TTBR0_ACR1","TTBR1_ACR1","TCR_ACR1","MAIR_ACR1","IOTTBR_ACR1","IOTCR_ACR1","IOMAIR_ACR1"],"reset":"zero","side_effects":["pto-v0-identity-translation-does-not-consume-value"],"write":"store-value"},{"id":"timer-time","profile_status":"architectural-active","read":"architectural-time","registers":["TIMER_TIME_ACRn"],"reset":"zero","side_effects":["aliases-architectural-time"],"write":"reject-read-only"},{"id":"timer-compare","profile_status":"architectural-active","read":"stored-value","registers":["TIMER_TIMECMP_ACRn"],"reset":"zero","side_effects":["refreshes-timer-pending-state"],"write":"store-value"},{"id":"acr-parameter-storage","profile_status":"pto-v0-storage-only","read":"stored-value","registers":["XBINFO_ACRn","ACR_PARAM_ACRn"],"reset":"zero","side_effects":["pto-v0-does-not-consume-value"],"write":"store-value"},{"id":"saved-execution-context","profile_status":"architectural-active","read":"saved-context-value","registers":["EBARG0_ACRn","EBARG_BPC_CUR_ACRn","EBARG_BPC_TGT_ACRn","EBARG_TPC_ACRn","EBARG_LRA_ACRn","EBARG_TQ0_ACRn","EBARG_TQ1_ACRn","EBARG_TQ2_ACRn","EBARG_TQ3_ACRn","EBARG_UQ0_ACRn","EBARG_UQ1_ACRn","EBARG_UQ2_ACRn","EBARG_UQ3_ACRn"],"reset":"zero","side_effects":["save-and-recovery-profile-state"],"write":"store-saved-context-value"},{"id":"saved-loop-context-storage","profile_status":"pto-v0-storage-only","read":"stored-value","registers":["EBARG_LB_ACRn","EBARG_LC_ACRn"],"reset":"zero","side_effects":["trap-save-clears-value","pto-v0-recovery-does-not-consume-value"],"write":"store-value"},{"id":"extended-context-storage","profile_status":"pto-v0-storage-only","read":"stored-value","registers":["EBARG_EXTCTX_PTR_ACRn","EBARG_EXTCTX_META_ACRn","EBARG_TPLFLAGS_ACRn"],"reset":"zero","side_effects":["trap-save-preserves-value","pto-v0-recovery-does-not-consume-value"],"write":"store-value"},{"id":"debug-identity-storage","profile_status":"pto-v0-storage-only","read":"stored-value","registers":["DBGID_ACRn"],"reset":"zero","side_effects":["pto-v0-debug-matching-disabled"],"write":"reject-read-only"},{"id":"debug-control-storage","profile_status":"pto-v0-storage-only","read":"stored-value","registers":["DBCR0_ACRn","DBCR1_ACRn","DBCR2_ACRn","DBCR3_ACRn","DBVR0_ACRn","DBVR1_ACRn","DBVR2_ACRn","DBVR3_ACRn","DCCR0_ACRn","DCVR0_ACRn","DWCR0_ACRn","DWCR1_ACRn","DWCR2_ACRn","DWCR3_ACRn","DWVR0_ACRn","DWVR1_ACRn","DWVR2_ACRn","DWVR3_ACRn"],"reset":"zero","side_effects":["pto-v0-debug-matching-disabled"],"write":"store-value"}],"schema_version":1,"trap_numbers":[{"argument":"source-tpc","cause":"zero","name":"EXEC_STATE_CHECK","number":0,"producers":["ArchitectureEnterRequest","SetFault(Fault_ExecutionStateCheck)"],"pto_v0_status":"production-active","restart":"saved-source-context"},{"argument":"fault-address","cause":"zero","name":"ILLEGAL_INST","number":4,"producers":["SetFault(Fault_IllegalInstruction)"],"pto_v0_status":"production-active","restart":"saved-source-context"},{"argument":"fault-address","cause":"zero","name":"BUNDLE_TRAP","number":5,"producers":["SetFault(Fault_BundleControl)","SetFault(Fault_TileAllocation)","SetFault(Fault_TileLegality)"],"pto_v0_status":"production-active","restart":"saved-source-context"},{"argument":"source-tpc","cause":"request-type","name":"SCALL","number":6,"producers":["RaiseServiceRequest","SetFault(Fault_ServiceRequest)"],"pto_v0_status":"production-active","restart":"saved-context-resume-next-instruction"},{"argument":"invalid-target","cause":"zero","name":"INST_PC_FAULT","number":32,"producers":["SetFault(Fault_InstructionPC)"],"pto_v0_status":"production-active","restart":"saved-source-context"},{"argument":"fault-address","cause":"zero","name":"INST_PAGE_FAULT","number":33,"producers":["SetFault(Fault_InstructionPage)"],"pto_v0_status":"envelope-only-no-trigger","restart":"saved-source-context"},{"argument":"fault-address","cause":"zero","name":"DATA_ALIGN_FAULT","number":34,"producers":["SetFault(Fault_DataAlignment)"],"pto_v0_status":"production-active","restart":"saved-source-context"},{"argument":"fault-address","cause":"zero","name":"DATA_PAGE_FAULT","number":35,"producers":["SetFault(Fault_DataPage)"],"pto_v0_status":"production-active","restart":"saved-source-context"},{"argument":"interrupt-id","cause":"source-supplied","name":"INTERRUPT","number":44,"producers":["RaiseInterrupt"],"pto_v0_status":"production-active","restart":"saved-source-context"},{"argument":"instruction-address","cause":"zero","name":"HW_BREAKPOINT","number":49,"producers":["SetFault(Fault_HardwareBreakpoint)"],"pto_v0_status":"envelope-only-no-trigger","restart":"saved-source-context"},{"argument":"instruction-address","cause":"zero","name":"SW_BREAKPOINT","number":50,"producers":["SetFault(Fault_SoftwareBreakpoint)"],"pto_v0_status":"production-active","restart":"saved-source-context"},{"argument":"data-address","cause":"zero","name":"HW_WATCHPOINT","number":51,"producers":["SetFault(Fault_HardwareWatchpoint)"],"pto_v0_status":"envelope-only-no-trigger","restart":"saved-source-context"},{"argument":"instruction-address","cause":"zero","name":"ASSERT_FAIL","number":52,"producers":["SetFault(Fault_Assert)"],"pto_v0_status":"production-active","restart":"saved-source-context"}]}}
type SystemRegister of enumeration {
    SystemRegister_THREAD_PTR,
    SystemRegister_GLOBAL_PTR,
    SystemRegister_TIME,
    SystemRegister_CORE_STATE,
    SystemRegister_CORE_ID,
    SystemRegister_THREAD_ID,
    SystemRegister_VENDOR,
    SystemRegister_VERSION,
    SystemRegister_CORE_FEATURE,
    SystemRegister_CORE_FEATURE_ENABLE,
    SystemRegister_TILE_CAPACITY,
    SystemRegister_BLOCKNUM,
    SystemRegister_BLOCKID,
    SystemRegister_CYCLE
};

type SystemRegisterAccess of enumeration {
    SystemRegisterAccess_Unknown,
    SystemRegisterAccess_ReadOnly,
    SystemRegisterAccess_WriteOnly,
    SystemRegisterAccess_ReadWrite
};

type MaintenanceOperation of enumeration {
    Maintenance_DC_IALL,
    Maintenance_DC_IVA,
    Maintenance_DC_ISW,
    Maintenance_DC_ZVA,
    Maintenance_DC_CVA,
    Maintenance_DC_CIVA,
    Maintenance_DC_CSW,
    Maintenance_DC_CISW,
    Maintenance_IC_IALL,
    Maintenance_IC_IVA,
    Maintenance_BC_IALL,
    Maintenance_BC_IVA,
    Maintenance_TLB_IV,
    Maintenance_TLB_IAV,
    Maintenance_TLB_IA,
    Maintenance_TLB_IALL
};
```
<!-- GENERATED-ASL-END: unit -->
