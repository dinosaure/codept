(** Codept server *)
open Params
let tool_name = "codept"
let version = 0.3
let stderr= Format.err_formatter
let std = Format.std_formatter

let io = Analysis.direct_io

let uaddr= "codept_test_3"

let addr = Unix.ADDR_UNIX uaddr
let socket = Unix.(socket PF_UNIX SOCK_STREAM 0)
let () = Unix.setsockopt socket Unix.SO_REUSEADDR true

let answer f where =
  let ch = Unix.in_channel_of_descr where in
  let out = Unix.out_channel_of_descr where in
  let query: Parse_arg.query = input_value ch in
  let fmt = Format.formatter_of_out_channel out in
  f fmt query;
  output_string out "Done\n";
  flush out;
  Unix.close where


let process out (query:Parse_arg.query) =
  let task = io.findlib query.task query.findlib in
  List.iter (Parse_arg.eval_single out query.params query.task) query.action.singles;
  if not (query.action.modes = [] && query.action.makefiles = [] ) then
    let analyzed = Analysis.main io query.params.analyzer task in
    List.iter (Parse_arg.iter_mode out query.params analyzed) query.action.modes;
    List.iter (Parse_arg.iter_makefile out query.params analyzed)
      query.action.makefiles


let rec server () =
  Unix.listen socket 10;
  Printf.printf "Server\n";
  match Unix.select [socket] [] [] 5. with
  | [_], _ , _  ->
    let client, _addr = Unix.accept socket in
    let _t = Thread.create (answer process) client in
    server ()
  | _ ->
    Unix.close socket;
    Unix.unlink uaddr


let () =
  Unix.bind socket addr;
  Unix.listen socket 10;
  server ()