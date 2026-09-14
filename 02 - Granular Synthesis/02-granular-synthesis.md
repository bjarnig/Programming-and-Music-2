---
theme: seriph
addons:
  - ./shared
title: Programming and Music 2 — 02 Granular Synthesis
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

<div class="deck-title">Granular Synthesis</div>

<div class="sub">
  Programming and Music 2
  <a href="https://www.bjarni-gunnarsson.net">https://www.bjarni-gunnarsson.net</a>
</div>

---

# Granular synthesis

Perhaps the only synthesis technique not described as a set of equations.

An **attitude**, not a specific activity, that involves building sounds using small particles of **10 to 100 ms**.

> "Lends itself for experimentation with compositional methods, due to the relative lack of acoustic limitations (it always sounds good whatever you do)."

<span class="note">Paul Berg</span>

The term *microsound* was first used by **Xenakis**, and the synthesis method originally comes from his artistic vision.

---

# Dennis Gabor

A physicist working on the analysis of signals rather than on music. Three papers, **1946, 1947 and 1952**, propose that any sound can be decomposed into a family of functions obtained by shifting a single **Gaussian particle** in time and in frequency.

He argues against Fourier analysis as a model of hearing, because it describes a sound in terms of periodic waves of infinite duration, while a sound has a time pattern as well as a frequency pattern.

The unit that follows is the **acoustic quantum**: a sinusoid under a Gaussian envelope, short enough to be a grain and narrow enough to have a frequency.

---

# Xenakis

Coined the term **microsound** in 1960, and was the first musician to set out a compositional theory for grains.

*Concret PH* (1958) is made from recordings of burning charcoal cut into one second fragments and mixed to vary the density. There is no electronic alteration of the source, since filtering would diminish its richness.

*Analogique B* (1959) is the systematic one. Sine tones recorded to tape and cut into fragments, then organised with **screens**, taking the cell size from the Gabor matrix by way of Meyer-Eppler and Moles.

---
class: light
---

# Screens

<div class="shot"><img src="/figures/screens-algo-000.svg" /></div>

---
layout: center
class: divider
---

<Listen file="xenakis-concret-ph.mp3">Xenakis, Concret PH (1958)</Listen>

---

# Stockhausen

Worked with impulse generators at the Cologne studio. An impulse has neither pitch nor timbre of its own; it is a brief energy impetus that forms pulse or tone.

*How Time Passes* (1957) argues that **period** is a single concept. It appears in rhythm, from 6 seconds down to a sixteenth of a second, and in pitch, from a sixteenth of a second down to a three thousand two hundredth.

Pitch and rhythm are then the **same phenomenon at different rates**, and the serial method can be applied to duration as it is to pitch. That problem occupies the rest of the text.

---
class: light
---

# Rhythm and Pitch

<div class="shot"><img src="/figures/continuum-algo-000.svg" /></div>

---

# Rate and Perception

The rate of an impulse train is swept upward, then downward, then both.

```supercollider
// up: a pulse becomes a tone
{ Impulse.ar(Line.kr(1, 120, 15)) }.play;

// down: a tone becomes a pulse again
{ Impulse.ar(XLine.kr(1000, 1, 5)) }.play;

// up and down, through the boundary twice
{ Impulse.ar(EnvGen.kr(Env.new([1, 1000, 1], [5, 5]))) }.play;
```

<span class="q">At what rate does counting become hearing a pitch?</span>

---

# Curtis Roads

Realised his first granular study in **1974** with the Music V synthesis language, and has written his own granular programs since, first in Algol, then C, and recently in **SuperCollider**.

Author of **glisson**, **grainlet**, **trainlet** and **pulsar** synthesis, set out in his book *Microsound*, along with the nine time scales on the next slide.

Has written many pieces with granular synthesis, among them *Nscor* (1980), *Half-life* (1999) and *Volt air* (2003).

<span class="note">Class 03 features more of these examples.</span>

---
class: light
---

# Time Scales of Music

<div class="shot"><img src="/figures/timescales-algo-000.svg" /></div>

---

# Perception

