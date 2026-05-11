#set text(font: "New Computer Modern")

#let note(content) = block(
  fill: rgb("#e6f2ff"), // A very light blue
  stroke: rgb("#007ace") + 0.5pt, // Optional border
  inset: 10pt,
  radius: 3pt,
  width: 100%,
  [*NOTE:* #content]
)

#let lemma(title: none, body) = {
  block(
    width: 100%,
    stroke: (left: 2.5pt + rgb("#007ace")), 
    inset: (left: 12pt, y: 8pt),
    fill: rgb("#f0f8ff"), // Slightly cleaner light blue
    breakable: true,
    spacing: 1.5em,
    [
      #text(weight: "bold", fill: rgb("#007ace"))[Lemma.]
      #if title != none [
        #text(weight: "bold")[(#title)]
      ]
      #h(0.1em) #body
    ]
  )
}

#let hcount = counter("hmath-counter")

#let hmath(content) = {
  hcount.step()
  
  box(baseline: 40%, stack( // High baseline pushes the box's "seat" lower
    dir: ttb,
    spacing: 0.5pt, // Extremely tight spacing
    
    // The Highlighted Box
    box(
      fill: rgb("#e8f5e9"),
      inset: (x: 4pt, y: 3pt),
      radius: 2pt,
      baseline: 0pt, 
      content
    ),
    
    // The Counter Label
    context align(center, text(size: 5pt, weight: "bold", fill: gray.darken(50%))[
      #hcount.display()
    ])
  ))
}

#set math.equation(numbering: "(1)")
#set page(
  // 1. Automatically add page numbers (defaults to the bottom center)
  numbering: "1",

  // 2. Create a custom header
  header: [
    #set text(size: 10pt, style: "italic") // Make header text smaller and italic
    
    BIOENG 241: Probabilistic Models in Computational Biology
    #h(1fr) // This acts like a spring, pushing the next text to the far right
    Aakarsh Vermani
    
    // Add a little space and a horizontal line to separate the header from the content
    #line(length: 100%, stroke: 0.5pt + luma(150)) 
  ]
)

#align(center)[
  #text(size: 24pt, weight: "bold")[HW 3] 
  #v(-0.8em)
  #text(size: 12pt)[Aakarsh Vermani]
  #v(-0.8em)
  #text(size: 14pt, style: "italic")[April 20, 2026]
]

#v(1em)

#set heading(numbering: "1.")

= Instantaneous Model
== ODEs for $r_n (t)$
#v(0.5em)
New links are inserted at a rate of $lambda$ and deleted with a rate of $mu$. Therefore, with rate $mu + lambda$ we have sequences leaving the state of $n$ mortal links. Note that each of the $n$ mortal links can die while each of mortal links _plus the immortal link_ can give birth. Modeling just the probability mass leaving the current state gives us

$ r_n (t + Delta t) = r_n (t) - r_n (t) (underbrace(n mu, "deaths") + underbrace((n+ 1)lambda, "births"))Delta t.  $

Modeling the mass entering the state requires us to consider the $n-1$ and $n + 1$ states:

$ r_n (t + Delta t) = r_n (t) + (underbrace((n+1) r_(n+1) (t) mu, "deaths") + underbrace(n r_(n-1)(t)lambda, "births"))Delta t. $

Combining the two and taking the limit as $Delta t arrow 0$ gives us the following ODE

$ frac(d r_n (t), d t) = - [n mu + (n+1) lambda ]r_n (t) + (n+1)mu r_(n+1)(t) + n lambda r_(n-1)(t) $

== Existence of Equilibrium Distribution 
#v(0.5em)

This outer process will *converge to an equilibrium distribution* because of the constraint that $mu > lambda$, meaning the number of links can't grow without bound.

== Equilibrium Probability
#v(0.5em)

Because birth-death chains are reversible, we can use the detailed balance equations to determine the equilibrium probability $rho_n (t)$. In particular, we can enforce that the probability mass being exchanged between states $n$ and $n+1$ are equal, because for a reversible Markov chain this is equivalent to the system being in equilibrium.

