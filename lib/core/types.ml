(** Storage implementation.

    The first-class module [(module STORAGE)] is the singleton responsible for {i storing}
    data within the ambient context.

    It is responsible for keeping track of that context in a manner that's consistent with
    the program's choice of control flow paradigm:

    - for synchronous/threaded/direct style code, {b TLS} ("thread local storage") keeps
      track of a global variable per thread. Each thread has its own copy of the variable
      and updates it independently of other threads.

    - for Lwt, any ['a Lwt.t] created inside the [with_binding k v (fun _ -> …)] will
      inherit the [k := v] assignment.

    - for Eio, fibers created inside [with_binding k v (fun () -> …)] will inherit the
      [k := v] assignment. This is consistent with the structured concurrency approach of
      Eio.

    The only data stored by this storage is a {!Hmap.t}, ie a heterogeneous map. Various
    users (libraries, user code, etc.) can create their own {!key} to store what they are
    interested in, without affecting other parts of the storage. *)

module Hmap = Ambient_context_hmap.Hmap

type 'a key = 'a Hmap.key

module type STORAGE = sig
  val name : string
  (** Name of the storage implementation. *)

  val get_map : unit -> Hmap.t option
  (** Get the hmap from the current ambient context, or [None] if there is no ambient
      context. *)

  val with_map : Hmap.t -> (unit -> 'b) -> 'b
  (** [with_hmap h cb] calls [cb()] in an ambient context in which [get_map()] will return
      [h]. Once [cb()] returns, the storage is reset to its previous value. *)

  val create_key : unit -> 'a key
  (** Create a new storage key, guaranteed to be distinct from any previously created key. *)

  val get : 'a key -> 'a option
  val with_binding : 'a key -> 'a -> (unit -> 'b) -> 'b
  val without_binding : 'a key -> (unit -> 'b) -> 'b
end

type storage = (module STORAGE)
