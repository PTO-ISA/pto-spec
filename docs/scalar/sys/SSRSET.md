<!-- GENERATED FROM: asl/scalar/sys/SSRSET.asl -->
# SSRSET

**Normative ASL source:** `asl/scalar/sys/SSRSET.asl`

SSRSET writes the complete encoded system-register address.

## Normative identity {#PTO-INST-SCALAR-SSRSET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ssrset-purpose role=purpose -->
## What SSRSET does

`SSRSET` writes one system register. It takes the value to store from the Reg5 source `SrcL` and the target from the 12-bit address `SSR_ID`, and it writes the complete XLEN value into the addressed register.

<!-- PTO-READER-BLOCK: scalar-ssrset-mechanism role=mechanism -->
## System mechanism

`InstructionContractHandler_SSRSET` selects `ScalarHandler_ExecuteSystemRegisterSet` (`asl/scalar/sys/SSRSET.asl:18`), and `InstructionContractSystemAddressWidth_SSRSET` fixes the address width at 12 (`asl/scalar/sys/SSRSET.asl:36`). The dispatcher decodes `SrcL` as a Reg5 selector and `SSR_ID` as a system-register address (`asl/scalar/model/dispatch/sys.asl:111`).

The helper checks before it reads: `ExecuteSystemRegisterSet` rejects the attempt when `SystemRegisterWritePermitted` is false, and only then reads the source register (`asl/scalar/model/sys/registers.asl:157`).

<!-- PTO-READER-BLOCK: scalar-ssrset-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SrcL` accepts the Reg5 source encodings R0..R23, T#1..T#4, and U#1..U#4, and supplies the value to store. `SSR_ID` is the 12-bit system-register identifier (`asl/scalar/sys/SSRSET.asl:1`).

`SSRSET` has no destination operand, so no register or queue receives a result. Encoded zero in `SrcL` names the architectural zero GPR, which is a legal way to write zero, and encoded zero in `SSR_ID` is the base register at address 0.

<!-- PTO-READER-BLOCK: scalar-ssrset-effects role=effects -->
## Architectural effects

A successful attempt writes the complete source value into the addressed register and then advances `TPC` by 4 bytes. Some addresses have side effects inside the write path, and address 0x0020 is the clearest example: storing into `CORE_STATE` also sets the current access ring from bits 3:0 of the stored value (`asl/scalar/model/sys/semantics.asl:63`).

Design point: the write permission check runs before the source read, so an attempt that will be rejected consumes no source value and changes no system register. A rejected `SSRSET` therefore leaves its source operand and the target register unchanged; a Reg5 source read never consumes a temporary-queue entry.

The instruction performs no ordinary scalar memory access.

<!-- PTO-READER-BLOCK: scalar-ssrset-constraints role=constraints -->
## Placement and rejection

Placement is checked first: outside an active SYS block body the attempt raises `Fault_BundleControl` before any address or operand work. The write path then rejects with `Fault_IllegalInstruction` when the current ring lacks permission for the address, or when the access class is unknown or read-only (`asl/scalar/model/sys/registers.asl:105`).

Design point: an address such as 0x0021 is readable from every ring but never writable, because its access class is read-only. The same address therefore succeeds for `ssrget` and faults for `ssrset`, which is why the access class and not the ring alone decides a write.

<!-- PTO-READER-BLOCK: scalar-ssrset-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

`ssrset SrcL, SSR_ID` with `SSR_ID` 0x0020 and a source holding the value 2 stores into `CORE_STATE`, and because bits 3:0 of the stored value are 2 the current access ring becomes ACR2 for later attempts. Using `SSR_ID` 0x0021 instead is rejected with `Fault_IllegalInstruction`, because that address is read-only, and the source register is never read.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ssrset SrcL, SSR_ID
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ssrset_32_4dd3b71802c6 | L32 | 32 | 0x0000103b / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ssrset_32_4dd3b71802c6 | SSR_ID | 12 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |
| ssrset_32_4dd3b71802c6 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ssrset_32_4dd3b71802c6 | SSR_ID | 12 | 0–4095 | none | none | system-register identifier | Encoded zero selects value zero of the system-register identifier. |
| ssrset_32_4dd3b71802c6 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SSR_ID | system-register identifier |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/SSRSET.asl -->
```asl
readonly func InstructionContractOperation_SSRSET()
    => ScalarOperation
begin
    return ScalarOperation_SSRSET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
SSRSET executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/SSRSET.asl -->
```asl
readonly func InstructionContractHandler_SSRSET()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterSet;
end;

pure func InstructionContractRequiresSystemBlock_SSRSET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_SSRSET()
    => bits(2)
begin
    return '01';
end;

pure func InstructionContractSystemAddressWidth_SSRSET()
    => integer {5,12,24}
begin
    return 12;
end;

pure func InstructionContractPushesTemporaryT_SSRSET()
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

- ssrset SrcL, SSR_ID
