open Prims
type mlsymbol = Prims.string
type mlident = (mlsymbol * Prims.int)
type mlpath = (mlsymbol Prims.list * mlsymbol)
let ocamlkeywords : Prims.string Prims.list =
  ["and";
  "as";
  "assert";
  "asr";
  "begin";
  "class";
  "constraint";
  "do";
  "done";
  "downto";
  "else";
  "end";
  "exception";
  "external";
  "false";
  "for";
  "fun";
  "function";
  "functor";
  "if";
  "in";
  "include";
  "inherit";
  "initializer";
  "land";
  "lazy";
  "let";
  "lor";
  "lsl";
  "lsr";
  "lxor";
  "match";
  "method";
  "mod";
  "module";
  "mutable";
  "new";
  "object";
  "of";
  "open";
  "or";
  "private";
  "rec";
  "sig";
  "struct";
  "then";
  "to";
  "true";
  "try";
  "type";
  "val";
  "virtual";
  "when";
  "while";
  "with";
  "nonrec"] 
let is_reserved : Prims.string -> Prims.bool =
  fun k  -> FStar_List.existsb (fun k'  -> k' = k) ocamlkeywords 
let idsym : mlident -> mlsymbol =
  fun uu____15  -> match uu____15 with | (s,uu____17) -> s 
let string_of_mlpath : mlpath -> mlsymbol =
  fun uu____21  ->
    match uu____21 with
    | (p,s) -> FStar_String.concat "." (FStar_List.append p [s])
  
type gensym_t =
  {
  gensym: Prims.unit -> mlident ;
  reset: Prims.unit -> Prims.unit }
let __proj__Mkgensym_t__item__gensym : gensym_t -> Prims.unit -> mlident =
  fun projectee  ->
    match projectee with
    | { gensym = __fname__gensym; reset = __fname__reset;_} ->
        __fname__gensym
  
let __proj__Mkgensym_t__item__reset : gensym_t -> Prims.unit -> Prims.unit =
  fun projectee  ->
    match projectee with
    | { gensym = __fname__gensym; reset = __fname__reset;_} -> __fname__reset
  
let gs : gensym_t =
  let ctr = FStar_Util.mk_ref (Prims.parse_int "0")  in
  let n_resets = FStar_Util.mk_ref (Prims.parse_int "0")  in
  {
    gensym =
      (fun uu____78  ->
         FStar_Util.incr ctr;
         (let uu____83 =
            let uu____84 =
              let uu____85 =
                let uu____86 = FStar_ST.read n_resets  in
                FStar_Util.string_of_int uu____86  in
              let uu____89 =
                let uu____90 =
                  let uu____91 = FStar_ST.read ctr  in
                  FStar_Util.string_of_int uu____91  in
                Prims.strcat "_" uu____90  in
              Prims.strcat uu____85 uu____89  in
            Prims.strcat "_" uu____84  in
          (uu____83, (Prims.parse_int "0"))));
    reset =
      (fun uu____94  ->
         FStar_ST.write ctr (Prims.parse_int "0"); FStar_Util.incr n_resets)
  } 
let gensym : Prims.unit -> mlident = fun uu____104  -> gs.gensym () 
let reset_gensym : Prims.unit -> Prims.unit = fun uu____108  -> gs.reset () 
let rec gensyms : Prims.int -> mlident Prims.list =
  fun x  ->
    match x with
    | _0_39 when _0_39 = (Prims.parse_int "0") -> []
    | n1 ->
        let uu____116 = gensym ()  in
        let uu____117 = gensyms (n1 - (Prims.parse_int "1"))  in uu____116 ::
          uu____117
  
let mlpath_of_lident :
  FStar_Ident.lident -> (Prims.string Prims.list * Prims.string) =
  fun x  ->
    if FStar_Ident.lid_equals x FStar_Syntax_Const.failwith_lid
    then ([], ((x.FStar_Ident.ident).FStar_Ident.idText))
    else
      (let uu____125 =
         FStar_List.map (fun x1  -> x1.FStar_Ident.idText) x.FStar_Ident.ns
          in
       (uu____125, ((x.FStar_Ident.ident).FStar_Ident.idText)))
  
