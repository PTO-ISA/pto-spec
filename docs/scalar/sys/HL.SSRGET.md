<!-- GENERATED FROM: asl/scalar/sys/HL.SSRGET.asl -->
# HL.SSRGET

**Normative ASL source:** `asl/scalar/sys/HL.SSRGET.asl`

HL.SSRGET reads the complete encoded system-register address.

## Normative identity {#PTO-INST-SCALAR-HL-SSRGET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ssrget-purpose role=purpose -->
## What HL.SSRGET does

`HL.SSRGET` is the wide-address form of the system-register read. It behaves like `SSRGET`, but its address field is 24 bits instead of 12, so the same instruction covers a much larger register space.

<!-- PTO-READER-BLOCK: scalar-hl-ssrget-mechanism role=mechanism -->
## System mechanism

`InstructionContractHandler_HL_SSRGET` selects `ScalarHandler_ExecuteSystemRegisterGet` (`asl/scalar/sys/HL.SSRGET.asl:18`), the same helper used by the 32-bit form. What changes is the address: `InstructionContractSystemAddressWidth_HL_SSRGET` fixes the width at 24 (`asl/scalar/sys/HL.SSRGET.asl:36`), and the assembly is a 48-bit form (`asl/scalar/sys/HL.SSRGET.asl:1`).

The dispatcher builds that 24-bit address from two 12-bit pieces before calling the get helper (`asl/scalar/model/dispatch/sys.asl:91`).

<!-- PTO-READER-BLOCK: scalar-hl-ssrget-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SSR_ID` is the 24-bit system-register address and `RegDst` is the destination selector `discard, R1..R23, push U, or push T` (`asl/scalar/sys/HL.SSRGET.asl:1`). `InstructionContractPushesTemporaryT_HL_SSRGET` returns `FALSE` (`asl/scalar/sys/HL.SSRGET.asl:42`), and the destination selector alone decides whether the value lands in a GPR or on a temporary queue.

Encoded zero in `SSR_ID` is the base register at address 0, and encoded zero in `RegDst` names the architectural zero GPR.

<!-- PTO-READER-BLOCK: scalar-hl-ssrget-effects role=effects -->
## Architectural effects

On success the complete register value is published through the Reg5 destination mapping and `TPC` advances by the instruction length. The destination is written only when the read reported no fault (`asl/scalar/model/sys/registers.asl:148`), so a rejected wide read leaves the destination and the temporary queues untouched.

Design point: the read path accepts only addresses whose bits 23:16 are zero for the stored extended file, and `SystemRegisterFileIndexOf` asserts that condition (`asl/scalar/model/sys/registers.asl:56`). An address in that part of the space is therefore admitted or rejected by the access-class table before the index is formed.

The instruction does not modify the system-register file and performs no ordinary scalar memory access.

<!-- PTO-READER-BLOCK: scalar-hl-ssrget-constraints role=constraints -->
## Placement and rejection

Placement in an active SYS block body is checked first, and an attempt elsewhere raises `Fault_BundleControl`. The read path then rejects with `Fault_IllegalInstruction` when the ring lacks permission for the address or when the access class is unknown or write-only (`asl/scalar/model/sys/registers.asl:66`).

Design point: the wider address field does not widen the permission rule. Addresses whose low 12 bits are below 0x0F00 stay reachable from every ring, while the context, translation, and debug families need ACR0, exactly as for the 12-bit form.

<!-- PTO-READER-BLOCK: scalar-hl-ssrget-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

`hl.ssrget SSR_ID, ->{t, u, Rd}` with `SSR_ID` 0x1F02 and a destination of R2 reads the ring-1 trap-status register at ACR0 and publishes its packed value into R2; that word carries the trap number in bits 5:0 together with the trap cause and the status flags. Reading `SSR_ID` 0x0F04 with the same destination is rejected with `Fault_IllegalInstruction`, because that address has no assigned access class, and R2 keeps its previous value.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ssrget SSR_ID, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ssrget_48_fde37e58a3c4 | HL48 | 48 | 0x0000003b000e / 0x000ff07f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ssrget_48_fde37e58a3c4 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ssrget_48_fde37e58a3c4 | SSR_ID | 24 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ssrget_48_fde37e58a3c4 | RegDst | 5 | 0–31 | none | none | Reg5 destination: discard, R1..R23, push U, or push T | Encoded zero names the architectural zero GPR. |
| hl_ssrget_48_fde37e58a3c4 | SSR_ID | 24 | 0–16777215 | none | none | system-register identifier | Encoded zero selects value zero of the system-register identifier. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination: discard, R1..R23, push U, or push T |
| SSR_ID | system-register identifier |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/HL.SSRGET.asl -->
```asl
readonly func InstructionContractOperation_HL_SSRGET()
    => ScalarOperation
begin
    return ScalarOperation_HL_SSRGET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
HL.SSRGET executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/HL.SSRGET.asl -->
```asl
readonly func InstructionContractHandler_HL_SSRGET()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterGet;
end;

pure func InstructionContractRequiresSystemBlock_HL_SSRGET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_HL_SSRGET()
    => bits(2)
begin
    return '00';
end;

pure func InstructionContractSystemAddressWidth_HL_SSRGET()
    => integer {5,12,24}
begin
    return 24;
end;

pure func InstructionContractPushesTemporaryT_HL_SSRGET()
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

- Read the complete XLEN system-register value and publish it through the common Reg5 destination mapping.
- A rejected read preserves the destination and queue state except for ordinary trap entry.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check block placement and encoded legality before source reads or architectural effects.
- Snapshot every scalar source before the selected system effect, then advance TPC only after success.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- hl.ssrget SSR_ID, ->{t, u, Rd}
