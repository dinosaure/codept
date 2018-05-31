let parse argv args anon usage =
  let args =
    args @ [
      "-args", Arg.Expand Arg.read_arg,
      "<file> Read additional newline separated command line arguments \n\
      \      from <file>";
      "-args0", Arg.Expand Arg.read_arg0,
      "<file> Read additional NUL separated command line arguments from \n\
      \      <file>"
  ] in
  Clflags.add_arguments __LOC__ args;
    try
    let argv = ref argv in
    let current = ref (!Arg.current) in
    Arg.parse_and_expand_argv_dynamic current argv (ref args) anon usage
  with
  | Arg.Bad msg -> Printf.eprintf "%s" msg; exit 2
  | Arg.Help msg -> Printf.printf "%s" msg; exit 0
