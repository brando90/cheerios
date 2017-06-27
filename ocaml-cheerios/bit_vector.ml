(* serialize -> truncate unused bytes, add one byte to indicate how many bitse of the last byte are padding *)
type node = {bytes : bytes;
             mutable next : node option}
              
type iterator = {head : node;
                 mutable node : node;
                 mutable i : int}

type writer = iterator
type reader = iterator

exception Out_of_bounds
            
let byte_length = 8
;;
             
let makeNode n =
  {bytes = Bytes.make n (Char.chr 0);
   next = None}
;;
  
let makeIter node =
  {head = node;
   node = node;
   i = 0}
;;

let makeWriter () =
  let initialLength = 100
  in makeIter (makeNode initialLength)
;;

let insert iter c =
  let length = Bytes.length iter.node.bytes in
  (if iter.i = length
   then (let node' = (makeNode (length * 2))
         in iter.node.next <- Some (node');
            iter.node <- node';
            iter.i <- 0));
   Bytes.set iter.node.bytes iter.i c;
   iter.i <- iter.i + 1
;;

let read iter =
  let length = Bytes.length iter.node.bytes
  in (if iter.i = length
      then match iter.node.next with
           | Some node' -> (iter.node <- node';
                            iter.i <- 0)
           | None -> raise Out_of_bounds);
     let c = Bytes.get iter.node.bytes iter.i
     in (iter.i <- iter.i + 1;
         c)  
;;

let pushBack = insert
;;

let writerToReader (iter : iterator) : reader =
  { head = iter.head;
    node = iter.head;
    i = 0 }

let pop : reader -> char =
  read


(* dumps bytes from current iterator position until end *)
let dumpReader (r : reader) =
  let rec loop () =
    (try (let c = read r
         in Printf.printf "%x " (Char.code c))
     with
     | Out_of_bounds -> ());
    loop () in
  loop ()
;;        
