<!-- GENERATED FROM: asl/block/model/commit/effects.asl -->
# Effects

**Normative ASL source:** `asl/block/model/commit/effects.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-COMMIT-EFFECTS}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/commit/effects.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-COMMIT-EFFECTS","surface":"block","classification":["model","commit","effects"],"depends_on":["PTO-BLOCK-MODEL-LIFECYCLE-LIFETIME","PTO-ARCH-GQM"]}
func ExecuteQueueManagerMove(destination: Reg5Selector,
                             address: Word,
                             capacity_source: Word,
                             flags: bits(4))
begin
    let initialize = flags[3] == '1';
    let notify_event = flags[2] == '1';
    let suspend = flags[1] == '1';
    let restore = flags[0] == '1';
    var result = GQMResult(0, '01');
    var succeeded = FALSE;

    if initialize then
        let capacity = UInt(capacity_source[9:0]) as GQMQueueCapacity;
        - = InitializeGQMQueue(address, capacity);
        result = GQMResult((capacity * 8) as integer {0..8191}, '00');
        succeeded = TRUE;
    else
        let found = FindGQMQueue(address);
        if found != PTO_MODEL_GQM_QUEUE_SLOTS then
            let slot = found as GQMQueueSlot;
            if !_GQMQueueCorrupt[[slot]] then
                result = GQMResult(GQMQueueRemaining(address), '00');
                succeeded = TRUE;
            end;
        end;
    end;

    if succeeded then
        // Combined controls execute after the primary operation, in encoded
        // architectural order: event first, then suspension or restoration.
        if notify_event then
            BroadcastGQMEvent(address);
        end;
        if suspend then
            SetGQMQueueSuspended(address, TRUE);
        elsif restore then
            SetGQMQueueSuspended(address, FALSE);
        end;
    end;

    _LastQueueLeft = address;
    _LastQueueRight = capacity_source;
    _LastQueueFlags = flags;
    WriteScalarDestination(destination, result);
end;

func ExecuteQueueManagerPop(destination0: Reg5Selector,
                            destination1: Reg5Selector,
                            address: Word,
                            flags: bits(4))
begin
    let notify_event = flags[1] == '1';
    let relaxed = flags[0] == '1';
    let response = PopGQMQueueEntry(
        address,
        relaxed,
        notify_event);

    _LastQueueLeft = address;
    _LastQueueRight = Zeros{PTO_XLEN};
    _LastQueueFlags = flags;
    WriteScalarDestination(destination0, response.data);
    WriteScalarDestination(destination1, response.result);
end;

func ExecuteQueueManagerPush(destination: Reg5Selector,
                             address: Word,
                             entry: Word,
                             flags: bits(4))
begin
    let at_head = flags[3] == '1';
    let notify_event = flags[2] == '1';
    let relaxed = flags[0] == '1';
    let result = PushGQMQueueEntry(
        address,
        entry,
        at_head,
        relaxed,
        notify_event);

    _LastQueueLeft = address;
    _LastQueueRight = entry;
    _LastQueueFlags = flags;
    WriteScalarDestination(destination, result);
end;

pure func MemoryRangeWraps(address: Word, length: Word) => boolean
begin
    if length == Zeros{PTO_XLEN} then
        return FALSE;
    end;
    let end_address = address + length;
    return UInt(end_address) < UInt(address);
end;

pure func MemoryCopyRangesOverlap(destination: Word,
                                  source: Word,
                                  length: Word) => boolean
begin
    if length == Zeros{PTO_XLEN} then
        return FALSE;
    end;
    let destination_end = destination + length;
    let source_end = source + length;
    return UInt(destination) < UInt(source_end) &&
           UInt(source) < UInt(destination_end);
end;

pure func MemoryCopyStepSize(remaining: Word) => integer {1,2,4,8}
begin
    assert remaining != Zeros{PTO_XLEN};
    if UInt(remaining) >= 8 then
        return 8;
    elsif UInt(remaining) >= 4 then
        return 4;
    elsif UInt(remaining) >= 2 then
        return 2;
    else
        return 1;
    end;
end;

func StartMemoryCopyTemplate(destination: Word,
                             source: Word,
                             length: Word) => boolean
begin
    if MemoryRangeWraps(destination, length) ||
       MemoryRangeWraps(source, length) ||
       MemoryCopyRangesOverlap(destination, source, length) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;

    _MemoryCopyTemplate.active = TRUE;
    _MemoryCopyTemplate.instruction_pc = ReadTPC();
    _MemoryCopyTemplate.destination = destination;
    _MemoryCopyTemplate.source = source;
    _MemoryCopyTemplate.length = length;
    _MemoryCopyTemplate.progress = Zeros{PTO_XLEN};
    return TRUE;
end;

func CompleteMemoryCopyTemplate()
begin
    _LastMemoryCommandAddress = _MemoryCopyTemplate.destination;
    _LastMemoryCommandSize = _MemoryCopyTemplate.length;
    _MemoryCopyTemplate.active = FALSE;
end;

func ExecuteMemoryCopyStep()
begin
    let progress = _MemoryCopyTemplate.progress;
    let remaining = _MemoryCopyTemplate.length - progress;
    let step_size = MemoryCopyStepSize(remaining);
    let step_word = NaturalToWord(
        step_size as integer {0..262144});
    let source_address = _MemoryCopyTemplate.source + progress;
    let destination_address = _MemoryCopyTemplate.destination + progress;

    // Both accesses are probed before the source value is observed.  A
    // rejected destination therefore cannot leave a source read or event.
    let source_probe = ProbeDataAccess(
        source_address,
        step_size,
        1,
        FALSE);
    let destination_probe = ProbeDataAccess(
        destination_address,
        step_size,
        1,
        TRUE);
    if RaiseDataAccessFault(source_probe, source_address) then
        return;
    elsif RaiseDataAccessFault(destination_probe, destination_address) then
        return;
    end;

    let value = LoadTranslatedUnsigned(
        source_probe.translated_address,
        step_size);
    RecordLoadEvent(
        source_probe.translated_address,
        step_size,
        value,
        MemoryOrder_Relaxed);
    StoreTranslated(
        destination_address,
        destination_probe.translated_address,
        step_size,
        value);
    RecordStoreEvent(
        destination_probe.translated_address,
        step_size,
        value,
        MemoryOrder_Relaxed);
    _MemoryCopyTemplate.progress = progress + step_word;
end;

func ExecuteMemoryCopyTemplate(destination: Word,
                               source: Word,
                               length: Word)
begin
    if !_MemoryCopyTemplate.active then
        if !StartMemoryCopyTemplate(destination, source, length) then
            return;
        end;
    end;

    if _MemoryCopyTemplate.instruction_pc != ReadTPC() then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;

    for step = 0 to PTO_MODEL_MEMORY_BYTES - 1
        looplimit PTO_MODEL_MEMORY_BYTES do
        if _MemoryCopyTemplate.active &&
           _LastFault == Fault_None then
            if _MemoryCopyTemplate.progress ==
               _MemoryCopyTemplate.length then
                CompleteMemoryCopyTemplate();
            else
                ExecuteMemoryCopyStep();
            end;
        end;
    end;

    if _MemoryCopyTemplate.active &&
       _LastFault == Fault_None &&
       _MemoryCopyTemplate.progress == _MemoryCopyTemplate.length then
        CompleteMemoryCopyTemplate();
    end;
end;

func ExecuteMemorySet(destination: Word, value: Word, length: Word)
begin
    if MemoryRangeWraps(destination, length) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;

    // The fixed storage size is a bounded-reference-model parameter.  A
    // portable MSET has no corresponding architectural length ceiling.
    if UInt(length) > PTO_MODEL_MEMORY_BYTES then
        SetFault(Fault_DataPage, destination);
        return;
    end;

    let byte_count = UInt(length)
        as integer {0..PTO_MODEL_MEMORY_BYTES};
    if byte_count != 0 then
        let access_size = byte_count as integer {1..262144};
        let write_probe = ProbeDataAccess(destination, access_size, 1, TRUE);
        if RaiseDataAccessFault(write_probe, destination) then
            return;
        else
            StoreTranslatedFillModelBounded(
                destination,
                write_probe.translated_address,
                byte_count as integer {1..PTO_MODEL_MEMORY_BYTES},
                value[7:0]);
        end;
    end;
    if _LastFault == Fault_None then
        _LastMemoryCommandAddress = destination;
        _LastMemoryCommandSize = length;
    end;
end;

func ExecuteCrossBlockTransferState(acr_id: bits(10), block_id: bits(7))
begin
    _LastCrossBlockACR = acr_id;
    _LastCrossBlockID = block_id;
    _BARG.transfer_type = BundleTransfer_Indirect;
end;
```
<!-- GENERATED-ASL-END: unit -->
