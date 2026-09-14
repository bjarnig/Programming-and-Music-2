---
theme: seriph
addons:
  - ./shared
title: Programming and Music 2 — 03 Granular Examples
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

<div class="deck-title">Granular Examples</div>

<div class="sub">
  Programming and Music 2
  <a href="https://www.bjarni-gunnarsson.net">https://www.bjarni-gunnarsson.net</a>
</div>

---

# Varieties of Particle Synthesis

The previous class covered **the grain**: a waveform, an envelope, a duration, and a way of emitting them.

This class covers **glisson**, **trainlet** and **pulsar**. Roads treats them as varieties of one method rather than as separate techniques: the emitter is the same, and what differs is the contents of the particle.

Each has a section of its own in chapter 4 of *Microsound*.

<span class="note">Curtis Roads, Microsound, chapter 4.</span>

---
class: light
---

# Shared Parameters

<div class="shot"><img src="/figures/engine-000.svg" /></div>

---

# Glisson

A grain whose frequency changes over its own duration. In signal processing this is called a **chirp**.

Roads took it from Xenakis, who described each grain as a **vector** in a space of time, frequency and amplitude, rather than as a point. A vector has a direction, so the grain can glide.

> "In glisson synthesis, each particle or glisson has an independent frequency trajectory, an ascending or descending glissando."

<span class="note">Roads implemented it in 1998 with Stephen Pope, in SuperCollider 1, and again in 1999 with Alberto de Campo in SuperCollider 2.</span>

---
class: light
---

# Magnetization

<div class="shot"><img src="/figures/magnetization-000.svg" /></div>

---

# Glisson in Code

This implementation glisses a **recording** rather than a synthetic waveform, by applying a line to the playback rate.

```supercollider
SynthDef(\gliss, { |buf=0, start=0, amp=0.5, dur=0.3, pan=0, from=0.5, to=4.0|
	var sig, shape, env, pos;
	shape = Env([0, amp, 0], [dur*0.5, dur*0.5], \sine);
	env = EnvGen.ar(shape, doneAction: 2);
	pos = start * BufFrames.ir(buf);
	sig = PlayBuf.ar(1, buf, Line.ar(from, to, dur) * BufRateScale.ir(buf), 1, pos, 0);
	OffsetOut.ar(0, Pan2.ar(sig * env, pan));
}).add;
```

<span class="note">`from` and `to` are the two ends of the glissando. Roads' own glisson chirps a synthetic waveform, so this is a variant rather than the same object.</span>

---

# Glisson Clouds

The read position advances through the buffer while the glissando range widens.

```supercollider
var dur = 0.02, overlap = 2.0, sample = ~voice;

Routine {
	var total = sample.numFrames / sample.sampleRate;
	var times = ((total / dur) * overlap).asInteger;
	times.do { |i|
		var next = dur / overlap;
		var start = (i * next) / total;
		Synth(\gliss, [
			\buf, sample.bufnum, \dur, dur, \start, start,
			\from, i.linlin(0, times, 1.0, 2.0),
			\to,   i.linlin(0, times, 2.0, 10.0)
		]);
		next.wait;
	};
}.play;
```

<span class="q">Two `linlin` lines set the shape of the cloud. Which magnetization pattern is this?</span>

---

# Trainlet

A particle consisting of a **short burst of impulses** rather than a waveform.

> "A trainlet is an acoustic particle consisting of a brief series or train of impulses. Like other particles, trainlets usually last between 1 to 100 ms."

Roads lists five parameters: **density** of the trainlets, their **attack time**, **pulse period**, **harmonic structure**, and **spectral energy profile**.

<span class="note">Impulse generators were standard equipment in the 1950s studios. The ones at WDR Cologne ran from 1.1 Hz to 10 kHz.</span>

---

# Trainlet in Code

`Blip` is a band-limited impulse train, so the particle is a single UGen.

```supercollider
SynthDef(\trainlet, { |amp=1.0, dur=0.3, pan=0, density=20, harmonics=10|
	var sig, shape, env;
	shape = Env.perc(dur*0.2, dur*0.8);
	env = EnvGen.ar(shape, doneAction: 2);
	sig = Blip.ar(density, harmonics);
	OffsetOut.ar(0, Pan2.ar(sig * env, pan, amp));
}).add;
```

