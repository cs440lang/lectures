type expr = Var of string
          | Abs of string * expr
          | App of expr * expr  
  