type mlidents = mlident Prims.list
type mlsymbols = mlsymbol Prims.list
type e_tag =
  | E_PURE 
  | E_GHOST 
  | E_IMPURE 
let uu___is_E_PURE : e_tag -> Prims.bool =
  fun projectee  ->
    match projectee with | E_PURE  -> true | uu____135 -> false
  
let uu___is_E_GHOST : e_tag -> Prims.bool =
  fun projectee  ->
    match projectee with | E_GHOST  -> true | uu____140 -> false
  
let uu___is_E_IMPURE : e_tag -> Prims.bool =
  fun projectee  ->
    match projectee with | E_IMPURE  -> true | uu____145 -> false
  
type mlloc = (Prims.int * Prims.string)
let dummy_loc : (Prims.int * Prims.string) = ((Prims.parse_int "0"), "") 
type mlty =
  | MLTY_Var of mlident 
  | MLTY_Fun of (mlty * e_tag * mlty) 
  | MLTY_Named of (mlty Prims.list * mlpath) 
  | MLTY_Tuple of mlty Prims.list 
  | MLTY_Top 
let uu___is_MLTY_Var : mlty -> Prims.bool =
  fun projectee  ->
    match projectee with | MLTY_Var _0 -> true | uu____178 -> false
  
let __proj__MLTY_Var__item___0 : mlty -> mlident =
  fun projectee  -> match projectee with | MLTY_Var _0 -> _0 
let uu___is_MLTY_Fun : mlty -> Prims.bool =
  fun projectee  ->
    match projectee with | MLTY_Fun _0 -> true | uu____195 -> false
  
let __proj__MLTY_Fun__item___0 : mlty -> (mlty * e_tag * mlty) =
  fun projectee  -> match projectee with | MLTY_Fun _0 -> _0 
let uu___is_MLTY_Named : mlty -> Prims.bool =
  fun projectee  ->
    match projectee with | MLTY_Named _0 -> true | uu____221 -> false
  
let __proj__MLTY_Named__item___0 : mlty -> (mlty Prims.list * mlpath) =
  fun projectee  -> match projectee with | MLTY_Named _0 -> _0 
let uu___is_MLTY_Tuple : mlty -> Prims.bool =
  fun projectee  ->
    match projectee with | MLTY_Tuple _0 -> true | uu____245 -> false
  
let __proj__MLTY_Tuple__item___0 : mlty -> mlty Prims.list =
  fun projectee  -> match projectee with | MLTY_Tuple _0 -> _0 
let uu___is_MLTY_Top : mlty -> Prims.bool =
  fun projectee  ->
    match projectee with | MLTY_Top  -> true | uu____261 -> false
  
type mltyscheme = (mlidents * mlty)
type mlconstant =
  | MLC_Unit 
  | MLC_Bool of Prims.bool 
  | MLC_Int of (Prims.string * (FStar_Const.signedness * FStar_Const.width)
  option) 
  | MLC_Float of FStar_BaseTypes.float 
  | MLC_Char of FStar_BaseTypes.char 
  | MLC_String of Prims.string 
  | MLC_Bytes of FStar_BaseTypes.byte Prims.array 
let uu___is_MLC_Unit : mlconstant -> Prims.bool =
  fun projectee  ->
    match projectee with | MLC_Unit  -> true | uu____298 -> false
  
let uu___is_MLC_Bool : mlconstant -> Prims.bool =
  fun projectee  ->
    match projectee with | MLC_Bool _0 -> true | uu____304 -> false
  
let __proj__MLC_Bool__item___0 : mlconstant -> Prims.bool =
  fun projectee  -> match projectee with | MLC_Bool _0 -> _0 
let uu___is_MLC_Int : mlconstant -> Prims.bool =
  fun projectee  ->
    match projectee with | MLC_Int _0 -> true | uu____323 -> false
  
let __proj__MLC_Int__item___0 :
  mlconstant ->
    (Prims.string * (FStar_Const.signedness * FStar_Const.width) option)
  = fun projectee  -> match projectee with | MLC_Int _0 -> _0 
