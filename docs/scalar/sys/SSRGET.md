<!-- GENERATED FROM: asl/scalar/sys/SSRGET.asl -->
# SSRGET

**Normative ASL source:** `asl/scalar/sys/SSRGET.asl`

SSRGET reads the complete encoded system-register address.

## Normative identity {#PTO-INST-SCALAR-SSRGET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ssrget-purpose role=purpose -->
## What SSRGET does

`SSRGET` reads one system register. It takes a 12-bit register address in `SSR_ID` and a 5-bit destination selector in `RegDst`, reads the addressed register, and publishes the complete value to that destination. The address space is canonical, so base registers and context registers are reached by the same instruction.

<!-- PTO-READER-BLOCK: scalar-ssrget-mechanism role=mechanism -->
## System mechanism

`InstructionContractHandler_SSRGET` selects `ScalarHandler_ExecuteSystemRegisterGet` (`asl/scalar/sys/SSRGET.asl:18`), and `InstructionContractSystemAddressWidth_SSRGET` fixes the address width at 12 (`asl/scalar/sys/SSRGET.asl:36`). The dispatcher decodes `RegDst` as a Reg5 selector and `SSR_ID` as a system-register address, then calls the get helper in that order (`asl/scalar/model/dispatch/sys.asl:106`).

The helper reads first and writes second: `ExecuteSystemRegisterGet` reads the addressed register, then writes the destination only if no fault was raised (`asl/scalar/model/sys/registers.asl:144`).

<!-- PTO-READER-BLOCK: scalar-ssrget-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SSR_ID` is the 12-bit system-register identifier and `RegDst` is the destination selector `discard, R1..R23, push U, or push T` (`asl/scalar/sys/SSRGET.asl:1`). The ReadSystemRegisterAddress path classifies the address as base, extended, or unassigned, and checks its access class before the read (`asl/scalar/model/sys/registers.asl:60`).

The L32 form is 32 bits long, so `SSR_ID` addresses 4096 register positions. Encoded zero in `SSR_ID` is the base register at address 0, and encoded zero in `RegDst` names the architectural zero GPR, which discards the value.

<!-- PTO-READER-BLOCK: scalar-ssrget-effects role=effects -->
## Architectural effects

A successful read publishes the complete register value through the Reg5 destination mapping, which writes a GPR or pushes onto the U queue or the T queue (`asl/scalar/model/types/operands.asl:65`). `TPC` then advances by 4 bytes.

Design point: the destination write is conditional on the read having succeeded. A rejected read therefore leaves the destination register, the temporary queues, and the system register unchanged, so a failed `SSRGET` cannot clobber a value that later code depends on.

`SSRGET` does not modify the system-register file, and it performs no ordinary scalar memory access.

<!-- PTO-READER-BLOCK: scalar-ssrget-constraints role=constraints -->
## Placement and rejection

The first gate is placement in an active SYS block body; outside one the attempt raises `Fault_BundleControl` before the address is examined. The second gate is the address check: a read is rejected with `Fault_IllegalInstruction` when the ring lacks permission, or when the address class is `SystemRegisterAccess_Unknown` or `SystemRegisterAccess_WriteOnly` (`asl/scalar/model/sys/registers.asl:66`).

Design point: access-ring permission is decided by the address, not by the instruction. Addresses below 0x0F00 are reachable from every ring, while the context, translation, and debug families need ACR0, so the same `SSRGET` encoding succeeds or fails depending on the ring that executes it.

<!-- PTO-READER-BLOCK: scalar-ssrget-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

`ssrget SSR_ID, ->{t, u, Rd}` with `SSR_ID` 0x0010 and a destination of R1 reads `TIME`, the architectural time register, and publishes that value into R1. Repeating the instruction with `SSR_ID` 0x0F04 is rejected instead, because that address has no assigned access class and the read raises `Fault_IllegalInstruction` before any destination write.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ssrget SSR_ID, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ssrget_32_959957ab6b75 | L32 | 32 | 0x0000003b / 0x000ff07f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ssrget_32_959957ab6b75 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ssrget_32_959957ab6b75 | SSR_ID | 12 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ssrget_32_959957ab6b75 | RegDst | 5 | 0–31 | none | none | Reg5 destination: discard, R1..R23, push U, or push T | Encoded zero names the architectural zero GPR. |
| ssrget_32_959957ab6b75 | SSR_ID | 12 | 0–4095 | none | none | system-register identifier | Encoded zero selects value zero of the system-register identifier. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination: discard, R1..R23, push U, or push T |
| SSR_ID | system-register identifier |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/SSRGET.asl -->
```asl
readonly func InstructionContractOperation_SSRGET()
    => ScalarOperation
begin
    return ScalarOperation_SSRGET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
SSRGET executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/SSRGET.asl -->
```asl
readonly func InstructionContractHandler_SSRGET()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterGet;
end;

pure func InstructionContractRequiresSystemBlock_SSRGET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_SSRGET()
    => bits(2)
begin
    return '00';
end;

pure func InstructionContractSystemAddressWidth_SSRGET()
    => integer {5,12,24}
begin
    return 12;
end;

pure func InstructionContractPushesTemporaryT_SSRGET()
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

- ssrget SSR_ID, ->{t, u, Rd}