Below about **200 ms** many aspects of hearing change character, which is the reason microsound needs its own account of perceptioncompared to other time scales.

**Loudness.** Short sounds must be greater in intensity than long ones to be heard as equally loud. A 1 ms tone pip needs about **20 dB** more than a 100 ms one.

**Fusion.** If one impulse follows another by less than 200 ms, the first tends to mask the second. A train at about **20 a second** fuses into a continuous tone, which is the same crossing Stockhausen described, arriving this time from the side of the ear.

**Acuity.** Events shorter than about **2 ms** are heard as clicks, and yet their waveform and frequency still change the timbre of the click. Even microsecond events are distinguished by amplitude, timbre and spatial position.

---
class: light
---

# Thresholds

<div class="shot"><img src="/figures/thresholds-algo-000.svg" /></div>

---

# Horacio Vaggione

Gives attention to the interaction between **algorithmic processes** and musical composition, across several time scales at once.

The problem with a **black box** is that the only way to intervene is to edit its output. Vaggione works instead with a plurality of operations, so that the composer can act directly at each scale.

He treats time as **irreversible**. A sound is a dynamic, energetic phenomenon rather than a periodicity, and the musical interest of a granular approach lies in the treatment of the elements at the microscale.

The working method is **micromontage**: a library of edited particles, placed on a timeline by hand, a few thousand at a time.

---
class: light
---

# Micromontage

<div class="shot"><img src="/figures/micromontage-algo-000.svg" /></div>

---
layout: center
class: divider
---

<Listen file="vaggione-points-critiques.mp3">Vaggione, Points Critiques (2011)</Listen>

---

# Granular Synthesis

A **grain** is a microsonic event, typically lasting from 10 to 100 ms.

Each grain has a **waveform** and an **envelope**. The waveform is often a small portion of a sampled sound, but it can also be synthetic.

Thousands of grains are then played in succession, and they can also overlap, to form a higher level sound object.

If *n* is the number of controls needed per grain, and *d* is the number of grains per second, then the total number of parameters is *n* times *d*. Since *n* is normally greater than ten, and *d* can be up to a thousand, a **global strategy of organization** is required.

---
class: light
---

# Clouds

<div class="shot"><img src="/figures/cloud-algo-000.svg" /></div>

---

# Parameters

Variants of granular synthesis differ mostly in how they organise grains **globally**. The parameters divide into two levels.

Per **grain**:

- **Duration**, from a few milliseconds up
- **Waveform**, synthetic or read from a buffer, and the **read position** in it
- **Frequency** or playback rate
- **Amplitude**
- **Envelope** shape
- **Spatial position**

---

# Parameters

Per **cloud/texture/gesture**, a higher-level sound object

- **Start time** and **duration** of the event
- **Density**, in grains per second, which may itself be a curve
- **Rate** and **regularity** of grain generation
- **Frequency band**, given as an upper and a lower boundary curve, or restricted to a set of pitches
- **Amplitude envelope** of the whole cloud
- **Spatial variation**

<span class="note">After the cloud parameters in *Microsound*, chapter 3. Any of them may be a constant, a curve, or a range to draw from.</span>

---
class: light
---

# Grain Distribution

<div class="shot"><img src="/figures/streams-algo-000.svg" /></div>

---

# Grain Envelopes

The same sine grain is played under three envelope shapes.

```supercollider
(
// a rounded window: no click at either end
SynthDef(\gauss, { |amp = 0.5, freq = 440, sustain = 0.1|
	OffsetOut.ar(0, SinOsc.ar(freq) * EnvGen.ar(Env.sine(sustain, amp), doneAction: 2) ! 2);
}).add;

// a sharp attack and a long decay: the grain has a direction
SynthDef(\perc, { |amp = 0.5, freq = 440, sustain = 0.1|
	OffsetOut.ar(0, SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.1, 0.9, amp), timeScale: sustain, doneAction: 2) ! 2);
}).add;

// the same, reversed: it arrives rather than departs
SynthDef(\reversed, { |amp = 0.5, freq = 440, sustain = 0.1|
	OffsetOut.ar(0, SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.9, 0.1, amp), timeScale: sustain, doneAction: 2) ! 2);
}).add;
)
```

