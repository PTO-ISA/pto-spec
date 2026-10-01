<!-- GENERATED FROM: asl/scalar/sys/HL.SSRSET.asl -->
# HL.SSRSET

**Normative ASL source:** `asl/scalar/sys/HL.SSRSET.asl`

HL.SSRSET writes the complete encoded system-register address.

## Normative identity {#PTO-INST-SCALAR-HL-SSRSET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ssrset-purpose role=purpose -->
## What HL.SSRSET does

`HL.SSRSET` is the wide-address form of the system-register write. It stores the complete XLEN value of the Reg5 source into the system register named by a 24-bit address.

<!-- PTO-READER-BLOCK: scalar-hl-ssrset-mechanism role=mechanism -->
## System mechanism

`InstructionContractHandler_HL_SSRSET` selects `ScalarHandler_ExecuteSystemRegisterSet` (`asl/scalar/sys/HL.SSRSET.asl:18`), and `InstructionContractSystemAddressWidth_HL_SSRSET` fixes the address width at 24 (`asl/scalar/sys/HL.SSRSET.asl:36`). The 48-bit assembly carries the address as two 12-bit pieces, which the dispatcher recombines before the call (`asl/scalar/model/dispatch/sys.asl:96`).

The helper preflights write permission and only then reads the source, so the source is not consumed by an attempt that cannot store (`asl/scalar/model/sys/registers.asl:160`).

<!-- PTO-READER-BLOCK: scalar-hl-ssrset-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SrcL` is the Reg5 source from R0..R23, T#1..T#4, or U#1..U#4, and `SSR_ID` is the 24-bit register address (`asl/scalar/sys/HL.SSRSET.asl:1`). There is no destination operand.

`InstructionContractPushesTemporaryT_HL_SSRSET` returns `FALSE` (`asl/scalar/sys/HL.SSRSET.asl:42`), and the instruction has no destination operand, so no temporary queue is written. Encoded zero in `SrcL` names the architectural zero GPR, which is an assigned value and a legal way to write zero.

<!-- PTO-READER-BLOCK: scalar-hl-ssrset-effects role=effects -->
## Architectural effects

A successful attempt stores the source value into the addressed register and advances `TPC` by the length of the 48-bit form. When the address is a base pointer register such as 0x0000, the store lands in that register; when it is `CORE_STATE`, the store also updates the current access ring from bits 3:0 (`asl/scalar/model/sys/semantics.asl:63`).

Design point: a store to a read-only or unknown address faults before the source read, so a rejected wide write leaves both the source register and the target register exactly as they were. Nothing about the wider address field changes that ordering.

The instruction performs no ordinary scalar memory access.

<!-- PTO-READER-BLOCK: scalar-hl-ssrset-constraints role=constraints -->
## Placement and rejection

The attempt must sit in an active SYS block body; otherwise it raises `Fault_BundleControl` before any address work. The write path then rejects with `Fault_IllegalInstruction` when the current ring lacks permission for the address, or when the access class is unknown or read-only (`asl/scalar/model/sys/registers.asl:105`).

Design point: the permission rule keys on the low 12 bits of the address, so a 24-bit address whose low index is below 0x0F00 remains open to every ring, while the context and debug families stay ACR0-only. The extra address bits do not create a second privilege rule.

<!-- PTO-READER-BLOCK: scalar-hl-ssrset-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

`hl.ssrset SrcL, SSR_ID` with `SSR_ID` 0x0001 stores the source value into the global pointer register. Using `SSR_ID` 0x0C00 instead is rejected with `Fault_IllegalInstruction`, because `CYCLE` is read-only, and the source read never happens.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ssrset SrcL, SSR_ID
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ssrset_48_dd25753307c2 | HL48 | 48 | 0x0000103b000e / 0x00007fff000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ssrset_48_dd25753307c2 | SSR_ID | 24 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |
| hl_ssrset_48_dd25753307c2 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ssrset_48_dd25753307c2 | SSR_ID | 24 | 0–16777215 | none | none | system-register identifier | Encoded zero selects value zero of the system-register identifier. |
| hl_ssrset_48_dd25753307c2 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SSR_ID | system-register identifier |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/HL.SSRSET.asl -->
```asl
readonly func InstructionContractOperation_HL_SSRSET()
    => ScalarOperation
begin
    return ScalarOperation_HL_SSRSET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
HL.SSRSET executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/HL.SSRSET.asl -->
```asl
readonly func InstructionContractHandler_HL_SSRSET()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterSet;
end;

pure func InstructionContractRequiresSystemBlock_HL_SSRSET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_HL_SSRSET()
    => bits(2)
begin
    return '01';
end;

pure func InstructionContractSystemAddressWidth_HL_SSRSET()
    => integer {5,12,24}
begin
    return 24;
end;

pure func InstructionContractPushesTemporaryT_HL_SSRSET()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- The complete encoded address is checked against its RO, WO, RW, unknown-address, and current-ACR access rules before effects.

## State effects

- Write the complete XLEN source to the selected writable system register.
- A rejected write preserves the source and target register except for ordinary trap entry.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Preflight the complete address, current-ACR permission, and writable access class before reading SrcL.
- Snapshot SrcL, perform the register write, and then advance TPC.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- hl.ssrset SrcL, SSR_ID
