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
