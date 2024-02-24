
module TLS = Thread_local_storage

type 'a t = 'a option TLS.key

let get : 'a t -> 'a option = TLS.get

let[@inline] create () : 'a t = TLS.new_key (fun () -> None) 

let[@inline] get_exn (k:'a t) : 'a = match TLS.get k with
  | None -> raise Not_found
  | Some x -> x

let get_or_create ~create (k:'a t) : 'a = match TLS.get k with
  | None ->
    let v = create () in
    TLS.set k (Some v);
    v
  | Some x -> x

let[@inline] set k x : unit = TLS.set k (Some x)

let[@inline] remove k = TLS.set k None

let with_ k v f =
  let old = get k in
  set k v;
  try
    let res = f old in
    TLS.set k old;
    res
  with e ->
    let bt = Printexc.get_raw_backtrace () in
    TLS.set k old;
    Printexc.raise_with_backtrace e bt
