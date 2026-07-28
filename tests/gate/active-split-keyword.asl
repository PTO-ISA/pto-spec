// Escape fixture: a line-anchored keyword scan cannot match `func` when the
// declaration name is on the following line, because the keyword is not
// followed by whitespace on its own line.
func
    Gate_SplitKeyword() => integer
begin
    return 0;
end;