Writing this out mathematically,

$ (n+1) lambda rho_n (t) = (n + 1) mu rho_(n+1) (t) \ 
frac(rho_(n+1) (t), rho_n (t)) = frac(lambda,mu) $

This gives us a recurrence relation that we can unroll as a function of $rho_0 (t)$:

$ rho_n (t) = (frac(lambda, mu))^n rho_0 (t). $
As a sanity check we can see that this expression will never blow up because $lambda / mu < 1$. We can also solve for $p_0 (t)$ by recognizing that this is a valid probability distribution meaning all the states' probabilities sum to 1$ 1 = sum_(n=0)^infinity rho_n (t) = rho_0 (t)underbrace(sum_(n=0)^infinity (lambda/mu)^n, "Geometric Sum") = (rho_0 (t)) / (1 - lambda/mu) \ rho_0(t) = 1 - lambda/mu $

Therefore, we have that the equilibrium distribution of number of mortal links is actually Geometric with parameter $1 - lambda/mu$:

$ p_n (t) = (lambda/mu)^n (1 - lambda/mu) $

== Expected Number of Links (i) and Probability of No Links (ii) <sec_1.4>
#v(0.5em)

The expectation of a geometric distribution with parameter $p$ defined over $0,1,dots,$ is $(1-p)/p$, so the expected number of mortal links at equilibrium is $ bb(E)[n] = lambda/mu / (1-lambda/mu) = lambda / (mu-lambda) $

We found the probability of having no links in 1.3

$ rho_0 (t)=1-lambda/mu $ <p_no_link>

== Expected Number of Residues per Mortal Link
#v(0.5em)

Since the number of residues per link is Geometrically distributed with extension probability#footnote[In this subpart the parameter is the probability of "failure" or extension probability, but in #link(<sec_1.4>)[Section 1.4] we treat the parameter as the probability of "success". The other difference between the two distributions is whether or not 0 is in the state space.] $rho$, the expected number of residues per link is $ bb(E)[a] = 1/(1-rho) $

== Expected Total Number of Residues
#v(0.5em)

If we let $a_i$ represent the number of residues per link $i$, the expected total number of residues is given by $ bb(E)_(n ~ rho(t), a_i ~ "Geom"(rho))[sum_(i=1)^n a_i]. $Note that $rho(t)$ refers to the equilibrium distribution for the number of links and $rho$ is the paramter for the Geometric distribution describing the number of residues per link. By linearity of expectation we have $ bb(E)_(n ~ rho(t)) [sum_(i=1)^n bb(E)[a_i]]. $ By independence of $a_i$ and $n$, we can evaluate the inner expectation first $ bb(E)_(n ~ rho(t)) [sum_(i=1)^n bb(E)[a_i]] &= bb(E)_(n ~ rho(t)) [sum_(i=1)^n 1/(1-rho)] \ &= bb(E)_(n ~ rho(t)) [n / (1-rho)] \ &= lambda / ((1-rho) (mu - lambda)) $

== HMM for TKF92 Equilibrium Distribution
#v(0.5em)
We can construct an HMM with 4 hidden states: (S)tart, (E)nd, (M)ortal link, (C)ontinuation. The emitting states are $M$ and $C$, which each emit residues via the stational distribution $pi$:
$ P(x|M) = p(x|C) = pi_x. $ The transitions between the states are governed by $lambda$, $mu$, and $rho$, allowing us to construct the following transition matrix with states ordered as $S,M,C,E$:

$ mat(0, lambda/mu, 0, 1 - lambda/mu; 0, quad (1 - rho)lambda/mu quad , rho, (1-rho)(1-lambda/mu); 0, (1 - rho)lambda/mu, rho, quad (1-rho)(1-lambda/mu) quad ; 0, 0, 0, 1 ) $

