module Atomic_ = Ambient_context_atomic.Atomic
module TLS = Ambient_context_tls.Thread_local
include Types

type 'a key = 'a Hmap.key

let compare_key = ( - )
let default_storage = Storage_tls.storage ()
let storage : storage Atomic_.t = Atomic_.make default_storage

let create_key () =
   let (module Store : STORAGE) = Atomic_.get storage in
   Store.create_key ()


let get k =
   let (module Store : STORAGE) = Atomic_.get storage in
   Store.get k


let with_binding k v cb =
   let (module Store : STORAGE) = Atomic_.get storage in
   Store.with_binding k v cb


let without_binding k cb =
   let (module Store : STORAGE) = Atomic_.get storage in
   Store.without_binding k cb


let set_storage_during new_storage cb : unit =
   let storage_before = ref @@ Atomic_.get storage in
   while
     let seen = Atomic_.get storage in
     let (module Store : STORAGE) = seen in
     if seen != default_storage && new_storage != seen then
       invalid_arg
         ("ambient-context: storage already configured to be " ^ Store.name
        ^ " on this stack") ;
     let success = Atomic_.compare_and_set storage seen new_storage in
     if success then storage_before := seen ;
     not success
   do
     ()
   done ;
   cb () ;
   let restore = !storage_before in
   while
     let seen = Atomic_.get storage in
     not (Atomic_.compare_and_set storage seen restore)
   do
     ()
   done
