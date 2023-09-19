module Js = Js_of_ocaml.Js
module Ctx = Ambient_context

let console_log (s : Js.js_string Js.t) : unit =
   Js.Unsafe.fun_call (Js.Unsafe.js_expr "console.log") [| Js.Unsafe.inject s |]


let () =
   Js.Unsafe.global ##. OCAML_AMBIENT_CONTEXT_DEBUG := true ;
   let x = Js.Unsafe.global ##. OCAML_AMBIENT_CONTEXT_DEBUG in
   console_log x ;
   Printf.printf "debug=%b\n" (Js.to_bool x) ;

   Ctx.set_storage_provider (Ambient_context_JSOO_globals.storage ()) ;
   Printf.printf "Hello, World!\n"
