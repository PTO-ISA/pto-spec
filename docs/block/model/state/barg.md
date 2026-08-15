<!-- GENERATED FROM: asl/block/model/state/barg.asl -->
# Barg

**Normative ASL source:** `asl/block/model/state/barg.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-STATE-BARG}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/state/barg.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-BARG","surface":"block","classification":["model","state","barg"],"depends_on":["PTO-BLOCK-MODEL-STATE-CONTROL-STATE"]}
// BARG is the sole block-continuation authority. BPC names the current BSTART;
// BlockType identifies the block class; BPCN is the candidate next PC; TYPE
// selects the continuation rule; TAKEN is meaningful only for COND. BARG has
// no TRAP field.

// NDF-BEGIN: PTO-BARG-CONTINUATION-001
// ndf: kind=contract level=L1 layer=block status=accepted
// BSTART MUST initialize BARG.BPC, BARG.BlockType, BARG.BPCN, BARG.TYPE, and
// BARG.TAKEN; BSTOP or the next BSTART MUST be the only boundary that selects
// the next PC from BARG.BPCN or the sequential continuation.
// NDF-END: PTO-BARG-CONTINUATION-001

readonly func BARGSelectsBPCN() => boolean
begin
    return _BARG.transfer_type == BundleTransfer_Direct ||
           _BARG.transfer_type == BundleTransfer_Call ||
           _BARG.transfer_type == BundleTransfer_Indirect ||
           _BARG.transfer_type == BundleTransfer_IndirectCall ||
           _BARG.transfer_type == BundleTransfer_Return ||
           (_BARG.transfer_type == BundleTransfer_Conditional && _BARG.taken);
end;

readonly func BARGCommitPC(continuation: Word) => Word
begin
    if BARGSelectsBPCN() then return _BARG.bpcn;
    else return continuation;
    end;
end;

readonly func BARGHasCandidateWord() => boolean
begin
    return _BARG.block_type == BundleKind_Standard ||
           _BARG.block_type == BundleKind_Floating;
end;

readonly func PackCurrentBARGControlWord() => Word
begin
    var value: Word = Zeros{PTO_XLEN};
    value[3:0] = PTOv0BundleKindCode(_BARG.block_type);
    if BARGHasCandidateWord() then
        value[6:4] = PTOv0BundleTransferCode(_BARG.transfer_type);
        value[7] = if _BARG.taken then '1' else '0';
    end;
    value[8] = if _BundleControlAttributes.atomic then '1' else '0';
    value[9] = if _BundleControlAttributes.acquire then '1' else '0';
    value[10] = if _BundleControlAttributes.release then '1' else '0';
    value[11] = if _BundleControlAttributes.far then '1' else '0';
    value[12] =
        if _BundleControlAttributes.dimension_reduction then '1' else '0';
    return value;
end;

readonly func CurrentBARGWordApplicable(identifier: bits(12)) => boolean
begin
    if !_BundleActive || !_BundleBodyActive then
        return FALSE;
    end;
    case UInt(identifier) of
        when 0 => return TRUE;
        when 1 => return BARGHasCandidateWord();
        when 2 => return TRUE;
        otherwise => return FALSE;
    end;
end;

readonly func ReadCurrentBARGWord(identifier: bits(12)) => Word
begin
    assert CurrentBARGWordApplicable(identifier);
    case UInt(identifier) of
        when 0 => return ReadBPC();
        when 1 => return _BARG.bpcn;
        when 2 => return PackCurrentBARGControlWord();
        otherwise => unreachable;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
