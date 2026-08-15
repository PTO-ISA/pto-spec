<!-- GENERATED FROM: asl/block/encoding/C.BSTART.asl -->
# C.BSTART

**Normative ASL source:** `asl/block/encoding/C.BSTART.asl`

Starts a compressed standard block with a PC-relative direct or conditional candidate target.

## Normative identity {#PTO-INST-BLOCK-C-BSTART}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
