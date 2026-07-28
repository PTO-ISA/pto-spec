// Escape fixture: ASL1 declaration forms outside the previous keyword list.
// Any block list over a language that keeps gaining syntax has this failure
// mode, which is why the gate allow-lists comments instead.
accessor Gate_Accessor() <=> integer
begin
    getter
    begin
        return 0;
    end;

    setter = value
    begin
        pass;
    end;
end;

pragma gate_unlisted_pragma;
