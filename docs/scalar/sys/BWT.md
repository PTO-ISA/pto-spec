<!-- GENERATED FROM: asl/scalar/sys/BWT.asl -->
# BWT

**Normative ASL source:** `asl/scalar/sys/BWT.asl`

BWT publishes the WaitTimeout nonblocking execution-control request.

## Normative identity {#PTO-INST-SCALAR-BWT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
bwt SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bwt_32_5a0fe4a8e61f | L32 | 32 | 0x0030002b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bwt_32_5a0fe4a8e61f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bwt_32_5a0fe4a8e61f | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/BWT.asl -->
```asl
readonly func InstructionContractOperation_BWT()
    => ScalarOperation
begin
    return ScalarOperation_BWT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BWT executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/BWT.asl -->
```asl
readonly func InstructionContractHandler_BWT()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteControlRequest;
end;

pure func InstructionContractRequiresSystemBlock_BWT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractControlRequest_BWT()
    => ExecutionControlRequest
begin
    return ExecutionControl_WaitTimeout;
end;

pure func InstructionContractControlRequestIsNonblocking_BWT()
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
- Every assigned Reg5 source selector follows the common scalar-source availability rule.

## State effects

- Snapshot SrcL, publish ExecutionControl_WaitTimeout and the exact XLEN operand, increment the architecture-request epoch, then advance TPC.
- PTO defines no additional asleep, mailbox, timeout-counter, or pending-wake state for this nonblocking request.

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

- bwt SrcL

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
