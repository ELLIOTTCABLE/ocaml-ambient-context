module type STORAGE = Types.STORAGE

type storage = (module STORAGE)

val default_storage : Types.storage
val get_current_storage : unit -> Types.storage
val with_storage_provider : Types.storage -> (unit -> unit) -> unit

type 'a key

val compare_key : int -> int -> int
val create_key : unit -> 'a key
val get : 'a key -> 'a option
val with_binding : 'a key -> 'a -> (unit -> 'r) -> 'r
val without_binding : 'a key -> (unit -> 'b) -> 'b
