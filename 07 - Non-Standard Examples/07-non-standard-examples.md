---
theme: seriph
addons:
  - ./shared
title: Programming and Music 2 — 07 Non-Standard Examples
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

<div class="deck-title">Non-Standard Examples</div>

<div class="sub">
  Programming and Music 2
  <a href="https://www.bjarni-gunnarsson.net">https://www.bjarni-gunnarsson.net</a>
</div>

---

# Sample-Level Thinking

In the previous class the waveform was described directly. This class is the same idea in SuperCollider, using tools that already exist.

The unit of composition is the **sample**, not the note. A duration of one sample turns a sequencer into an oscillator, and an envelope into a waveform.

Three techniques, each of which takes something built for one time scale and uses it at another:

- **Demand rate**, where an envelope becomes a stream
- **Binary operations**, where one signal shapes another sample by sample
- **Wavetables**, where a buffer of one cycle is read at audio rate

---

# Demand Rate

A demand-rate UGen produces **one value when asked for one**. It has no length and no array behind it.

`Duty` and `TDuty` ask on a clock. `DemandEnvGen` asks for a level and a duration, then interpolates between them.

Set that duration to `SampleDur.ir` and the envelope generator becomes an **oscillator whose waveform is a stream**.

<span class="note">`Dseq`, `Dser`, `Dwhite`, `Dbrown` and `Dbrown2` are the streams. They nest, so a stream can supply values to another stream.</span>

---
class: light
---

# Demand Rate

<div class="shot"><img src="/figures/demand-000.svg" /></div>

---

# Demand Rate

A sawtooth, built from a rising series read one sample at a time.

```supercollider
{
	var levels = Dseq([Dseries(-1.0, 0.02, 100)], inf);
	var durations = SampleDur.ir * 5;
	DemandEnvGen.ar(levels, durations) ! 2 * 0.3;
}.play
```

`Dseries(-1.0, 0.02, 100)` counts from -1 in steps of 0.02, a hundred times. At five samples a step that is a ramp of five hundred samples, which is a sawtooth at about 88 Hz.

---

# Waveforms from Streams

Only the levels change. Each line below replaces the first line of the saw.

```supercollider
// a triangle: up, then down
var levels = Dseq([Dseries(-1, 0.04, 50), Dseries(1, -0.04, 50)], inf);

// a square: each level repeated fifty times
var levels = Ddup(50, Dseq([-1, 1], inf));

// a staircase: shape 0 jumps to each level and holds it
var levels = Dseq((-4..4) / 4, inf);
DemandEnvGen.ar(levels, SampleDur.ir * 40, 0) * 0.2 ! 2

// an exponential ramp: Dgeom instead of Dseries, rescaled to -1 and 1
var levels = Dseq([Dgeom(0.01, 1.05, 95)], inf);
DemandEnvGen.ar(levels, SampleDur.ir * 5) * 2 - 1 * 0.2 ! 2
```

---

# Two Time Scales

The same generator, read at two speeds. With durations in seconds it is an **envelope**. With durations of a few samples it is the **waveform**, and the sum of the durations sets the pitch.

```supercollider
( // durations in seconds: an envelope on the frequency of a sine
{
	var levels = Dseq([200, 800, 400, 1200], inf);
	SinOsc.ar(DemandEnvGen.kr(levels, Dseq([0.5, 0.25], inf))) * 0.2 ! 2
}.play
)

( // durations of 12 and 6 samples: the streams are now a waveform
{
	var levels = Dseq([-1, 1, -0.3, 0.6], inf);
	DemandEnvGen.ar(levels, Dseq([12, 6], inf) * SampleDur.ir) * 0.2 ! 2
}.play
)
```

---

# Random Streams

```supercollider
// white levels at a fixed duration: a noise with a pitch
{ DemandEnvGen.ar(Dwhite(-1, 1), SampleDur.ir * 20) * 0.2 ! 2 }.play

// a brown walk: the waveform drifts rather than jumps
{ DemandEnvGen.ar(Dbrown(-0.8, 0.8, 0.1), SampleDur.ir * 20) * 0.2 ! 2 }.play

( // random durations as well: the pitch wanders with the shape
{
	var durations = Dwhite(5, 40) * SampleDur.ir;
	DemandEnvGen.ar(Dbrown(-0.8, 0.8, 0.1), durations) * 0.2 ! 2
}.play
)
```

---

# Curves and Reset

