// PTO-TEST: {"id":"PTO-AVS-TILE-TLOAD-SHARED-PARENT-002","source":"asl/tile/memory-and-data-movement/regular/TLOAD.asl","requirements":["PTO-B-SHARED-WHOLE-PARENT-READY-001","PTO-INST-TILE-TLOAD"],"kind":"execution","summary":"A single Shared TLOAD issuer loads and publishes the complete logical parent.","pass_condition":"One selected PE supplies every valid parent element from its private base and stride; producer metadata does not partition the payload.","related_sources":["asl/tile/model/memory/shared-movement.asl","asl/tile/model/state/shared-registers.asl"]}
func main() => integer
begin
    ResetProfileState();
    let shared_tile_id = (Zeros{6} + 12) as SharedTileID;
    var base_addresses: CorePEWords;
    var row_strides: CorePEWords;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        base_addresses[[agent]] = Zeros{PTO_XLEN} + pe * 0x200;
        row_strides[[agent]] = Zeros{PTO_XLEN} + 32;
    end;
    for row = 0 to 1 do
        for column = 0 to 3 do
            let address = Zeros{PTO_XLEN} + 0x400 + row * 32 + column * 8;
            Store(address, 8, Zeros{PTO_XLEN} + row * 4 + column + 1);
        end;
    end;

    TLOADShared(shared_tile_id, base_addresses, row_strides, 1,
        2, 4, 2, 4, TileDataType_U64, TileLayout_RowMajor, '0010');

    assert _LastFault == Fault_None;
    assert SharedTilePublished(shared_tile_id);
    assert SharedTileRecord(shared_tile_id).whole_parent_ready;
    assert SharedTileRecord(shared_tile_id).allocation_mask == '0010';
    assert SharedTileRecord(shared_tile_id).initialized_mask == '0010';
    assert SharedTileRecord(shared_tile_id).tile.contents_defined;
    for row = 0 to 1 do
        for column = 0 to 3 do
            let element = TileLogicalLinearIndex(
                SharedTileRecord(shared_tile_id).tile,
                row as integer {0..65535}, column as integer {0..65535});
            assert ReadSharedTileWord(shared_tile_id, element) ==
                Zeros{PTO_XLEN} + row * 4 + column + 1;
        end;
    end;
    return 0;
end;
