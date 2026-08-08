// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-LIFECYCLE-BEGIN","surface":"block","classification":["model","lifecycle","begin"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-ATTRIBUTES"]}
func BeginBundle(kind: BundleKind, transfer: BundleTransfer, target: Word,
                fallthrough: Word, return_target: Word, condition: boolean)
begin
    if _BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    elsif target[0] == '1' then
        SetFault(Fault_InstructionPC, target);
    else
        _BundleActive = TRUE;
        _BundleBodyActive = FALSE;
        _BundleKind = kind;
        _BundleTransfer = transfer;
        _BundleCondition = condition;
        _BundleTarget = target;
        _BundleFallthrough = fallthrough;
        _BundleReturnTarget = return_target;
        WriteBPC(target);
        // BSTART installs the transfer selected for the bundle commit. Header
        // commands remain sequential until BSTOP or the next BSTART commits it.
        WriteTPC(fallthrough);
        if transfer == BundleTransfer_Call ||
           transfer == BundleTransfer_IndirectCall then
            _ReturnAddress = return_target;
            WriteGPR(10, return_target);
        end;
    end;
end;

