<!-- GENERATED FROM: asl/scalar/model/types/operands.asl -->
# Operands

**Normative ASL source:** `asl/scalar/model/types/operands.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-TYPES-OPERANDS}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/types/operands.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-TYPES-OPERANDS","surface":"scalar","classification":["model","types","operands"],"depends_on":["PTO-SCALAR-MODEL-TYPES-OPERATIONS","PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS"]}
// PTO-REQ-SCALAR-OPERAND-001: one-level Reg5 source and destination behavior.

// Reg5 codes 0..23 select absolute GPRs. Codes 24..27 select T#1..T#4
// and codes 28..31 select U#1..U#4. Queue index zero is the newest value.
readonly func ScalarSourceSelectorLegal(selector: Reg5Selector) => boolean
begin
    if selector < PTO_ABSOLUTE_GPR_COUNT then
        return TRUE;
    elsif selector < 28 then
        return TemporaryQueueSourceAvailable(
            TRUE,
            (selector - 24) as TemporaryQueueIndex);
    else
        return TemporaryQueueSourceAvailable(
            FALSE,
            (selector - 28) as TemporaryQueueIndex);
    end;
end;

readonly func ScalarDestinationSelectorLegal(selector: Reg5Selector) => boolean
begin
    return TRUE;
end;

readonly func ScalarImplicitSourceOperandsLegal(
    operation: ScalarOperation)
    => boolean
begin
    case operation of
        when ScalarOperation_C_SDI,
             ScalarOperation_C_SLLI,
             ScalarOperation_C_SRLI =>
            return TemporaryQueueSourceAvailable(TRUE, 0);
        when ScalarOperation_C_SWI =>
            return TemporaryQueueSourceAvailable(TRUE, 0);
        otherwise =>
            return TRUE;
    end;
end;

readonly func ReadScalarRegisterOperand(selector: Reg5Selector) => Word
begin
    if selector < PTO_ABSOLUTE_GPR_COUNT then
        return ReadGPR(selector as GPRIndex);
    elsif selector < 28 then
        return ReadTemporaryQueue(TRUE,
            (selector - 24) as TemporaryQueueIndex);
    else
        return ReadTemporaryQueue(FALSE,
            (selector - 28) as TemporaryQueueIndex);
    end;
end;

// B.IOR uses only absolute GPR selectors.  Shared operations apply one encoded
// selector to each PE's private register file rather than sharing a value
// resolved by the PE that happened to dispatch the block.
readonly func ReadPEAbsoluteGPROperand(pe: MemoryAgentId,
                                      selector: Reg5Selector) => Word
begin
    assert selector < PTO_ABSOLUTE_GPR_COUNT;
    return ReadPEGPR(pe, selector as GPRIndex);
end;

func WriteScalarDestination(selector: Reg5Selector, value: Word)
begin
    if selector < PTO_ABSOLUTE_GPR_COUNT then
        WriteGPR(selector as GPRIndex, value);
    elsif selector == 30 then
        PushTemporaryQueue(FALSE, value);
    elsif selector == 31 then
        PushTemporaryQueue(TRUE, value);
    end;
    // Destination selectors 24..29 are non-writing encodings. Codes 30 and 31
    // are the encoded ->u and ->t queue-push destinations respectively.
end;

func WriteCompressedTResult(value: Word)
begin
    PushTemporaryQueue(TRUE, value);
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
