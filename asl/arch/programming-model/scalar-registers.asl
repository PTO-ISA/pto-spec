// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS","surface":"arch","classification":["programming-model","scalar-registers"],"depends_on":["PTO-ARCH-SYSTEM-REGISTERS-INTERRUPT"]}
readonly func ReadGPR(index: GPRIndex) => Word
begin
    if index == 0 then
        return Zeros{PTO_XLEN};
    else
        return _GPR[[index]];
    end;
end;

func WriteGPR(index: GPRIndex, value: Word)
begin
    if index != 0 then
        _GPR[[index]] = value;
    end;
end;

