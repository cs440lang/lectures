(*
   Topics covered:
   - top-level let bindings
   - type annotation
   - basic types and related operators:
     - int, float, bool, string, tuple
   - basic expressions:
     - let-in
     - if-then-else
     - assert
*)

let class_num : int = 440

let class_num' : int = 44 * 10

let class_num'' : float = 44.0 *. 10.0

let class_name = "CS "
               ^ string_of_int class_num
               ^ ": Programming Languages"

let class_name' =
  Printf.sprintf "CS %d: Programming Languages" class_num

let f = let c = 32. in
        c *. 9. /. 5. +. 32. 

let (r1,r2) : float * float =
  let a = 1. in
  let b = 1. in
  let c = -2. in
  let disc = b *. b -. 4. *. a *. c in
  (* let _ = assert (disc >= 0.) in *)
  assert (disc >= 0.) ;
  let sqrt_disc = sqrt disc in
  ((-.b+.sqrt_disc)/.(2.*.a)), ((-.b-.sqrt_disc)/.(2.*.a))

let h = "It is " ^ if f < 32. then "Freezing"
                   else if f < 65. then "Brisk"
                   else if f < 90. then "Warm"
                   else "Hot"

let days =
  let month = 9 in
  let year = 2025 in
    if month = 2 then
      if year mod 4 = 0 then 29 else 28
    else if month = 4 || month = 6
            || month = 9 || month = 11 then 30
    else if month >= 1 && month <= 12 then 31
    else invalid_arg "Invalid month!"
