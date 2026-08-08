// PTO-UNIT: {"id":"PTO-ARCH-STATE-EXECUTION-MASK","surface":"arch","classification":["state","execution-mask"],"depends_on":["PTO-ARCH-STATE-PROGRAM-COUNTER"]}
readonly func ReadExecutionMask() => Word
begin
    return _ExecutionMask;
end;

func WriteExecutionMask(value: Word)
begin
    _ExecutionMask = value;
end;