Shape `5` bends each segment by the **curve** argument, which can also be a stream. A **reset** restarts every stream, which puts a second period on top of the first, like hard sync.

```supercollider
( // the curve as a stream: every segment bends differently
{
	var sd = SampleDur.ir * 50;
	DemandEnvGen.ar(Dseq([-1, 1], inf), sd, 5, Dwhite(-8, 8)) * 0.2 ! 2
}.play
)

( // a reset restarts the streams
{
	var levels = Dseq([Dseries(-1, 0.01, 200)], inf);
	var reset = Impulse.ar(MouseX.kr(50, 400));
	DemandEnvGen.ar(levels, SampleDur.ir * 2, reset: reset) * 0.2 ! 2
}.play
)
```

---

# Whole Waveforms

`Dswitch` plays the **whole stream** it has chosen before it chooses again. `Dswitch1` takes **one value** and moves on. The first gives a different waveform every cycle. The second is how GENDY is built on the next slides.

```supercollider
(
{
	var saw = Dseries(-1, 0.04, 50);
	var tri = Dseq([Dseries(-1, 0.08, 25), Dseries(1, -0.08, 25)]);
	var sqr = Ddup(25, Dseq([-1, 1]));
	var levels = Dswitch([saw, tri, sqr], Drand([0, 1, 2], inf));
	DemandEnvGen.ar(levels, SampleDur.ir * 4) * 0.2 ! 2
}.play
)
```

---

# Demand Rate

Streams nested inside streams, so the waveform has structure above the sample.

```supercollider
{
	var from = 10, to = 35, repeats = 100, sd = SampleDur.ir;

	DemandEnvGen.ar(
		Dseq([
			Dseq([0, 0.5], repeats),
			Dseq([-0.2, 0.8], repeats/2),
			Dseq([-1.0, 1.0], Dwhite(repeats/32, repeats)),
			Dseq([-0.8, 0.1], repeats/16)
		], inf),
		Dseq([
			Dwhite(from, to, repeats),
			Dwhite(from/1.5, to/1.5, repeats),
			Dbrown(from/10, to/10, from/20, repeats)
		], inf) * sd
	);
}.play
```

<span class="note">The levels and the durations are separate streams, so amplitude and pitch have independent structures. This is *DemandEx.scd*.</span>

---

# GENDY by Hand

Xenakis' dynamic stochastic synthesis, written as streams after Sergio Luque. The cycle has `n` breakpoints, and each one keeps its **own random walk** for amplitude and for duration.

`Dswitch1` visits the breakpoints in order, so the cycle comes back every time, a little changed. That return is what is heard as a pitch.

<span class="note">Replace both `Dseq` with `Drand` and the breakpoints are visited in random order. The cycle is gone, and so is the pitch.</span>

---

# GENDY by Hand

```supercollider
( // after Sergio Luque: every breakpoint has its own walk
{
	var n = 12;
	var amps = { Dbrown(-0.8, 0.8, 0.05) } ! n;
	var durs = { Dbrown(4, 40, 2) } ! n;
	DemandEnvGen.ar(
		Dswitch1(amps, Dseq((0..n - 1), inf)),
		Dswitch1(durs, Dseq((0..n - 1), inf)) * SampleDur.ir
	) * 0.2 ! 2
}.play
)
```

<span class="note">Each `Dswitch1` needs its own `Dseq`. A single index stream shared by both is pulled twice per breakpoint, so each would see only every other index.</span>

---

# Buffers on Demand

A buffer can be a stream too. `Dbufrd` reads a cell when asked, and `Dbufwr` writes one, so the waveform can be **rewritten while it is read**.

```supercollider
~table = Buffer.loadCollection(s, Array.fill(64, { 1.0.rand2 }));

( // read in order, four samples a cell: one cycle is 256 samples
{
	var levels = Dbufrd(~table, Dseq((0..63), inf));
	DemandEnvGen.ar(levels, SampleDur.ir * 4) * 0.2 ! 2
}.play
)

( // write a walk into a random cell twenty times a second, while reading
{
	var levels = Dbufrd(~table, Dseq((0..63), inf));
	Demand.kr(Impulse.kr(20), 0, Dbufwr(Dbrown(-1, 1, 0.2), ~table, Diwhite(0, 63)));
	DemandEnvGen.ar(levels, SampleDur.ir * 4) * 0.2 ! 2
}.play
)
```

---

# Binary Operations

