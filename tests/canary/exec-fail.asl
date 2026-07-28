// Executed by ASLRef. A run-time failure must surface as a nonzero exit, or a
// failing semantic test would be reported as a passing one.
func main() => integer
begin
    assert FALSE;
    return 0;
end;
