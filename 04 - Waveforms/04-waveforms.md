---
theme: seriph
addons:
  - ./shared
title: Programming and Music 2 — 04 Waveforms
titleTemplate: '%s'
layout: default
class: title
transition: slide-left
colorSchema: dark
favicon: /favicon.ico
mdc: true
---

<div class="logos">
  <img src="/figures/logo-001.png" alt="Institute of Sonology" />
  <img src="/figures/logo-002.png" alt="Royal Conservatoire The Hague" />
</div>

<div class="deck-title">Waveforms</div>

<div class="sub">
  Programming and Music 2
  <a href="https://www.bjarni-gunnarsson.net">https://www.bjarni-gunnarsson.net</a>
</div>

<!--
The lineage class. Six people, one idea, and then the code that implements it.
The listening examples are not in the deck: play them from your own library at the
slides that name them.
-->

---
layout: center
class: divider
---

Composing Sound

---

# Composing Sound

Composing sound instead of composing **with** sound.

Attitudes concerned with creating sound through the manipulation of **individual samples**.

Attempts at unifying micro and macroform of composition. Sometimes this results in a tight relationship between frequency and time.

Composing form, composing material.

<span class="note">The term for this lineage is *non-standard synthesis*: the waveform is described directly, rather than by a model of an instrument or of an acoustic process.</span>

---

# Xenakis

In the 1960s, Xenakis was using probabilities and computers to compose instrumental music. He also imagined the potential of using **stochastic methods for sound synthesis**.

His ideas are described in the chapter *New Proposals in Microsound Structure*, in **Formalized Music** (1971).

He opposes synthesis techniques based on Fourier analysis and trigonometric functions, and proposes stochastic methods as a means to produce sounds with complex transients.

---
class: light
---

# Xenakis

> "Instead of starting from the unit element concept and its tireless iteration and from the increasing irregular superposition of such iterated unit elements, we can start from a disorder concept and then introduce means that would increase or reduce it. This is like saying that we take the inverse road: We do not wish to construct a complex sound edifice by using discontinuous unit elements (bricks = sine or other functions); we wish to construct sounds with continuous variations that are not made out of unit elements. This method would use **stochastic variations of the sound pressure directly**."

<div class="src">(Iannis Xenakis, Formalized Music)</div>

---
class: light
---

# Xenakis

<div class="fig tall"><img src="/figures/xenakis-cauchy-000.png" /></div>

<div class="src">(Exponential x Cauchy densities with barriers and randomized time, Formalized Music)</div>

---

# Xenakis

Stochastic synthesis was used for the first time in *Polytope de Cluny* (1972).

In *La Légende d'Eer* (1977) Xenakis uses a new technique, **Dynamic Stochastic Synthesis**, based on the ideas proposed in *New Proposals*. It was built on breakpoint sets, random walks and barriers.

He returns to the idea in the late 1980s with the **GENDY** and **PARAG** programs, and composes *GENDY3* (1991) and *S.709* (1994).

---
class: light
---

# Random Walks and Barriers

<div class="fig tall"><img src="/figures/luque-walk-000.png" /></div>

<div class="src">(from Stochastic Synthesis, Origins and Extensions, Sergio Luque)</div>

---
layout: center
class: divider
---

Xenakis, S.709 (1994)

---

# Herbert Brün

To design processes and discover what they will bring forward.

Starting from scratch and composing with **sample values** instead of translating traditional music thinking to computer languages.

Interested in the social functions of the *composer* and the *listener*.

Composed works for instruments and tape, as well as pure tape pieces where he composed the waveform itself using **SAWDUST**, a program he wrote.

---
class: light
---

# Herbert Brün

> "If ever there will be a technological era worth talking about, it will be thanks to technologists and composers. By their joint efforts, extended over a prolonged period, they may contrive to emancipate thought from language sufficiently for a rehabilitation of both, and continuing from that, introduce an era for mankind where every thought has its language, and where all people have at their disposal a device that will respond to each person's input according to the language stipulated by that person."

<div class="src">(Herbert Brün, Technology and the Composer)</div>

---
class: light
---

# Herbert Brün

<div class="fig">
  <img src="/figures/brun-000.png" />
  <img src="/figures/brun-001.png" />
</div>

