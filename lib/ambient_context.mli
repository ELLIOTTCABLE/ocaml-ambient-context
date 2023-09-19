
(** Ambient context.

    The ambient context, like the Matrix, is everywhere around you *)

module Types := Ambient_context_core.Types
module type STORAGE = Types.STORAGE

module Hmap = Ambient_context_hmap.Hmap

type storage = (module STORAGE)

val default_storage : Types.storage
val get_current_storage : unit -> Types.storage
val set_storage_provider : Types.storage -> unit

type 'a key
(** A key that can be mapped to values of type ['a] in the ambient context. *)

val compare_key : int -> int -> int
(** Total order on keys *)

val create_key : unit -> 'a key
(** Create a new fresh key, distinct from any previously created key. *)

val get : 'a key -> 'a option
(** Get the current value for a given key, or [None] if no value was associated with the
    key in the ambient context. *)

val with_binding : 'a key -> 'a -> (unit -> 'r) -> 'r
(** [without_binding k v cb] calls [cb()] in a context in which [k] is bound to [v]. When
    [cb()] returns, storage is restored to its previous state. *)

val without_binding : 'a key -> (unit -> 'b) -> 'b
(** [without_binding k cb] calls [cb()] in a context where [k] has no binding (possibly
    shadowing the current ambient binding of [k] if it exists). *)
