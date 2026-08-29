type literal =
  | L_Int of Z.t
  | L_Bool of bool
  | L_Real of Q.t
  | L_BitVector of Bitvector.t

type expr_desc =
  | E_Literal of literal
  | E_Var of string
  | E_Binop of binop * expr_desc * expr_desc
  | E_Call of string

and binop =
  [ `ADD ]

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
  | SB_Primitive of bool

type subprogram_type =
  | ST_Procedure
  | ST_Function

type global_decl_keyword =
  | GDK_Var

type override_info =
  | Impdef

type decl_desc =
  | D_Func of string
  | D_GlobalStorage of string