`density` is the pulse period and `harmonics` is the harmonic structure. The attack is in the envelope. The **spectral energy profile**, Roads' fifth parameter, is the one this version leaves out.

---

# Pulsar

A **pulsaret** followed by a measured **silence**. Pulsar particles do not overlap, which is what distinguishes the method from granular synthesis.

The separation gives two independent controls. The **period** sets the fundamental, and the **pulsaret duration** sets a formant.

<span class="note">Roads gives pulsar synthesis the longest section in the chapter, and it is the version most covered in practice.</span>

---
class: light
---

# Fundamental and Formant

<div class="shot"><img src="/figures/pulsar-000.svg" /></div>

---

# Pulsar in Code

`GrainBuf` already emits particles, so the implementation is three lines.

```supercollider
SynthDef(\pulsar, { |fund=10, form=100, amp=1.0, wavebuf, envbuf|
	var trig = Impulse.ar(fund);
	var grdur = form.reciprocal;
	var rate = form * BufDur.kr(wavebuf);
	Out.ar(0, GrainBuf.ar(2, trig, grdur, wavebuf, rate, 0, 4, 0, envbuf, mul: amp));
}).add;
```

`fund` is the emission rate, so it is the pitch. `form` sets the grain duration to `1/form`, so it is the formant. Change one and the other stays where it is.

<span class="note">After the Microsound chapter by Alberto de Campo in the SuperCollider Book.</span>

---

# The Pulsaret

The pulsaret is whatever is in the buffer, and it is read once per pulse. Changing it changes the colour of the formant while the two frequencies stay where they are.

```supercollider
// a single sine: the formant is one clean peak
~pSine = Buffer.alloc(s, 2048, 1); ~pSine.sine1([1.0], asWavetable: false);

// ten random partials: a formant with an internal colour
~pRand = Buffer.sendCollection(s, Signal.sineFill(2048, { 1.0.rand }.dup(10)), 1);

// odd harmonics falling as 1/n^2, plus five inharmonic partials on top
~pOdd = Buffer.sendCollection(s, Signal.sineFill(2048,
	Array.fill(20, { |i| if (i.even) { 0 } { 1 / (i + 1).squared } })
		++ [0.2, 0.15, 0.1, 0.08, 0.05],
	Array.fill(25, { 2pi.rand })), 1);
```

---

# Masking

A train with a fixed fundamental is a steady buzz. **Masking** is a rule applied to the train after it has been generated, deciding which pulses sound at all, and it is where the rhythm of pulsar synthesis comes from.

Roads takes the term from Xenakis. There are three implementations in the code:

- **Probability**, where each pulse survives with probability *p*
- **Burst and rest**, where the train is grouped into *n* sounding and *m* silent
- **Channel**, where consecutive pulses are sent to different positions

The pulsaret and both frequencies are untouched throughout.

---
class: light
---

# Masking

<div class="shot"><img src="/figures/pulsar-masking-000.svg" /></div>

---

# Masking in Code

```supercollider
// each pulse survives with probability prob
trig = CoinGate.ar(prob, trig);

// then the survivors are grouped: burst sounding, rest silent
trig = trig * Demand.ar(trig, 0,
	Dseq([Dser([1], burst), Dser([0], rest)], inf));

// and a position is demanded once per surviving pulse
mask = Demand.ar(trig, 0, Dseq([
	Dser([-1], chanMask), Dser([1], chanMask), Dser([0], centerMask)
], inf)).lag(0.005);
```

`Demand.ar` asks its stream for one value per trigger, so the mask advances **per pulse** rather than per second. That is why the pattern stays locked to the train when `fund` changes.

<span class="note">*PulsarsAdvanced.scd*, the masking section.</span>

---

# Flux

A pulsar train with constant parameters is recognisable as a synthetic object within a second. **Flux** is a bounded random walk applied to both frequencies, and the bound is the part that matters: unbounded, the walk leaves the useful range and does not come back.