<span class="note">After Alberto de Campo, the Microsound chapter of the SuperCollider Book. The full set is in *TimeScales.scd*.</span>

---
class: light
---

# Grain Windows

<div class="shot"><img src="/figures/windows-000.svg" /></div>

---

# Window Buffers

`GrainBuf` reads the grain envelope from a buffer, passed as `envbufnum`.

```supercollider
// four come with SuperCollider, the rest are Envs or written out by hand
~windows = (
	rect:     Signal.rectWindow(1024),
	hann:     Signal.hanningWindow(1024),
	welch:    Signal.welchWindow(1024),
	sine:     Env.sine(1, 1).discretize(1024),
	expodec:  Env([1, 0.001], [1], \exp).discretize(1024),
	rexpodec: Env([0.001, 1], [1], \exp).discretize(1024)
);

// each one becomes a one-channel buffer
~envbufs = ();
~windows.keysValuesDo { |k, w| ~envbufs[k] = Buffer.sendCollection(s, w, 1) };

// and GrainBuf takes it as its ninth argument
{ GrainBuf.ar(2, Impulse.kr(12), 0.09, ~wave.bufnum, 1, 0, 2, 0,
	~envbufs[\rect].bufnum, mul: 0.3) }.play
```

<span class="note">`Env.welch` does not exist. `\welch` is a curve name for a segment, which is a different thing. All in *Windows.scd*.</span>

---

# Reading a Buffer

`TGrains` reads the buffer in three different ways below.

```supercollider
// straight through: the pointer follows a line across the buffer
{	var buf = ~voice.bufnum;
	TGrains.ar(2, Impulse.kr(10), buf, 1,
		Line.kr(0, BufDur.kr(buf), BufDur.kr(buf), doneAction: 2), 0.2);
}.play

// an envelope drives both the read position and the grain size
{	var buf = ~voice.bufnum, env = EnvGen.ar(Env([0, 1, 0.2, 0.8], [1, 2, 8]));
	TGrains.ar(2, Impulse.kr(10), buf, 1, env, env);
}.play

// five layers, each with its own random rate and position
{	var buf = ~voice.bufnum, trig = Impulse.kr(50);
	Mix.fill(5, {
		TGrains.ar(2, trig, buf, TRand.kr(0.5, 1.5, trig),
			TRand.kr(0, BufDur.kr(buf), trig), 0.1, TRand.kr(-1, 1, trig), 0.1)
	});
}.play
```

---
class: light
---

# Anatomy of a Grain

<div class="shot"><img src="/figures/grain-anatomy-000.svg" /></div>

---

# GrainBuf

The UGen that granulates a **buffer**. It takes ten arguments.

> "All args except `numChannels` and `trigger` are polled at grain creation time."

A grain reads every setting once, when it is created, and keeps those values until it ends. A grain cannot be changed while it is sounding.

<span class="note">`GrainSin`, `GrainFM` and `GrainIn` behave the same way. `TGrains` is the older sibling with fewer arguments and no envelope control.</span>

---
class: light
---

# Arguments

<div class="shot"><img src="/figures/grainbuf-args-000.svg" /></div>

---

# A Single Grain

A single grain, emitted slowly enough to be heard on its own.

```supercollider
// one grain, roughly once a second, from a third of the way into the buffer
{ GrainBuf.ar(2, Impulse.kr(0.8), 0.08, ~voice.bufnum, 1, 0.3) * 0.6 }.play

// the same grain, with its length under the mouse
{ GrainBuf.ar(2, Impulse.kr(2), MouseX.kr(0.001, 0.2, \exponential),
	~voice.bufnum, 1, 0.3) * 0.6 }.play
```

<span class="q">At what duration does the grain stop being a sound and become a click?</span>

---
class: light
---

# Grain Creation Time

<div class="shot"><img src="/figures/grainbuf-poll-000.svg" /></div>

---

# Position and Grain Size

The same sweep of `pos` is used at two grain sizes and two rates.

