open L10_miniml.Eval

let rec repl () =
  print_string "> ";
  flush stdout;
  match read_line () with
  | "" -> ()
  | line -> (
      try
        let expr = parse line in
        let value = eval expr [] in
        print_endline (string_of_val value);
        repl ()
      with
      | RuntimeError msg ->
          Printf.printf "Runtime Error: %s\n" msg;
          repl ()
      | L10_miniml.Parser.Error ->
          print_endline "Parse error.";
          repl ())

let () =
  print_endline "MiniML REPL:\n";
  repl ()
