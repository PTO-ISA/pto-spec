// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-LIFECYCLE-ENTER-STOP","surface":"block","classification":["model","lifecycle","enter-stop"],"depends_on":["PTO-BLOCK-MODEL-LIFECYCLE-BEGIN"]}
func EnterBundleBody()
begin
    if !_BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    else
        _BundleBodyActive = TRUE;
        // Only machine-parallel and machine-sequential bodies enter the
        // kernel EXEC domain. Other bundle kinds retain the stored mask and
        // continue to branch on CARG.
        if BundleKindUsesExecutionMask(_BundleKind) then
            WriteExecutionMask(Ones{PTO_XLEN});
        end;
        WriteTPC(ReadBPC());
    end;
end;

func StopBundle()
begin
    if !_BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    else
        _BundleActive = FALSE;
        _BundleBodyActive = FALSE;
        WriteTPC(_BundleFallthrough);
    end;
end;

func StopBundleAt(continuation: Word)
begin
    if !_BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    elsif continuation[0] == '1' then
        SetFault(Fault_InstructionPC, continuation);
    else
        let take_target = _BundleTransfer == BundleTransfer_Direct ||
            _BundleTransfer == BundleTransfer_Call ||
            _BundleTransfer == BundleTransfer_Indirect ||
            _BundleTransfer == BundleTransfer_IndirectCall ||
            _BundleTransfer == BundleTransfer_Return ||
            (_BundleTransfer == BundleTransfer_Conditional && _BundleCondition);
        _BundleActive = FALSE;
        _BundleBodyActive = FALSE;
        if take_target then WriteTPC(_BundleTarget);
        else WriteTPC(continuation);
        end;
    end;
end;
