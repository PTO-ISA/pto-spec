// PTO-TEST: {"id":"PTO-AVS-ARCH-CONCRETE-RESET-EXEC-007","source":"asl/arch/profile/reference-profile.asl","requirements":[],"kind":"execution","summary":"reference-profile reset clears every architectural state family","pass_condition":"reset state, memory, Tile, reservation, and context assertions hold","related_sources":[]}
func TestConcreteResetProfile()
begin
    WriteGPR(1, Zeros{PTO_XLEN} + 0x55);
    WriteGPR(23, Zeros{PTO_XLEN} + 0x66);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x11);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x22);
    WritePredicateRegister(0, Zeros{PTO_PREDICATE_WIDTH});
    WritePredicateRegister(7, Zeros{PTO_PREDICATE_WIDTH} + 0x77);
    Store(Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN} + 0xaa);
    - = AddInitialWriteEvent(Zeros{PTO_XLEN} + 2048, 8,
        Zeros{PTO_XLEN});
    _MemoryEventCaptureEnabled = TRUE;
    _CurrentMemoryAgent = 3;
    _ExtendedSystemRegisters[[0x0f00]] = Ones{PTO_XLEN};
    _ExtendedSystemRegisters[[0x1f01]] = Ones{PTO_XLEN};
    _ExtendedSystemRegisters[[0xffb7]] = Ones{PTO_XLEN};
    ConfigureTile(0, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(63, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(63, 0, 0, Zeros{PTO_XLEN} + 2);
    BeginBundle(BundleKind_Standard, BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x200, Zeros{PTO_XLEN} + 4,
        Zeros{PTO_XLEN} + 4, TRUE);
    EnterBundleBody();
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 3);
    SetBundleScalarBinding(31, 1, 2, 3, 4, 3);
    SetBundleTileBinding(15, TRUE, 3, 3, '1111', TRUE, TRUE, 0, 63,
        TRUE);
    SetBundleControlAttributeState(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE);
    SetBundleDataAttributeState(Zeros{5} + 1, Zeros{5} + 2,
        Zeros{2} + 3, Zeros{3} + 1, Zeros{3} + 2, TRUE, FALSE);
    _ReservationValid = TRUE;
    _ReservationAddress = Zeros{PTO_XLEN} + 0x80;
    _ReservationSize = 8;
    _ACRTrapNumber[[15]] = Zeros{6} + 52;
    _ACRTrapArgument0[[15]] = Ones{PTO_XLEN};
    _TrapContexts[[15]].valid = TRUE;
    _TrapContexts[[15]].predicates[[7]] = Ones{PTO_PREDICATE_WIDTH};
    _SystemRegisters.thread_ptr = Ones{PTO_XLEN};
    _SystemRegisters.global_ptr = Ones{PTO_XLEN};
    _SystemRegisters.core_feature_enable = Ones{PTO_XLEN};
    SetCurrentACR(2);
    ResetProfileState();
    assert CurrentACR() == 0;
    assert ReadGPR(1) == Zeros{PTO_XLEN};
    assert ReadGPR(23) == Zeros{PTO_XLEN};
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN};
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN};
    assert ReadPredicateRegister(0) == Ones{PTO_PREDICATE_WIDTH};
    assert ReadPredicateRegister(7) == Zeros{PTO_PREDICATE_WIDTH};
    assert _MemoryEventCount == 0;
    assert !_MemoryEventCaptureEnabled;
    assert _CurrentMemoryAgent == 0;
    let reset_memory = LoadUnsigned(Zeros{PTO_XLEN}, 8);
    assert reset_memory == Zeros{PTO_XLEN};
    let final_reset_time = ReadMonotonicTime();
    assert final_reset_time == Zeros{PTO_XLEN};
    assert _SystemRegisters.version == Zeros{PTO_XLEN} + 1;
    assert _SystemRegisters.tile_capacity ==
        Zeros{PTO_XLEN} + PTO_MODEL_MAX_TILE_CAPACITY_BYTES;
    assert _SystemRegisters.thread_id == Zeros{PTO_XLEN};
    assert _SystemRegisters.thread_ptr == Zeros{PTO_XLEN};
    assert _SystemRegisters.global_ptr == Zeros{PTO_XLEN};
    assert _SystemRegisters.core_feature_enable == Zeros{PTO_XLEN};
    assert !_BundleActive && !_BundleBodyActive;
    assert _BundleDimensions[[0]] == Zeros{PTO_XLEN};
    assert _BundleDimensions[[2]] == Zeros{PTO_XLEN};
    assert !_BundleScalarBindings[[31]].valid;
    assert !_BundleTileBindings[[15]].valid;
    assert !_BundleControlAttributes.trap_enabled;
    assert !_BundleDataAttributes.saturating;
    assert !_Tiles[[0]].allocated && !_Tiles[[63]].allocated;
    assert !_Tiles[[0]].contents_defined && !_Tiles[[63]].contents_defined;
    assert _Tiles[[0]].capacity_bytes == 0 &&
        _Tiles[[63]].capacity_bytes == 0;
    assert !_ReservationValid;
    assert _ReservationAddress == Zeros{PTO_XLEN};
    assert _ReservationSize == 1;
    for ring = 0 to PTO_ACR_COUNT - 1 do
        assert _ACRTrapNumber[[ring]] == Zeros{6};
        assert _ACRTrapArgument0[[ring]] == Zeros{PTO_XLEN};
        assert !_TrapContexts[[ring]].valid;
        assert _TrapContexts[[ring]].predicates[[0]] ==
            Zeros{PTO_PREDICATE_WIDTH};
        assert _TrapContexts[[ring]].predicates[[7]] ==
            Zeros{PTO_PREDICATE_WIDTH};
    end;
    assert _ExtendedSystemRegisters[[0x0f00]] == Zeros{PTO_XLEN};
    assert _ExtendedSystemRegisters[[0x1f01]] == Zeros{PTO_XLEN};
    assert _ExtendedSystemRegisters[[0xffb7]] == Zeros{PTO_XLEN};
end;
func main() => integer
begin
    ResetProfileState();
    TestConcreteResetProfile();
    return 0;
end;
