module Hmap = Ambient_context_hmap.Hmap

let global_store = ref Hmap.empty
let ( let* ) = Option.bind

module M = struct
  let name = "Storage_JSOO_globals"
  let[@inline] get_map () = Some !global_store

  let[@inline] with_map m cb =
     let store_before = !global_store in

     global_store := m ;
     let result = cb () in

     global_store := store_before ;
     result


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

let storage () : Ambient_context_core.Types.storage = (module M)
