module Mref = Ambient_context.Metastorage
module Hmap = Ambient_context.Hmap

let ( let* ) = Option.bind

module BoxedInt = struct
  type t = { i : int }
  (** Since we cannot get the GC to track integers, we'll use a trivially-boxed integer as
      a GC-tracked canary. *)

  let equal hi1 hi2 = hi1.i = hi2.i
  let hash t = t.i
end

module WeakIntTbl = Ephemeron.K1.Make (BoxedInt)

let counter = Mref.Monotonic.create 0
let dislocated_store_key : Hmap.t Mref.t = Mref.create ()
let dislocated_store : Hmap.t WeakIntTbl.t = WeakIntTbl.create 50
let _internal_key : BoxedInt.t Lwt.key = Lwt.new_key ()

let debug =
   match Sys.getenv_opt "OCAML_AMBIENT_CONTEXT_DEBUG" with
   | Some ("1" | "true") -> true
   | _ -> false


let next () =
   let open Mref.Monotonic in
   incr counter ;
   BoxedInt.{ i = get counter }


let stats_summary () =
   let Hashtbl.{ num_bindings; num_buckets; max_bucket_length; bucket_histogram = _ } =
      WeakIntTbl.stats_alive dislocated_store
   in
   Printf.sprintf "%i/%i@%i" num_bindings num_buckets max_bucket_length


module M = struct
  let name = "Storage_lwt"

  let get_map () =
     let* id = Lwt.get _internal_key in
     WeakIntTbl.find_opt dislocated_store id


  let with_map m cb =
     let id = next () in
     WeakIntTbl.replace dislocated_store id m ;
     if debug then (
       let i = id.i in
       let finaliser () =
          Printf.printf "%s: GC'd map#%i (%s)\n%!" name i (stats_summary ())
       in
       Printf.printf "%s: with_map map#%i (%s)\n%!" name i (stats_summary ()) ;
       Gc.finalise_last finaliser id) ;
     Lwt.with_value _internal_key (Some id) cb


  let create_key = Hmap.Key.create

  let get k =
     let* context = get_map () in
     Hmap.find k context


  let with_binding k v cb =
     let new_context =
        match get_map () with
        | None -> Hmap.singleton k v
        | Some old_context -> Hmap.add k v old_context
     in
     with_map new_context cb


  let without_binding k cb =
     let new_context =
        match get_map () with
        | None -> Hmap.empty
        | Some old_context -> Hmap.rem k old_context
     in
     with_map new_context cb
end

let storage () : Ambient_context.storage = (module M)
