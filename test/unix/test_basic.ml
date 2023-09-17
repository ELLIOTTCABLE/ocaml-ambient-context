open Alcotest

let test_create_key () =
   let _k = Ambient_context.create_key () in
   ()


let test_set_then_get () =
   let k = Ambient_context.create_key () in
   Ambient_context.with_binding k "hello" @@ fun () ->
   let v = Ambient_context.get k in
   check (option string) "retrieve same string" v (Some "hello")


let test_set_then_unset () =
   let k = Ambient_context.create_key () in
   Ambient_context.with_binding k "hello" @@ fun () ->
   let v = Ambient_context.get k in
   check (option string) "retrieve same string" v (Some "hello") ;
   Ambient_context.without_binding k @@ fun () ->
   let v = Ambient_context.get k in
   check (option string) "retrieve nothing" v None


let suite =
   [
     ("can create keys", `Quick, test_create_key);
     ("can set, and get, keys", `Quick, test_set_then_get);
     ("can unset keys", `Quick, test_set_then_unset);
   ]


let () = Alcotest.run "Dummy" [ ("Greeting", suite) ]
