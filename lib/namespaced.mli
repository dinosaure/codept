(** Namespaced name, useful for packed module *)

type p = Paths.S.t
type t = { namespace: p; name: Name.t }
type namespaced = t
val pp: t Pp.t
val make: ?nms:p -> Name.t -> t
val flatten: t -> p
val of_path: p -> t

val of_filename: t -> t

module Map: sig
  include Map.S with type key = t
  val find_opt: namespaced -> 'a t -> 'a option 
end           
module Set: Set.S with type elt = t
