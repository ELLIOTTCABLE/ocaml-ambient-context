include Ambient_context_types
module TLS = Ambient_context_thread_local.Thread_local
module Atomic = Ambient_context_atomic.Atomic

let id = Atomic.make 0

let generate_debug_id () =
   let prev = Atomic.fetch_and_add id 1 in
   prev + 1


let current_storage_key : storage TLS.t = TLS.create ()

let get_or_create_current_storage ~create () =
   TLS.get_or_create ~create current_storage_key


let set_current_storage = TLS.set current_storage_key