```supercollider
// long grains, few of them: you hear eight fixed excerpts, not a scrub
{ GrainBuf.ar(2, Impulse.kr(2), 0.4, ~voice.bufnum, 1, Line.kr(0, 1, 4)) * 0.6 }.play

// short grains, many of them: the steps are too small to hear separately
{ GrainBuf.ar(2, Impulse.kr(60), 0.05, ~voice.bufnum, 1, Line.kr(0, 1, 4)) * 0.3 }.play
```

<span class="note">The steps remain in both cases. They become inaudible when they are small and frequent enough.</span>

---
class: light
---

# Read Position

<div class="shot"><img src="/figures/grainbuf-pointer-000.svg" /></div>

---

# Moving the Read Position

`pos` is a fraction of the buffer, from 0 to 1. Its speed is independent of the grain rate.

```supercollider
// forward, slower than real time: a time stretch
{ GrainBuf.ar(2, Impulse.kr(40), 0.08, ~voice.bufnum, 1, Line.kr(0, 1, 20)) * 0.4 }.play

// frozen: one point, read over and over, under the mouse
{ GrainBuf.ar(2, Impulse.kr(40), 0.08, ~voice.bufnum, 1, MouseX.kr(0, 1)) * 0.4 }.play

// reversed: the pointer walks back while every grain still plays forwards
{ GrainBuf.ar(2, Impulse.kr(40), 0.08, ~voice.bufnum, 1, Line.kr(1, 0, 12)) * 0.4 }.play

// scattered inside a window that drifts
(
{	var trig = Impulse.kr(40), centre = Line.kr(0, 1, 20);
	GrainBuf.ar(2, trig, 0.08, ~voice.bufnum, 1,
		(centre + TRand.kr(-0.03, 0.03, trig)).clip(0, 1)) * 0.4
}.play
)
```

---
class: light
---

# Fill Factor

<div class="shot"><img src="/figures/grain-density-000.svg" /></div>

---

# Density

The grain length is constant and the rate varies.

```supercollider
// sparse, fill factor 0.2: you can count them
{ GrainBuf.ar(2, Impulse.kr(10), 0.02, ~bikecat.bufnum, 1, LFNoise1.kr(0.3).range(0, 1)) * 0.5 }.play

// covered, fill factor 1.0: the grains just meet
{ GrainBuf.ar(2, Impulse.kr(50), 0.02, ~bikecat.bufnum, 1, LFNoise1.kr(0.3).range(0, 1)) * 0.4 }.play

// packed, fill factor 2.0: the holes are gone
{ GrainBuf.ar(2, Impulse.kr(100), 0.02, ~bikecat.bufnum, 1, LFNoise1.kr(0.3).range(0, 1)) * 0.3 }.play

// or sweep the density and listen for where it closes up
{ GrainBuf.ar(2, Impulse.kr(XLine.kr(4, 200, 15)), 0.02, ~bikecat.bufnum, 1, LFNoise1.kr(0.3).range(0, 1)) * 0.3 }.play
```

<span class="note">Everything in this section is in *GrainBuf.scd*, one block per slide.</span>

---
class: light
---

# Brassage

<div class="fig tall"><img src="/figures/brassage-000.png" /></div>

<div class="src">(from Computer Sound Design and Synthesis Techniques, Miranda)</div>

---

# One Synth Per Grain

Everything so far has been one node with the grains inside it. The other way is one **node per grain**, scheduled by a pattern in the language.

```supercollider
SynthDef(\grain, { |buf = 0, rate = 1, start = 0, amp = 0.5, dur = 0.3, pan = 0, curve = 0|
	var shape = Env([0, amp, 0], [dur * 0.5, dur * 0.5], [curve, curve.neg]);
	var env = EnvGen.ar(shape, doneAction: 2);
	var pos = start * BufSamples.ir(buf);
	var sig = PlayBuf.ar(1, buf, rate * BufRateScale.ir(buf), 1, pos, 0);
	OffsetOut.ar(0, Pan2.ar(sig * env, pan));
}).add;
```

