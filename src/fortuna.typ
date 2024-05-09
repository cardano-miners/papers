#import "@preview/unequivocal-ams:0.1.0": ams-article, theorem, proof

#show: ams-article.with(
  title: [Fortuna - A Randomness Beacon],
  authors: (
    (
      name: "Kasey White",
      department: [Survey Corps],
      organization: [Cardano Foundation],
      location: [Dammstrasse 16, 6300 Zug, CH],
      email: "kasey.white@cardanofoundation.org",
      url: "https://github.com/microproofs"
    ),
    (
      name: "Lucas Rosa",
      department: [Survey Corps],
      organization: [Cardano Foundation],
      location: [Dammstrasse 16, 6300 Zug, CH],
      email: "lucas.rosa@cardanofoundation.org",
      url: "https://rvcas.dev"
    ),
  ),
  abstract: lorem(100),
  bibliography: bibliography("fortuna.bib"),
)

= What is Fortuna?

Fortuna is a protocol enforced by a spend and mint validator that verifies Proof of Work 
transactions on the Cardano blockchain. By mimicing the attributes of
a Bitcoin block header inside a datum, Fortuna is able to dynamically adjust its difficulty
based on the demand of the network. This averages out to a Fortuna transaction 
every 10 minutes. The Fortuna protocol pays out TUNA to the creator of the transaction 
as a reward for their work.

= What can Fortuna provide?


= FortunaV1 Design

== Overview


== Pros


== Cons


= How to Hard Fork from an active policy

Anyone caught using formulas such as $sqrt(x+y)=sqrt(x)+sqrt(y)$
or $1/(x+y) = 1/x + 1/y$ will fail.

The binomial theorem is
$ (x+y)^n=sum_(k=0)^n binom(n, k) x^k y^(n-k). $

A favorite sum of most mathematicians is
$ sum_(n=1)^oo 1/n^2 = pi^2 / 6. $

Likewise a popular integral is
$ integral_(-oo)^oo e^(-x^2) dif x = sqrt(pi) $

#theorem[
  The square of any real number is non-negative.
]

#proof[
  Any real number $x$ satisfies $x > 0$, $x = 0$, or $x < 0$. If $x = 0$,
  then $x^2 = 0 >= 0$. If $x > 0$ then as a positive time a positive is
  positive we have $x^2 = x x > 0$. If $x < 0$ then $−x > 0$ and so by
  what we have just done $x^2 = (−x)^2 > 0$. So in all cases $x^2 ≥ 0$.
]

= FortunaV2 Design

== Overview

== Differences from FortunaV1

== Pros

== Cons


= FortunaV2 Governance


== Why Governance?

== How Voting Works

== The Future of Fortuna
This is a new section.
You can use tables like @solids.

#figure(
  table(
    columns: (1fr, auto, auto),
    inset: 5pt,
    align: horizon,
    [], [*Area*], [*Parameters*],
    [*Cylinder*],
    $ pi h (D^2 - d^2) / 4 $,
    [$h$: height \
     $D$: outer radius \
     $d$: inner radius],
    [*Tetrahedron*],
    $ sqrt(2) / 12 a^3 $,
    [$a$: edge length]
  ),
  caption: "Solids",
) <solids>