Two signals, one operator, applied sample by sample. The second signal is not a modulator in the usual sense: it sets a **boundary** that the first is forced through.

- `fold2` and `wrap2` turn amplitude into harmonics by reflecting or wrapping
- `thresh` and `amclip` gate one signal by another
- `scaleneg` treats the negative half differently from the positive
- `leastChange` and `mod` choose between signals rather than mixing them

<span class="note">These are not effects applied after synthesis. At audio rate they are the synthesis.</span>

---

# Binary Operations

```supercollider
// fold a sine with a sine, plotted before it is heard
{ SinOsc.ar(60).fold2(SinOsc.ar(58)) }.plot(2)

// fold with the UGen, which takes a low and a high boundary
{ Fold.ar(SinOsc.ar(60), SinOsc.ar(20), SinOsc.ar(80)) }.play

// output whichever input changed least
{ LeastChange.ar(SinOsc.ar(100), Saw.ar(15)) * 0.2 }.play

// threshold a sine with respect to another
{ SinOsc.ar(100).thresh(SinOsc.ar()) }.play

// ring modulate only where the polarity is negative
{ LFNoise2.ar(400).scaleneg(LFSaw.ar(1000)) }.play
```

<span class="note">*BinaryEx.scd* ends with a list of every operator worth trying. *BinaryOperations.scd* has one worked example each.</span>

---

# Streams and Operators

A demand-rate waveform folded by a sine. The levels come in a stereo pair, so the two channels differ, and the mouse sets the frequency of the fold.

```supercollider
(
{
	var sd = SampleDur.ir, min = 0.1, max = 0.3, from = 9, to = 12;
	HPF.ar(
		DemandEnvGen.ar(
			Dseq([min, min.neg, [max.neg, max]], inf),
			sd * Dseq([from, to, Dbrown(from, to, to, from.neg, from)], inf)
		).fold2(SinOsc.ar(MouseX.kr(0.1, 80, \exponential))),
	40) * 0.2
}.play
)
```

---

# Wavetables

A wavetable is a **stored waveform** read by an oscillator. `Osc` reads one. `VOsc` reads a **fractional index** into a range of buffers and interpolates between them, so the waveform becomes a signal rather than a setting.

`VOsc` imposes three conditions, and breaks silently if any is unmet:

- the buffers must be **consecutive** in number
- they must all be the **same power-of-two size**
- they must be in **wavetable format**, which `asWavetable` produces

