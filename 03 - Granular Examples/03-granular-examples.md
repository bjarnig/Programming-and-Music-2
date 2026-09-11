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

<!--
The code is the class. Have all five files open and run from them; the slides are
here to name what is happening and to say why the four species belong together.
-->

---

# Four Species

Last class was **the grain**: a waveform, an envelope, a duration, and a way of emitting them.

This class is the other three. **Glisson**, **trainlet** and **pulsar** are not separate techniques. They are the same emitter with something different inside the particle.

Roads calls them **varieties of particle synthesis**, and gives each a chapter section of its own. The useful thing is what they share.

<span class="note">Curtis Roads, Microsound, chapter 4.</span>

---
class: light
---

# One Engine

<div class="shot"><img src="/figures/engine-000.svg" /></div>

<!--
Say this before anything else and come back to it after each species. Duration, density,
envelope, amplitude and pan mean the same thing in all four. Once that lands, the fourth
species takes ten minutes rather than an hour.
-->

---

# Glisson

A grain whose frequency **moves while it sounds**. In signal processing it is called a **chirp**.

Roads took it from Xenakis, who described each grain as a **vector** in a space of time, frequency and amplitude, rather than as a point. A vector has a direction, so the grain can glide.

> "In glisson synthesis, each particle or glisson has an independent frequency trajectory, an ascending or descending glissando."

<span class="note">Roads implemented it in 1998 with Stephen Pope, in SuperCollider 1, and again in 1999 with Alberto de Campo in SuperCollider 2.</span>

---
class: light
---

# Magnetization

<div class="shot"><img src="/figures/magnetization-000.svg" /></div>

<!--
Roads' word, not a metaphor I invented. Three independent binary choices, so six clouds
out of one parameter. Our code does two of the six; the exercises ask for a third.
-->

---

# Glisson in Code

Our version glisses a **recording** rather than a synthetic waveform, by putting a line on the playback rate.

```supercollider {*|3-5|6|*}
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

# A Cloud of Glissons

The cloud walks the buffer while every particle glides further than the one before.

```supercollider {*|1|4-6|8-14|*}
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

<span class="q">Two `linlin` lines decide the whole shape of the cloud. Which magnetization pattern is this?</span>

---

# Trainlet

A particle that is a **short burst of impulses** rather than a waveform.

> "A trainlet is an acoustic particle consisting of a brief series or train of impulses. Like other particles, trainlets usually last between 1 to 100 ms."

Roads lists five parameters: **density** of the trainlets, their **attack time**, **pulse period**, **harmonic structure**, and **spectral energy profile**.

<span class="note">Impulse generators were standard equipment in the 1950s studios. The ones at WDR Cologne ran from 1.1 Hz to 10 kHz, which crosses the rhythm-to-pitch boundary in one dial.</span>

---

# Trainlet in Code

`Blip` is a band-limited impulse train, so the whole particle is one UGen.

```supercollider {*|5|6|*}
SynthDef(\trainlet, { |amp=1.0, dur=0.3, pan=0, density=20, harmonics=10|
	var sig, shape, env;
	shape = Env.perc(dur*0.2, dur*0.8);
	env = EnvGen.ar(shape, doneAction: 2);
	sig = Blip.ar(density, harmonics);
	OffsetOut.ar(0, Pan2.ar(sig * env, pan, amp));
}).add;
```

`density` is the pulse period and `harmonics` is the harmonic structure. The attack is in the envelope. The **spectral energy profile**, Roads' fifth parameter, is the one this version leaves out.

<!--
Worth naming the gap rather than hiding it: with harmonics fixed and no tilt across them,
every trainlet has the same spectral slope. Exercise 3 is the way in.
-->

---

# Pulsar

A **pulsaret** followed by a measured **silence**. The silence is the point: pulsar particles never overlap.

That separation buys two independent controls from one oscillator. The **period** sets the pitch, and the **pulsaret duration** sets a formant.

<span class="note">Roads gives pulsar synthesis the longest section in the chapter, and it is the species with the most written about it.</span>

---
class: light
---

# Two Frequencies, One Oscillator

<div class="shot"><img src="/figures/pulsar-000.svg" /></div>

<!--
Draw the analogy to pulse width modulation for anyone who knows analogue synths: the duty
cycle becomes formant-determining, and the contents of the duty cycle are arbitrary.
-->

---

# Pulsar in Code

The whole technique is three lines, because `GrainBuf` already emits particles.

```supercollider {*|2|3|4|5|*}
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

# Grainlet

The fourth species, and the one that is **not a sound**.

> "The fundamental notion of grainlet synthesis is that any parameter of synthesis can be made dependent on (or linked to) any other parameter."

There is no grainlet UGen and there could not be one. There is a grain, and a set of **rules** saying which of its parameters follow which.

Roads' first case is the **wavelet** relationship: high grains short, low grains long. But he is explicit that the general case is the point.

---
class: light
---

# Parameter Linkage

<div class="shot"><img src="/figures/linkage-000.svg" /></div>

<!--
This is the slide that connects the class to the rest of the year. A granular instrument
passes six to eight controls very quickly, which is more than an ear can hold at once.
Linkage is how you get a large parameter space you can still steer.
-->

---

# One Link

The same cloud twice. The only difference is one line of arithmetic.

```supercollider {*|1-6|8-14|*}
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

<span class="q">Nothing was added. One number became a function of another. Why does the second one hold together?</span>

---

# Links as Data

Written this way the rules are a **structure you can edit**, not statements buried in a loop.

```supercollider {*|1-6|8-17|19|*}
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

<span class="note">Add a key and you have added a link. This is the shape most of your assignment code should have.</span>

---

# Transformation and Reconstruction

Two more files, and both are about a **recording** rather than a synthetic particle.

- *Graintrnsfrm.scd* transforms each grain on its way past: filtered, shifted, panned, one decision per particle
- *Reconstruction.scd* takes a recording apart and puts it back together, and the interest is in **what survives**

<span class="q">Granulate a voice and hand it back. What is still recognisably the voice, and at what grain size does that stop?</span>

<!--
The 40 ms figure from Roads is the one to have ready: under it, sampled files lose their
identifiable qualities, and above it speech survives.
-->

---

# Next Steps

- Run all six files in order, and keep *Grainlet.scd* for last
- Take one glisson cloud and change only its magnetization pattern
- Add a spectral tilt to the trainlet, so the harmonics are not all equally strong
- Write one linkage that is not in the file, and be able to say what it does

<span class="note">The six files are *Glisson.scd*, *Trainlet.scd*, *Pulsars.scd*, *Grainlet.scd*, *Graintrnsfrm.scd* and *Reconstruction.scd*.</span>

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

<span class="workshop">- workshop -</span>