To elaborate row by row: we move from $S -> M$ with probability $lambda/mu$ or there are no mortal links, meaning we move from $S -> E$, which will happen with probability $1 - lambda/mu$. We can't move from $S -> C$ because $C$ is defined as a continuation of an existing mortal link. In any of the emitting states, we either continue emitted residues in the current link, which occurs with probability $P((dot)-> C) = rho$. Or we end the current link (probability $1 - rho$), in which case we move to a new mortal link: $P((dot)-> M) = (1-rho)lambda/mu$ or we we end the sequence $P((dot)-> E) = (1-rho)(1-lambda/mu)$. The last row must be all 0 except for $(E, E)$ since once the sequence ends there are no more new states.

We can easily verify that this matrix is properly normalized, as all the rows sum to 1. 

== One-to-One Mapping
#v(0.5em)

No, there is not, because each possible sequence in the character alphabet could map to multiple different TKF92 states. For example, consider the DNA sequence "ACATGG." There are multiple ways we could group each nucleotide with each link, and there could be anywhere from 1 to 6 mortal links. So, the TKF92 model has strictly "more" information.
#pagebreak()
= Finite-Time Solution 

#note[To align the ODEs I derive with those from the TKF91 paper, I'm interpreting "children" as referring to descendants of a mortal link at any depth (i.e. including grandchildren, great-grandchildren, etc.). Furthermore, I'm using $n$ to count just the children, NOT including the original link the ODEs are w.r.t. This is in contrast with how $n$ is defined in the TKF91 paper (more on this in section 2.5).
]

== ODEs for $p_n (t)$, $q_n (t)$, $r_n (t)$
#v(0.5em)
Starting with $p_n (t)$ we want to model the probability that a given link stays alive AND $n$ children survive. If we look at a very small time period $Delta t$ for a given parent link, the events that can occur to enter our $p_n$ state are that the parent has $n$ children and one dies (which occurs with rate $mu$), or that the parent has $n-1$ children and another one is born (which occurs with rate $lambda$). The events that can occur resulting in leaving the $p_n$ state are the parent link dying, a child dying, or a child being born. Writing this out explicitly, we have $ p_n (t + Delta t) = p_n (t) +  underbrace((n+1) p_(n+1) (t)mu Delta t + n p_(n-1) (t)lambda Delta t, "entering") \
- underbrace((n + 1) p_n (t)(mu + lambda) Delta t , "leaving"). $
Taking the limit as $Delta t arrow 0$ and dividing both sides by $d t$ gives us $ (d p_n (t) )/ (d t) = (n+1) p_(n+1) (t) mu + n p_(n-1) (t) lambda - (n + 1)p_n (t) (lambda + mu) $

