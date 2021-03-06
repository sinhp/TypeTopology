Arithmetic via equivalence
--------------------------

Martín Hötzel Escardó

Originally 10 July 2014, modified 10 Oct 2017, 22 March 2018.

This is a literate proof in univalent mathematics, in Agda notation.

We have that 3+3+3+3+3 = 5+5+5, or 5×3 = 3×5, and more generally

  m×n = n×m.

This can of course be proved by induction. A more appealing pictorial
proof is

  ooo
  ooo         ooooo
  ooo    =    ooooo
  ooo         ooooo
  ooo

where "o" is an pebble. We just rotate the grid of pebbles, or swap
the coordinates, and doing this doesn't change the number of pebbles.

How can this proof be formally rendered, as faithfully as possible to
the intuition?

We first define an interpretation function Fin : ℕ → 𝓤₀ of numbers as
sets (in the universe 𝓤₀) by

 (1) Fin   0  = 𝟘,          where 𝟘 is the empty set,
 (2) Fin(n+1) = Fin n + 𝟙,  where 𝟙 is the singleton set,

Then Fin is a semiring homomorphism:

 (3) Fin(m + n) ≃ Fin m + Fin n, where "+" in the rhs is disjoint union,
 (4) Fin 1 ≃ 𝟙,
 (5) Fin(m × n) ≃ Fin m × Fin n, where "×" in the rhs is cartesian product,

It is also left-cancellable:

 (6) Fin m ≃ Fin n → m = n.

