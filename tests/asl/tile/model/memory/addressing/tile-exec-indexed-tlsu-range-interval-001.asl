// PTO-TEST: {"id":"PTO-AVS-TILE-I414-RANGE-INTERVAL-001","source":"asl/tile/model/memory/addressing.asl","requirements":["PTO-ARCH-MEMORY-MODEL-RANGE-001","PTO-INDEXED-TLSU-STRIDE-001","PTO-INDEXED-TLSU-RANGE-BINDING-001"],"kind":"execution","summary":"Mathematical indexed TLSU intervals preserve signed bounds, half-open overlap, and fail-closed alias comparison.","pass_condition":"The canonical negative/positive example, widths 1/2/4/8, adjacent and overlapping intervals, 2^64 endpoint, S64 extrema, absent high-U64 certificate, and incomparable alias all produce conservative results.","related_sources":["asl/arch/memory-model/ordering.asl","asl/block/model/dispatch/indexed-tlsu-range-schema.asl","asl/tile/model/memory/addressing.asl"]}
func main() => integer
begin
    let example = TileIndexedTLSUByteIntervalFromDescriptor(TRUE,
        Zeros{64} + 0x10000, Zeros{64} - 64, Zeros{64} + 128, 4);
    assert example.valid;
    assert example.start_byte == 0xffc0;
    assert example.end_byte_exclusive == 0x10084;

    let adjacent = TileIndexedTLSUByteIntervalFromDescriptor(TRUE,
        Zeros{64} + 0x10084, Zeros{64}, Zeros{64}, 1);
    let overlapping = TileIndexedTLSUByteIntervalFromDescriptor(TRUE,
        Zeros{64} + 0x10083, Zeros{64}, Zeros{64}, 1);
    assert adjacent.valid && overlapping.valid;
    assert TileIndexedTLSUByteIntervalRelation(example, adjacent, TRUE) ==
        TileIndexedTLSURange_Disjoint;
    assert TileIndexedTLSUByteIntervalRelation(example, overlapping, TRUE) ==
        TileIndexedTLSURange_Overlap;
    assert TileIndexedTLSUByteIntervalRelation(example, adjacent, FALSE) ==
        TileIndexedTLSURange_Unknown;

    let union = TileIndexedTLSUByteIntervalUnion(example, overlapping);
    assert union.valid && union.start_byte == 0xffc0 &&
           union.end_byte_exclusive == 0x10084;
    assert TileIndexedTLSUByteIntervalRelation(example,
        TileIndexedTLSUByteInterval {valid = FALSE, start_byte = 0,
            end_byte_exclusive = 0}, TRUE) == TileIndexedTLSURange_Unknown;

    let width1 = TileIndexedTLSUByteIntervalFromDescriptor(TRUE,
        Zeros{64} + 0x2000, Zeros{64}, Zeros{64}, 1);
    let width2 = TileIndexedTLSUByteIntervalFromDescriptor(TRUE,
        Zeros{64} + 0x2000, Zeros{64}, Zeros{64}, 2);
    let width4 = TileIndexedTLSUByteIntervalFromDescriptor(TRUE,
        Zeros{64} + 0x2000, Zeros{64}, Zeros{64}, 4);
    let width8 = TileIndexedTLSUByteIntervalFromDescriptor(TRUE,
        Zeros{64} + 0x2000, Zeros{64}, Zeros{64}, 8);
    assert width1.valid && width1.end_byte_exclusive == 0x2001;
    assert width2.valid && width2.end_byte_exclusive == 0x2002;
    assert width4.valid && width4.end_byte_exclusive == 0x2004;
    assert width8.valid && width8.end_byte_exclusive == 0x2008;
    // Packed four-bit ordinary transactions use W=1; MSCATTER.POPC uses W=4.
    let packed = TileIndexedTLSUByteIntervalFromDescriptor(TRUE,
        Zeros{64} + 0x3000, Zeros{64}, Zeros{64}, 1);
    let popc = TileIndexedTLSUByteIntervalFromDescriptor(TRUE,
        Zeros{64} + 0x3000, Zeros{64}, Zeros{64}, 4);
    assert packed.end_byte_exclusive == 0x3001;
    assert popc.end_byte_exclusive == 0x3004;

    let address_space_end = UInt(Ones{PTO_XLEN}) + 1;
    let final_byte = TileIndexedTLSUByteIntervalFromDescriptor(TRUE,
        Ones{PTO_XLEN} - 3, Zeros{64}, Zeros{64}, 4);
    assert final_byte.valid && final_byte.end_byte_exclusive == address_space_end;
    let wrapping = TileIndexedTLSUByteIntervalFromDescriptor(TRUE,
        Ones{PTO_XLEN} - 3, Zeros{64}, Zeros{64}, 8);
    assert !wrapping.valid;
    let negative_start = TileIndexedTLSUByteIntervalFromDescriptor(TRUE,
        Zeros{64}, Zeros{64} - 1, Zeros{64}, 1);
    assert !negative_start.valid;

    let signed_extremes = TileIndexedTLSUByteIntervalFromDescriptor(TRUE,
        Zeros{64} + 0x8000000000000000,
        Zeros{64} + 0x8000000000000000,
        Zeros{64} + 0x7fffffffffffffff, 1);
    assert signed_extremes.valid && signed_extremes.start_byte == 0 &&
           signed_extremes.end_byte_exclusive == address_space_end;
    let absent_high_u64 = TileIndexedTLSUByteIntervalFromDescriptor(FALSE,
        Zeros{64} + 0x1000, Zeros{64},
        Zeros{64} + 0x8000000000000001, 4);
    assert !absent_high_u64.valid;
    return 0;
end;
