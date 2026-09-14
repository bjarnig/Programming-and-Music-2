---
theme: seriph
addons:
  - ./shared
title: Programming and Music 2 — 06 Non-Standard Synthesis
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

<div class="deck-title">Non-Standard Synthesis</div>

<div class="sub">
  Programming and Music 2
  <a href="https://www.bjarni-gunnarsson.net">https://www.bjarni-gunnarsson.net</a>
</div>

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

In the 1960s Xenakis used probabilities and a computer to compose instrumental music, and proposed the same methods for sound synthesis in the chapter *New Proposals in Microsound Structure*, in **Formalized Music**.

He rejects synthesis built on Fourier analysis and trigonometric functions, and proposes **stochastic variation of the sound pressure** itself.

The technique first appears in *Polytope de Cluny* (1972) and is named **Dynamic Stochastic Synthesis** in *La Légende d'Eer* (1977). He returns to it in the late 1980s with the **GENDY** and **PARAG** programs, and composes *GENDY3* (1991) and *S.709* (1994).

---
class: light
---

# Dynamic Stochastic Synthesis

<div class="shot"><img src="/figures/gendy-algo-000.svg" /></div>

---
layout: center
class: divider
---

Xenakis, S.709 (1994)

---

# Herbert Brün

Brün wrote **SAWDUST** at the University of Illinois in the early 1970s to compose the waveform itself, and used it for a series of tape pieces.

He starts from **sample values** rather than from a translation of instrumental thinking into a computer language.

The program assembles a sound from **elements**, gathers them into **links**, and then transforms the links. His sketches show waveform lengths linked to tempered pitch scales, and twelve-tone rows used to order them.

---
class: light
---

# SAWDUST

<div class="shot"><img src="/figures/sawdust-algo-000.svg" /></div>

---

# Koenig

Koenig designed **SSP** in 1972, extending the selection principles of **PR1** and **PR2** to sound synthesis. A working implementation by Paul Berg followed in 1977.

The program rests on one proposition: a musical sound may be described as a function of amplitude over time. The composer lists amplitude values and time values, and the program selects from those lists.

SSP can be related to **serialism** through the wish to unify macro and microtime by applying the same organisation principles at both.

---
class: light
---

# SSP

<div class="shot"><img src="/figures/ssp-algo-000.svg" /></div>

---

# Paul Berg

Berg wrote **ASP** (Automated Sound Programs) in 1974 and 1975: twenty-two assembler programs for the PDP-15 that produce sound in real time with no acoustic model behind them.

Each program takes an initial condition, starts, and runs until it is switched off. They are built from counting, comparing, arithmetic and logical operations, from choosing among loops, and from varying the sample rate at arbitrary moments.

**PILE** (1977) is a language that abstracts the instruction groups that kept recurring in ASP. Curtis Roads later named the approach **instruction synthesis**.

---
class: light
---

# ASP and PILE

<div class="shot"><img src="/figures/asp-algo-000.svg" /></div>

---
layout: center
class: divider
---

Berg, Merriweather's Guide to Plants and People (1975)

---

# Sergio Luque

Luque wrote his own implementation of the 1991 dynamic stochastic synthesis algorithm in SuperCollider, and then extended it, in **Stochastic Concatenation of Dynamic Stochastic Synthesis**.

A waveform is built by **concatenating** the waveforms of a set of GENDYs, one iteration at a time. Conceptually the set is unbounded; in his implementation 72 is a practical limit.

Which GENDY is taken next is decided by a stochastic procedure, and that procedure gives the sound its behaviour.

---
class: light
---

# Stochastic Concatenation

<div class="shot"><img src="/figures/concat-algo-000.svg" /></div>

---

# Agostino Di Scipio

Di Scipio holds that composition at the microstructural level escapes the traditional separation of sound material and musical form.

He used **iterated nonlinear functions** to control granular synthesis in *kairós* (1991/2) and *Zeitwerk* (1992), and then to compute the samples themselves, in **Functional Iteration Synthesis**.

The map is applied a fixed number of times **within one sample**, so the iteration does not run along the signal. The parameters are the scale factor, the starting value and the number of iterations.

In recent years he has worked with environmental feedback loops, in the audible ecosystems and the room-dependent installations.

