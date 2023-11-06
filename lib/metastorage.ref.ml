include Ambient_context_types

let id = ref 0

let generate_debug_id () =
   incr id ;
   !id


(* TODO: replace with noop store *)
let current_storage : storage option ref = ref None

let get_or_create_current_storage ~create () =
   match !current_storage with
   | Some s -> s
   | None ->
       let s = create () in
       current_storage := Some s ;
       s


let set_current_storage s = current_storage := Some s