<div class="src">(computer generated graphics)</div>

---

# SAWDUST

An **element** consists of an amplitude and a duration in samples. Elements are gathered into lists.

**Links** are created, each consisting of a sequence of elements and the number of times it should be played.

Transformations are then made to the links:

- **Mingle**, repeat links or collections of links
- **Merge**, combine or alternate link values
- **Vary**, transform one link into another

---
class: light
---

# SAWDUST

> "If it can be shown that there exist significant musical ideas which require compositional thinking where not the sound but the waveform is the basic element and standard, then it can also be shown how the computer not only helps the composer to the fulfillment of up to now unfulfillable desires, but actually assists the composer in generating desires he never knew before."

<div class="src">(Herbert Brün)</div>

---

# Koenig

Extending ideas from **PR1** and **PR2**, Koenig created **SSP** for sound synthesis in the early 1970s. The first working version was completed by Paul Berg in 1977 and operated in real time.

SSP can be related to **serialism** through the desire to unify macro and microtime by using the same organization principles on multiple levels.

It represents a rule-based attitude to composition: given the rules, find the music.

---
class: light
---

# SSP

> "Serialism is not just about the 'series' but also about quantization and differentiation."

> "Both serial and electronic music are characterized by a high degree of formalization and mechanization."

> "I experience form as a process as soon as I start working in the studio or at my desk; every bar on paper, every sound on tape changes its formal function every time I look at it, like the light in a landscape under scudding clouds."

<div class="src">(Gottfried Michael Koenig)</div>

---
class: light
---

# Paul Berg

Instead of using the computer for its fast number crunching, more interesting cases can be imagined:

> "To hear that which without the computer could not be heard; to think that which without the computer could not be thought; to learn that which without the computer could not be learned."

<div class="src">(Paul Berg)</div>

---

# Instruction Synthesis

<div class="shot"><img src="/figures/studio-000.png" /></div>

<span class="note">The Computerstudio with its PDP-15. Berg's PILE and ASP describe a waveform as a sequence of instructions rather than as a function of time.</span>

---
layout: center
class: divider
---

Berg, Merriweather's Guide to Plants and People (1975)

---

# Sergio Luque

Luque has proposed extensions to Xenakis' dynamic stochastic synthesis model: **Stochastic Concatenation of Dynamic Stochastic Synthesis**.

The technique constructs a waveform by **concatenating** the waveforms of a set of GENDY outputs.

---
class: light
---

# Stochastic Concatenation

<div class="shot"><img src="/figures/luque-concat-000.png" /></div>

<div class="src">(from Stochastic Synthesis, Origins and Extensions, Sergio Luque)</div>

---

# Agostino Di Scipio

Holds that microstructural timbre composition escapes the traditional separation of sound material and musical form.

Has used **iterated nonlinear functions** to control granular synthesis, and later to generate waveforms directly, in *Functional Iterated Synthesis*.

Inspired by noise and turbulence, and in recent years working with environmental feedback loops, in the audible ecosystems and room-dependent installations.

---
class: light
---

# Di Scipio

> "I intimated that design processes addressing such low scales of time in the musical structure may be conceived of as strategies of microstructural time modeling of sound. Such strategies imply some model or knowledge of how macro-level properties of musical structure can emerge from micro-level morphological conditions. The uniqueness of micro-time sonic strategies lies exactly in fostering and supporting this kind of creative attitude in the context of timbre composition, hence in the possibility of a profound shift in the relationship of materials of form."

<div class="src">(Agostino Di Scipio, Micro-time sonic design and timbre formation)</div>

---

# Daphne Oram

Oram developed **Oramics** at her own studio from 1959, having co-founded the BBC Radiophonic Workshop in 1958 and left it within about a year.

Shapes are **drawn by hand onto 35 mm film strips** and read optically. The drawn shapes generate waveform, envelope and pitch.

That places Oramics in this lineage on technical grounds: a control function described directly, by drawing, rather than derived from an acoustic model. It is the same construction as a breakpoint set, made with a pen.

<span class="note">Daphne Oram, *An Individual Note of Music, Sound and Electronics*, Galliard, 1972.</span>

---

# Trevor Wishart

Wishart developed **waveset distortion** while composing *Tongues of Fire* (1994).