<span class="note">`asWavetable` returns twice as many samples as it is given, so the 4096-frame files in *tables/* become 8192-frame buffers.</span>

---

# Wavetables

Thirteen single-cycle files, sorted by name and loaded into consecutive buffers.

```supercollider
~tablePath = (PathName(thisProcess.nowExecutingPath)).pathOnly ++ "tables/";
var files = SoundFile.collect(~tablePath ++ "*.wav").sort { |a, b|
	a.path.split($/).last < b.path.split($/).last
};

~tables = files.collect { |sf|
	var file = SoundFile.new, signal;
	file.openRead(sf.path);
	signal = Signal.newClear(file.numFrames);
	file.readData(signal);
	file.close;
	Buffer.loadCollection(s, signal.asWavetable);
};

// check, because VOsc will simply be silent if this is false
~tables.collect(_.bufnum).differentiate.drop(1).every(_ == 1)
```

---

# Wavetables

```supercollider
// one table, read by Osc
{ Osc.ar(~tables[0].bufnum, 110, 0, 0.2) ! 2 }.play

// a fractional index: 3.5 is halfway between the fourth table and the fifth
{ VOsc.ar(~tables[0].bufnum + 3.5, 110, 0, 0.2) ! 2 }.play

// swept across the whole set over thirty seconds
{ VOsc.ar(~tables[0].bufnum + Line.kr(0, 12, 30), 110, 0, 0.2) ! 2 }.play

// the index modulated at audio rate, which moves the waveform
// as fast as the waveform itself
{ VOsc.ar(~tables[0].bufnum + SinOsc.ar(40).range(0, 12), 110, 0, 0.2) ! 2 }.play
```

---

# Morphing Wavetables

The tables do not have to come from files. `allocConsecutive` reserves eight buffers in a row, and `sine1` writes each one in wavetable format, so the three conditions are met in two lines.

```supercollider
( // eight tables in consecutive buffers, each with one more harmonic
~wt = Buffer.allocConsecutive(8, s, 2048);
~wt.do { |b, i| b.sine1(Array.fill(i + 1, { |h| 1 / (h + 1) })) };
)

// one table, read by Osc
{ Osc.ar(~wt[7], 110) * 0.2 ! 2 }.play

// VOsc reads between tables: the mouse moves from a sine to a saw
{ VOsc.ar(~wt[0].bufnum + MouseX.kr(0, 6.99), 110) * 0.2 ! 2 }.play

// swept slowly, so the morph is the sound
{ VOsc.ar(~wt[0].bufnum + SinOsc.kr(0.1).range(0, 6.99), 110) * 0.2 ! 2 }.play
```

---

# Morphing Wavetables

The index is a signal, so anything that makes a signal can move it.

```supercollider
( // at audio rate: the waveform moves as fast as it repeats
{
	var index = SinOsc.ar(MouseY.kr(1, 200, \exponential)).range(0, 6.99);
	VOsc.ar(~wt[0].bufnum + index, 110) * 0.2 ! 2
}.play
)

( // VOsc3: three detuned oscillators over the same morph
{
	var index = LFNoise1.kr(0.3).range(0, 6.99);
	VOsc3.ar(~wt[0].bufnum + index, 110, 110.5, 109.6) * 0.1 ! 2
}.play
)

( // as a stream: one step through the tables every quarter second
{
	var index = DemandEnvGen.kr(Dbrown(0, 6.99, 1), 0.25);
	VOsc.ar(~wt[0].bufnum + index, 110) * 0.2 ! 2
}.play
)
```

---

# Rewriting the Tables

A table can be rewritten while `VOsc` is reading it. The morph carries on between the new shapes. Run either block while one of the previous examples is playing.

```supercollider
// random partials this time
~wt.do { |b| b.sine1(Array.rand(12, 0.0, 1.0)) };

( // or each table by hand: a cubic bent by a sine that grows per table
~wt.do { |b, i|
	b.loadCollection(Signal.newFrom(1024.collect { |j|
		var x = j / 1023 * 2 - 1;
		(x.cubed * 0.7) + (0.3 * (x * (i + 1) * pi).sin)
	}).asWavetable)
};
)
```

<span class="note">`asWavetable` doubles the size, so 1024 values fill a buffer of 2048 frames, which is the size the tables were allocated with.</span>

---
layout: center
class: divider
---

Exercises

---

# Exercises

Eleven short ones first, each a small change to an example from *Examples.scd*, then the longer ones. Write them in *Exercises.scd*.

1. Make the saw **fall** instead of rise.
2. Set the saw to **220 Hz**. How many samples long is one cycle?
3. Replace the `Dseries` in the saw with a `Dseq` of five levels of your own.
4. Give the triangle **random durations** with `Dwhite`.
5. Use `Dswitch` to alternate between **two waveforms of your own**.

---

# Exercises

6. Fold one of your waveforms with `fold2`, by a slow sine.
7. Fill the eight tables with `sine1` and random partials, and **morph** between them with the mouse.
8. Drive the `VOsc` index with a `Dbrown` stream instead of the mouse.
9. Play three `VOsc3` frequencies that form a **chord**.
10. Put one demand-rate waveform in a **SynthDef** with an envelope, and play it from a `Pbind`.
11. Use the same `Dseq` of levels twice: as a **waveform**, and in seconds as a **frequency envelope**.

---

# Exercises

12. Create a `DemandEnvGen` process containing at least two layers of the main UGen, where the envelope points are created using `Dbrown` or `Dbrown2`.

13. Create a `DemandEnvGen` process that forms a **varying triangle** waveform.

14. Combine the binary operations so that different ones are used for the high frequencies of the input sound and different ones for the low frequencies.

---
layout: center
class: divider
---

Recap

---

# Recap

Every exercise of the block so far, by class, so you can go back to the slides and code of each. The two sounds in *code/samples*, *vocal.wav* and *bikecat.wav*, will do for all of them.

- **02 Granular Synthesis** and **03 Granular Examples**: grains, glissons, pulsars, trainlets
- **04 Sound Transformation** and **05 Sound Transformation Examples**: CDP, wavesets, breakpoints
- **06 Non-Standard Synthesis** and this class: demand rate, binary operations, Gendy, DynGen

<span class="note">Start with the ones closest to the assignment problem you are working on.</span>

---

# Recap: 02 Granular Synthesis

1. Create a **granular texture** that evolves from dense to sparse, with at least two different voices created with a granular UGen and multichannel expansion.
2. Create a **movement** of granular sound controlled by audio rate waveforms, such as sine waves or `LFNoise`, mixing more than one buffer to read from.
3. Experiment with **coupling parameters**, so that only two or three controls are mapped to all the granular controls used.
4. Implement a **granular routine** where each grain is filtered, enveloped, speed-shifted and panned differently.

---

# Recap: 03 Granular Examples

1. Create a **glisson synthesis** variant where each of the glissandi goes progressively lower in pitch.
2. Create a layered version of a **pulsar synthesis** train where each layer has a different waveform, envelope and potentially frequency as well.
3. Extend the example of **trainlet synthesis** by including not only the synthetic impulses but also sampled sound.
4. Extend any of the included examples by making them a **function** that can generate clouds of a certain duration.
5. Take one of the above and write it as a **Pbind**, with at least one parameter derived from another using `Pkey`.

---

# Recap: 03 Granular Examples

6. Build a **live granulation** where the delay is not fixed but moves, and describe what the moving delay does to the material.
7. Use `Pdef` to replace a playing cloud with a different one, so that the change is heard as a **transition** rather than as a stop and a start.
8. Write a **mask** that is not in the file: a sieve, a rhythm read from an array, or a mask driven by the amplitude of another signal.
9. Excite a set of resonators with a pulsar train, where the **set** and the **rhythm** are composed separately and can be changed independently.

---

# Recap: 04 Sound Transformation

1. Choose a short sound and **extend** it, using `drunk`, `zigzag` or another extension method, until it is at least ten times its original length.
2. Take one source and build a **family** of eight related sounds from it. Keep the chain that made each one.
3. Make one transformation from A to B where both ends stay recognisable, and one where B has lost all trace of A. Say which was harder.
4. Chain at least **four** programs, listening to every intermediate file, and keep the one you did not expect.
5. Implement a pattern process for **waveset distortion** that uses different patterns to control the play rate and the repeats parameters.
6. Implement a pattern process for waveset distortion that adds a **per-waveset transformation**, such as a filter, a glissando or a binary transformation.

---

# Recap: 05 Sound Transformation Examples

1. Write a breakpoint file with a pattern and use it as the speed or the stretch of one sound. Run it with two different seeds and compare.
2. Apply *distort repeat* and *distort delete* to the same sound and compare how each changes the length and the surface of the **wavesets**.
3. Run *distort divide* and *distort multiply* on a pitched sound and on a noisy one, and describe which source keeps more of its character.
4. Chain three **waveset** distortions with `~cdp`, for example *omit*, *telescope* and *average*, and listen to the file after each step.
5. Make a **family** of eight sounds from one source using at least two programs. Keep the log and the files.
6. **Cross synthesize** two sounds from your family. Transform one of them first and cross again.

---

# Recap: 06 Non-Standard Synthesis

1. Create a **demand rate waveform** that contains two different demand patterns, for creating both durations and levels.
2. Implement a SynthDef with two or more **Gendy** oscillators. These should additionally be cross-modulated using binary operations.
3. Generate a buffer to read with `Osc`, based on at least three different ways of creating random numbers.
4. Create a shape that is used at the same time as a **waveform** for synthesis and as an **envelope** for a sound object.

---

# Recap: 06 Non-Standard Synthesis

With DynGen:

5. Change *A Saw by Hand* into a **square wave**: output 1 while the phase is below 0, and -1 above it.
6. Write a **ring modulator**: multiply `in0` by a sine computed in the script, with its frequency as a parameter.
7. In the GENDY script, set `points:` anywhere from 2 to 100 and listen for where the pitch gives way to a low, rough texture.
8. Count samples in a variable and use it to **switch between two waveforms** every half second (`srate / 2` samples).

---

# Assignment 1

Handed in the week of **8 December 2026**. Four problems: two written in class, two handed in with code, recordings and a text of at least 500 words. The brief is in the download and on the course page.

- **Grain Variants**, in class: three textures from one sound, each a different grain variant (02, 03)
- **A Composed Waveform**, in class: one SynthDef without standard oscillators, evolving for a minute (06, 07)
- **Sound Transformation**, hand-in: a CDP suite from one sound, with breakpoints written in code, in a two-minute study (04, 05)
- **Microsound**, hand-in: an étude of three minutes or more across time scales (02 to 07)

<span class="workshop">- workshop -</span>
