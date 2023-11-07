open Lwt.Syntax
module Ctx = Ambient_context

let show_option o = Option.value ~default:"<none>" o

let create_leak n =
   let rec aux = function
      | 0 -> Lwt.return_unit
      | i ->
          let promise, _ = Lwt.wait () in
          let bound_promise = Lwt.bind promise (fun _ -> Lwt.return_unit) in
          (* Continue the chaining *)
          Lwt.bind bound_promise (fun () -> aux (i - 1))
   in
   aux n


let test () =
   Ctx.set_storage_provider (Ambient_context_lwt.storage ()) ;
   let k = Ctx.create_key () in

   let setter_sequence =
      (* The set has to happen inside a Lwt context; *)
      let* () = Lwt.return () in
      (* inside which we set the value immediately ... *)
      Printf.printf "[1] set value to 'foo'\n%!" ;
      Ctx.with_binding k "foo" @@ fun () ->
      let* () = Lwt_unix.sleep 1. in

      let* () = create_leak 1 in

      (* ... then, after three seconds, we get the value *inside* the sequence. *)
      let v = Ctx.get k in
      Printf.printf "[1] got value '%s'\n%!" (show_option v) ;
      Lwt.return ()
   in
   let* () = setter_sequence in
   Lwt.return ()


let () =
   let open Printf in
   printf
     "The following test, when executed with OCAML_AMBIENT_CONTEXT_DEBUG=true, should \
      show an empty weakmap at the end\n\n" ;

   failwith
     "NYI: get this test working, at the moment it just hangs *or* doesn't leak. it \
      should leak and not hang." ;
   printf "Gc.full_major ...\n%!" ;
   Gc.full_major () ;

   Lwt_main.run @@ test () ;

   printf "Gc.full_major ...\n%!" ;
   Gc.full_major ()