For $q_n (t)$ we wish to model the probability that a given link _dies_ and $n$ children survive. Modeling the transitions based on the children is the same as for $p_n (t)$ except in this case we can transition from a state $p_n arrow q_n$ if the parent link dies (although notably the opposite transition is impossible because a link can't be brought back to life). This gives us the following ODE: $ (d q_n (t) )/ (d t) = (n+1)q_(n+1) (t) mu + (n-1) q_(n -1) (t) lambda + p_(n) (t) mu  - n q_n (t) (mu + lambda) quad n>0 $
Note that the above ODE is only defined for $n>0$: $q_0 (t)$ corresponds to the case where the original link dies and leaves no surviving children. This can either happen if the original link is dead and its only child dies or the original link is alive and has no children: $ (d q_0 (t))/(d t) = mu q_1 (t) + mu p_0 (t) $



Lastly, for $r_n (t)$, since the immortal link cannot die, all we need to model is the children being born or dying. This gives us $ (d r_n (t) )/ (d t) = (n+1) r_(n+1) (t) mu + n r_(n-1) (t) lambda - (n+1) r_n (t) lambda - n r_n (t) mu $
== Differences between $r_n (t)$
#v(0.5em)
This $r_n (t)$ is almost exactly the same except we explicitly have the initial condition of $ r_0(0) = 1 $ in this section, where as the initial conditions were unspecified in section 1.
== "Immigration" Term 
#v(0.5em)

Immigration refers to the fact that even if all the children die, there's an immortal link that cane give birth with rate $lambda$. Or, in other words, there is always constant immigration with rate $lambda.$

== Solving ODEs
#v(0.5em)

*Solving for $beta(t)$*

Start with $r_n (t) = beta^n (1 - beta)$. Differentiating:

$ (d)/(d t)[beta^n (1-beta)] = beta^(n-1) beta' [n - (n+1)beta] $

Substituting into the $r_n$ ODE and dividing both sides by $beta^(n-1)$:

$ beta'[n - (n+1)beta] = (1-beta)[n(1-beta)(lambda - mu beta) - lambda] + lambda $

After substitution, the coefficient of $n$ on the left is $beta'(1-beta)$ and on the right is $(1-beta)^2(lambda - mu beta)$, giving

$ beta' = (1 - beta)(lambda - mu beta) $

Separating variables:

$ (d beta)/((mu beta - lambda)(beta - 1)) = d t $

Using partial fractions with $1/((mu beta - lambda)(beta - 1)) = 1/(mu - lambda) [mu/(mu beta - lambda) - 1/(beta - 1)]$ and integrating:

$ 1/(mu - lambda)[ln|mu beta - lambda| - ln|beta - 1|] = t + C $

$ ln lr(|frac(mu beta - lambda, beta - 1)|) = (mu - lambda)t + tilde(C) $

At $t = 0$, $beta = 0$: $tilde(C) = ln(lambda)$. Exponentiating:

$ frac(mu beta - lambda, beta - 1) = lambda e^((mu - lambda)t) $

Solving for $beta$:

$ mu beta - lambda = lambda e^((mu-lambda)t)(beta - 1) $
$ beta(mu - lambda e^((mu-lambda)t)) = lambda - lambda e^((mu - lambda)t) $

#box(stroke: black + 1pt, inset: 10pt)[$ beta(t) = frac(lambda(1 - e^((lambda - mu)t)), mu - lambda e^((lambda - mu)t)). $<beta>]

*Solving for $alpha(t)$*

#lemma[ Let $A = e^((lambda - mu)t)$. Then we can rewrite $beta (t)$ as $ beta(t) = (lambda (1 - A))/(mu - lambda A) = (lambda - lambda A)/ (mu - lambda A). $Since we're given that $lambda < mu$, we know that $beta (t) < 1$. Furthermore, we have that $0 < A < 1$, meaning the numerator of $beta (t)$ must be nonnegative and the denominator must be positive, meaning $0 <= beta (t) < 1$.
]

