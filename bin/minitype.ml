open L12_typeinfer

let rec repl () =
  print_string "> ";
  flush stdout;
  match read_line () with
  | "" -> ()
  | line -> (
      try
        let expr = Eval.parse line in
        let inferred_type = Poly_typeinfer.infer expr in
        let value = Eval.eval expr [] in
        Printf.printf "- : %s = %s\n"
          (Poly_typeinfer.string_of_type inferred_type)
          (Eval.string_of_val value);
        repl ()
      with
      | Poly_typeinfer.TypeError msg ->
          Printf.printf "Type Error: %s\n" msg;
          repl ()
      | Eval.RuntimeError msg ->
          Printf.printf "Runtime Error: %s\n" msg;
          repl ()
      | Parser.Error ->
          print_endline "Parse error.";
          repl ())

let () =
  print_endline "Type Inferred MiniML REPL:\n";
  repl ()
