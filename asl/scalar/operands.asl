// PTO-REQ-SCALAR-OPERAND-001: one-level Reg5 source and destination behavior.

// Reg5 codes 0..23 select absolute GPRs. Codes 24..27 select T#1..T#4
// and codes 28..31 select U#1..U#4. Queue index zero is the newest value.
readonly func ScalarSourceSelectorLegal(selector: Reg5Selector) => boolean
begin
    return TRUE;
end;

readonly func ScalarDestinationSelectorLegal(selector: Reg5Selector) => boolean
begin
    return TRUE;
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