The trial solution is $p_n (t) = alpha beta ^ n (1 - beta)$ which is a very convenient form since if you take the sum over all $n$ from 0 to infinity you get $ sum_(n=0)^infinity p_n (t) = alpha(1 - beta) sum_(n=0)^infinity beta^n = alpha (1 - beta)1/(1- beta) =alpha(t) $where we can use the infinite geometric sum since $beta (t) in [0, 1)$ by the above lemma. In other words, $alpha(t)$ corresponds to the probability that the original link stays alive and has any number of children surviving, meaning it simply corresponds to the probability that the original link stays alive. Since links die at rate $mu$, this is just equivalent to the inverse CDF of an Exponential distribution with parameter $mu$:
$ alpha(t) = 1 - P(t' <= t) = 1 - (1-e^(-mu t)) $ #box(stroke: black + 1pt, inset: 10pt)[$ alpha(t) = e^(-mu t) $<alpha>]

If we want the ODE for $alpha (t)$ we can simply differentiate to get $ frac(d alpha (t), d t) = -mu e^(-mu t) $


*Solving for $gamma(t)$.*

Using the trial solutions $q_0 (t) = (1 - alpha)(1 - gamma)$, $q_1 (t) = (1-alpha)gamma(1-beta)$, and $p_0 (t) = alpha (1-beta)$, we get $ (d q_0 (t))/(d t) = mu (1 -alpha)gamma(1 - beta) + mu alpha (1 - beta) $  $ = mu(1 - beta)[gamma(1 - alpha) + alpha]. $

Rearranging the trial solution for $q_0 (t)$ gets us $ gamma(1 - alpha) = 1 - alpha - q_0 (t) $$ arrow.double (d q_0 (t))/(d t) = mu(1 - beta)[1 - alpha - q_0 (t) + alpha] $ $ = mu (1 - beta)[1 - q_0 (t)] $This ODE we've derived for $q_0 (t)$ is quite similar to what we had for $beta (t)$: $ frac(d beta (t), d t) = (1 - beta)(lambda - mu beta) = lambda (1 - beta) (1 - mu/lambda beta). $We can pattern match to get $ q_0 (t) = mu/lambda beta (t) $meaning $ (1 - alpha(t))(1 - gamma (t)) = mu/lambda beta (t) $ #box(stroke: black + 1pt, inset: 10pt)[$ arrow.double gamma (t) = 1 - (mu beta(t))/( lambda (1 - alpha (t))) $]

== Sanity Check with TKF91 Paper
#v(0.5em)

As noted earlier in section 2.4, the TKF91 paper seems to use a slightly different indexing since $n$ includes the original link, meaning $n_("TKF") = n + 1$. In equation (10) of their paper, they define $beta$ (which I'll refer to as $beta_"TKF"$) as the same $beta$ I derived above but off by a factor of $lambda$. Specifically, $ beta(t) = lambda beta_"TKF" (t). $ With this in mind, their equation for $p_n$ is  $ p_(n_"TKF") (t) = underbrace(e^(-mu t), alpha (t))[1 - lambda beta_"TKF" (t)][lambda beta_"TKF"]^(n_"TKF" - 1) $which exactly matches the trial solution given in the homework based on our definitions of $alpha (t)$, $ beta (t)$ and $n$. We can check $gamma (t)$ matches up because they also derive $ q_0 (t) = mu beta_"TKF" = mu/lambda beta (t), $ from which simply performed some algebraic manipulation to get a result for $gamma (t)$. Note that in the TKF91 paper, they use $p_n' (t)$ to denote what we call $q_n (t)$.

In general, the solutions are all _independent_ of $n$.
#pagebreak()
= Hidden Markov Model
#v(0.5em)

#note[To avoid confusion I'll try to use the terms ancestral and descendant when talking about the _sequences_ and parent and child when talking about the _links_. In general, child doesn't just refer to a direct child link but children at all possible depths (e.g. grandchildren, great-grandchildren, etc.)]

== Constructing the Transition Matrix
#v(0.5em)
Let's start constructing our hidden state transition matrix by considering the $S$ and $E$ states. Specifically, we know that once we leave the $S$ state we can't reenter and that we can't stay in the $S$ state. Also, once we enter the $E$ state we can't leave. If we order our states as $S,M,I,D,E$ then the first column must be all $0$ and the last row must be all $0$ except for a 1 at $(E,E)$ since we must stay at $E$ (functionally ending the generation process).

*Transitions out of $S$*

When starting from $S$ we must first consider descendants of the immortal link, which we modeled with $r_n (t)$. Using the indexing convention from TKF91, we can see that $r_n (t)$ is geometrically distributed with expansion parameter $beta$, which was derived in section 2. This is also consistent with our definition for $p_n (t)$, which is the same expression but with an $alpha$ coefficient at the front representing the probability that the mortal parent link stays alive (note that we can think of $r_n (t)$ as a special case of $p_n (t)$ where $alpha=1$).

Therefore,  #hmath($P(S arrow I) = beta$), the probability of a new child descendant link from the immortal link (which refers to any new mortal link).

To get the probability of a $D$ from $S$ we must consider the probability that an ancestral mortal link existed, then died, and that no new descendant link was born, each of which have probabilities $lambda/mu$ (see @p_no_link), $1-alpha$ (see @alpha), and $1 - beta$, giving us #hmath($P(S arrow D) = lambda/mu (1- alpha)(1 - beta).$) 

Similarly, we transition from $S$ to $M$ under the same criteria except the ancestral link stays alive, which occurs with probability $alpha$: #hmath($P(S -> M) = lambda/mu alpha (1 - beta)$).

The last possible transition out of $S$ is to $E$, which implies that no ancestral mortal link ever existed and no new descendant link was created: #hmath($P (S -> E) = (1-lambda/mu)(1 - beta).$)

*Transitions out of $M$*

If we are in state $M$ then we are in a surviving mortal link, and we stay in that link with probability $rho$, which is the extension parameter that governs the Geometric distribution of residues per link (as defined in section 1). Alternatively, the link could end (probability $1 - rho$) and you could ender another $M$ state with the next ancestral link, which is the same probability as $P(S -> M)$. Therefore, we have #hmath($P (M -> M) = rho + lambda/mu alpha (1 - beta)(1 - rho)$).

Similarly, we can transition into $D$, $I$, or $E$ states if the residue block ends, giving us #hmath($P(M -> D) = lambda/mu (1-alpha)(1-beta)(1- rho)$), #hmath($P(M-> I) = beta (1 - rho)$), and #hmath($P(M -> E) = (1 - lambda/mu)(1- beta)(1- rho)$).

*Transitions out of $I$*

If we are in state I then we are in a new child descendant link that didn't exist in the ancestral sequence. This new descendant link will output another residue with probability $rho$ or end the residue block and enter a new descendant child link with probability $beta (1 - rho)$ resulting in #hmath($P(I -> I) = rho + beta (1 - rho)$). 

Just like for transitions out of $M$, we can model the other states with the same probability as leaving $S$ but multiplied by the probability of the residue block ending: #hmath($P(I -> M) = lambda/mu alpha (1 - beta) (1 - rho)$), #hmath($P(I -> D) = lambda/mu (1-alpha)(1-beta)(1- rho)$), and #hmath($P(I -> E) = (1 - lambda/mu)(1- beta)(1- rho)$).

*Transitions out of $D$*

So far we've had nice interpretations of the $alpha$ and $beta$ functions that we derived in section 2, and it turns out there's a nice interpretation for $gamma$ as well. If we consider $q_0 (t) = (1 - alpha)(1 - gamma)$, the probability that a mortal link dies AND leaves no children, we can think of this as factorizing the probability into $ q_0 (t) = P("mortal link dies")P("mortal link leaves no children" | "mortal link dies") $ where we know the first term is represented by $1 - alpha$ meaning the second term represents $1 - gamma$. Taking the inverse, we have that $ gamma = P("ancestral mortal link leaves > 0 orphaned child" | "ancestral mortal link dies"). $

Now, considering transitions out of $D$, we can stay in $D$ if another residue is generated with probability $rho$ or if the block ends and the original ancestral link had no orphaned children and the next link also died: #hmath($P(D -> D) = rho + lambda/mu (1 - alpha)(1 - rho)(1- gamma)$). 

Similarly, we can enter an $M$ or $E$ state if no orphaned children were born: #hmath($P(D -> M) = lambda /mu alpha (1 - rho) (1 - gamma)$), #hmath($P(D -> E) = (1 - lambda/mu)(1 - rho)(1 - gamma)$)

If the dead link did leave orphaned children, then this would be a transition to an $I$ state: #hmath($P(D -> I) = (1 - rho)gamma$).

Now, notice that we've enumerated all the entries of our $5 times 5$ transition matrix (16 transition matrices explicitly enumerated plus the 9 entries made up by the $S$ column and $E$ row as described at the start).

== Emission Probability of $(x,y)$ in $M$ state
#v(0.5em)

From section 1 we know that substitutions are sampled according to a rate matrix $Q$, so we can sample transitions from $x -> y$ after some time $t$ by performing a matrix exponential $ P (t) = exp(Q t). $ The ancestral residue $x$ is sampled from the equilibrium distribution $pi$, so the final emission probability of $(x, y)$ in the $M$ state is $ pi_x [exp(Q t)]_(x y) $

== Emission Probabilities in $I$ and $D$ states
#v(0.5em)

Since inserted residues are sampled from the equilibrium distribution as are the ancestral residues, both $x$ and $y$ are sampled from $pi$. Specifically, we have $ P((epsilon, y)) = pi_y quad "(I)nsert" $and $ P((x, epsilon)) = pi_x quad "(D)elete" $

== Confirmation of Expected Properties
#v(0.5em)
=== Normalization
#v(0.5em)
First we must confirm that all rows add to 1 for our transition matrix to be properly normalized. For each row, we'll add all the transitions going to states $S, M, I, D, E$ respectively.

S: $ 0 + lambda/mu alpha (1 - beta) + beta + lambda/mu (1 - alpha) (1 - beta) + (1 - lambda/mu) (1 - beta) \ = (1 - beta)lambda/mu (1 - alpha + alpha ) + beta + (1 - lambda/mu) (1 - beta) \ = (1 - beta)(lambda/mu + 1 - lambda / mu) + beta = 1 - beta + beta = 1 med  #sym.checkmark $
M: $ 0 + rho + lambda/mu alpha (1 - beta)(1 - rho) + beta (1 - rho) + lambda/mu (1-alpha)(1-beta)(1- rho) +\ (1 - lambda/mu)(1- beta)(1- rho) = 1 med #sym.checkmark $
I:$ 0 + lambda/mu alpha (1 - beta) (1 - rho) + rho + beta (1 - rho) +lambda/mu (1-alpha)(1-beta)(1- rho) + \ (1 - lambda/mu)(1- beta)(1- rho) = 1 med #sym.checkmark $
D: $ 0 + lambda /mu alpha (1 - rho) (1 - gamma) + (1 - rho)gamma + rho + lambda/mu (1 - alpha)(1 - rho)(1- gamma) +\ (1 - lambda/mu)(1 - rho)(1 - gamma) = 1 med #sym.checkmark  $
E: $ 0 + 0 + 0 + 0 + 1 = 1 med #sym.checkmark $

To confirm that the emission probabilities are normalized, consider $I$ and $D$ emissions:
$ sum_y pi_y = 1, quad sum_x pi_x = 1 $which is true by definition. For $M$ emissions
$ sum_(x,y)pi_x P_(x -> y)(t) = sum_x pi_x underbrace(sum_y P_(x->y)(t), 1) = sum_x pi_x = 1 $which follows from the fact that all rows of the $Q$ rate matrix sum to 0 so all rows of the resulting $P(t)$ sum to 1.

=== Null Cycles
#v(0.5em)
The only states with no associated emissions are $S$ and $E$. The transition matrix is constructed such that no transition into $S$ can occur. Technically, once a state enters $E$ it stays there indefinitely, but this is by design since it represents the generation process ending.

#pagebreak()

= HMM Algorithms

== Calculate $P(A, X, Y | theta, t)$
#v(0.5em)
This task is asking us to score the probability an alignment $A$ made up of ancestral sequence $X$ and descendant sequence $Y$ using an HMM with parameters $theta$ and a time $t$. A context in which this would be useful is scoring two different alignments of the same sequence under a given HMM parameterization to determine which is a better fit.

If we let $T_(u,v)$ represent the probability of the state transition $u -> v$, let $e_u (c_i)$ represent the emission probability of residue $c_i$ in state $u$ and let $s_1, dots, s_L$ represent the hidden state path then for the TKF92 HMM we have $ P(A, X, Y | theta, t) = T_(S, s_1)e_(s_1) (c_1) product_(k=2)^L T_(s_(k-1), s_k) e_(s_k) (c_k) dot T_(s_L, E) $<hmm_prob> and each of these variables has been defined exactly in terms of the HMM parameters in sections 2 and 3.

I've implemented this calculation in Python at #link("https://github.com/aakarshv1/TKF92")[https://github.com/aakarshv1/TKF92].


== Find $hat(t) = "argmax"_t med P(A, X, Y | theta, t)$
#v(0.5em)
This task is asking us to fit the optimal branch length between an ancestral sequence $X$ and descendant sequence $Y$ that are aligned according to $A$. This might come up when trying to fit the branch lengths for a phylogenetic tree given an existing topology and alignments between sequences.

To implement this we can write out @hmm_prob as a function of $t$ in terms of the component functions $alpha (t)$, $beta(t)$, $gamma(t)$, and $exp (Q t)$ and perform maximum likelihood estimation on the log-likelihood via gradient descent or more naively using a grid search, which should still be fairly effective since there's only a single scalar to optimize, $t$.

I've implemented this optimization in Python at #link("https://github.com/aakarshv1/TKF92")[https://github.com/aakarshv1/TKF92].

== Calculate $P(X, Y | theta, t)$
#v(0.5em)
This task is asking us to marginalize out the alignments to calculate the likelihood of observing sequences $X$ and $Y$ together as ancestor and descendant under our HMM model $theta$ and time $t$. A context in which this task might be useful is determining if 2 unaligned sequences $X$ and $Y$ are evolutionarily related. 

Note that mathematically we would essentially need to compute $ P(X, Y | theta, t) =  sum_A P(A, X, Y | theta, t), $which one can do tractably through the pair-HMM forward algorithm. Broadly, we can run this algorithm by recursively defining forward variables $F_s (i, j)$ for each of the emitting states $s in {M, I, D}$ and summing over all states, setting $i$ and $j$ equal to the lengths of $X$ and $Y$ respectively.

== Calculate $P(Y | X, theta, t)$
#v(0.5em)
This task is asking us to calculate the likelihood of observing a descendant $Y$ given an ancestor $X$ under our HMM model $theta$ and time $t$. One context in which this would be useful is simulating evolution of an ancestor sequence $X$ after some time $t$ via some form of Monte Carlo method.

We can use Bayes' rule to get $ P(Y | X, theta, t) = frac(P(X, Y | theta, t), P(X | theta)). $Therefore, to calculate $P(Y | X, theta, t)$ we can use our answer from question 4.3 and divide by the probability of sequence $X$ under our equilibrium distribution found in section 1 (since $X$ is sampled from an equilibrium distribution, we can drop the $t$ from conditioning in the denominator). 



== Find $hat(A) = "argmax"_A med P(A | X, Y, theta, t)$
#v(0.5em)
This task is asking us to find the most probable alignment between sequences $X$ and $Y$ under our HMM model given evolutionary time $t$. A context in which this might be useful is constructing a multiple species alignment (MSA).

We can use maximum likelihood estimation: perform Bayes' rule to rewrite as $ P(A | X, Y, theta, t) = frac(P(A, X, Y | theta, t), P(X, Y|theta, t)) $and since the denominator doesn't depend on $A$ we just need to maximize $P(A, X, Y | theta, t)$, the expression from question 4.1 with respect to $A$. We can perform this using the pair-HMM Viterbi algorithm, which is similar to the pair-HMM forward algorithm but replaces sums with maxima and stores backpointers. 

== Find $hat(theta) = "argmax"_theta med P(A, X, Y | theta, t)$
#v(0.5em)
This task is asking us to estimating HMM model parameters given an alignment $A$ between ancestor $X$ and descendant $Y$ with some time $t$ between them. A context in which this might useful is training an HMM from a dataset of pre-constructed alignments that can then be applied to align other sequence pairs.

Implementing this would require a very similar procedure as question 4.2 although we now have multiple parameters to optimize over ()$lambda, mu, rho, Q, pi$) instead of a single scalar. Therefore, a grid search would be much harder, but we could use techniques like gradient descent instead.