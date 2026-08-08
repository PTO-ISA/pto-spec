<!-- GENERATED FROM: asl/block/model/commit/effects.asl -->
# Effects

**Normative ASL source:** `asl/block/model/commit/effects.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-COMMIT-EFFECTS}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/commit/effects.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-COMMIT-EFFECTS","surface":"block","classification":["model","commit","effects"],"depends_on":["PTO-BLOCK-MODEL-LIFECYCLE-LIFETIME"]}
func ExecuteQueueManagerMove(destination: Reg5Selector, left: Word,
                             right: Word, flags: bits(4))
begin
    _LastQueueLeft = left;
    _LastQueueRight = right;
    _LastQueueFlags = flags;
    WriteScalarDestination(destination, left);
end;

func ExecuteQueueManagerPop(destination0: Reg5Selector,
                            destination1: Reg5Selector,
                            left: Word, right: Word, flags: bits(4))
begin
    _LastQueueLeft = left;
    _LastQueueRight = right;
    _LastQueueFlags = flags;
    WriteScalarDestination(destination0, left);
    WriteScalarDestination(destination1, right);
end;

func ExecuteQueueManagerPush(destination: Reg5Selector, left: Word,
                             right: Word, flags: bits(4))
begin
    _LastQueueLeft = left;
    _LastQueueRight = right;
    _LastQueueFlags = flags;
    WriteScalarDestination(destination, left + right);
end;

func ExecuteBoundedMemoryCopy(destination: Word, source: Word, length: Word)
begin
    if UInt(length) > 63 then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;
    let byte_count = UInt(length) as integer {0..63};
    if byte_count != 0 then
        let access_size = byte_count as integer {1..262144};
        let read_probe = ProbeDataAccess(source, access_size, 1, FALSE);
        let write_probe = ProbeDataAccess(destination, access_size, 1, TRUE);
        if RaiseDataAccessFault(read_probe, source) then
            return;
        elsif RaiseDataAccessFault(write_probe, destination) then
            return;
        else
            let buffer = LoadTranslatedBytesBounded(
                read_probe.translated_address, byte_count);
            StoreTranslatedBytesBounded(destination,
                write_probe.translated_address, byte_count, buffer);
        end;
    end;
    if _LastFault == Fault_None then
        _LastMemoryCommandAddress = destination;
        _LastMemoryCommandSize = length;
    end;
end;

func ExecuteBoundedMemorySet(destination: Word, value: Word, length: Word)
begin
    if UInt(length) > 63 then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;
    let byte_count = UInt(length) as integer {0..63};
    if byte_count != 0 then
        let access_size = byte_count as integer {1..262144};
        let write_probe = ProbeDataAccess(destination, access_size, 1, TRUE);
        if RaiseDataAccessFault(write_probe, destination) then
            return;
        else
            StoreTranslatedFillBounded(destination, write_probe.translated_address,
                byte_count, value[7:0]);
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
    _BundleTransfer = BundleTransfer_Indirect;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
