<!-- GENERATED FROM: asl/block/model/state/barg.asl -->
# Barg

**Normative ASL source:** `asl/block/model/state/barg.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-STATE-BARG}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-state-barg-purpose role=purpose-scope -->
## Purpose and scope

This unit defines how `BARG`, the bundle argument register, chooses where execution continues after a bundle commits. It also defines the three `BARG` words that `LSRGET` can read from inside a bundle body.

Its contract, `PTO-BARG-CONTINUATION-001`, says `BSTART` initializes every `BARG` field, and `BSTOP` or the next `BSTART` is the only boundary that picks the next PC.

<!-- PTO-READER-BLOCK: block-model-state-barg-concepts role=concepts-state -->
## Concepts and visible state

`BARG` has five parts:

- `BPC`, the address of the current `BSTART`, stored in program-control state.
- `BlockType`, the block class, such as `Standard`, `Floating`, or `System`.
- `BPCN`, the candidate next PC.
- `TYPE`, the transfer rule: `Fallthrough`, `Direct`, `Conditional`, `Call`, `Return`, `Indirect`, or `IndirectCall`.
- `TAKEN`, which matters only for `Conditional`.

`BARG` has no trap field. The `B.CATR` trap request is held in the bundle control attributes.

<!-- PTO-READER-BLOCK: block-model-state-barg-rules role=rules-interactions -->
## Rules and interactions

`BARGSelectsBPCN` is true for `Direct`, `Call`, `Indirect`, `IndirectCall`, and `Return`, and for `Conditional` when `TAKEN` is set. `BARGCommitPC(continuation)` returns `BPCN` when it is selected and the sequential continuation otherwise.

`LSRGET` identifiers are:

| ID | Word | Applicable when |
| --- | --- | --- |
| 0 | `BPC` | an active bundle body |
| 1 | `BPCN` | an active body of a `Standard` or `Floating` block |
| 2 | packed control word | an active bundle body |

The packed control word holds the block-kind code in bits `3:0`. For `Standard` and `Floating` blocks, it holds the transfer code in bits `6:4` and `TAKEN` in bit 7. Bits 8 to 12 hold the `B.CATR` atomic, acquire, release, far, and dimension-reduction flags. All higher bits are zero.

Design point: one record decides the continuation. `SETC.TGT` rewrites `BPCN`, and a `SETC` condition sets `TAKEN`, but neither changes control flow directly. Commit reads the final `BARG` once, so the program sees exactly one transfer per bundle, taken only when the bundle commits.

Design point: `BARGHasCandidateWord` is true only for `Standard` and `Floating` blocks. For other kinds ID 1 is not applicable and the transfer and `TAKEN` bits of the packed word stay zero, so a program never reads a candidate target from those kinds.

<!-- PTO-READER-BLOCK: block-model-state-barg-boundaries role=boundaries -->
## Architectural boundaries

`ReadCurrentBARGWord` asserts applicability. The `LSRGET` caller checks it first and raises `Fault_BundleControl` when an ID is not applicable or no bundle body is active.

This unit does not write `BARG`. Begin, the commit target setters, the condition setters, stop, reset, and trap-context recovery do.

<!-- PTO-READER-BLOCK: block-model-state-barg-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

In the body of a `Standard` conditional block with `BPCN = 0x2000`, a `SETC` sets `TAKEN`. `LSRGET` ID 1 returns `0x2000`. ID 2 returns block-kind code `0000`, transfer code `010` in bits `6:4`, and 1 in bit 7. At `BSTOP`, `BARGCommitPC` selects `0x2000`.

<!-- PTO-READER-BLOCK: block-model-state-barg-related role=related-owners-navigation -->
## Related owners

- [Begin](../lifecycle/begin.md) initializes `BARG`.
- [Enter and stop](../lifecycle/enter-stop.md) consumes it at commit.
- [Bundle encoding](../schema/bundle-encoding.md) defines the kind and transfer codes.
- [LSRGET](../../../scalar/sys/LSRGET.md) and [SETC.TGT](../../../scalar/sys/SETC.TGT.md) read and write it from the body.
<!-- SUPPLEMENTARY-END -->

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
    value[3:0] = BundleKindCode(_BARG.block_type);
    if BARGHasCandidateWord() then
        value[6:4] = BundleTransferCode(_BARG.transfer_type);
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