A **waveset** is defined as the signal between any pair of zero crossings.

The transformations built on wavesets are **signal-dependent** and time-varying by definition, since the waveset boundaries are given by the sound itself rather than by an external process.

---
class: light
---

# Wavesets

<div class="fig tall"><img src="/figures/wishart-wavesets-000.png" /></div>

<div class="src">(Trevor Wishart)</div>

---
layout: center
class: divider
---

Code

---

# Waveforms

An `Env` with random breakpoints, read as a waveform rather than as an envelope. At five cycles a second it is a control shape; raise the frequency and it becomes a tone.

```supercollider {*|2-3|4|5|*}
{	var freq = 5, points = 10256, env, values, durations;
	values = Array.fill(points, { rrand(-1.0, 1.0) });
	durations = Array.fill(points, { rrand(0.0, 1.0) }).normalizeSum;
	env = Env(values, durations).circle;
	EnvGen.ar(env, timeScale: freq.reciprocal) * 0.2;
}.play;
```

<span class="note">`.circle` makes the envelope loop, which is what turns a shape into an oscillator.</span>

---

# Waveforms

The same construction with the frequency modulated, so the waveform is read at a changing rate.

```supercollider {*|5|6|*}
{	var freq, points = 512, env, values, durations;
	values = Array.fill(points, { rrand(-1.0, 1.0) });
	durations = Array.fill(points, { rrand(0.0, 1.0) }).normalizeSum;
	env = Env(values, durations).circle;
	freq = 100 * SinOsc.kr(0.1, mul: 0.4, add: 0.5);
	EnvGen.ar(env, timeScale: freq.reciprocal) * 0.2;
}.play;
```

<span class="note">The rest of *Shapes.scd* writes the same material into a buffer and reads it with `Osc`.</span>

---

# Gendy

Three UGens in the standard distribution, written by Nick Collins after Xenakis' stochastic synthesis.

```supercollider {*|1-2|4-5|7-8|10-11|*}
// the amplitude and duration distributions are the two main controls
{ Gendy1.ar(ampdist: 10, ddparam: 0.001, minfreq: 200) * 0.5 }.play

// more breakpoints and a wider frequency range
{ Gendy1.ar(initCPs: 20, minfreq: 20, maxfreq: 2000) * 0.5 }.play

// Gendy2 adds the Lehmer random generator parameters a and c
{ Gendy2.ar(a: 0.7, c: 0.2, ddparam: 0.2, minfreq: 100, maxfreq: 1000) }.play

// Gendy3 fixes the fundamental and distributes the breakpoints within it
{ Gendy3.ar(freq: 800, durscale: 0.8, knum: 12) }.play
```

<span class="note">The full set, including `Gendy2` through a `Klank`, is in *Gendy.scd*.</span>

---

# DynGen

An extension that compiles **EEL2** code into the audio graph and runs it **once per sample** on the server.

A script is registered like a SynthDef, under a name, and takes its inputs from `in0`, `in1` and its parameters from names prefixed with an underscore. Output is written to `out0`.

Nothing in this section uses an oscillator UGen. Every waveform below is arithmetic.

<span class="note">Requires SuperCollider 3.14. The plugin is not notarized, so it needs de-quarantining once after installation.</span>

---
class: light
---

# DynGen

<div class="shot"><img src="/figures/dyngen-000.svg" /></div>

<!--
The reason this belongs in this class and not in a general SuperCollider class: single
sample operations are exactly what Brün, Koenig and Berg were doing, on machines that took
minutes to produce seconds. This is the same operation at the same rate as the audio.
-->

---

# A Sine by Hand

A phase accumulator, wrapped, and the sine of it. There is no `SinOsc` anywhere.

```supercollider {*|2-5|8|*}
(
DynGenDef(\bySine, "
phase += 2*$pi * _freq / srate;
phase >= (2*$pi) ? phase -= 2*$pi;
out0 = sin(phase);
").send;
)

{ DynGen.ar(1, \bySine, params: [freq: 220]) * 0.2 ! 2 }.play
```

<span class="note">Variables inside the script are created on first use and start at zero, so `phase` needs no declaration.</span>

---

# Instructions

After Berg's PILE and ASP: the waveform is decided by conditions rather than described by a formula. A value walks by a fixed step and turns around at a barrier.