let uu___is_MLC_Float : mlconstant -> Prims.bool =
  fun projectee  ->
    match projectee with | MLC_Float _0 -> true | uu____352 -> false
  
let __proj__MLC_Float__item___0 : mlconstant -> FStar_BaseTypes.float =
  fun projectee  -> match projectee with | MLC_Float _0 -> _0 
let uu___is_MLC_Char : mlconstant -> Prims.bool =
  fun projectee  ->
    match projectee with | MLC_Char _0 -> true | uu____366 -> false
  
let __proj__MLC_Char__item___0 : mlconstant -> FStar_BaseTypes.char =
  fun projectee  -> match projectee with | MLC_Char _0 -> _0 
let uu___is_MLC_String : mlconstant -> Prims.bool =
  fun projectee  ->
    match projectee with | MLC_String _0 -> true | uu____380 -> false
  
let __proj__MLC_String__item___0 : mlconstant -> Prims.string =
  fun projectee  -> match projectee with | MLC_String _0 -> _0 
let uu___is_MLC_Bytes : mlconstant -> Prims.bool =
  fun projectee  ->
    match projectee with | MLC_Bytes _0 -> true | uu____395 -> false
  
let __proj__MLC_Bytes__item___0 :
  mlconstant -> FStar_BaseTypes.byte Prims.array =
  fun projectee  -> match projectee with | MLC_Bytes _0 -> _0 
type mlpattern =
  | MLP_Wild 
  | MLP_Const of mlconstant 
  | MLP_Var of mlident 
  | MLP_CTor of (mlpath * mlpattern Prims.list) 
  | MLP_Branch of mlpattern Prims.list 
  | MLP_Record of (mlsymbol Prims.list * (mlsymbol * mlpattern) Prims.list) 
  | MLP_Tuple of mlpattern Prims.list 
let uu___is_MLP_Wild : mlpattern -> Prims.bool =
  fun projectee  ->
    match projectee with | MLP_Wild  -> true | uu____446 -> false
  
let uu___is_MLP_Const : mlpattern -> Prims.bool =
  fun projectee  ->
    match projectee with | MLP_Const _0 -> true | uu____452 -> false
  
let __proj__MLP_Const__item___0 : mlpattern -> mlconstant =
  fun projectee  -> match projectee with | MLP_Const _0 -> _0 
let uu___is_MLP_Var : mlpattern -> Prims.bool =
  fun projectee  ->
    match projectee with | MLP_Var _0 -> true | uu____466 -> false
  
let __proj__MLP_Var__item___0 : mlpattern -> mlident =
  fun projectee  -> match projectee with | MLP_Var _0 -> _0 
let uu___is_MLP_CTor : mlpattern -> Prims.bool =
  fun projectee  ->
    match projectee with | MLP_CTor _0 -> true | uu____483 -> false
  
let __proj__MLP_CTor__item___0 : mlpattern -> (mlpath * mlpattern Prims.list)
  = fun projectee  -> match projectee with | MLP_CTor _0 -> _0 
let uu___is_MLP_Branch : mlpattern -> Prims.bool =
  fun projectee  ->
    match projectee with | MLP_Branch _0 -> true | uu____507 -> false
  
let __proj__MLP_Branch__item___0 : mlpattern -> mlpattern Prims.list =
  fun projectee  -> match projectee with | MLP_Branch _0 -> _0 
let uu___is_MLP_Record : mlpattern -> Prims.bool =
  fun projectee  ->
    match projectee with | MLP_Record _0 -> true | uu____530 -> false
  
let __proj__MLP_Record__item___0 :
  mlpattern -> (mlsymbol Prims.list * (mlsymbol * mlpattern) Prims.list) =
  fun projectee  -> match projectee with | MLP_Record _0 -> _0 
let uu___is_MLP_Tuple : mlpattern -> Prims.bool =
  fun projectee  ->
    match projectee with | MLP_Tuple _0 -> true | uu____563 -> false
  
let __proj__MLP_Tuple__item___0 : mlpattern -> mlpattern Prims.list =
  fun projectee  -> match projectee with | MLP_Tuple _0 -> _0 
type c_flag =
  | Mutable 
  | Assumed 
  | Private 
  | NoExtract 
  | Attribute of Prims.string 
