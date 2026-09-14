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

<span class="q">Change the 100 and the 5. Which one is pitch and which one is shape?</span>

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

<span class="q">Sorting by filename puts wv10 before wv2. Does that matter here?</span>

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

<span class="note">*WavetableSet.scd* adds four detuned layers drifting through the set independently, and two tables written from scratch rather than loaded. The browser tool at <a href="https://slides.bjarni-gunnarsson.net/tools/wavetable/">slides.bjarni-gunnarsson.net/tools/wavetable</a> does the same morph without SuperCollider.</span>

---

# Next Steps

- Run *DemandEnvGen.scd* first, then *DemandEx.scd*, which is the same idea further along
- *BinaryEx.scd* and *BinaryOperations.scd* are a list to work through, not a sequence
- *Wavetables.scd*, *WavetableSet.scd* and *Youtube-Microsound.scd* are the ones to leave for last

<span class="note">Take one waveform from class 04 and rebuild it here with demand-rate UGens. The point of the comparison is which of the two you can still read a week later.</span>

---
layout: center
class: divider
---

Exercises

---

# Exercises

1. Create a `DemandEnvGen` process containing at least two layers of the main UGen, where the envelope points are created using `Dbrown` or `Dbrown2`.

2. Create a `DemandEnvGen` process that forms a **varying triangle** waveform.

3. Combine the binary operations so that different ones are used for the high frequencies of the input sound and different ones for the low frequencies.

---

# Exercises

From the previous class, if they are not finished:

1. Create a demand rate waveform containing two different demand patterns, for both durations and levels.

2. Implement a SynthDef with two or more **Gendy** oscillators, cross-modulated using binary operations.

3. Generate a buffer to read with `Osc`, based on at least three different ways of creating random numbers.

4. Create a shape used at the same time as a waveform for synthesis and as an envelope for a sound object.

<span class="workshop">- workshop -</span>
