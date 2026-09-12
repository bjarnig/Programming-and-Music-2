---
theme: seriph
addons:
  - ./shared
title: Programming and Music 2 — 05 Waveforms Examples
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

<div class="deck-title">Waveforms Examples</div>

<div class="sub">
  Programming and Music 2
  <a href="https://www.bjarni-gunnarsson.net">https://www.bjarni-gunnarsson.net</a>
</div>

<!--
The practical half of class 04. Have the code open and run from it; the slides name
what is happening. Eight files, and nobody gets through all of them in one session.
-->

---

# Sample-Level Thinking

In the previous class the waveform was described directly. This class is the same idea in SuperCollider, using tools that already exist.

The unit of composition is the **sample**, not the note. A duration of one sample turns a sequencer into an oscillator, and an envelope into a waveform.

Three techniques, each of which takes something built for one time scale and uses it at another:

- **Demand rate**, where an envelope becomes a stream
- **Binary operations**, where one signal shapes another sample by sample
- **Wavesets**, where the signal decides where it is cut

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

<!--
The point to make out loud: this is the data structure GENDYN already used. Xenakis' program
kept breakpoints and asked for the next one, which is exactly what a demand-rate stream does.
The difference is that here it is a standard part of the language.
-->

---

# Demand Rate

A sawtooth, built from a rising series read one sample at a time.

```supercollider {*|2|3|4|*}
{
	var levels = Dseq([Dseries(-1.0, 0.02, 100)], inf);
	var durations = SampleDur.ir * 5;
	DemandEnvGen.ar(levels, durations) ! 2 * 0.3;
}.play
```

`Dseries(-1.0, 0.02, 100)` counts from -1 in steps of 0.02, a hundred times. At five samples a step that is a ramp of five hundred samples, which is a sawtooth at about 88 Hz.

<span class="q">Change the 100 and the 5. Which one is pitch and which one is shape?</span>

---

# Demand Rate

Streams nested inside streams, so the waveform has structure above the sample.

```supercollider {*|4-9|10-14|*}
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

# Binary Operations

Two signals, one operator, applied sample by sample. The second signal is not a modulator in the usual sense: it sets a **boundary** that the first is forced through.

- `fold2` and `wrap2` turn amplitude into harmonics by reflecting or wrapping
- `thresh` and `amclip` gate one signal by another
- `scaleneg` treats the negative half differently from the positive
- `leastChange` and `mod` choose between signals rather than mixing them

<span class="note">These are not effects applied after synthesis. At audio rate they are the synthesis.</span>

---

# Binary Operations

```supercollider {*|1-2|4-5|7-8|10-11|13-14|*}
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

# Wavesets

A **waveset** is the signal between one zero crossing and the next but one. The cuts are made by the signal itself, so no window and no length is chosen.

Once a sound is cut this way it is a **list of unequal items**, and the list can be reordered, repeated, thinned or replaced.

Wishart developed this while composing *Tongues of Fire*. The transformations are signal-dependent by definition, which is why the results are hard to predict.

<span class="note">The `Wavesets` class and its examples come from Alberto de Campo's Microsound chapter in the SuperCollider Book.</span>

---
class: light
---

# Wavesets

<div class="shot"><img src="/figures/waveset-000.svg" /></div>

<!--
The unevenness is the whole character. A window would give equal items and a predictable
result; taking the boundaries from the signal gives items whose lengths carry the shape of
the source, which is why waveset repetition turns noise into pitch.
-->

---

# Wavesets

The analysis first. Everything after it is list operations.

```supercollider {*|1-2|4-5|7-8|10-11|*}
// analyse a file into wavesets
w = Wavesets.from(~path ++ "/samples/bikecat.wav");

// how many cuts were found
w.numXings

// the length of every waveset, as an array
w.lengths

// and the peak amplitude of each
w.amps

// look at one, then look at ten
w.plot(1000, 1); w.plot(1000, 10);
```