let uu___is_Mutable : c_flag -> Prims.bool =
  fun projectee  ->
    match projectee with | Mutable  -> true | uu____583 -> false
  
let uu___is_Assumed : c_flag -> Prims.bool =
  fun projectee  ->
    match projectee with | Assumed  -> true | uu____588 -> false
  
let uu___is_Private : c_flag -> Prims.bool =
  fun projectee  ->
    match projectee with | Private  -> true | uu____593 -> false
  
let uu___is_NoExtract : c_flag -> Prims.bool =
  fun projectee  ->
    match projectee with | NoExtract  -> true | uu____598 -> false
  
let uu___is_Attribute : c_flag -> Prims.bool =
  fun projectee  ->
    match projectee with | Attribute _0 -> true | uu____604 -> false
  
let __proj__Attribute__item___0 : c_flag -> Prims.string =
  fun projectee  -> match projectee with | Attribute _0 -> _0 
type tyattr =
  | PpxDeriving 
  | PpxDerivingConstant of Prims.string 
let uu___is_PpxDeriving : tyattr -> Prims.bool =
  fun projectee  ->
    match projectee with | PpxDeriving  -> true | uu____621 -> false
  
let uu___is_PpxDerivingConstant : tyattr -> Prims.bool =
  fun projectee  ->
    match projectee with
    | PpxDerivingConstant _0 -> true
    | uu____627 -> false
  
let __proj__PpxDerivingConstant__item___0 : tyattr -> Prims.string =
  fun projectee  -> match projectee with | PpxDerivingConstant _0 -> _0 
type tyattrs = tyattr Prims.list
type mlletflavor =
  | Rec 
  | NonRec 
let uu___is_Rec : mlletflavor -> Prims.bool =
  fun projectee  -> match projectee with | Rec  -> true | uu____641 -> false 
let uu___is_NonRec : mlletflavor -> Prims.bool =
  fun projectee  ->
    match projectee with | NonRec  -> true | uu____646 -> false
  
type c_flags = c_flag Prims.list
type mlexpr' =
  | MLE_Const of mlconstant 
  | MLE_Var of mlident 
  | MLE_Name of mlpath 
  | MLE_Let of ((mlletflavor * c_flags * mllb Prims.list) * mlexpr) 
  | MLE_App of (mlexpr * mlexpr Prims.list) 
  | MLE_Fun of ((mlident * mlty) Prims.list * mlexpr) 
  | MLE_Match of (mlexpr * (mlpattern * mlexpr option * mlexpr) Prims.list) 
  | MLE_Coerce of (mlexpr * mlty * mlty) 
  | MLE_CTor of (mlpath * mlexpr Prims.list) 
  | MLE_Seq of mlexpr Prims.list 
  | MLE_Tuple of mlexpr Prims.list 
  | MLE_Record of (mlsymbol Prims.list * (mlsymbol * mlexpr) Prims.list) 
  | MLE_Proj of (mlexpr * mlpath) 
  | MLE_If of (mlexpr * mlexpr * mlexpr option) 
  | MLE_Raise of (mlpath * mlexpr Prims.list) 
  | MLE_Try of (mlexpr * (mlpattern * mlexpr option * mlexpr) Prims.list) 
and mlexpr = {
  expr: mlexpr' ;
  mlty: mlty ;
  loc: mlloc }
and mllb =
  {
  mllb_name: mlident ;
  mllb_tysc: mltyscheme option ;
  mllb_add_unit: Prims.bool ;
  mllb_def: mlexpr ;
  print_typ: Prims.bool }
let uu___is_MLE_Const : mlexpr' -> Prims.bool =
  fun projectee  ->
    match projectee with | MLE_Const _0 -> true | uu____801 -> false
  
let __proj__MLE_Const__item___0 : mlexpr' -> mlconstant =
  fun projectee  -> match projectee with | MLE_Const _0 -> _0 
let uu___is_MLE_Var : mlexpr' -> Prims.bool =
  fun projectee  ->
    match projectee with | MLE_Var _0 -> true | uu____815 -> false
  
let __proj__MLE_Var__item___0 : mlexpr' -> mlident =
  fun projectee  -> match projectee with | MLE_Var _0 -> _0 
