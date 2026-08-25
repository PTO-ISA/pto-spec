<!-- GENERATED FROM: asl/block/encoding/C.BSTART.asl -->
# C.BSTART

**Normative ASL source:** `asl/block/encoding/C.BSTART.asl`

Starts a compressed standard block with a PC-relative direct or conditional candidate target.

## Normative identity {#PTO-INST-BLOCK-C-BSTART}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-c-bstart-purpose role=purpose -->
## What C.BSTART does

`C.BSTART` opens an active Block descriptor; the body supplies the attributes and bindings required before completion.

<!-- PTO-READER-BLOCK: block-c-bstart-mechanism role=mechanism -->
## Placement and execution mechanism

`C.BSTART` must appear as the starter of its Block. Later attributes, dimensions, and bindings accumulate in the active descriptor until `BSTOP` or the next accepted `BSTART` completion boundary.

The accepted carrier uses the `C16` encoding class and resolves every displayed field before the command reads bindings or changes state.

At completion, the descriptor runs its selected Block operation only after all schema and state preflight succeeds.

<!-- PTO-READER-BLOCK: block-c-bstart-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- Encoded operands: `simm12` — 12-bit signed bundle target displacement.
- After an active predecessor commits successfully, this carrier opens one Standard Block whose header runs until `BSTOP` or the next `BSTART` completion boundary.
- Encoded zero remains an assigned value or a specifically documented rejection; it never silently means an omitted operand.

<!-- PTO-READER-BLOCK: block-c-bstart-effects role=effects -->
## State effects and ordering

Starting the Block records the selected carrier and leaves operation execution deferred until the completion boundary.

After complete preflight and computation, every enabled output publishes as the owner-defined atomic group; successful mathematical sources remain available unless the contract explicitly consumes them.

<!-- PTO-READER-BLOCK: block-c-bstart-constraints role=constraints -->
## Legality, faults, and atomicity

Fixed bits, reserved values, selector domains, and required Block placement are checked before architectural effects.

The current owner reports invalid schema, state, address, or continuation conditions through `Fault_InstructionPC`; no prose on this page creates an additional fault rule.

Complete schema, binding, readiness, alias, capacity, and allocation preflight precedes source snapshots and every destination publication.

<!-- PTO-READER-BLOCK: block-c-bstart-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
C.BSTART DIRECT, label
```

The starter establishes the descriptor first; the following carriers fill its declared schema, and the final completion boundary triggers validation and operation execution.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
C.BSTART COND,  label
C.BSTART DIRECT, label
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_bstart_16_c4e238a9227a | C16 | 16 | 0x0004 / 0x000f | [] |
| c_bstart_16_f833d2a4753c | C16 | 16 | 0x0002 / 0x000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_bstart_16_c4e238a9227a | simm12 | 12 | signed | [{"instruction_lsb":4,"value_lsb":0,"width":12}] |
| c_bstart_16_f833d2a4753c | simm12 | 12 | signed | [{"instruction_lsb":4,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_bstart_16_c4e238a9227a | simm12 | 12 | 0–4095 | none | none | 12-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| c_bstart_16_f833d2a4753c | simm12 | 12 | 0–4095 | none | none | 12-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm12 | 12-bit signed bundle target displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/C.BSTART.asl -->
```asl
readonly func InstructionContractMatches_C_BSTART(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_16_c4e238a9227a) ||
           (operation == CommandOperation_c_bstart_16_f833d2a4753c);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
After any active predecessor block commits successfully, C.BSTART opens one Standard block. Header commands execute sequentially until BSTOP or the next BSTART commits the new BARG continuation.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/C.BSTART.asl -->
```asl
pure func InstructionContractTarget_C_BSTART(
    instruction_pc: Word,
    displacement: bits(12))
    => Word
begin
    return instruction_pc +
        LSL(SignExtend{PTO_XLEN}(displacement), 1);
end;

readonly func InstructionContractHandler_C_BSTART() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- simm12 is always encoded. Encoded zero computes the candidate target P and is not omission.
- The conditional form initializes BARG.TAKEN to false; the direct form initializes it to true.

## Legality

- Exactly the low-nibble forms 0x2 (DIRECT) and 0x4 (COND) are assigned to C.BSTART.
- simm12 accepts every signed 12-bit value and computes P + (SignExtend(simm12) << 1).

## State effects

- Installs BARG.BPC=P, BlockType=STD, BPCN=the computed candidate target, and TYPE=DIRECT or COND.
- DIRECT installs TAKEN=1; COND installs TAKEN=0 until an applicable SETC operation resolves it. The candidate continuation is selected only at BSTOP or the next BSTART.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Decode, target calculation, and target alignment checks precede predecessor retirement. New BARG state is installed only after successful retirement.

## Exceptions

- An odd computed candidate target raises Fault_InstructionPC before predecessor retirement or new BARG effects.
- If predecessor commit fails, the retiring block remains authoritative and no Standard BARG is installed.

## Examples

- C.BSTART DIRECT, label
- C.BSTART COND, label
