open Alcotest
module Ctx = Ambient_context

let test_create_key () =
   let _k = Ctx.create_key () in
   ()


let test_set_then_get () =
   let k = Ctx.create_key () in
   Ctx.with_binding k "hello" @@ fun () ->
   let v = Ctx.get k in
   check (option string) "retrieve same string" v (Some "hello")


let test_set_then_unset () =
   let k = Ctx.create_key () in
   Ctx.with_binding k "hello" @@ fun () ->
   let v = Ctx.get k in
   check (option string) "retrieve same string" v (Some "hello") ;
   Ctx.without_binding k @@ fun () ->
   let v = Ctx.get k in
   check (option string) "retrieve nothing" v None