let uu___is_MLE_Name : mlexpr' -> Prims.bool =
  fun projectee  ->
    match projectee with | MLE_Name _0 -> true | uu____829 -> false
  
let __proj__MLE_Name__item___0 : mlexpr' -> mlpath =
  fun projectee  -> match projectee with | MLE_Name _0 -> _0 
let uu___is_MLE_Let : mlexpr' -> Prims.bool =
  fun projectee  ->
    match projectee with | MLE_Let _0 -> true | uu____849 -> false
  
let __proj__MLE_Let__item___0 :
  mlexpr' -> ((mlletflavor * c_flags * mllb Prims.list) * mlexpr) =
  fun projectee  -> match projectee with | MLE_Let _0 -> _0 
let uu___is_MLE_App : mlexpr' -> Prims.bool =
  fun projectee  ->
    match projectee with | MLE_App _0 -> true | uu____884 -> false
  
let __proj__MLE_App__item___0 : mlexpr' -> (mlexpr * mlexpr Prims.list) =
  fun projectee  -> match projectee with | MLE_App _0 -> _0 
let uu___is_MLE_Fun : mlexpr' -> Prims.bool =
  fun projectee  ->
    match projectee with | MLE_Fun _0 -> true | uu____912 -> false
  
let __proj__MLE_Fun__item___0 :
  mlexpr' -> ((mlident * mlty) Prims.list * mlexpr) =
  fun projectee  -> match projectee with | MLE_Fun _0 -> _0 
let uu___is_MLE_Match : mlexpr' -> Prims.bool =
  fun projectee  ->
    match projectee with | MLE_Match _0 -> true | uu____948 -> false
  
let __proj__MLE_Match__item___0 :
  mlexpr' -> (mlexpr * (mlpattern * mlexpr option * mlexpr) Prims.list) =
  fun projectee  -> match projectee with | MLE_Match _0 -> _0 
let uu___is_MLE_Coerce : mlexpr' -> Prims.bool =
  fun projectee  ->
    match projectee with | MLE_Coerce _0 -> true | uu____986 -> false
  
let __proj__MLE_Coerce__item___0 : mlexpr' -> (mlexpr * mlty * mlty) =
  fun projectee  -> match projectee with | MLE_Coerce _0 -> _0 
let uu___is_MLE_CTor : mlexpr' -> Prims.bool =
  fun projectee  ->
    match projectee with | MLE_CTor _0 -> true | uu____1012 -> false
  
let __proj__MLE_CTor__item___0 : mlexpr' -> (mlpath * mlexpr Prims.list) =
  fun projectee  -> match projectee with | MLE_CTor _0 -> _0 
let uu___is_MLE_Seq : mlexpr' -> Prims.bool =
  fun projectee  ->
    match projectee with | MLE_Seq _0 -> true | uu____1036 -> false
  
let __proj__MLE_Seq__item___0 : mlexpr' -> mlexpr Prims.list =
  fun projectee  -> match projectee with | MLE_Seq _0 -> _0 
let uu___is_MLE_Tuple : mlexpr' -> Prims.bool =
  fun projectee  ->
    match projectee with | MLE_Tuple _0 -> true | uu____1054 -> false
  
let __proj__MLE_Tuple__item___0 : mlexpr' -> mlexpr Prims.list =
  fun projectee  -> match projectee with | MLE_Tuple _0 -> _0 
let uu___is_MLE_Record : mlexpr' -> Prims.bool =
  fun projectee  ->
    match projectee with | MLE_Record _0 -> true | uu____1077 -> false
  
let __proj__MLE_Record__item___0 :
  mlexpr' -> (mlsymbol Prims.list * (mlsymbol * mlexpr) Prims.list) =
  fun projectee  -> match projectee with | MLE_Record _0 -> _0 
let uu___is_MLE_Proj : mlexpr' -> Prims.bool =
  fun projectee  ->
    match projectee with | MLE_Proj _0 -> true | uu____1111 -> false
  
let __proj__MLE_Proj__item___0 : mlexpr' -> (mlexpr * mlpath) =
  fun projectee  -> match projectee with | MLE_Proj _0 -> _0 
