type bop =
  | Add
  | Mult
  | Leq

type expr =
  | Int of int
  | Bool of bool
  | Var of string
  | Binop of bop * expr * expr
  | If of expr * expr * expr
  | Let of string * expr * expr