```supercollider
// inside the SynthDef: a slow walk around 1, multiplying both frequencies
flux  = LFDNoise3.ar(fluxRate, fluxAmt, 1).lag(0.2);
grain = form * flux;
trig  = Impulse.ar(fund * LFDNoise3.kr(fluxRate, fluxAmt * 0.5, 1).lag(0.2));
```

<span class="q">Run the flux example with `fluxAmt` at 0, 0.05, 0.15 and 0.35. Where does it stop being the same sound?</span>

---

# Pulsar Excitations

A pulsar has a wide spectrum and a sharp attack, which is suitable for resonators. Treated as an **excitation** rather than as the finished sound, the train carries the rhythm and the resonator carries the pitch.

```supercollider
~freqs = [110, 164, 247, 371, 556, 833];   // any set will do

Ringz.ar(sig, ringFreq, ringDecay)                    // one resonance each
CombL.ar(sig, 0.2, combFreq.reciprocal, combDecay)    // pitch and echo at once
DynKlank.ar(`[~freqs, nil, decays], sig)              // the whole set in one bank
```

<span class="note">*PulsarsAdvanced.scd*, the last two sections.</span>

---

# Grainlet

The fourth variety does not describe a sound.

> "The fundamental notion of grainlet synthesis is that any parameter of synthesis can be made dependent on (or linked to) any other parameter."

There is no grainlet UGen. There is a grain, and a set of **rules** stating which of its parameters depend on which.

Roads' first case is the **wavelet** relationship, where high grains are short and low grains long. He is explicit that the general case is what matters.

---
class: light
---

# Parameter Linkage

<div class="shot"><img src="/figures/linkage-000.svg" /></div>

---

# Linkage

The same sequence is played with and without a linkage.

```supercollider
// no linkage: frequency and duration chosen independently
Routine({
	200.do {
		Synth(\grainlet, [\freq, exprand(200, 4000), \dur, rrand(0.01, 0.12)]);
		0.04.wait;
	};
}).play;

// duration follows frequency: high grains short, low grains long
Routine({
	200.do {
		var freq = exprand(200, 4000);
		Synth(\grainlet, [\freq, freq, \dur, freq.explin(200, 4000, 0.12, 0.008)]);
		0.04.wait;
	};
}).play;
```

<span class="q">One number became a function of another.</span>

---

# Linkages as Data

Written this way the linkages are a **structure**, rather than statements inside a loop.

```supercollider
~links = (
	dur:   { |i, n, freq| freq.explin(120, 6000, 0.14, 0.006) },
	pan:   { |i, n, freq| freq.explin(120, 6000, -0.9, 0.9) },
	depth: { |i, n, freq| i / n * 0.8 },
	amp:   { |i, n, freq| 0.2 * (1 - (i / n * 0.5)) }
);

~cloud = { |n = 240|
	Routine({
		n.do { |i|
			var freq = exprand(120, 6000), args = [\freq, freq];
			~links.keysValuesDo { |k, f| args = args ++ [k, f.value(i, n, freq)] };
			Synth(\grainlet, args);
			0.03.wait;
		};
	}).play;
};

~links.removeAt(\dur); ~cloud.value;   // remove a link, hear what it was doing
```

---
layout: center
class: divider
---

Patterns

---

# Patterns

Every example so far emits its grains from a **Routine**: a loop that computes some numbers, makes a `Synth`, and waits.

A **Pbind** describes the same approach as a set of parallel streams, one per parameter. Nothing about the sound changes, and the SynthDefs are untouched.

What you gain is that the specification is now a value, so it can be stored, combined and replaced while it plays. What you lose is the Routine's local variables, and with them the easiest way to write a linkage.

<span class="note">*PatternGrains.scd* has all three variants written both ways.</span>

---
class: light
---

# Parallel Streams

<div class="shot"><img src="/figures/pbind-event-000.svg" /></div>

---

# Routine and Pbind

```supercollider
// the glisson cloud as a Routine
Routine({
	500.do { |i|
		Synth(\gliss, [\buf, ~voice.bufnum, \dur, 0.02, \start, i * 0.002,
			\from, 1.0 + (i * 0.002), \to, 2.0 + (i * 0.016)]);
		0.01.wait;
	};
}).play;

