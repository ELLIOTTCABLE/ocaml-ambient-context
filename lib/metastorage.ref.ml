type 'a t = 'a option ref

let create () = ref None

let get_or_create ~create t =
   match !t with
   | Some v -> v
   | None ->
       let v = create () in
       t := Some v ;
       v


let set t v = t := Some v

module Monotonic = struct
  type t = int ref

  let create i = ref i
  let get t = !t
  let incr = incr
end
