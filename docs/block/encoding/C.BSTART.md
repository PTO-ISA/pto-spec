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

`C.BSTART` is the 16-bit start command for a Standard block with a PC-relative target. It has two forms: `C.BSTART DIRECT, label` and `C.BSTART COND, label`. A block (also called a bundle) is a group of header commands and body instructions that commits as one unit at `BSTOP` or at the next block start.

The command does not jump. It records a candidate target in `BARG`, the bundle argument register, and the jump happens only when the new block commits. The model pages [Bundle start dispatch](../model/dispatch/start.md) and [Begin](../model/lifecycle/begin.md) define the shared start sequence.

<!-- PTO-READER-BLOCK: block-c-bstart-mechanism role=mechanism -->
## Encoding and start sequence

Both forms are one halfword. The low nibble selects the form: `0x2` is DIRECT and `0x4` is COND. Bits 15:4 hold `simm12`, a signed 12-bit displacement counted in halfwords.

The candidate target is `P + (SignExtend(simm12) << 1)`, where `P` is the address of the `C.BSTART` itself. The reachable range is therefore -4096 to +4094 bytes from `P`.

Execution follows the common start order. The target is computed and checked for alignment first. Then any active predecessor block commits. The new Standard block is opened only if that commit selected this `C.BSTART` address as the next PC. Header execution then continues at `P + 2`.

Design point: the displacement is added to `P`, not to the next instruction. Encoded zero is a real zero displacement, so `C.BSTART DIRECT` with `simm12 = 0` names its own address as the target and, at commit, execution returns to this `C.BSTART`.

<!-- PTO-READER-BLOCK: block-c-bstart-inputs role=inputs-outputs -->
## Fields and BARG values

- `simm12` is always encoded. It has no omitted form and no default.
- DIRECT installs `BARG.BPC = P`, `BlockType = STD`, `BPCN =` the computed target, `TYPE = DIRECT`, and `TAKEN = 1`.
- COND installs the same `BPC`, `BlockType`, and `BPCN`, with `TYPE = COND` and `TAKEN = 0`.

Design point: COND starts with `TAKEN = 0`, so a conditional block that executes no `SETC` condition falls through at commit. A `SETC` condition in the body may set `TAKEN`, and `SETC.TGT` may replace `BPCN`, before the block commits. See [BARG helpers](../model/state/barg.md).

<!-- PTO-READER-BLOCK: block-c-bstart-effects role=effects -->
## State effects and ordering

A successful start clears the previous header state, marks the new block active in its header phase, writes `BARG` and `BPC`, and takes a fresh execution-domain token. `C.BSTART` performs no memory access and writes no GPR.

The candidate target is selected only at `BSTOP` or at the next block start. `BARGSelectsBPCN` is true for DIRECT, and for COND only when `TAKEN` is set; otherwise commit continues at the sequential PC.

Design point: the predecessor commits before the new `BARG` is installed. If the predecessor commit fails, the predecessor stays authoritative and no Standard `BARG` is installed. If the predecessor transfers elsewhere, this `C.BSTART` was on an unselected path and opens nothing.

<!-- PTO-READER-BLOCK: block-c-bstart-constraints role=constraints -->
## Legality and fault boundary

Only the low-nibble values `0x2` and `0x4` belong to `C.BSTART`. Every `simm12` value is assigned.

An odd computed target raises `Fault_InstructionPC` before the predecessor commits and before any new `BARG` effect. Because the start checks run before predecessor retirement, a rejected `C.BSTART` leaves the active predecessor in place.

A final `BPCN` rewritten by `SETC.TGT` is checked again at commit, where an odd selected target raises `Fault_InstructionPC` before block effects become visible.

<!-- PTO-READER-BLOCK: block-c-bstart-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
C.BSTART COND, label
```

Suppose this `C.BSTART COND` sits at `0x1000` and `label` is `0x1040`. The encoded `simm12` is `0x20`, because `0x1000 + (0x20 << 1) = 0x1040`. After the start, `BARG.BPCN` is `0x1040`, `TAKEN` is 0, and header execution continues at `0x1002`. If a `SETC` condition in the body sets `TAKEN`, the commit continues at `0x1040`; otherwise it continues after the block.
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
