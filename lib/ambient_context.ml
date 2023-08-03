module TLS = Ambient_context_tls.Thread_local
include Types

type 'a key = 'a Hmap.key

let compare_key = ( - )
let default_storage = Storage_tls.storage ()
let current_storage_key : storage TLS.t = TLS.create ()

let get_current_storage () =
   TLS.get_or_create ~create:(fun () -> default_storage) current_storage_key


let create_key () =
   let (module Store : STORAGE) = get_current_storage () in
   Store.create_key ()


let get k =
   let (module Store : STORAGE) = get_current_storage () in
   Store.get k


let with_binding k v cb =
   let (module Store : STORAGE) = get_current_storage () in
   Store.with_binding k v cb


let without_binding k cb =
   let (module Store : STORAGE) = get_current_storage () in
   Store.without_binding k cb


let with_storage_provider new_storage cb : unit =
   let storage_before = get_current_storage () in
   if new_storage = storage_before then cb ()
   else
     let (module Store : STORAGE) = storage_before in
     if storage_before != default_storage && new_storage != default_storage then
       invalid_arg
         ("ambient-context: storage already configured to be " ^ Store.name
        ^ " on this stack") ;
     try
       let rv = cb () in
       TLS.set current_storage_key storage_before ;
       rv
     with exn ->
       TLS.set current_storage_key storage_before ;
       raise exn
