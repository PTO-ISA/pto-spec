// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-STEP-PE0-RESET-001","source":"asl/arch/dispatch/functional-step.asl","requirements":["PTO-REQ-FUNCTIONAL-RESET-001"],"kind":"state-transition","summary":"Functional initialization selects PE0 and initializes only its private GPR file.","pass_condition":"InitializeFunctionalModel resets all PEs, selects PE0, installs entry TPC, and InitializeFunctionalModelGPR changes only PE0.","related_sources":["asl/arch/profile/reset.asl","asl/arch/programming-model/scalar-registers.asl"]}
func main() => integer
begin
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0xa0);
    WritePEGPR(1, 2, Zeros{PTO_XLEN} + 0xa1);
    WritePEGPR(2, 2, Zeros{PTO_XLEN} + 0xa2);
    WritePEGPR(3, 2, Zeros{PTO_XLEN} + 0xa3);

    InitializeFunctionalModel(Zeros{PTO_XLEN} + 0x100);
    assert _CurrentMemoryAgent == 0;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x100;
    assert ReadPEGPR(0, 2) == Zeros{PTO_XLEN};
    assert ReadPEGPR(1, 2) == Zeros{PTO_XLEN};
    assert ReadPEGPR(2, 2) == Zeros{PTO_XLEN};
    assert ReadPEGPR(3, 2) == Zeros{PTO_XLEN};

    let gpr_initialized = InitializeFunctionalModelGPR(
        2,
        Zeros{PTO_XLEN} + 0x55);
    assert gpr_initialized;

    assert ReadPEGPR(0, 2) == Zeros{PTO_XLEN} + 0x55;
    assert ReadPEGPR(1, 2) == Zeros{PTO_XLEN};
    assert ReadPEGPR(2, 2) == Zeros{PTO_XLEN};
    assert ReadPEGPR(3, 2) == Zeros{PTO_XLEN};
    return 0;
end;