```supercollider {*|2-3|5-7|8|*}
DynGenDef(\instr, "
@init
dir = 1;
@sample
val += dir * _step;
val >= _barrier ? (val = _barrier; dir = -1);
val <= -_barrier ? (val = -_barrier; dir = 1);
out0 = val;
").send;
```

<span class="note">A triangle, arrived at without naming a triangle. The barrier sets the pitch, because the walk turns sooner.</span>

---

# Dynamic Stochastic Synthesis

Xenakis' algorithm written out. At each breakpoint a new duration and a new amplitude are drawn by a random walk, both held inside barriers.

```supercollider {*|5-7|8-10|11-13|15|*}
DynGenDef(\gendy, "
@init
dur = 100;
@sample
count += 1;
count >= dur ? (
  count = 0; from = to;
  amp += (rand() * 2 - 1) * _ampStep;
  amp > _ampBarrier ? amp = _ampBarrier;
  amp < -_ampBarrier ? amp = -_ampBarrier;
  to = amp;
  dur += (rand() * 2 - 1) * _durStep;
  dur = max(_durMin, min(_durMax, dur));
);
out0 = from + ((to - from) * (count / dur));
").send;
```

<span class="q">What happens to the sound as the barriers widen?</span>

---

# Iterated Functions

Di Scipio's functional iterated synthesis: one equation applied to its own output, once per sample. The logistic map at 44100 iterations a second.

```supercollider {*|2-6|9|12|15|*}
DynGenDef(\iterated, "
@init
y = 0.5;

@sample
y = _r * y * (1 - y);
out0 = (y * 2) - 1;
").send;

// below 3.0 it settles, and the output is silence after the first click
{ DynGen.ar(1, \iterated, params: [r: 2.8]) * 0.2 ! 2 }.play

// past 3.57 it never repeats, and the result is broadband noise
{ DynGen.ar(1, \iterated, params: [r: 3.9]) * 0.2 ! 2 }.play

// swept through the bifurcations
{ DynGen.ar(1, \iterated, params: [r: Line.kr(2.8, 4.0, 20)]) * 0.2 ! 2 }.play
```

---

# Generated Code

A definition is a string, so it can be assembled by another program. This is the SAWDUST idea with the machine of 1976 replaced.

```supercollider {*|2-6|7-9|13-15|*}
~partials = { |n|
	var terms = Array.fill(n, { |i|
		"(" ++ (1 / (i + 1)) ++ " * sin(" ++ (i + 1) ++ " * phase))"
	});
	"phase += 2*$pi * _freq / srate;\n"
	++ "phase >= (2*$pi) ? phase -= 2*$pi;\n"
	++ "out0 = " ++ terms.join(" + ") ++ ";";
};

~partials.(3).postln;
// out0 = (1.0 * sin(1 * phase)) + (0.5 * sin(2 * phase)) + (0.333 * sin(3 * phase));

DynGenDef(\built, ~partials.(32)).send;
{ DynGen.ar(1, \built, params: [freq: 110]) * 0.2 ! 2 }.play
```

<span class="note">At 32 partials on a 110 Hz fundamental the upper terms pass Nyquist and alias. That is audible, and it is the argument for band-limited oscillators.</span>

---

# Short Scripts

One line for each person named earlier in the class. None is a faithful implementation. Each is the smallest thing that carries the idea.

```supercollider {*|1-2|4-5|7-8|10-11|*}
// Xenakis: stochastic variation of the sound pressure, held by barriers
"w += (rand() * 2 - 1) * _step; w = max(-1, min(1, w)); out0 = w;"

// Brün: an element is an amplitude and a duration in samples
"c += 1; c >= _len ? (c = 0; v = rand() * 2 - 1); out0 = v;"

// Koenig: the same, with the amplitudes quantised to a small set
"c += 1; c >= _len ? (c = 0; v = floor(rand() * 5) / 2 - 1); out0 = v;"

// Berg: the waveform follows from an instruction rather than from a curve
"p += _step; p > 1 ? p = -1; out0 = p;"
```

<span class="q">Read each line and predict the sound before playing it.</span>

---

# Short Scripts