<span class="note">`OffsetOut` rather than `Out`, so a grain starts at the sample it was scheduled for rather than at the next block boundary.</span>

---

# Reading Through a Sound

The read position is a pattern, so the same three lines give a scan, a scatter, or a time-stretch.

```supercollider
// straight through, one grain every 10 ms
\start, Pseries(0, 1/n, n)

// scattered inside a narrow window of the file
\start, Pwhite(0.0, 0.1, n)

// through it eight times more slowly than it was recorded
\start, Pseries(0, next / totaldur / 8, n)
```

<span class="q">The grains are the same in all three. What changed?</span>

---

# Per Grain

Each grain is its own event, so any key can carry a pattern instead of a number. No new SynthDef is needed for any of these.

```supercollider
\pan,   Pwhite(-1.0, 1.0)                          // a mono source gains width
\rate,  Pwhite(-5, 5).midiratio                    // a cloud around the pitch
\rate,  Prand([-12, -5, 0, 7, 12, 19], inf).midiratio   // quantised to a chord
\dur,   Pwhite(0.01, 0.3)                          // noisy grains and audible ones
\curve, Pseg(Pseq([8, -8, 8], inf), 6, \lin)       // percussive to soft and back
\delta, Pseg(Pseq([0.005, 0.12, 0.005], inf), 8, \exp)  // the cloud thins out
```

<span class="note">All of it in *GrainPatterns.scd*, with the last example varying six of them at once.</span>

---

# Loudness

Grains overlap by `dur / delta`. At `dur 0.1` and `delta 0.01`, ten sound at once.

They do not sum in phase, so the result grows with the **square root** of the overlap rather than with the overlap itself. One expression then holds every example at the same level, whatever `dur` and `delta` are doing:

```supercollider
~amp = Pfunc { |e| 0.9 * sqrt(e[\delta] / e[\dur]) };
```

<span class="q">Where does the square root come from?</span>

<span class="note">Measured across the eleven examples in the file: peaks between 0.16 and 0.38, none clipping.</span>

---

# Granular Techniques

**Pitch-time changing.** Stretch or shrink the timescale of a sound without affecting its pitch.

**Freezing.** Stopping the grain read pointer. A single grain is read repeatedly, effectively freezing the sound.

**Deterministic selection.** The read pointer moves from left to right, in time order.

**Random selection.** Scattering. The read pointer selects from random points in the sound file.

---

# Granular Techniques

**Grain size variation.** Short grains induce noise into the signal.

**Granulation with pitch-shifting.** Each grain is pitch-shifted by a random amount within a range set by the user.

**Granulation with filtering.** Applying a band-pass filter to each grain, where the filter centre frequency is random within a range set by the user.

**Formant shifting.** Granulation with a variable formant shift that is independent of pitch.

**Atomic scrubbing.** Moving the playback cursor back and forth, for forward and backward playback at a variable speed.

<span class="note">Curtis Roads, Composing Electronic Music: A New Aesthetic</span>

---

# Granular Techniques

Four more that follow from the cloud parameters rather than from the read pointer.

**Spatial granulation.** Each grain gets its own position, so a mono source becomes a body of sound with width and depth.

**Sieving.** Restricting the grain frequencies to a set of pitches, so a cloud has a harmony.

**Granular delay.** Feeding the output back into the granulator, so each pass is granulated again.

**Convolution with a cloud.** A cloud of grains with a sharp attack and an exponential decay used as an impulse response.

<span class="q">Which of these change the source, and which change only how it is read?</span>

---
layout: center
class: divider
---

Exercises

---

# Exercises

1. Create a **granular texture** that evolves from dense to sparse, with at least two different voices created with a granular UGen and multichannel expansion.

2. Create a **movement** of granular sound controlled by audio rate waveforms, such as sine waves or `LFNoise`, mixing more than one buffer to read from.

3. Experiment with **coupling parameters**, so that only two or three controls are mapped to all the granular controls used.

4. Implement a **granular routine** where each grain is filtered, enveloped, speed-shifted and panned differently.

<span class="workshop">- workshop -</span>
