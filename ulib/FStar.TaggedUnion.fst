module FStar.TaggedUnion

module P = FStar.Pointer
module DM = FStar.DependentMap
module HS = FStar.HyperStack
module HST = FStar.HyperStack.ST

(** Code

  The code of a tagged union with fields `l` is `typ l`
*)

let typ_l (l: P.union_typ) =
  P.([("tag", TBase TUInt32); ("union", TUnion l)])

let tag_field (l: P.union_typ) : P.struct_field (typ_l l) = "tag"
let union_field (l: P.union_typ) : P.struct_field (typ_l l) = "union"

let typ (l: P.union_typ) : P.typ = P.TStruct (typ_l l)

(******************************************************************************)

(* Tagging, at the logical level

  `tags l` defines "physical tags" (i.e. integers) for the fields of `l`.
*)

let tags (l: P.union_typ) : Tot Type0 =
  tl: list UInt32.t {
    List.Tot.length tl == List.Tot.length l /\
    List.Tot.noRepeats tl
  }

(* Get a field from its physical tag. *)
let rec field_of_tag
  (#l: P.union_typ)
  (tgs: tags l)
  (t: UInt32.t)
: Pure (P.struct_field l)
  (requires (List.Tot.mem t tgs))
  (ensures (fun _ -> True))
= let ((f, _) :: l') = l in
  let (t' :: tgs') = tgs in
  if t = t' then f
  else (
    assert (Cons? l');
    let ff' : string = field_of_tag #l' tgs' t in
    ff'
  )

(* Get the physical tag corresponding to a field. *)
let rec tag_of_field
  (#l: P.union_typ)
  (tgs: tags l)
  (f: P.struct_field l)
: Pure UInt32.t
  (requires True)
  (ensures (fun t -> List.Tot.mem t tgs))
= let ((f', _) :: l') = l in
  let (t :: tgs') = tgs in
  if f = f' then t
  else (
    assert (Cons? l');
    let ff : string = f in
    tag_of_field #l' tgs' ff
  )

let rec field_of_tag_of_field
  (#l: P.union_typ)
  (tgs: tags l)
  (f: P.struct_field l)
: Lemma (field_of_tag #l tgs (tag_of_field #l tgs f) == f)
  [SMTPat (field_of_tag #l tgs (tag_of_field #l tgs f))]
= let ((f', _) :: l') = l in
  let (t' :: tgs') = tgs in
  if f = f' then ()
  else (
    let ff : string = f in
    field_of_tag_of_field #l' tgs' ff
  )

let rec tag_of_field_of_tag
  (#l: P.union_typ)
  (tgs: tags l)
  (t: UInt32.t)
: Lemma
  (requires (List.Tot.mem t tgs))
  (ensures (
    List.Tot.mem t tgs /\
    tag_of_field #l tgs (field_of_tag #l tgs t) == t
  ))
  [SMTPat (tag_of_field #l tgs (field_of_tag #l tgs t))]
= let ((f', _) :: l') = l in
  let (t' :: tgs') = tgs in
  if t = t' then ()
  else (
    tag_of_field_of_tag #l' tgs' t
  )

(******************************************************************************)

(* Stateful invariant

   `valid h tgs p` states that p points to a tagged union:
   - which physical tag is readable and valid wrt `tgs`
   - which union has an active field corresponding to its physical tag
*)

let valid
  (#l: P.union_typ)
  (h: HS.mem)
  (tgs: tags l)
  (p: P.pointer (typ l))
: GTot Type0
=
  let tag_ptr = P.gfield p (tag_field l) in
  let u_ptr = P.gfield p (union_field l) in
  let t = P.gread h tag_ptr in
  P.readable h tag_ptr /\
  List.Tot.mem t tgs /\
  (let f = field_of_tag #l tgs t in
   P.is_active_union_field h u_ptr f)

let valid_live
  (#l: P.union_typ)
  (h: HS.mem)
  (tgs: tags l)
  (p: P.pointer (typ l))
: Lemma (requires (valid h tgs p))
        (ensures (P.live h p))
  [SMTPat (valid h tgs p)]
= ()

(******************************************************************************)

(* Operations *)

let gread_tag
  (#l: P.union_typ)
  (h: HS.mem)
  (tgs: tags l)
  (p: P.pointer (typ l))
: GTot UInt32.t
= P.gread h (P.gfield p (tag_field l))

let read_tag
  (#l: P.union_typ)
  (tgs: tags l)
  (p: P.pointer (typ l))
: HST.Stack UInt32.t
  (requires (fun h -> valid h tgs p))
  (ensures (fun h0 t h1 ->
    h0 == h1 /\
    List.Tot.mem t tgs /\
    t == gread_tag h0 tgs p))
= P.read (P.field p (tag_field l))


let gfield
  (#l: P.union_typ)
  (tgs: tags l)
  (p: P.pointer (typ l))
  (f: P.struct_field l)
: GTot (p': P.pointer (P.typ_of_struct_field l f) { P.includes p p' })
= P.gufield (P.gfield p (union_field l)) f

let field
  (#l: P.union_typ)
  (tgs: tags l)
  (p: P.pointer (typ l))
  (f: P.struct_field l)
: HST.ST (P.pointer (P.typ_of_struct_field l f))
  (requires (fun h ->
    valid h tgs p /\
    gread_tag h tgs p == tag_of_field tgs f
  ))
  (ensures (fun h0 p' h1 ->
    h0 == h1 /\
    p' == gfield tgs p f
  ))
= P.ufield (P.field p (union_field l)) f

// We could also require the user to manually provide the integer tagged I claim
// it should not be needed since we need to normalise/inline write before
// extraction anyway (check this)
let write
  (#l: P.union_typ)
  (tgs: tags l)
  (p: P.pointer (typ l))
  (f: P.struct_field l)
  (v: P.type_of_typ (P.typ_of_struct_field l f))
: HST.Stack unit
  (requires (fun h ->
    P.live h p
  ))
  (ensures (fun h0 _ h1 ->
    P.live h0 p /\ P.live h1 p /\
    P.modifies_1 p h0 h1 /\
    P.readable h1 p /\
    valid h1 tgs p /\
    gread_tag #l h1 tgs p == tag_of_field tgs f /\
    P.gread h1 (gfield tgs p f) == v
  ))
=
  let tag_ptr = P.field p (tag_field l) in
  let u_ptr = P.field p (union_field l) in
  let t = tag_of_field #l tgs f in
  P.write tag_ptr t;
  let h11 = HST.get () in
  P.write (P.ufield u_ptr f) v;
  let h1 = HST.get () in
  // SMTPats for this lemma do not seem to trigger?
  P.no_upd_lemma_1 h11 h1 u_ptr tag_ptr;
  assert (P.readable h1 tag_ptr);
  assert (P.readable h1 u_ptr);
  P.readable_struct h1 p;
  P.is_active_union_field_intro #l h1 u_ptr f (P.ufield u_ptr f);
  assert (P.is_active_union_field #l h1 u_ptr f)

(******************************************************************************)

(* Lemmas *)

let modifies_1_valid
  (#l: P.union_typ)
  (tgs: tags l)
  (p: P.pointer (typ l))
  (f: P.struct_field l)
  (h0 h1: HS.mem)
  (#t': P.typ)
  (p': P.pointer t')
: Lemma
  (requires (
    valid h0 tgs p /\
    gread_tag h0 tgs p == tag_of_field tgs f /\
    P.modifies_1 (gfield tgs p f) h0 h1 /\
    P.includes (gfield tgs p f) p' /\
    P.readable h1 p'
  ))
  (ensures (valid h1 tgs p))
=
  let u_ptr = P.gfield p (union_field l) in
  P.is_active_union_field_intro h1 u_ptr f p'

(******************************************************************************)

(* Logical representation of a tagged union.
*)

let raw (l: P.union_typ) : Tot Type0 = P.type_of_typ (typ l)

let raw_get_tag (#l: P.union_typ) (tu: raw l)
: Tot UInt32.t
=
  P.struct_sel tu (tag_field l)

let raw_get_field (#l: P.union_typ) (tu: raw l)
: GTot (P.struct_field l)
=
  P.union_get_key #l (P.struct_sel tu (union_field l))

let raw_get_value (#l: P.union_typ) (tu: raw l) (f: P.struct_field l)
: Pure (P.type_of_typ (P.typ_of_struct_field l f))
  (requires (raw_get_field tu == f))
  (ensures (fun _ -> True))
=
  let u : P.union l = P.struct_sel tu (union_field l) in
  P.union_get_value u f

let matching_tags
  (#l: P.union_typ)
  (raw_tu: raw l)
  (tgs: tags l)
: Tot Type
=
  let t = raw_get_tag raw_tu in
  List.Tot.mem t tgs /\
  field_of_tag tgs t == raw_get_field raw_tu


let t (l: P.union_typ) (tgs: tags l) : Tot Type0 =
  tu : raw l { matching_tags tu tgs }

let get_field (#l: P.union_typ) (#tgs: tags l) (tu: t l tgs)
: GTot (P.struct_field l)
=
  raw_get_field tu

let get_tag (#l: P.union_typ) (#tgs: tags l) (tu: t l tgs)
: Pure (t: UInt32.t)
  (requires True)
  (ensures (fun t ->
    List.Tot.mem t tgs /\
    t == tag_of_field tgs (get_field tu)))
=
  raw_get_tag #l tu

let get_value
  (#l: P.union_typ) (#tgs: tags l)
  (tu: t l tgs)
  (f: P.struct_field l)
: Pure (P.type_of_typ (P.typ_of_struct_field l f))
  (requires (get_field tu == f))
  (ensures (fun _ -> True))
=
  raw_get_value #l tu f

(* Lemma: "valid p ==> matching_tags (gread p)" *)

let valid_matching_tags
  (#l: P.union_typ)
  (h: HS.mem)
  (tgs: tags l)
  (p: P.pointer (typ l))
: Lemma
  (requires (valid h tgs p))
  (ensures (matching_tags (P.gread h p) tgs))
  [SMTPatOr [[SMTPat (valid h tgs p)]; [SMTPat (matching_tags (P.gread h p) tgs)]]]
= ()


// Not sure if useful
(*
let read
  (#l: P.union_typ)
  (h: HS.mem)
  (tgs: tags l)
  (p: P.pointer (typ l))
: HST.Stack (t l tgs)
  (requires (fun h ->
    P.live h p /\ P.readable h p /\
    valid h tgs p))
  (ensures (fun h0 tu h1 ->
    h0 == h1 /\
    (let raw_tu : raw l = tu in
     raw_tu == P.gread h0 p)
  ))
= P.read p
*)