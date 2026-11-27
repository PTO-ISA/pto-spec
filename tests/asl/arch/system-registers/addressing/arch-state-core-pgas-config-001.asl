// PTO-TEST: {"id":"PTO-AVS-ARCH-CORE-PGAS-CONFIG-001","source":"asl/arch/system-registers/addressing.asl","requirements":["PTO-CORE-PGAS-RANGE-001"],"kind":"state-transition","summary":"Production platform admission validates Core PGAS endpoints and overlap before publishing","pass_condition":"admission accepts valid ranges, rejects bad or overlapping endpoints in both zero-based orders, and preserves both Core pairs on rejection","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    let first = ConfigureCorePGAS(0, 0, 1);
    assert first;
    let absent = ConfigureCorePGAS(1, 0, 0);
    assert absent;
    let gapped = ConfigureCorePGAS(1, 7, 10);
    assert gapped;
    let maximum = ConfigureCorePGAS(1, 0xfffffffffffffffe, 0xffffffffffffffff);
    assert maximum;
    let adjacent = ConfigureCorePGAS(1, 1, 3);
    assert adjacent;

    let overlap = ConfigureCorePGAS(1, 0, 2);
    assert !overlap;
    let equal_ranges = ConfigureCorePGAS(1, 0, 1);
    assert !equal_ranges;
    let reversed = ConfigureCorePGAS(1, 2, 1);
    assert !reversed;
    let equal_nonzero = ConfigureCorePGAS(1, 1, 1);
    assert !equal_nonzero;
    let negative_base = ConfigureCorePGAS(1, -1, 1);
    assert !negative_base;
    let negative_limit = ConfigureCorePGAS(1, 0, -1);
    assert !negative_limit;
    let overflow_limit = ConfigureCorePGAS(1, 0, 0x10000000000000000);
    assert !overflow_limit;
    let both_overflow = ConfigureCorePGAS(1, 0x10000000000000000, 0x10000000000000001);
    assert !both_overflow;
    let reverse_overlap = ConfigureCorePGAS(0, 0, 2);
    assert !reverse_overlap;
    let interior_overlap = ConfigureCorePGAS(0, 2, 4);
    assert !interior_overlap;

    SelectExecutionContext(0, 0);
    let lower = UInt(ReadSystemRegister(SystemRegister_CORE_PGAS_BASE));
    let upper = UInt(ReadSystemRegister(SystemRegister_CORE_PGAS_LIMIT));
    assert upper - lower == 1;
    assert lower <= 0 && 0 < upper;
    assert !(lower <= 1 && 1 < upper);
    SelectExecutionContext(1, 0);
    let other_lower = UInt(ReadSystemRegister(SystemRegister_CORE_PGAS_BASE));
    let other_upper = UInt(ReadSystemRegister(SystemRegister_CORE_PGAS_LIMIT));
    assert other_lower == 1 && other_upper == 3;
    assert _LastFault == Fault_None;
    return 0;
end;