let uu___is_MLE_If : mlexpr' -> Prims.bool =
  fun projectee  ->
    match projectee with | MLE_If _0 -> true | uu____1135 -> false
  
let __proj__MLE_If__item___0 : mlexpr' -> (mlexpr * mlexpr * mlexpr option) =
  fun projectee  -> match projectee with | MLE_If _0 -> _0 
let uu___is_MLE_Raise : mlexpr' -> Prims.bool =
  fun projectee  ->
    match projectee with | MLE_Raise _0 -> true | uu____1164 -> false
  
let __proj__MLE_Raise__item___0 : mlexpr' -> (mlpath * mlexpr Prims.list) =
  fun projectee  -> match projectee with | MLE_Raise _0 -> _0 
let uu___is_MLE_Try : mlexpr' -> Prims.bool =
  fun projectee  ->
    match projectee with | MLE_Try _0 -> true | uu____1194 -> false
  
let __proj__MLE_Try__item___0 :
  mlexpr' -> (mlexpr * (mlpattern * mlexpr option * mlexpr) Prims.list) =
  fun projectee  -> match projectee with | MLE_Try _0 -> _0 
let __proj__Mkmlexpr__item__expr : mlexpr -> mlexpr' =
  fun projectee  ->
    match projectee with
    | { expr = __fname__expr; mlty = __fname__mlty; loc = __fname__loc;_} ->
        __fname__expr
  
let __proj__Mkmlexpr__item__mlty : mlexpr -> mlty =
  fun projectee  ->
    match projectee with
    | { expr = __fname__expr; mlty = __fname__mlty; loc = __fname__loc;_} ->
        __fname__mlty
  
let __proj__Mkmlexpr__item__loc : mlexpr -> mlloc =
  fun projectee  ->
    match projectee with
    | { expr = __fname__expr; mlty = __fname__mlty; loc = __fname__loc;_} ->
        __fname__loc
  
let __proj__Mkmllb__item__mllb_name : mllb -> mlident =
  fun projectee  ->
    match projectee with
    | { mllb_name = __fname__mllb_name; mllb_tysc = __fname__mllb_tysc;
        mllb_add_unit = __fname__mllb_add_unit; mllb_def = __fname__mllb_def;
        print_typ = __fname__print_typ;_} -> __fname__mllb_name
  
let __proj__Mkmllb__item__mllb_tysc : mllb -> mltyscheme option =
  fun projectee  ->
    match projectee with
    | { mllb_name = __fname__mllb_name; mllb_tysc = __fname__mllb_tysc;
        mllb_add_unit = __fname__mllb_add_unit; mllb_def = __fname__mllb_def;
        print_typ = __fname__print_typ;_} -> __fname__mllb_tysc
  
let __proj__Mkmllb__item__mllb_add_unit : mllb -> Prims.bool =
  fun projectee  ->
    match projectee with
    | { mllb_name = __fname__mllb_name; mllb_tysc = __fname__mllb_tysc;
        mllb_add_unit = __fname__mllb_add_unit; mllb_def = __fname__mllb_def;
        print_typ = __fname__print_typ;_} -> __fname__mllb_add_unit
  
let __proj__Mkmllb__item__mllb_def : mllb -> mlexpr =
  fun projectee  ->
    match projectee with
    | { mllb_name = __fname__mllb_name; mllb_tysc = __fname__mllb_tysc;
        mllb_add_unit = __fname__mllb_add_unit; mllb_def = __fname__mllb_def;
        print_typ = __fname__print_typ;_} -> __fname__mllb_def
  
let __proj__Mkmllb__item__print_typ : mllb -> Prims.bool =
  fun projectee  ->
    match projectee with
    | { mllb_name = __fname__mllb_name; mllb_tysc = __fname__mllb_tysc;
        mllb_add_unit = __fname__mllb_add_unit; mllb_def = __fname__mllb_def;
        print_typ = __fname__print_typ;_} -> __fname__print_typ
  
