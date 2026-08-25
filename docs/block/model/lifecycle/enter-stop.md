<!-- GENERATED FROM: asl/block/model/lifecycle/enter-stop.asl -->
# Enter Stop

**Normative ASL source:** `asl/block/model/lifecycle/enter-stop.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-LIFECYCLE-ENTER-STOP}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/lifecycle/enter-stop.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-LIFECYCLE-ENTER-STOP","surface":"block","classification":["model","lifecycle","enter-stop"],"depends_on":["PTO-BLOCK-MODEL-LIFECYCLE-BEGIN","PTO-BLOCK-MODEL-STATE-BARG"]}
func EnterBundleBody()
begin
    if !_BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    else
        _BundleBodyActive = TRUE;
    end;
end;

func StopBundle()
begin
    if !_BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    else
        StopBundleAt(_BundleSequentialPC);
    end;
end;

func StopBundleAt(continuation: Word)
begin
    if !_BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    elsif continuation[0] == '1' || BARGCommitPC(continuation)[0] == '1' then
        SetFault(Fault_InstructionPC, BARGCommitPC(continuation));
    else
        let next_pc = BARGCommitPC(continuation);
        let post_commit_trap = _BundleControlAttributes.trap_enabled;
        _BundleActive = FALSE;
        _BundleBodyActive = FALSE;
        ClearBundleHeaderState();
        _BARG.block_type = BundleKind_Standard;
        _BARG.transfer_type = BundleTransfer_Fallthrough;
        _BARG.taken = FALSE;
        _BARG.bpcn = Zeros{PTO_XLEN};
        _BundleSequentialPC = Zeros{PTO_XLEN};
        _FrameStackReturnTarget = Zeros{PTO_XLEN};
        WriteBPC(Zeros{PTO_XLEN});
        WriteTPC(next_pc);
        if post_commit_trap then
            // SetFault snapshots the already committed, cleared block state.
            // Recovering that context resumes next_pc, never the retired
            // block or its BSTOP instruction.
            SetFault(Fault_BundlePostCommit, next_pc);
        end;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
