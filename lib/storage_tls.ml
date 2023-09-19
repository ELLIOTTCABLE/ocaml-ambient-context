module TLS = Ambient_context_tls.Thread_local
open Types

let _internal_key : Hmap.t TLS.t = TLS.create ()

let[@inline] ( let* ) o f =
   match o with
   | None -> None
   | Some x -> f x


module M = struct
  let name = "Storage_tls"
  let[@inline] get_map () = TLS.get _internal_key
  let[@inline] with_map m cb = TLS.with_ _internal_key m @@ fun _map -> cb ()
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
     with_map new_context @@ fun _context -> cb ()


  let without_binding k cb =
     let new_context =
        match get_map () with
        | None -> Hmap.empty
        | Some old_context -> Hmap.rem k old_context
     in
     with_map new_context @@ fun _context -> cb ()
end

let storage () : storage = (module M)
