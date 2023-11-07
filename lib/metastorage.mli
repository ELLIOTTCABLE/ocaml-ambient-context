module Types := Ambient_context_types

type 'a t

val create : unit -> 'a t
val get_or_create : create:(unit -> 'a) -> 'a t -> 'a
val set : 'a t -> 'a -> unit

module Monotonic : sig
  type t

  val create : int -> t
  val get : t -> int
  val incr : t -> unit
end
