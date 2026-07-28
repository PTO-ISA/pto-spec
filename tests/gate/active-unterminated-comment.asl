// Escape fixture: a block comment that is never closed.
//
// Sources are concatenated before the gate runs, so an unterminated comment in
// one source hides every later source behind it. Treating end of file as an
// implicit close would certify the assembled specification as inert while it
// still carried content. The gate must refuse to certify this file.

/* opened and never closed
func Gate_HiddenBehindUnterminatedComment() => integer
begin
    return 0;
end;