---
class: light
---

# Functional Iteration Synthesis

<div class="shot"><img src="/figures/iterated-algo-000.svg" /></div>

---
layout: center
class: divider
---

Code

---

# Waveforms

An `Env` with random breakpoints, read as a waveform rather than as an envelope. At five cycles a second it is a control shape; raise the frequency and it becomes a tone.

```supercollider
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

```supercollider
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

```supercollider
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

---

# EEL2

The language inside the quotes is **EEL2**, Cockos' expression language, the one that powers REAPER's JSFX. A definition is compiled when it is sent, on a non-realtime thread, so a new synth outputs zero for a moment before the script takes over.

* Variables need no declaration and are all **double-precision floats**. One that was never assigned reads 0.
* A variable keeps its value from one sample to the next. That is where a phase accumulator, a counter or a random walk comes from, with nothing declared.
* Conditions are written `cond ? ( ... ) : ( ... )`, which works as a statement or as a value. There is no `if` keyword, but `loop(n, ...)` and `while( ... )` are there.
* Equality is loose: `==` is true when the difference is under 0.00001, so `1.0 == 1.000001` holds. `===` compares exactly.

<span class="note">The language reference is at *cockos.com/EEL2*, and the JSFX programming reference at *reaper.fm/sdk/js* documents the same language with audio examples.</span>

---

# A Sine by Hand

A phase accumulator, wrapped, and the sine of it. There is no `SinOsc` anywhere.

```supercollider
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

```supercollider
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

```supercollider
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

One equation applied to its own output, once per sample. The logistic map from class 22 at 44100 iterations a second, where the orbit itself is the signal.

