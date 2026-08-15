<!-- GENERATED FROM: asl/scalar/sys/ASSERT.asl -->
# ASSERT

**Normative ASL source:** `asl/scalar/sys/ASSERT.asl`

ASSERT raises the architecture assertion trap exactly when its snapshotted scalar condition is zero.

## Normative identity {#PTO-INST-SCALAR-ASSERT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
assert SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| assert_32_f05d67874ae5 | L32 | 32 | 0x0000102b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| assert_32_f05d67874ae5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| assert_32_f05d67874ae5 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/ASSERT.asl -->
```asl
readonly func InstructionContractOperation_ASSERT()
    => ScalarOperation
begin
    return ScalarOperation_ASSERT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
ASSERT executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/ASSERT.asl -->
```asl
readonly func InstructionContractHandler_ASSERT()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureAssert;
end;

pure func InstructionContractRequiresSystemBlock_ASSERT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractFaultsWhenZero_ASSERT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractPreservesSource_ASSERT()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- Every available Reg5 source selector is assigned.

## State effects

- Snapshot SrcL; zero raises Fault_Assert at the faulting PC and nonzero performs no effect other than successful retirement.

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

- assert SrcL

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
