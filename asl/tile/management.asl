// PTO-REQ-TILE-MANAGEMENT-001: direct FIFO tile and global-slot transfer.

func ConfigurePipe(pipe: PipeIndex, base_address: Word,
                   slot_size_bytes: integer {1..262144},
                   slot_count: integer {1..PTO_MODEL_PIPE_DEPTH})
begin
    assert UInt(base_address) + slot_size_bytes * slot_count <= PTO_MODEL_MEMORY_BYTES;
    _Pipes[[pipe]].configured = TRUE;
    _Pipes[[pipe]].base_address = base_address;
    _Pipes[[pipe]].slot_size_bytes = slot_size_bytes;
    _Pipes[[pipe]].slot_count = slot_count;
    _Pipes[[pipe]].head = 0;
    _Pipes[[pipe]].tail = 0;
    _Pipes[[pipe]].count = 0;
    _Pipes[[pipe]].producer_claimed = FALSE;
    _Pipes[[pipe]].consumer_claimed = FALSE;
    _Pipes[[pipe]].producer_slot = 0;
    _Pipes[[pipe]].consumer_slot = 0;
end;

readonly func PipeSlotAddress(pipe: PipeIndex,
                              slot: integer {0..PTO_MODEL_PIPE_DEPTH-1}) => Word
begin
    let byte_offset: integer = slot * _Pipes[[pipe]].slot_size_bytes;
    assert byte_offset <= 262144;
    return _Pipes[[pipe]].base_address +
        NaturalToWord(byte_offset as integer {0..262144});
end;

func TPUSH(pipe: PipeIndex, source: TileIndex)
begin
    assert _Pipes[[pipe]].configured;
    assert _Tiles[[source]].allocated;
    assert !_Pipes[[pipe]].producer_claimed;
    assert _Pipes[[pipe]].count < _Pipes[[pipe]].slot_count;
    let slot = _Pipes[[pipe]].tail;
    _Pipes[[pipe]].slots[[slot]] = _Tiles[[source]];
    _Pipes[[pipe]].tail = ((slot + 1) MOD _Pipes[[pipe]].slot_count)
        as integer {0..PTO_MODEL_PIPE_DEPTH-1};
    _Pipes[[pipe]].count = (_Pipes[[pipe]].count + 1)
        as integer {0..PTO_MODEL_PIPE_DEPTH};
end;

func TPOP(destination: TileIndex, pipe: PipeIndex)
begin
    assert _Pipes[[pipe]].configured;
    assert !_Pipes[[pipe]].consumer_claimed;
    assert _Pipes[[pipe]].count > 0;
    let slot = _Pipes[[pipe]].head;
    let popped = _Pipes[[pipe]].slots[[slot]];
    assert TileCapacityInUseExcept(destination) + popped.capacity_bytes <= 524288;
    _Tiles[[destination]] = popped;
    _Pipes[[pipe]].head = ((slot + 1) MOD _Pipes[[pipe]].slot_count)
        as integer {0..PTO_MODEL_PIPE_DEPTH-1};
    _Pipes[[pipe]].count = (_Pipes[[pipe]].count - 1)
        as integer {0..PTO_MODEL_PIPE_DEPTH};
end;

func TALLOC(pipe: PipeIndex) => Word
begin
    assert _Pipes[[pipe]].configured;
    assert !_Pipes[[pipe]].producer_claimed;
    assert _Pipes[[pipe]].count < _Pipes[[pipe]].slot_count;
    let slot = _Pipes[[pipe]].tail;
    _Pipes[[pipe]].producer_claimed = TRUE;
    _Pipes[[pipe]].producer_slot = slot;
    return PipeSlotAddress(pipe, slot);
end;

func TPUSHGlobal(pipe: PipeIndex, slot_address: Word)
begin
    assert _Pipes[[pipe]].producer_claimed;
    let slot = _Pipes[[pipe]].producer_slot;
    assert slot_address == PipeSlotAddress(pipe, slot);
    _Pipes[[pipe]].tail = ((slot + 1) MOD _Pipes[[pipe]].slot_count)
        as integer {0..PTO_MODEL_PIPE_DEPTH-1};
    _Pipes[[pipe]].count = (_Pipes[[pipe]].count + 1)
        as integer {0..PTO_MODEL_PIPE_DEPTH};
    _Pipes[[pipe]].producer_claimed = FALSE;
end;

func TPOPGlobal(pipe: PipeIndex) => Word
begin
    assert _Pipes[[pipe]].configured;
    assert !_Pipes[[pipe]].consumer_claimed;
    assert _Pipes[[pipe]].count > 0;
    let slot = _Pipes[[pipe]].head;
    _Pipes[[pipe]].consumer_claimed = TRUE;
    _Pipes[[pipe]].consumer_slot = slot;
    return PipeSlotAddress(pipe, slot);
end;

func TFREE(pipe: PipeIndex)
begin
    // Tile-data pop releases immediately. With no outstanding global slot,
    // the symmetry form has no state effect.
    if _Pipes[[pipe]].consumer_claimed then
        let slot = _Pipes[[pipe]].consumer_slot;
        _Pipes[[pipe]].head = ((slot + 1) MOD _Pipes[[pipe]].slot_count)
            as integer {0..PTO_MODEL_PIPE_DEPTH-1};
        _Pipes[[pipe]].count = (_Pipes[[pipe]].count - 1)
            as integer {0..PTO_MODEL_PIPE_DEPTH};
        _Pipes[[pipe]].consumer_claimed = FALSE;
    end;
end;