```supercollider {*|1-2|4-5|7-9|*}
// Di Scipio: one equation applied to its own output, once per sample
"y = y <= 0 ? 0.5 : _r * y * (1 - y); out0 = y * 2 - 1;"

// Wishart: a new gain at every zero crossing of the input, which is a waveset
"s = in0 >= 0; s != u ? g = rand(); u = s; out0 = in0 * g;"

// Oram: a shape drawn by hand, read as a waveform
"p += _freq * bufFrames(_buf) / srate; p >= bufFrames(_buf) ? p -= bufFrames(_buf);
 out0 = bufReadL(_buf, p);"
```

<span class="note">All seven are in *DynGen.scd*, each with a mouse control on the parameter that matters most.</span>

---
class: light
---

# Waveshapers

<div class="shot"><img src="/figures/shapers-000.svg" /></div>

<!--
Six saturators, plotted from the values the code actually produces. All are odd-symmetric,
so they add odd harmonics only. Where the curve bends is where the harmonics arrive, and the
dashed box shows how much of the bend a unit-amplitude input actually reaches.
-->

---

# Waveshapers

The functions are written once and run both in the language and at audio rate.

```supercollider {*|2-6|9-10|13-14|*}
~sigmoid = (
	tanh:      { |x| x.tanh },
	atan:      { |x| (x * 0.5pi).atan / 0.5pi },
	cubic:     { |x| var c = x.clip(-1, 1); ((3 * c) - c.cubed) / 2 },
	softclip:  { |x| x / (1 + x.abs) },
	algebraic: { |x| x / (1 + (x * x)).sqrt }
);

// plotted in the language
Signal.newFrom(400.collect { |i| ~sigmoid[\tanh].(i.linlin(0, 399, -3.0, 3.0)) }).plot;

// the same expression at audio rate, with the input gain swept
{ var sig = SinOsc.ar(220) * XLine.kr(0.2, 30, 12); (sig.tanh * 0.2) ! 2 }.play
```

<span class="q">At low gain the curve is almost a straight line. At what input does it stop being one?</span>

---

# Shaper

A transfer function written into a buffer once, then read by `Shaper`. The curve becomes data.

```supercollider {*|1-6|8-9|11-13|*}
~mkShaper = { |func, size = 1024|
	var sig = Signal.newFrom(size.collect { |i|
		func.value(i.linlin(0, size - 1, -1.0, 1.0))
	});
	Buffer.sendCollection(s, sig.asWavetableNoWrap, 1);
};

~curve = ~mkShaper.(~sigmoid[\cubic]);
{ Shaper.ar(~curve.bufnum, SinOsc.ar(180) * Line.kr(0.2, 1.0, 10)) * 0.2 ! 2 }.play

// a curve that is not a saturator: Chebyshev polynomials map a unit sine
// onto a chosen set of harmonics
~cheb = Buffer.alloc(s, 1024, 1, { |b| b.chebyMsg([1, 0, 0.4, 0, 0.2]) });
{ Shaper.ar(~cheb.bufnum, SinOsc.ar(180) * Line.kr(0.05, 1.0, 12)) * 0.2 ! 2 }.play
```

<span class="note">All seven curves, and the check that `logistic` and `tanh` are the same function, are in *Shapers.scd*.</span>

---

# Next Steps

- Run *Shapes.scd*, *Demand.scd*, *Binary.scd*, *Gendy.scd*, *Instructions.scd*, *Wavesets.scd* and *Shapers.scd*
- Plot a shaper curve before playing it, and predict what the plot will sound like
- Take one Gendy and reduce its parameters until you can hear what each one does
- Build a waveform from a breakpoint set, then use the same set as an envelope

---
layout: center
class: divider
---

Exercises

---

# Exercises

1. Create a **demand rate waveform** that contains two different demand patterns, for creating both durations and levels.

2. Implement a SynthDef with two or more **Gendy** oscillators. These should additionally be cross-modulated using binary operations.

3. Generate a buffer to read with `Osc`, based on at least three different ways of creating random numbers.

4. Implement a pattern for reading a sample that has been analysed into **wavesets**. The pattern should use brownian motion for its movements.

5. Create a shape that is used at the same time as a **waveform** for synthesis and as an **envelope** for a sound object.

<span class="workshop">- workshop -</span>
