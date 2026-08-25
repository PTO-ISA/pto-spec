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

`SSRSWAP` atomically exchanges an assigned RW system register and publishes its old XLEN value.

<!-- PTO-READER-BLOCK: scalar-ssrswap-mechanism role=mechanism -->
## System mechanism

The ASL DOC region selects `ScalarHandler_ExecuteSystemRegisterSwap`. Placement and encoded legality are checked before sources or system state can change.

The instruction occupies one scalar operation position in the body of an active SYS block.

<!-- PTO-READER-BLOCK: scalar-ssrswap-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`RegDst` carries the Reg5 destination: discard, R1..R23, push U, or push T; `SSR_ID` carries the system-register identifier; `SrcL` carries the Reg5 source: R0..R23, T#1..T#4, or U#1..U#4.

Encoded zero is an assigned field value, never an omitted operand.

<!-- PTO-READER-BLOCK: scalar-ssrswap-effects role=effects -->
## Architectural effects

After read/write preflight, the selected RW system register is atomically exchanged with snapshotted `SrcL`, and its old XLEN value is published through `RegDst`.

A rejected swap performs no register, destination, queue, read-side-effect, or `TPC` update beyond ordinary trap entry.

<!-- PTO-READER-BLOCK: scalar-ssrswap-constraints role=constraints -->
## Placement and rejection

Both permissions and the RW access class are established before either source or old-register value is consumed.

Invalid SYS-block placement is rejected before field checks. Reserved encodings or denied access produce no destination, queue, system-state, or `TPC` effect beyond the ordinary trap envelope.

<!-- PTO-READER-BLOCK: scalar-ssrswap-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Start with `ssrswap SrcL, SSR_ID, ->{t, u, Rd}` and trace its encoded fields through preflight before following the selected system effect.
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