// the same cloud as a Pbind
Pbind(
	\instrument, \gliss,
	\buf, ~voice.bufnum,
	\dur, 0.02,                    // the grain's own length
	\delta, 0.01,                   // the wait between grains
	\start, Pseries(0, 0.002, 500),
	\from,  Pseries(1.0, 0.002, 500),
	\to,    Pseries(2.0, 0.016, 500)
).play;
```

<span class="q">`dur` and `delta` are the same number in a Routine.</span>

---

# Linkage with Pkey

`Pkey` reads a key that has already been computed for this event, which is how a linkage is written without a local variable.

```supercollider
// duration follows frequency: high grains short, low grains long
Pbind(\instrument, \grainlet, \delta, 0.04,
	\freq, Pexprand(200, 4000),
	\dur,  Pkey(\freq).explin(200, 4000, 0.12, 0.008),
	\pan,  Pwhite(-1.0, 1.0)).play;

// two linkages from the one source, and the cloud is ordered in space as well
Pbind(\instrument, \grainlet, \delta, 0.03,
	\freq, Pexprand(200, 4000),
	\dur,  Pkey(\freq).explin(200, 4000, 0.12, 0.008),
	\pan,  Pkey(\freq).explin(200, 4000, -1.0, 1.0)).play;
```

<span class="note">Key order matters: `\freq` has to be written before anything that reads it.</span>

---

# Base and Drift

Flux can be written on the pattern side instead, and then it composes with a trajectory: a **base** that goes somewhere, times a **drift** that wanders. The drift is a value that remembers, so it is a `Pfunc` over a variable, and `Pkey` multiplies the two.

```supercollider
var formDrift = 1.0, fundDrift = 1.0;

Pmono(\pulsarM, \wavebuf, ~pOdd.bufnum, \envbuf, ~envbuf, \amp, 0.3, \dur, 0.1,
	\formBase, Pseg(Pseq([200, 1600, 400], inf), Pseq([8, 6, 10], inf), \exp),
	\fundBase, Pseg(Pseq([20, 70, 12], inf), Pseq([9, 7, 11], inf), \lin),
	\formDrift, Pfunc { formDrift = (formDrift * rrand(0.985, 1.015)).clip(0.75, 1.35) },
	\fundDrift, Pfunc { fundDrift = (fundDrift * rrand(0.99, 1.01)).clip(0.8, 1.25) },
	\form, Pkey(\formBase) * Pkey(\formDrift),
	\fund, Pkey(\fundBase) * Pkey(\fundDrift)).play;
```

<span class="note">The `clip` is the bound.</span>

---

# Amplitude and Overlap

Grains do not sum in phase, so a dense cloud grows with the **square root** of the overlap rather than with the number of grains.

```supercollider
~amp = Pfunc { |e| 0.6 * sqrt((e[\delta] / e[\dur]).min(1)) };
```

The event knows its own `dur` and `delta`, so one expression covers every density in the file. The `min(1)` matters: the correction exists for overlap, and when a grain is shorter than the gap after it there is nothing to correct.

<span class="q">Change `delta` while a cloud plays.</span>

---

# Replacing a Cloud While It Plays

`Pdef` holds a pattern under a name. Evaluate a new definition and the next event comes from it, with no gap.

```supercollider
Pdef(\gr, Pbind(\instrument, \grainlet, \delta, 0.04,
	\freq, Pexprand(200, 4000), \dur, 0.05, \amp, ~gamp)).play;

// re-evaluate this with the first still playing
Pdef(\gr, Pbind(\instrument, \grainlet, \delta, 0.01,
	\freq, Pexprand(200, 800), \dur, 0.2, \amp, ~gamp));