But instead of proving (3)-(5) after defining addition and
multiplication, we prove that

 (3') For every m,n:ℕ there is k:ℕ with Fin k ≃ Fin m + Fin n.
 (5') For every m,n:ℕ there is k:ℕ with Fin k ≃ Fin m × Fin n.

We then define addition and multiplication on ℕ from (3') and (5'),
from which (3) and (5) follow tautologically.

This relies on type arithmetic. To prove (3'), we use the trivial
equivalences

 X ≃ X + 𝟘,
 (X + Y) + 𝟙 ≃ X + (Y + 𝟙),

mimicking the definition of addition on ℕ in Peano arithmetic (but
with the equations written backwards).

To prove (4), we use the equivalence

 𝟘 + 𝟙 ≃ 𝟙

To prove (5'), we use the equivalences

 𝟘 ≃ X × 𝟘,
 X × Y + X ≃ X × (Y + 𝟙),

mimicking the definition of multiplication on ℕ in Peano arithmetic
(again backwards).

To prove the cancellation property (6), we use the cancellation
property

 X + 𝟙 ≃ Y + 𝟙 → X ≃ Y,

mimicking the cancellation property of the successor function on ℕ.
(This is the only combinatorial argument here.)

Now, relying on the equivalence

 X × Y ≃ Y × X,

which corresponds to the rotation of the grid of pebbles, we can prove
m × n = n × m as follows:

 Fin(m × n) ≃ Fin m × Fin n   by (5)
            ≃ Fin n × Fin m   by  X × Y ≃ Y × X,
            ≃ Fin(n × m)      by (5),

and so

 m × n ≃ n × m                by (6).

Similarly we can prove, of course,

 m + n ≃ n + m

using (3) and the equivalence

 X + Y ≃ Y + X.

Among all these constructions, we use induction on ℕ only in

  * the definition (1-2) of the function Fin : ℕ → 𝓤₀,

  * the existence (3')-(5') of addition and multiplication, and

  * the left-cancellability (6) of Fin.

With this, induction is not needed to prove that addition and
multiplication are commutative.

Side-remark, to be explored in a future version. From the equivalence

 (5) Fin(m × n) ≃ Fin m × Fin n

we get two maps

     f : Fin(m × n) → Fin m,
     g : Fin(m × n) → Fin n,

which we didn't define explicitly or combinatorially.

21st March 2018 remark: After doing this, I found this article by Tim
Gowers:

    Why is multiplication commutative?
    https://www.dpmms.cam.ac.uk/~wtg10/commutative.html

which says very much the same as above (implemented below in univalent
foundations in Agda notation).

\begin{code}

{-# OPTIONS --without-K --exact-split --safe #-}

open import SpartanMLTT hiding (_^_)
open import UF-FunExt

module ArithmeticViaEquivalence (fe : FunExt) where

fe₀ : funext 𝓤₀ 𝓤₀
fe₀ = fe 𝓤₀ 𝓤₀

open import UF-Equiv
open import UF-EquivalenceExamples
open import PlusOneLC

\end{code}

1st definition by induction. From a natural number n, get a finite set
with n elements. This can be considered as an interpretation function,
which defines the meaning of numbers as types.

\begin{code}

Fin : ℕ → 𝓤₀ ̇
Fin zero     = 𝟘
Fin (succ n) = Fin n + 𝟙

\end{code}

We have zero and successor for finite sets, with the following types:

\begin{code}

fzero : {n : ℕ} → Fin(succ n)
fzero = inr *

fsucc : {n : ℕ} → Fin n → Fin(succ n)
fsucc = inl

\end{code}

2nd definition by induction. Existence of addition:

\begin{code}

+construction : (m n : ℕ) → Σ \(k : ℕ) → Fin k ≃ Fin m + Fin n
+construction m zero = m , 𝟘-rneutral
+construction m (succ n) = g
  where
    IH : Σ \(k : ℕ) → Fin k ≃ Fin m + Fin n
    IH = +construction m n
    k : ℕ
    k = pr₁ IH
    φ : Fin k ≃ Fin m + Fin n
    φ = pr₂ IH
    φ' : Fin(succ k) ≃ Fin m + Fin (succ n)
    φ' =  Fin k + 𝟙           ≃⟨ Ap+ 𝟙 φ ⟩
         (Fin m + Fin n) + 𝟙  ≃⟨ +assoc ⟩
         (Fin m + Fin n + 𝟙)  ■
    g : Σ \(k' : ℕ) → Fin k' ≃ Fin m + Fin (succ n)
    g = succ k , φ'

\end{code}

The construction gives an addition function by projection:

\begin{code}

_+'_ : ℕ → ℕ → ℕ
m +' n = pr₁(+construction m n)

\end{code}

The construction also shows that its satisfies the usual
characterizing equations from Peano arithmetic:

\begin{code}

+base : {m : ℕ} → m +' zero ≡ m
+base = refl

+step : {m n : ℕ} → m +' (succ n) ≡ succ(m +' n)
+step = refl

\end{code}

Tautologically, we get that Fin : ℕ → 𝓤₀ is an
addition-homomorphism:

\begin{code}

Fin+homo : (m n : ℕ) → Fin(m +' n) ≃ Fin m + Fin n
Fin+homo m n = pr₂(+construction m n)

\end{code}

3rd and last definition by induction. The function Fin : ℕ → 𝓤₀ is
left-cancellable:

\begin{code}

Fin-lc : (m n : ℕ) → Fin m ≃ Fin n → m ≡ n
Fin-lc zero zero p = refl
Fin-lc (succ m) zero p = 𝟘-elim (eqtofun p fzero)
Fin-lc zero (succ n) p = 𝟘-elim (eqtofun (≃-sym p) fzero)
Fin-lc (succ m) (succ n) p = ap succ r
 where
  IH : Fin m ≃ Fin n → m ≡ n
  IH = Fin-lc m n
  remark : Fin m + 𝟙 ≃ Fin n + 𝟙
  remark = p
  q : Fin m ≃ Fin n
  q = +𝟙-cancellable fe p
  r : m ≡ n
  r = IH q

\end{code}

This uses the non-trivial construction +𝟙-cancellable defined in the
module PlusOneLC.lagda.

With this, no further induction is needed to prove commutativity of
addition:

\begin{code}

+'-comm : (m n : ℕ) → m +' n ≡ n +' m
+'-comm m n = Fin-lc (m +' n) (n +' m)
 (Fin (m +' n)   ≃⟨ Fin+homo m n ⟩
  Fin m + Fin n  ≃⟨ +comm  ⟩
  Fin n + Fin m  ≃⟨ ≃-sym (Fin+homo n m) ⟩
  Fin (n +' m)   ■)

\end{code}

We now repeat this story for multiplication:

\begin{code}

×construction : (m n : ℕ) → Σ \(k : ℕ) → Fin k ≃ Fin m × Fin n
×construction m zero = zero , ×𝟘
×construction m (succ n) = g
  where
    IH : Σ \(k : ℕ) → Fin k ≃ Fin m × Fin n
    IH = ×construction m n
    k : ℕ
    k = pr₁ IH
    φ : Fin k ≃ Fin m × Fin n
    φ = pr₂ IH
    φ' : Fin (k +' m) ≃ Fin m × (Fin n + 𝟙)
    φ' = Fin (k +' m)          ≃⟨ Fin+homo k m ⟩
         Fin k + Fin m         ≃⟨ Ap+ (Fin m) φ ⟩
         Fin m × Fin n + Fin m ≃⟨ 𝟙distr ⟩
         Fin m × (Fin n + 𝟙)   ■
    g : Σ \(k' : ℕ) → Fin k' ≃ Fin m × Fin (succ n)
    g = (k +' m) , φ'

_×'_ : ℕ → ℕ → ℕ
m ×' n = pr₁(×construction m n)

×base : {m : ℕ} → m ×' zero ≡ zero
×base = refl

×step : {m n : ℕ} → m ×' (succ n) ≡ m ×' n +' m
×step = refl

Fin×homo : (m n : ℕ) → Fin(m ×' n) ≃ Fin m × Fin n
Fin×homo m n = pr₂(×construction m n)

×'-comm : (m n : ℕ) → m ×' n ≡ n ×' m
×'-comm m n = Fin-lc (m ×' n) (n ×' m)
 (Fin (m ×' n)   ≃⟨ Fin×homo m n ⟩
  Fin m × Fin n  ≃⟨ ×comm ⟩
  Fin n × Fin m  ≃⟨ ≃-sym (Fin×homo n m) ⟩
  Fin (n ×' m)   ■)

\end{code}

Added 30th August 2018: Exponentiation. Requires one more induction.

\begin{code}

→construction : (m n : ℕ) → Σ \(k : ℕ) → Fin k ≃ (Fin m → Fin n)
→construction zero n = succ zero ,
                       (𝟘 + 𝟙        ≃⟨ 𝟘-lneutral ⟩
                        𝟙            ≃⟨ 𝟘→ fe₀ ⟩
                        (𝟘 → Fin n)  ■)
→construction (succ m) n = g
 where
  IH : Σ \(k : ℕ) → Fin k ≃ (Fin m → Fin n)
  IH = →construction m n
  k : ℕ
  k = pr₁ IH
  φ : Fin k ≃ (Fin m → Fin n)
  φ = pr₂ IH
  φ' : Fin (k ×' n) ≃ (Fin (succ m) → Fin n)
  φ' = Fin (k ×' n)                   ≃⟨ Fin×homo k n ⟩
       Fin k × Fin n                  ≃⟨ ×-cong φ (𝟙→ fe₀) ⟩
       (Fin m → Fin n) × (𝟙 → Fin n)  ≃⟨ ≃-sym (+→ fe₀) ⟩
       (Fin m + 𝟙 → Fin n)            ■
  g : Σ \(k' : ℕ) → Fin k' ≃ (Fin (succ m) → Fin n)
  g = k ×' n , φ'

_^_ : ℕ → ℕ → ℕ
n ^ m = pr₁(→construction m n)

^base : {n : ℕ} → n ^ zero ≡ succ zero
^base = refl

^step : {m n : ℕ} → n ^ (succ m) ≡ (n ^ m) ×' n
^step = refl

Fin^homo : (m n : ℕ) → Fin(n ^ m) ≃ (Fin m → Fin n)
Fin^homo m n = pr₂(→construction m n)

\end{code}

Then, without the need for induction, we get the exponential laws:

\begin{code}

^+homo : (k m n : ℕ) → k ^ (m +' n) ≡ (k ^ m) ×' (k ^ n)
^+homo k m n = Fin-lc (k ^ (m +' n)) (k ^ m ×' k ^ n)
 (Fin (k ^ (m +' n))                 ≃⟨ Fin^homo (m +' n) k ⟩
  (Fin (m +' n) → Fin k)             ≃⟨ →-cong fe₀ fe₀ (Fin+homo m n) (≃-refl (Fin k)) ⟩
  (Fin m + Fin n → Fin k)            ≃⟨ +→ fe₀ ⟩
  (Fin m → Fin k) × (Fin n → Fin k)  ≃⟨ ×-cong (≃-sym (Fin^homo m k)) (≃-sym (Fin^homo n k)) ⟩
  Fin (k ^ m) × Fin (k ^ n)          ≃⟨ ≃-sym (Fin×homo (k ^ m) (k ^ n)) ⟩
  Fin (k ^ m ×' k ^ n)               ■)

iterated^ : (k m n : ℕ) → k ^ (m ×' n) ≡ (k ^ n) ^ m
iterated^ k m n = Fin-lc (k ^ (m ×' n)) (k ^ n ^ m)
  (Fin (k ^ (m ×' n))         ≃⟨ Fin^homo (m ×' n) k ⟩
   (Fin (m ×' n) → Fin k)     ≃⟨ →-cong fe₀ fe₀ (Fin×homo m n) (≃-refl (Fin k)) ⟩
   (Fin m × Fin n → Fin k)    ≃⟨ curry-uncurry fe ⟩
   (Fin m → (Fin n → Fin k))  ≃⟨ →-cong fe₀ fe₀ (≃-refl (Fin m)) (≃-sym (Fin^homo n k)) ⟩
   (Fin m → Fin (k ^ n))      ≃⟨ ≃-sym (Fin^homo m (k ^ n)) ⟩
   Fin (k ^ n ^ m)            ■)

\end{code}

Operator precedences:

\begin{code}

infixl 20 _+'_
infixl 22 _×'_
infixl 23 _^_

\end{code}
