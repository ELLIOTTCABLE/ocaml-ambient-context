module Types := Ambient_context_types

val generate_debug_id : unit -> int

val get_or_create_current_storage :
  create:(unit -> Types.storage) -> unit -> Types.storage

val set_current_storage : Types.storage -> unit