Ppar([ /* one Pbind per variant */ ]).play;   // several variants at once
```

<span class="note">This is the practical reason to write clouds as patterns rather than as Routines.</span>

---
layout: center
class: divider
---

Live Granulation

---

# Granulating a Sound as It Arrives

Every example so far granulates a **recording**: the buffer is full before the first grain is emitted.

A source can also be written into a circular buffer while it is being granulated out of it. The buffer holds only the last few seconds, and the grains are taken from behind the write head.

The **delay** between the write head and the read position is the whole control. Too small and the reader catches up with the writer and reads what has not been written yet.

<span class="note">*LiveGranulation.scd*, one recorded source and one synthetic source.</span>

---
class: light
---

# Three Nodes and One Buffer

<div class="shot"><img src="/figures/live-granulation-000.svg" /></div>

---

# Live Granulation in Code

```supercollider
SynthDef(\writer, { |in = 0, out = 0, buf = 0|
	var pos = Phasor.ar(0, 1, 0, BufFrames.kr(buf));
	BufWr.ar(In.ar(in, 1), buf, pos);
	Out.ar(out, pos);                        // the position, as an audio signal
}).add;

SynthDef(\reader, { |buf, in, rate = 1, dur = 0.4, delay = 0.1|
	var pos = In.ar(in) / BufFrames.kr(buf); // normalised
	pos = pos - delay;                       // trail the write head
	Out.ar(0, GrainBuf.ar(1, Impulse.ar(20), dur ! 2, buf,
		rate, pos.wrap(0, 1)) * 0.5);
}).add;

Synth(\reader, [...]);   // started in reverse, so the writer
Synth(\writer, [...]);   // ends up ahead of the reader in the node order
Synth(\source, [...]);
```

<span class="q">Start the three in the order they are written instead. What do you hear?</span>

---

# Transformation and Reconstruction

Two further files, both concerning a **recording** rather than a synthetic particle.

- *Graintrnsfrm.scd* transforms each grain on its way past: filtered, shifted, panned, one decision per particle
- *Reconstruction.scd* takes a recording apart and puts it back together, useful as a **blueprint**

---

# Next Steps

- Run the variant files in order, and keep *Grainlet.scd* for last
- Take one glisson sequence and change only its magnetization pattern
- Add a spectral variation to the trainlet, so the harmonics are not all equally strong
- Run *LiveGranulation.scd* and find the smallest delay that still works
- Take one mask from *PulsarsAdvanced.scd* and drive it from a pattern instead of a constant

<span class="note">The files are *Glisson.scd*, *Trainlet.scd*, *Pulsars.scd*, *PulsarsAdvanced.scd*, *Grainlet.scd*, *Graintrnsfrm.scd*, *Reconstruction.scd*, *PatternGrains.scd* and *LiveGranulation.scd*.</span>

---
layout: center
class: divider
---

Exercises

---

# Exercises

1. Create a **glisson synthesis** variant where each of the glissandi goes progressively lower in pitch.

2. Create a layered version of a **pulsar synthesis** train where each layer has a different waveform, envelope and potentially frequency as well.

3. Extend the example of **trainlet synthesis** by including not only the synthetic impulses but also sampled sound.

4. Extend any of the included examples by making them a **function** that can generate clouds of a certain duration.

---

# Exercises

5. Create a **granular texture** that evolves from dense to sparse, with at least two different voices created with a granular UGen and multichannel expansion.

6. Create a **movement** of granular sound controlled by audio rate waveforms, mixing more than one buffer to read from.

7. Experiment with **coupling parameters**, so that only two or three controls are mapped to all the granular controls used.

8. Implement a **granular routine** where each grain is filtered, enveloped, speed-shifted and panned differently.

---

# Exercises

9. Take one of the above and write it as a **Pbind**, with at least one parameter derived from another using `Pkey`.

10. Build a **live granulation** where the delay is not fixed but moves, and describe what the moving delay does to the material.

11. Use `Pdef` to replace a playing cloud with a different one, so that the change is heard as a **transition** rather than as a stop and a start.

12. Write a **mask** that is not in the file: a sieve, a rhythm read from an array, or a mask driven by the amplitude of another signal.

13. Excite a set of resonators with a pulsar train, where the **set** and the **rhythm** are composed separately and can be changed independently.

<span class="workshop">- workshop -</span>
