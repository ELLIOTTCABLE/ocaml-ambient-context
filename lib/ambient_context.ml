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
   let storage_before = Atomic_.get storage in
   while
     let cur = Atomic_.get storage in
     let (module Store : STORAGE) = cur in
     if cur != default_storage && new_storage != cur then
       invalid_arg
         ("ambient-context: storage already configured to be " ^ Store.name
        ^ " on this stack")
     else not (Atomic_.compare_and_set storage cur new_storage)
   do
     cb () ;
     while
       let storage_after = Atomic_.get storage in
       not (Atomic_.compare_and_set storage storage_after storage_before)
     do
       ()
     done
   done
