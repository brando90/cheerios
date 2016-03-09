Require Import List.
Import ListNotations.
Require Import Arith.
Require Import Nat.
Require Import Ascii.

Fixpoint take_rec (acc: list bool) c xs :=
  match c with
    | O => Some (rev acc, xs)
    | S n =>
      match xs with
        | nil => None
        | x::xs => take_rec (x :: acc) n xs
      end
  end.

Definition take c xs :=
  take_rec nil c xs.

Fixpoint add_zeroes_rec (bin: list bool) length_left :=
  match length_left with
    | O => bin
    | S (n) => false :: (add_zeroes_rec bin n)
  end.

Definition add_zeroes bin len :=
  if ge_dec (length bin) len then
    bin
  else
    add_zeroes_rec bin (len - (length bin)).

Fixpoint nat_to_unary n : list bool :=
  match n with
  | 0 => [false]
  | S n' => true :: nat_to_unary n'
  end.

Fixpoint unary_to_nat (bin : list bool) : option (nat * list bool) :=
  match bin with
  | [] => None
  | b :: bin' => if b
                then match unary_to_nat bin' with
                     | None => None
                     | Some (n, rest) => Some (S n, rest)
                     end
                else Some (0, bin')
  end.

Lemma nat_to_unary_to_nat :
  forall n bin,
    unary_to_nat (nat_to_unary n ++ bin) = Some (n, bin).
Proof.
  induction n as [|n' IHn']; intros bin.
  - reflexivity.
  - simpl. now rewrite IHn'.
Qed.

Fixpoint nat_to_binary_rec fuel n :=
  match fuel with
    | 0 => nil
    | S fuel =>
  match n with
    | O => nil
    | _ => (Nat.odd n) :: nat_to_binary_rec fuel (div2 n)
  end
  end.

Definition nat_to_binary n :=
  rev (nat_to_binary_rec n n).

Fixpoint binary_to_nat_rec bin :=
  match bin with
    | nil => 0
    | hd::bin =>
      Nat.b2n hd + 2 * (binary_to_nat_rec bin)
  end.

Definition binary_to_nat bin :=
  binary_to_nat_rec (List.rev bin).

Definition int_to_binary i :=
  add_zeroes (nat_to_binary i) 31.

Definition binary_to_int bin :=
  match take 31 bin with
    | Some (bin, rest) => Some (binary_to_nat bin, rest)
    | None => None
  end.

Definition ascii_to_binary a :=
  add_zeroes (nat_to_binary (nat_of_ascii a)) 8.

Definition binary_to_ascii bin :=
  match take 8 bin with
    | Some (bin, rest) => Some (ascii_of_nat (binary_to_nat bin), rest)
    | None => None
  end.