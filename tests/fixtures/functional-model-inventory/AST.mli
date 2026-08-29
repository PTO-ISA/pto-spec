type literal =
  | L_Int of Z.t
  | L_Bool of bool

type expr_desc =
  | E_Literal of literal
  | E_Var of string

type type_desc =
  | T_Int of constraint_kind
  | T_Bool

and constraint_kind =
  | UnConstrained

type stmt_desc =
  | S_Pass
  | S_Return of expr_desc option

type subprogram_body =
  | SB_ASL of stmt_desc

type subprogram_type =
  | ST_Procedure

type global_decl_keyword =
  | GDK_Var

type decl_desc =
  | D_Func of string
  | D_GlobalStorage of string
