<!-- GENERATED FROM: asl/block/model/lifecycle/begin.asl -->
# Begin

**Normative ASL source:** `asl/block/model/lifecycle/begin.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-LIFECYCLE-BEGIN}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/lifecycle/begin.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-LIFECYCLE-BEGIN","surface":"block","classification":["model","lifecycle","begin"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-ATTRIBUTES"]}
func BeginBundleAt(start_pc: Word, kind: BundleKind, transfer: BundleTransfer,
                   target: Word, sequential: Word, return_target: Word,
                   taken: boolean)
begin
    if _BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    elsif target[0] == '1' then
        SetFault(Fault_InstructionPC, target);
    else
        _BundleActive = TRUE;
        _BundleBodyActive = FALSE;
        _BundleCommitTargetSet = FALSE;
        _BundleConditionSet = FALSE;
        _SystemBlockTerminalPending = FALSE;
        _BARG.block_type = kind;
        if kind == BundleKind_System then
            // SYS has no architectural candidate continuation. Keep the
            // shared representation in a canonical non-selecting state.
            _BARG.transfer_type = BundleTransfer_Fallthrough;
            _BARG.taken = FALSE;
            _BARG.bpcn = Zeros{PTO_XLEN};
        else
            _BARG.transfer_type = transfer;
            _BARG.taken = taken;
            _BARG.bpcn = target;
        end;
        _BundleSequentialPC = sequential;
        _FrameStackReturnTarget = return_target;
        // Each dynamic block execution receives a distinct mathematical
        // domain identity. Static BSTART addresses remain program locations
        // and never stand in for dynamic replay/squash identity.
        _BundleExecutionDomainToken = _NextBundleExecutionDomainToken;
        _NextBundleExecutionDomainToken =
            _NextBundleExecutionDomainToken + 1;
        // BPC is the address of this BSTART. BPCN is retained in
        // BARG.BPCN until BSTOP or the next BSTART commits the block.
        WriteBPC(start_pc);
        // BSTART installs the transfer selected for the bundle commit. Header
        // commands remain sequential until BSTOP or the next BSTART commits it.
        WriteTPC(sequential);
        if transfer == BundleTransfer_Call ||
           transfer == BundleTransfer_IndirectCall then
            _ReturnAddress = return_target;
            WriteGPR(10, return_target);
        end;
    end;
end;

func BeginBundle(kind: BundleKind, transfer: BundleTransfer, target: Word,
                 sequential: Word, return_target: Word, taken: boolean)
begin
    BeginBundleAt(ReadTPC(), kind, transfer, target, sequential,
        return_target, taken);
end;
```
<!-- GENERATED-ASL-END: unit -->
