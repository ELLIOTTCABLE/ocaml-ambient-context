include Ambient_context_thread_local.Thread_local

module Monotonic = struct
  module Atomic = Ambient_context_atomic.Atomic

  type t = int Atomic.t

  let create = Atomic.make
  let get = Atomic.get
  let incr = Atomic.incr
end
