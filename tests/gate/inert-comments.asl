// Comment-only fixture. The gate must report no active content here.
//
// The block comment below contains declaration keywords in the leading column.
// A keyword scan reports them as violations; an allow-list over comments does
// not. Authoring templates such as asl/instructions/TEMPLATE.asl depend on this
// distinction.

/*
func Gate_InsideBlockComment(value: integer) => integer
begin
    return value;
end;

type Gate_InsideBlockComment_Type of integer;
*/

//  var gate_line_commented: integer;
//  constant GATE_LINE_COMMENTED = 1;

    // Indented comments and blank lines are inert.
