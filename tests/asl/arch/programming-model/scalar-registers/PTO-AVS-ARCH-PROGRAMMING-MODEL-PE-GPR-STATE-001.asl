// PTO-TEST: {"id":"PTO-AVS-ARCH-PROGRAMMING-MODEL-PE-GPR-STATE-001","source":"asl/arch/programming-model/scalar-registers.asl","requirements":["PTO-ARCH-GM-ACCESS-001"],"kind":"state-transition","summary":"Each PE resolves one absolute GPR selector against its private register file.","pass_condition":"The same selector can hold four distinct PE values while ReadGPR follows the selected current PE.","related_sources":["asl/arch/programming-model/execution-context.asl"]}
func main() => integer
begin
    ResetProfileState();
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x100);
    WritePEGPR(1, 2, Zeros{PTO_XLEN} + 0x200);
    WritePEGPR(2, 2, Zeros{PTO_XLEN} + 0x300);
    WritePEGPR(3, 2, Zeros{PTO_XLEN} + 0x400);

    assert ReadPEGPR(0, 2) == Zeros{PTO_XLEN} + 0x100;
    assert ReadPEGPR(1, 2) == Zeros{PTO_XLEN} + 0x200;
    assert ReadPEGPR(2, 2) == Zeros{PTO_XLEN} + 0x300;
    assert ReadPEGPR(3, 2) == Zeros{PTO_XLEN} + 0x400;

    SelectMemoryEventAgent(2);
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0x300;
    WriteGPR(2, Zeros{PTO_XLEN} + 0x355);
    assert ReadPEGPR(2, 2) == Zeros{PTO_XLEN} + 0x355;
    assert ReadPEGPR(0, 2) == Zeros{PTO_XLEN} + 0x100;
    return 0;
end;