type mlbranch = (mlpattern * mlexpr option * mlexpr)
type mlletbinding = (mlletflavor * c_flags * mllb Prims.list)
type mltybody =
  | MLTD_Abbrev of mlty 
  | MLTD_Record of (mlsymbol * mlty) Prims.list 
  | MLTD_DType of (mlsymbol * (mlsymbol * mlty) Prims.list) Prims.list 
let uu___is_MLTD_Abbrev : mltybody -> Prims.bool =
  fun projectee  ->
    match projectee with | MLTD_Abbrev _0 -> true | uu____1331 -> false
  
let __proj__MLTD_Abbrev__item___0 : mltybody -> mlty =
  fun projectee  -> match projectee with | MLTD_Abbrev _0 -> _0 
let uu___is_MLTD_Record : mltybody -> Prims.bool =
  fun projectee  ->
    match projectee with | MLTD_Record _0 -> true | uu____1348 -> false
  
let __proj__MLTD_Record__item___0 : mltybody -> (mlsymbol * mlty) Prims.list
  = fun projectee  -> match projectee with | MLTD_Record _0 -> _0 
let uu___is_MLTD_DType : mltybody -> Prims.bool =
  fun projectee  ->
    match projectee with | MLTD_DType _0 -> true | uu____1377 -> false
  
let __proj__MLTD_DType__item___0 :
  mltybody -> (mlsymbol * (mlsymbol * mlty) Prims.list) Prims.list =
  fun projectee  -> match projectee with | MLTD_DType _0 -> _0 
type one_mltydecl =
  (Prims.bool * mlsymbol * mlsymbol option * mlidents * tyattrs * mltybody
    option)
type mltydecl = one_mltydecl Prims.list
type mlmodule1 =
  | MLM_Ty of mltydecl 
  | MLM_Let of mlletbinding 
  | MLM_Exn of (mlsymbol * (mlsymbol * mlty) Prims.list) 
  | MLM_Top of mlexpr 
  | MLM_Loc of mlloc 
let uu___is_MLM_Ty : mlmodule1 -> Prims.bool =
  fun projectee  ->
    match projectee with | MLM_Ty _0 -> true | uu____1443 -> false
  
let __proj__MLM_Ty__item___0 : mlmodule1 -> mltydecl =
  fun projectee  -> match projectee with | MLM_Ty _0 -> _0 
let uu___is_MLM_Let : mlmodule1 -> Prims.bool =
  fun projectee  ->
    match projectee with | MLM_Let _0 -> true | uu____1457 -> false
  
let __proj__MLM_Let__item___0 : mlmodule1 -> mlletbinding =
  fun projectee  -> match projectee with | MLM_Let _0 -> _0 
let uu___is_MLM_Exn : mlmodule1 -> Prims.bool =
  fun projectee  ->
    match projectee with | MLM_Exn _0 -> true | uu____1476 -> false
  
let __proj__MLM_Exn__item___0 :
  mlmodule1 -> (mlsymbol * (mlsymbol * mlty) Prims.list) =
  fun projectee  -> match projectee with | MLM_Exn _0 -> _0 
let uu___is_MLM_Top : mlmodule1 -> Prims.bool =
  fun projectee  ->
    match projectee with | MLM_Top _0 -> true | uu____1505 -> false
  
let __proj__MLM_Top__item___0 : mlmodule1 -> mlexpr =
  fun projectee  -> match projectee with | MLM_Top _0 -> _0 
let uu___is_MLM_Loc : mlmodule1 -> Prims.bool =
  fun projectee  ->
    match projectee with | MLM_Loc _0 -> true | uu____1519 -> false
  
let __proj__MLM_Loc__item___0 : mlmodule1 -> mlloc =
  fun projectee  -> match projectee with | MLM_Loc _0 -> _0 
type mlmodule = mlmodule1 Prims.list
type mlsig1 =
  | MLS_Mod of (mlsymbol * mlsig1 Prims.list) 
  | MLS_Ty of mltydecl 
  | MLS_Val of (mlsymbol * mltyscheme) 
  | MLS_Exn of (mlsymbol * mlty Prims.list) 
let uu___is_MLS_Mod : mlsig1 -> Prims.bool =
  fun projectee  ->
    match projectee with | MLS_Mod _0 -> true | uu____1561 -> false
  
