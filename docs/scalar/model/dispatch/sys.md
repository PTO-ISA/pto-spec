<!-- GENERATED FROM: asl/scalar/model/dispatch/sys.asl -->
# SYS

**Normative ASL source:** `asl/scalar/model/dispatch/sys.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-DISPATCH-SYS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-dispatch-sys-purpose role=purpose-scope -->
## Purpose and scope

This unit executes every decoded scalar system (SYS) form. `ExecuteDecodedSYSForm` decodes the operands of each operation and calls a helper from [SYS semantics](../sys/semantics.md) or [system registers](../sys/registers.md).

The forms fall into six groups:

- access-ring requests: `ACRC` and `ACRE`;
- checks and breakpoints: `ASSERT`, `EBREAK`, and `C.EBREAK`;
- cache and TLB maintenance: `BC.*`, `DC.*`, `IC.*`, and `TLB.*`;
- execution-control requests: `BSE`, `BWE`, `BWI`, and `BWT`;
- fences: `FENCE.D` and `FENCE.I`;
- register transfers and the commit target: `SSRGET`, `SSRSET`, `SSRSWAP`, `HL.SSRGET`, `HL.SSRSET`, `C.SSRGET`, `LSRGET`, and the commit-target setter `SETC.TGT`.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-sys-concepts role=concepts-state -->
## Concepts and visible state

Each group takes its operand from a specific field:

| Group | Operand |
| --- | --- |
| `ACRC`, `ACRE` | 4-bit `RST_Type` or `RRA_Type` |
| `ASSERT`, operand-bearing maintenance, control requests, `SETC.TGT` | the Reg5 value in `SrcL` |
| `IALL` maintenance | the constant 0 |
| `C.EBREAK`, `EBREAK` | 5-bit `imm5`, or 4-bit `imm4` zero-extended |
| `FENCE.D` | 4-bit `PRED_IMM` and `SUCC_IMM` |
| SSR transfers | `SSR_ID` or `SSRID`, as a 24-bit address |
| `LSRGET` | 12-bit `LSR_ID` |

A system-register address is a 24-bit value. `ScalarDecodedSystemRegisterAddress` keeps the low 24 bits of the raw field, so a 12-bit `SSR_ID` names addresses 0 through 0xFFF.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-sys-rules role=rules-interactions -->
## Rules and interactions

`C.SSRGET` pushes the value to T. `SSRGET` and `HL.SSRGET` write it through `RegDst`. `SSRSET` and `HL.SSRSET` read `SrcL` and write the register. `SSRSWAP` reads `SrcL`, writes the register, and returns the old value to `RegDst`.

Design point: each transfer helper checks permission and access class before reading a source or the register. A rejected transfer writes no destination and changes no register. For `SSRSWAP` both read and write permission are checked first, so a rejected swap cannot trigger a read-side effect.

`ASSERT` raises `Fault_Assert` when its operand is zero. `EBREAK` and `C.EBREAK` raise `Fault_SoftwareBreakpoint` with the tag as the cause.

Design point: breakpoints and failed assertions are ordinary synchronous faults. Top-level dispatch sees `_LastFault` set, returns rejected, and does not advance TPC; the trap context records the TPC of the breakpoint instruction.

Maintenance and control requests update epochs and record their operand. They do not access memory.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-sys-boundaries role=boundaries -->
## Architectural boundaries

Most SYS forms may only run in the body of an active System bundle. `ScalarOperationApplicable` checks this before dispatch, so a misplaced form raises `Fault_BundleControl` before its handler runs; only the body-entry transition made by top-level dispatch remains. `LSRGET` needs any active bundle body, and `SETC.TGT` needs a Standard or Floating bundle.

Field legality is also checked before dispatch. For example, `ACRE` accepts only `RRA_Type` 0 or 1, and `C.SSRGET` accepts only `SSRID` 0, 1, or 16.

Among SYS forms, only `ACRE` is named by `ScalarHandlerWritesTPC`, through `ScalarHandler_ArchitectureEnterRequest`, so top-level dispatch does not add its length to TPC.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-sys-example role=example-usage -->
## Non-normative reading example

Take the 32-bit word 0x020002BB. It matches `SSRGET` (mask 0x000FF07F, match 0x3B).

| Field | Bits | Raw | Meaning |
| --- | --- | --- | --- |
| `RegDst` | 11:7 | 5 | GPR 5 |
| `SSR_ID` | 31:20 | 0x020 | `CORE_STATE` |

Inside a System bundle body, the handler calls `ExecuteSystemRegisterGet`. Address 0x020 has low bits below 0xF00, so every ring may read it, and its access class is read-write. GPR 5 receives the full `CORE_STATE`, including the rounding mode in bits 39:37 and the sticky flags in bits 36:32.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-sys-related role=related-owners-navigation -->
## Related owners

- [SYS semantics](../sys/semantics.md) owns fences, maintenance, requests, and applicability.
- [System registers](../sys/registers.md) owns SSR permission, access class, and transfers.
- [Scalar decode helpers](decode.md) own `ScalarDecodedSystemRegisterAddress`.
- [Execution context](../../../arch/programming-model/execution-context.md) declares the maintenance epochs and records.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/dispatch/sys.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-SYS","surface":"scalar","classification":["model","dispatch","sys"],"depends_on":["PTO-SCALAR-MODEL-DISPATCH-DECODE","PTO-SCALAR-MODEL-SYS-REGISTERS","PTO-SCALAR-ACRC","PTO-SCALAR-ACRE","PTO-SCALAR-ASSERT","PTO-SCALAR-BC-IALL","PTO-SCALAR-BC-IVA","PTO-SCALAR-BSE","PTO-SCALAR-BWE","PTO-SCALAR-BWI","PTO-SCALAR-BWT","PTO-SCALAR-C-EBREAK","PTO-SCALAR-C-SSRGET","PTO-SCALAR-DC-CISW","PTO-SCALAR-DC-CIVA","PTO-SCALAR-DC-CSW","PTO-SCALAR-DC-CVA","PTO-SCALAR-DC-IALL","PTO-SCALAR-DC-ISW","PTO-SCALAR-DC-IVA","PTO-SCALAR-DC-ZVA","PTO-SCALAR-EBREAK","PTO-SCALAR-FENCE-D","PTO-SCALAR-FENCE-I","PTO-SCALAR-HL-SSRGET","PTO-SCALAR-HL-SSRSET","PTO-SCALAR-IC-IALL","PTO-SCALAR-IC-IVA","PTO-SCALAR-LSRGET","PTO-SCALAR-SETC-TGT","PTO-SCALAR-SSRGET","PTO-SCALAR-SSRSET","PTO-SCALAR-SSRSWAP","PTO-SCALAR-TLB-IA","PTO-SCALAR-TLB-IALL","PTO-SCALAR-TLB-IAV","PTO-SCALAR-TLB-IV"]}
func ExecuteDecodedSYSForm(instruction: bits(48),
                           form: integer {0..PTO_SCALAR_FORM_COUNT-1})
begin
    let operation = ScalarOperationOfForm(form);
    case operation of
        when ScalarOperation_ACRC =>
            ArchitectureCloseRequest(ScalarDecodedBits4(
                instruction, form, ScalarField_RST_Type));
        when ScalarOperation_ACRE =>
            ArchitectureEnterRequest(ScalarDecodedBits4(
                instruction, form, ScalarField_RRA_Type));
        when ScalarOperation_ASSERT =>
            ArchitectureAssert(ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));

        when ScalarOperation_BC_IALL =>
            ExecuteMaintenance(Maintenance_BC_IALL, Zeros{PTO_XLEN});
        when ScalarOperation_BC_IVA =>
            ExecuteMaintenance(Maintenance_BC_IVA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_IALL =>
            ExecuteMaintenance(Maintenance_DC_IALL, Zeros{PTO_XLEN});
        when ScalarOperation_DC_IVA =>
            ExecuteMaintenance(Maintenance_DC_IVA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_ISW =>
            ExecuteMaintenance(Maintenance_DC_ISW, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_ZVA =>
            ExecuteMaintenance(Maintenance_DC_ZVA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_CVA =>
            ExecuteMaintenance(Maintenance_DC_CVA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_CIVA =>
            ExecuteMaintenance(Maintenance_DC_CIVA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_CSW =>
            ExecuteMaintenance(Maintenance_DC_CSW, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_CISW =>
            ExecuteMaintenance(Maintenance_DC_CISW, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_IC_IALL =>
            ExecuteMaintenance(Maintenance_IC_IALL, Zeros{PTO_XLEN});
        when ScalarOperation_IC_IVA =>
            ExecuteMaintenance(Maintenance_IC_IVA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_TLB_IV =>
            ExecuteMaintenance(Maintenance_TLB_IV, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_TLB_IAV =>
            ExecuteMaintenance(Maintenance_TLB_IAV, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_TLB_IA =>
            ExecuteMaintenance(Maintenance_TLB_IA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_TLB_IALL =>
            ExecuteMaintenance(Maintenance_TLB_IALL, Zeros{PTO_XLEN});

        when ScalarOperation_BSE =>
            ExecuteControlRequest(ExecutionControl_SendEvent,
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL));
        when ScalarOperation_BWE =>
            ExecuteControlRequest(ExecutionControl_WaitEvent,
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL));
        when ScalarOperation_BWI =>
            ExecuteControlRequest(ExecutionControl_WaitInterrupt,
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL));
        when ScalarOperation_BWT =>
            ExecuteControlRequest(ExecutionControl_WaitTimeout,
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL));

        when ScalarOperation_C_EBREAK =>
            SoftwareBreakpoint(ScalarDecodedBits5(
                instruction, form, ScalarField_imm5));
        when ScalarOperation_EBREAK =>
            SoftwareBreakpoint(ZeroExtend{5}(ScalarDecodedBits4(
                instruction, form, ScalarField_imm4)));
        when ScalarOperation_FENCE_D =>
            FenceData(
                ScalarDecodedBits4(instruction, form, ScalarField_PRED_IMM),
                ScalarDecodedBits4(instruction, form, ScalarField_SUCC_IMM));
        when ScalarOperation_FENCE_I => FenceInstruction();

        when ScalarOperation_C_SSRGET =>
            ExecuteCompressedSystemRegisterGet(
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSRID));
        when ScalarOperation_HL_SSRGET =>
            ExecuteSystemRegisterGet(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_HL_SSRSET =>
            ExecuteSystemRegisterSet(
                ScalarDecodedSelector(instruction, form, ScalarField_SrcL),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_LSRGET =>
            ExecuteLocalStateRegisterGet(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                DecodeScalarOperandRaw(
                    instruction, form, ScalarField_LSR_ID)[11:0]);
        when ScalarOperation_SSRGET =>
            ExecuteSystemRegisterGet(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_SSRSET =>
            ExecuteSystemRegisterSet(
                ScalarDecodedSelector(instruction, form, ScalarField_SrcL),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_SSRSWAP =>
            ExecuteSystemRegisterSwap(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarDecodedSelector(instruction, form, ScalarField_SrcL),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_SETC_TGT =>
            SetCommitTarget(ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        otherwise => unreachable;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