```supercollider
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

# Functional Iteration Synthesis

Not the slide before. There the iteration runs along the signal; here it runs inside one sample. The map is applied **n** times to a starting value, and the nth iterate is that sample.

```supercollider
DynGenDef(\fis, "
x = in0;
loop(_n, x = sin(_r * x));
out0 = x;
").send;

// n = 2, a smooth surface, in the window of the paper's first figure
{ DynGen.ar(1, \fis, LFSaw.ar(110).range(0.2, 0.4), params: [r: 3.2, n: 2]) * 0.3 ! 2 }.play

// n = 7, the same scan across a surface full of hills and valleys
{ DynGen.ar(1, \fis, LFSaw.ar(110).range(0.2, 0.4), params: [r: 3.2, n: 7]) * 0.3 ! 2 }.play

// the iterate order under the mouse, which is where the bandwidth comes from
{ DynGen.ar(1, \fis, LFSaw.ar(110).range(0.0, 1.0),
	params: [r: 3.6, n: MouseX.kr(1, 10).round]) * 0.3 ! 2 }.play
```

<span class="note">The input carries the starting value, so the oscillator scanning it draws the path. In *DynGen.scd*.</span>

---

# Generated Code

A definition is a string, so it can be assembled by another program. This is the SAWDUST idea with the machine of 1976 replaced.

```supercollider
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

One line each, for people named earlier in the class. None is a faithful implementation. Each is the smallest thing that carries the idea.

```supercollider
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

```supercollider
// Di Scipio: the sine map applied n times inside one sample
"x = in0; loop(_n, x = sin(_r * x)); out0 = x;"

// Wishart: a new gain at every zero crossing of the input, which is a waveset
"s = in0 >= 0; s != u ? g = rand(); u = s; out0 = in0 * g;"
```

<span class="note">All six are in *DynGen.scd*, each with a mouse control on the parameter that matters most.</span>

---
class: light
---

# Waveshapers

<div class="shot"><img src="/figures/shapers-000.svg" /></div>

---

# Waveshapers

The functions are written once and run both in the language and at audio rate.

```supercollider
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

```supercollider
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
layout: center
class: divider
---

Experiment

---

# Working at the Sample Level

Non-standard synthesis has **no acoustic model to aim at**. There is nothing to realise, and no correct result to approach.

What there is instead is a starting point, a change, and a listen. Luque points out that for Xenakis these techniques were only *"arbitrary starting points"*, and describes the *"somewhat limited timbral space of the non-standard approach"*.

The working habits matter more here than in a synthesis method that models something.

<span class="note">This is the part of the lineage that is practical rather than historical, and it is what separates this class from Composing with Algorithms 12, which takes the same people and asks what composing the waveform means.</span>

---

# A Seeded Accident

A random generator finds good material and then loses it. A generator written by hand takes a **seed**, so the same number returns the same waveform.

```supercollider
DynGenDef(\seeded, "
@init
r = _seed;
@sample
r = r * 1103515245 + 12345;
r = r - floor(r / 2147483648) * 2147483648;
c += 1;
c >= _len ? (c = 0; v = (r / 2147483648) * 2 - 1);
out0 = v;
").send;
```

Two renders with seed 7 were **identical sample for sample**. Seed 8 gave an unrelated waveform.

<span class="note">An accident you can return to is worth more than a new accident. Walk the seeds, keep the ones worth keeping.</span>

---

# Constraints

A limit is a generator. Restricting the material forces the search into a part of the space that adding things will not reach.

```supercollider
// only integers, so the amplitude has three values and nothing between them
"c += 1; c >= _len ? (c = 0; v = floor(rand() * 3) - 1); out0 = v * 0.5;"

// only one operation and one variable
"w += _step; w > 1 ? w -= 2; out0 = w;"

// no multiplication anywhere: addition, comparison and assignment only
"a += _step;
 a > 1 ? (a = -1; b += _step2);
 b > 1 ? b = -1;
 out0 = a + b > 1 ? (a + b - 2) : (a + b < -1 ? (a + b + 2) : (a + b));"
```

<span class="q">Which of these three could you have arrived at by adding to a sine?</span>

---

# Failure Modes

At the sample level the usual failures are the edges of the technique rather than bugs, and all three are audible.

**DC offset.** An unbounded walk drifts away from zero and stays there. Measured over 16384 samples: mean 0.04, ending at 0.08. Inaudible on small speakers and dangerous on large ones.

**Aliasing.** Terms above Nyquist fold back down. They do not sound like a mistake, they sound like partials in the wrong places.

**Blow-up.** Feedback above unity grows without limit. Keep the amplitude low and a `Limiter` after it while experimenting.

---

# Failure Modes

```supercollider
// the drift, and the leak toward zero that fixes it
"w += (rand() * 2 - 1) * _step; out0 = w * 0.1;"
"w += (rand() * 2 - 1) * _step; w = w - (w * _leak); out0 = w * 0.1;"

// see it rather than trust it
{ var w = 0; Signal.newFrom(4096.collect { w = w + (1.0.rand2 * 0.01) }).plot }.value

// aliasing, swept past Nyquist so the descent is audible
{ DynGen.ar(1, \alias, params: [freq: 220, mult: Line.kr(1, 200, 20)]) * 0.2 ! 2 }.play
```

<span class="note">The leak brought the mean back from 0.04 to -0.001 on the same walk.</span>

---

# Sweeping a Parameter

Rather than choosing a value, listen to the whole range once. The map is more useful than any point on it, and it is quicker than guessing.

```supercollider
DynGenDef(\space, "
c += 1;
c >= _len ? (c = 0; v = floor(rand() * _levels) / (_levels - 1) * 2 - 1);
out0 = v;
").send;

// two axes, swept slowly, so the whole space is heard in half a minute
{ DynGen.ar(1, \space, params: [
	len:    XLine.kr(3, 600, 30),
	levels: Line.kr(2, 24, 30).round(1)
]) * 0.3 ! 2 }.play
```

<span class="note">Everything in this section is in *Experiments.scd*.</span>

---

# Next Steps

- Run *Shapes.scd*, *Demand.scd*, *Binary.scd*, *Gendy.scd*, *Instructions.scd*, *Shapers.scd*, *DynGen.scd* and *Experiments.scd*
- Plot a shaper curve before playing it, and predict what the plot will sound like
- Take one Gendy and reduce its parameters until you can hear what each one does
- Build a waveform from a breakpoint set, then use the same set as an envelope
- Walk twenty seeds of the same script and keep three
- Write a script under a constraint of your own, and say what the constraint ruled out

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

4. Create a shape that is used at the same time as a **waveform** for synthesis and as an **envelope** for a sound object.

<span class="workshop">- workshop -</span>