let __proj__MLS_Mod__item___0 : mlsig1 -> (mlsymbol * mlsig1 Prims.list) =
  fun projectee  -> match projectee with | MLS_Mod _0 -> _0 
let uu___is_MLS_Ty : mlsig1 -> Prims.bool =
  fun projectee  ->
    match projectee with | MLS_Ty _0 -> true | uu____1584 -> false
  
let __proj__MLS_Ty__item___0 : mlsig1 -> mltydecl =
  fun projectee  -> match projectee with | MLS_Ty _0 -> _0 
let uu___is_MLS_Val : mlsig1 -> Prims.bool =
  fun projectee  ->
    match projectee with | MLS_Val _0 -> true | uu____1600 -> false
  
let __proj__MLS_Val__item___0 : mlsig1 -> (mlsymbol * mltyscheme) =
  fun projectee  -> match projectee with | MLS_Val _0 -> _0 
let uu___is_MLS_Exn : mlsig1 -> Prims.bool =
  fun projectee  ->
    match projectee with | MLS_Exn _0 -> true | uu____1623 -> false
  
let __proj__MLS_Exn__item___0 : mlsig1 -> (mlsymbol * mlty Prims.list) =
  fun projectee  -> match projectee with | MLS_Exn _0 -> _0 
type mlsig = mlsig1 Prims.list
let with_ty_loc : mlty -> mlexpr' -> mlloc -> mlexpr =
  fun t  -> fun e  -> fun l  -> { expr = e; mlty = t; loc = l } 
let with_ty : mlty -> mlexpr' -> mlexpr =
  fun t  -> fun e  -> with_ty_loc t e dummy_loc 
type mllib =
  | MLLib of (mlpath * (mlsig * mlmodule) option * mllib) Prims.list 
let uu___is_MLLib : mllib -> Prims.bool = fun projectee  -> true 
let __proj__MLLib__item___0 :
  mllib -> (mlpath * (mlsig * mlmodule) option * mllib) Prims.list =
  fun projectee  -> match projectee with | MLLib _0 -> _0 
let ml_unit_ty : mlty = MLTY_Named ([], (["Prims"], "unit")) 
let ml_bool_ty : mlty = MLTY_Named ([], (["Prims"], "bool")) 
let ml_int_ty : mlty = MLTY_Named ([], (["Prims"], "int")) 
let ml_string_ty : mlty = MLTY_Named ([], (["Prims"], "string")) 
let ml_unit : mlexpr = with_ty ml_unit_ty (MLE_Const MLC_Unit) 
let mlp_lalloc : (Prims.string Prims.list * Prims.string) =
  (["SST"], "lalloc") 
let apply_obj_repr : mlexpr -> mlty -> mlexpr =
  fun x  ->
    fun t  ->
      let obj_repr =
        with_ty (MLTY_Fun (t, E_PURE, MLTY_Top)) (MLE_Name (["Obj"], "repr"))
         in
      with_ty_loc MLTY_Top (MLE_App (obj_repr, [x])) x.loc
  
let avoid_keyword : Prims.string -> Prims.string =
  fun s  -> if is_reserved s then Prims.strcat s "_" else s 
let bv_as_mlident : FStar_Syntax_Syntax.bv -> mlident =
  fun x  ->
    let uu____1747 =
      ((FStar_Util.starts_with
          (x.FStar_Syntax_Syntax.ppname).FStar_Ident.idText
          FStar_Ident.reserved_prefix)
         || (FStar_Syntax_Syntax.is_null_bv x))
        || (is_reserved (x.FStar_Syntax_Syntax.ppname).FStar_Ident.idText)
       in
    if uu____1747
    then
      let uu____1748 =
        let uu____1749 =
          let uu____1750 =
            FStar_Util.string_of_int x.FStar_Syntax_Syntax.index  in
          Prims.strcat "_" uu____1750  in
        Prims.strcat (x.FStar_Syntax_Syntax.ppname).FStar_Ident.idText
          uu____1749
         in
      (uu____1748, (Prims.parse_int "0"))
    else
      (((x.FStar_Syntax_Syntax.ppname).FStar_Ident.idText),
        (Prims.parse_int "0"))
  