<span class="q">The lengths are uneven. What does that unevenness come from?</span>

---

# Wavesets

Playback takes a start and a length, so any ordering of the list is playable.

```supercollider {*|3|8-12|15|*}
Pbindef(\ws,
	\instrument, \waveset,
	\startWs, Pn(Pseries(0, 1, w.numXings), inf),
	\numWs, 1,
	\playRate, 1,
	\buf, w.buffer.bufnum,
	\repeats, 1,
	[\start, \length, \sustain], Pfunc({ |ev|
		var start, length, wsDur;
		#start, length, wsDur = w.frameFor(ev[\startWs], ev[\numWs]);
		[start, length, wsDur * ev[\repeats] / ev[\playRate].abs]
	}),
	\dur, Pkey(\sustain)
).play;

Pbindef(\ws, \playRate, 0.5, \startWs, Pn(Pseries(0, 4, 1000), inf)).play;
```

<span class="note">Played in order at rate 1 this reconstructs the source. The last line takes every fourth waveset at half speed, and that one change is a transposition. *WavesetsEx.scd* also has selection by amplitude and by length, and scrubbing.</span>

---

# Wavetables

A wavetable is a stored waveform read by an oscillator. `VOsc` reads a **range** of buffers and interpolates between them, so the waveform itself becomes a parameter.

```supercollider {*|1-2|4-6|8-9|*}
// a set of tables is loaded from disk into consecutive buffers
~wtb = Dictionary();
SoundFile.collect(~tablepath).do { |sf| ~addWt.(sf.path, ~wtb, sf.path.split($/).last) };

// the index is a signal, so the waveform itself changes continuously
{
	var bufindex = LFNoise1.kr(0.5).range(0, 5) + ~wtb["tbl07"].bufnum;
	VOsc.ar(bufindex, 100) ! 2 * 0.3;
}.play
```

<span class="note">*Wavetables.scd* loads a set from disk and steps through it. The browser tool at <a href="https://slides.bjarni-gunnarsson.net/tools/wavetable/">slides.bjarni-gunnarsson.net/tools/wavetable</a> does the same thing without SuperCollider.</span>

---

# Next Steps

- Run *DemandEnvGen.scd* first, then *DemandEx.scd*, which is the same idea further along
- *BinaryEx.scd* and *BinaryOperations.scd* are a list to work through, not a sequence
- *Wavesets.scd* and *WavesetsEx.scd* need a sound file of your own to be interesting
- *Wavetables.scd* and *Youtube-Microsound.scd* are the two to leave for last

<span class="note">Take one waveform from class 04 and rebuild it here with demand-rate UGens. The point of the comparison is which of the two you can still read a week later.</span>

---
layout: center
class: divider
---

Exercises

---

# Exercises

1. Implement a pattern process for **waveset distortion** that uses different patterns to control the play rate and the repeats parameters.

2. Implement a pattern process for waveset distortion that adds a **per-waveset transformation**, such as a filter, a glissando or a binary transformation.

3. Create a `DemandEnvGen` process containing at least two layers of the main UGen, where the envelope points are created using `Dbrown` or `Dbrown2`.

4. Create a `DemandEnvGen` process that forms a **varying triangle** waveform.

5. Combine the binary operations so that different ones are used for the high frequencies of the input sound and different ones for the low frequencies.

---

# Exercises

From the previous class, if they are not finished:

1. Create a demand rate waveform containing two different demand patterns, for both durations and levels.

2. Implement a SynthDef with two or more **Gendy** oscillators, cross-modulated using binary operations.

3. Generate a buffer to read with `Osc`, based on at least three different ways of creating random numbers.

4. Implement a pattern for reading a sample analysed into wavesets, using brownian motion for its movements.

5. Create a shape used at the same time as a waveform for synthesis and as an envelope for a sound object.

<span class="workshop">- workshop -</span>
