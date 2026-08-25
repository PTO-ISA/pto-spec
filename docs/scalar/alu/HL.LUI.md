<!-- GENERATED FROM: asl/scalar/alu/HL.LUI.asl -->
# HL.LUI

**Normative ASL source:** `asl/scalar/alu/HL.LUI.asl`

HL.LUI places its split 32-bit immediate in result bits 63:32 and clears result bits 31:0.

## Normative identity {#PTO-INST-SCALAR-HL-LUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lui-purpose role=purpose -->
## What HL.LUI does

`HL.LUI` is a 48-bit scalar ALU instruction. It places the split 32-bit immediate in result bits 63:32 and clears bits 31:0; its current instruction contract defines the result publication path and any additional state effect.

<!-- PTO-READER-BLOCK: scalar-hl-lui-mechanism role=mechanism -->
## How the result is formed

Execution snapshots the encoded inputs, then places the split 32-bit immediate in result bits 63:32 and clears bits 31:0, and only afterward performs the destination effects.

- The operation-specific width, signedness, and immediate rules are fixed by the mnemonic and the encoded fields shown below.
- Result publication uses the width and extension rule fixed by this mnemonic's current contract.

<!-- PTO-READER-BLOCK: scalar-hl-lui-inputs role=inputs-outputs -->
## Inputs and destinations

- The 5-bit `RegDst` field selects the Reg5 result target or discards the result.
- The 32-bit `imm` field carries the split 32-bit value placed in result bits `63:32`.

These roles come from the current instruction contract. T/U sources are read and snapshotted without being removed from their queues; exact encoded-zero meanings appear in the generated defaults below.

<!-- PTO-READER-BLOCK: scalar-hl-lui-effects role=effects -->
## Effects and ordering

Every scalar source is snapshotted before the destination effect. The completed value is then routed through `RegDst` using the current scalar destination map.

This ALU operation has no memory effect. After its successful architectural effects, `TPC` advances by 6 bytes.

The operation does not introduce a hidden scalar publication target or an implicit memory access. Architectural changes remain limited to the state effects enumerated by the current contract.

<!-- PTO-READER-BLOCK: scalar-hl-lui-constraints role=constraints -->
## Legality and fault boundary

Materialization, movement, and extension are total at their fixed widths and do not raise arithmetic exceptions. A fixed-bit mismatch or unavailable selected T/U source faults before state effects.

The generated legality table is authoritative for assigned field values, reserved encodings, and destination discard codes. Decode and source availability are checked before architectural effects.

<!-- PTO-READER-BLOCK: scalar-hl-lui-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `HL.LUI` example, immediate `1` places a one at result bit `32` and clears the low word.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lui imm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lui_48_255991889818 | HL48 | 48 | 0x00000017000e / 0x0000007f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lui_48_255991889818 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lui_48_255991889818 | imm | 32 | encoding-defined | [{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lui_48_255991889818 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| hl_lui_48_255991889818 | imm | 32 | 0–4294967295 | none | none | split 32-bit immediate placed in result bits 63:32 | Encoded zero materializes numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| imm | split 32-bit immediate placed in result bits 63:32 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.LUI.asl -->
```asl
readonly func InstructionContractOperation_HL_LUI() => ScalarOperation
begin
    return ScalarOperation_HL_LUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.LUI.asl -->
```asl
readonly func InstructionContractHandler_HL_LUI() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLongUpper;
end;

pure func InstructionContractResult_HL_LUI(
    encoded_immediate: bits(32))
    => Word
begin
    return MaterializeLongUpper(encoded_immediate);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded source, immediate, and explicit destination field is required; no field can be omitted.
- The mnemonic fixes unsigned immediate placement in result bits 63:32 and the common explicit destination behavior.

## Legality

- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every encoded operand value is assigned; fixed encoding bits must match the canonical form.

## State effects

- Reassemble imm from its two encoded pieces, zero-extend it to XLEN, shift it left by 32, and clear result bits 31:0.
- Publish the complete XLEN result through the common Reg5 destination map. Only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Reassemble the complete encoded immediate before the destination effect.
- Publish the upper-half result, then advance TPC by six bytes.

## Exceptions

- Materialization is a total fixed-width operation and raises no arithmetic exception.
- A fixed-bit mismatch raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- hl.lui imm, ->{t, u, rd}
