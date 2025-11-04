open L06_lc.Eval

let rec repl () =
  print_string "> ";
  flush stdout;
  match read_line () with
  | "" -> ()
  | line -> (
      try
        let expr = parse line in
        let value = eval_normal ~trace:false expr in
        print_endline (string_of_expr value);
        repl ()
      with
      | Failure msg ->
          Printf.printf "Error: %s\n" msg;
          repl ()
      | L06_lc.Parser.Error ->
          print_endline "Parse error.";
          repl ())

let () =
  print_endline "Lambda Calculus REPL (\\ for λ):\n";
  repl ()
