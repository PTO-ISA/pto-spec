<!-- GENERATED FROM: asl/scalar/sys/SSRSWAP.asl -->
# SSRSWAP

**Normative ASL source:** `asl/scalar/sys/SSRSWAP.asl`

SSRSWAP atomically swaps the complete encoded system-register address.

## Normative identity {#PTO-INST-SCALAR-SSRSWAP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ssrswap-purpose role=purpose -->
## What SSRSWAP does

`SSRSWAP` exchanges one system register with a scalar value in a single atomic step. It reads the addressed register, stores the value from `SrcL` in its place, and publishes the value it read to the Reg5 destination.

<!-- PTO-READER-BLOCK: scalar-ssrswap-mechanism role=mechanism -->
## System mechanism

`InstructionContractHandler_SSRSWAP` selects `ScalarHandler_ExecuteSystemRegisterSwap` (`asl/scalar/sys/SSRSWAP.asl:18`), and the dispatcher decodes all three operands: `RegDst`, `SrcL`, and the 12-bit `SSR_ID` address (`asl/scalar/model/dispatch/sys.asl:116`). `InstructionContractSystemTransferKind_SSRSWAP` returns `'10'`, the transfer kind that distinguishes a swap from a get or a set (`asl/scalar/sys/SSRSWAP.asl:30`).

The helper preflights both directions before it reads anything: `ExecuteSystemRegisterSwap` requires `SystemRegisterSwapPermitted`, which demands read permission, write permission, and the read-write access class (`asl/scalar/model/sys/registers.asl:168`).

<!-- PTO-READER-BLOCK: scalar-ssrswap-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SSR_ID` is the 12-bit address, `SrcL` is the Reg5 source of the new value, and `RegDst` is the Reg5 destination selector `discard, R1..R23, push U, or push T` (`asl/scalar/sys/SSRSWAP.asl:1`). The destination receives the old register value, not the written one.

Encoded zero in `SrcL` names the architectural zero GPR, which makes the swap a way to read and clear a register in one instruction.

<!-- PTO-READER-BLOCK: scalar-ssrswap-effects role=effects -->
## Architectural effects

A successful attempt snapshots the source, reads the old register value, writes the new value, publishes the old value to the destination, and advances `TPC` by 4 bytes. The register write is skipped if the read raised a fault, and the destination write is skipped as well (`asl/scalar/model/sys/registers.asl:140`).

Design point: the swap is a read/write transaction, so both permissions are checked before the read. The ASL comment gives the reason: a read can have effects, and the recorded example is timer-pending refresh on a register that cannot be written. Checking only the read direction first would let a swap that must fail still perform that read-side effect.

No ordinary scalar memory access is performed.

<!-- PTO-READER-BLOCK: scalar-ssrswap-constraints role=constraints -->
## Placement and rejection

Outside an active SYS block body the attempt raises `Fault_BundleControl` before operand work begins. The swap preflight then rejects with `Fault_IllegalInstruction` when either direction lacks ring permission, or when the access class is unknown, read-only, or write-only. No access class other than read-write can be swapped.

Design point: address 0x1F02 is a read-write context register, but its low index is at or above 0x0F00, so it needs ACR0 even though the same address pattern in another bank would be open. A swap of that address at ACR1 therefore faults instead of returning the ring-1 value.

<!-- PTO-READER-BLOCK: scalar-ssrswap-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

At ACR0, `ssrswap SrcL, SSR_ID, ->{t, u, Rd}` with `SSR_ID` 0x1F02 and a source holding 8 writes the packed ring-1 trap-status register and returns its previous value to the destination; the written value leaves trap number 8, a zero cause, and cleared status flags in that register. Repeating it with `SSR_ID` 0x0010 instead is rejected, because `TIME` is read-only and a swap requires the read-write class.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ssrswap SrcL, SSR_ID, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ssrswap_32_a01c7e2c7c29 | L32 | 32 | 0x0000203b / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ssrswap_32_a01c7e2c7c29 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ssrswap_32_a01c7e2c7c29 | SSR_ID | 12 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |
| ssrswap_32_a01c7e2c7c29 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ssrswap_32_a01c7e2c7c29 | RegDst | 5 | 0–31 | none | none | Reg5 destination: discard, R1..R23, push U, or push T | Encoded zero names the architectural zero GPR. |
| ssrswap_32_a01c7e2c7c29 | SSR_ID | 12 | 0–4095 | none | none | system-register identifier | Encoded zero selects value zero of the system-register identifier. |
| ssrswap_32_a01c7e2c7c29 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination: discard, R1..R23, push U, or push T |
| SSR_ID | system-register identifier |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/SSRSWAP.asl -->
```asl
readonly func InstructionContractOperation_SSRSWAP()
    => ScalarOperation
begin
    return ScalarOperation_SSRSWAP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
SSRSWAP executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/SSRSWAP.asl -->
```asl
readonly func InstructionContractHandler_SSRSWAP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterSwap;
end;

pure func InstructionContractRequiresSystemBlock_SSRSWAP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_SSRSWAP()
    => bits(2)
begin
    return '10';
end;

pure func InstructionContractSystemAddressWidth_SSRSWAP()
    => integer {5,12,24}
begin
    return 12;
end;

pure func InstructionContractPushesTemporaryT_SSRSWAP()
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

- Atomically exchange the selected RW system register with the snapshotted source and publish the old value through RegDst.
- A rejected swap performs neither read-side effects nor register, destination, queue, or TPC effects.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Preflight read permission, write permission, and RW access class before reading SrcL or the old register value.
- Snapshot SrcL, read the old value, write the new value, publish the old value, and then advance TPC.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- ssrswap SrcL, SSR_ID, ->{t, u, Rd}
