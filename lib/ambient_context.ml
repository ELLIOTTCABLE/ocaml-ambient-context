include Ambient_context_types
module Metastorage = Metastorage
module Atomic = Ambient_context_atomic.Atomic

type 'a key = int * 'a Hmap.key

let debug =
   match Sys.getenv_opt "OCAML_AMBIENT_CONTEXT_DEBUG" with
   | Some ("1" | "true") -> true
   | _ -> false


let id = Metastorage.Monotonic.create 0

let generate_debug_id () =
   let open Metastorage.Monotonic in
   incr id ;
   get id


let compare_key : int -> int -> int = Stdlib.compare
let default_storage = Ambient_context_tls.storage ()
let current_storage_key : storage Metastorage.t = Metastorage.create ()

let get_current_storage () =
   Metastorage.get_or_create ~create:(fun () -> default_storage) current_storage_key


let create_key () =
   let (module Store : STORAGE) = get_current_storage () in
   if not debug then (0, Store.create_key ())
   else
     let id = generate_debug_id () in
     Printf.printf "%s: create_key %i\n%!" Store.name id ;
     (id, Store.create_key ())


let get (id, k) =
   let (module Store : STORAGE) = get_current_storage () in
   if not debug then Store.get k
   else
     let rv = Store.get k in
     (match rv with
     | Some _ -> Printf.printf "%s: get %i -> Some\n%!" Store.name id
     | None -> Printf.printf "%s: get %i -> None\n%!" Store.name id) ;
     rv


let with_binding : 'a key -> 'a -> (unit -> 'r) -> 'r =
  fun (id, k) v cb ->
   let (module Store : STORAGE) = get_current_storage () in
   if not debug then Store.with_binding k v cb
   else (
     Printf.printf "%s: with_binding %i enter\n%!" Store.name id ;
     let rv = Store.with_binding k v cb in
     Printf.printf "%s: with_binding %i exit\n%!" Store.name id ;
     rv)


let without_binding (id, k) cb =
   let (module Store : STORAGE) = get_current_storage () in
   if not debug then Store.without_binding k cb
   else (
     Printf.printf "%s: without_binding %i enter\n%!" Store.name id ;
     let rv = Store.without_binding k cb in
     Printf.printf "%s: without_binding %i exit\n%!" Store.name id ;
     rv)


let set_storage_provider store_new =
   let store_before = get_current_storage () in
   if store_new == store_before then () else Metastorage.set current_storage_key store_new ;
   if debug then
     let (module Store_before : STORAGE) = store_before in
     let (module Store_new : STORAGE) = store_new in
     Printf.printf "set_storage_provider %s (previously %s)\n%!" Store_new.name
       Store_before.name
