---
theme: seriph
addons:
  - ./shared
title: Programming and Music 2 — 02 Granularity
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

<div class="deck-title">Granularity</div>

<div class="sub">
  Programming and Music 2
  <a href="https://www.bjarni-gunnarsson.net">https://www.bjarni-gunnarsson.net</a>
</div>

<!--
First class of the Material block. The four listening examples are not in this deck: play
them from your own library at the slides that name them.
-->

---

# Microsound

**Microsound** is a term used to discuss extremely short time scales of sound, and the music composed with a focus on these scales.

**Granular synthesis** is an example of a microsound-related activity.

Granular synthesis uses large numbers of **grains** to create higher level sonorities. The magnitude of the task requires a computer algorithm, and is also well suited for implementing compositional methods.

---

# Microsound

Perhaps the only synthesis technique not described as a set of equations.

An **attitude**, not a specific activity, that involves building sounds using small particles of **10 to 100 ms**.

> "Lends itself for experimentation with compositional methods, due to the relative lack of acoustic limitations (it always sounds good whatever you do)."

<span class="note">Paul Berg</span>

The term *microsound* was first used by **Xenakis**, and the synthesis method originally comes from his artistic vision.

---
class: light
---

# Xenakis

> "Events such as the collision of hail or rain with hard surfaces, the song of cicadas in a summer field, a political crowd of dozens or hundreds of thousands of people... It is an event of great power and beauty in its ferocity. Then the impact between the demonstrators and the enemy occurs. ...Imagine, in addition, the reports of dozens of machine guns and the whistle of bullets adding their punctuations to the total disorder. The crowd is then rapidly dispersed, and after sonic and visual hell follows a detonating calm, full of despair, dust, and death."

<div class="src">(Iannis Xenakis, Formalized Music)</div>

---
class: light
---

# Di Scipio

> "Most of the richness and complexity of sound afforded by this approach stems from the fact that micro-time sonic design does not implicitly prescribe any particular acoustic model: it is the implementation of a compositional micro-level strategy which determines the kind of sound behavior modelled or produced. That is, what is implemented is a model describing how quanta of acoustic energy are distributed in the time-domain, and how the temporal organisation of those innumerable elementary sonic units may result in a global auditory image."

<div class="src">(Agostino Di Scipio, Micro-time Sonic Design)</div>

---

# Time Scales

For **Schoenberg** the smallest element of a piece is the **note**. With notes one can construct motives. Motives can then construct phrases, which can be used to construct themes, and from those one arrives at musical compositions.

> "Smaller forms may be expanded by means of external repetitions, sequences, extensions, liquidations and broadening of connectives. The number of parts may be increased by supplying codettas, episodes, etc. In such situations, derivatives of the basic motive are formulated into new thematic units."

<span class="note">Schoenberg, 1967</span>

---

# Time Scales of Music

<div class="topics">
1. <b>Infinite</b> &nbsp;the ideal time span of mathematical durations<br>
2. <b>Supra</b> &nbsp;beyond that of an individual composition: months, years, decades<br>
3. <b>Macro</b> &nbsp;overall musical architecture or form, in minutes or hours<br>
4. <b>Meso</b> &nbsp;groupings of sound objects into hierarchies of phrase structures<br>
5. <b>Sound object</b> &nbsp;a basic unit of musical structure, generalizing the note<br>
6. <b>Micro</b> &nbsp;particles on a time scale down to the threshold of perception<br>
7. <b>Sample</b> &nbsp;the atomic level of digital audio systems<br>
8. <b>Subsample</b> &nbsp;fluctuations too brief to be properly perceived<br>
9. <b>Infinitesimal</b> &nbsp;the ideal time span of mathematical durations
</div>

<span class="note">Curtis Roads, Microsound</span>

---

# Macro

Top-down or bottom-up?

The **top-down** approach considers form as a preconceived global plan, where the details are completed at later stages of the composition.

The **bottom-up** approach considers form as the result of interaction between materials, where the overall form is brought forward by lower level relationships.

For many, composition involves a **tension** between the top-down and bottom-up approaches.

---

# Meso

Phrases and local structures.

Sequences, combinations and transmutations that constitute musical ideas usually unfold on the **meso** level.

They give rise to **sound masses**, **textures**, and **clouds** of sound objects.

---

# Sound Object

The **note**, an elementary unit of composition in scores.

The term *sound object* originates from **Pierre Schaeffer**, who used it for any sound whose origin was easily identifiable.

Notes can usually be described by four main attributes: **pitch**, **timbre**, **dynamics** and **duration**.

They involve generalization, as MIDI does, which is not always useful for discussing the inner life of sounds, or the possibilities in electronic music.

---

# Micro

Lasting from the **threshold of perception** up to short sound objects lies the domain of microsound.

Inaccessible until rather recently, microsound offers original options for composing sounds using the computer.

**Transient events** happening on the micro level influence highly how we perceive sound. These do not always reach perception until they occur in masses, forming collected sound objects.

---
class: light
---

# Duration

> "One of the most important properties of a sound is its duration. Certain sonic processes require a sufficient duration to unfold. For example, the sweep of the cutoff frequency of a filter is most effective on a timescale greater than 100 ms. When the duration of any sound is very short (e.g., less than 20 ms), it is perceived as a transient event, regardless of its inner structure. As the duration of an event shrinks toward 1 ms, its amplitude envelope affects its spectrum more than its waveform, due to the effects of convolution."

<div class="src">(Curtis Roads)</div>

---

# Perception

Sounds with a very short duration must be **greater in intensity** than longer ones in order to be perceived equally.

The onset of one impulse rapidly succeeding another can **mask** the second one, and any following it. This contributes to the illusion of a continuous sound.

---

# Perception

Pitch recognition is dependent on frequency, where the highest definition occurs in the **mid-range**.

It is possible to hear microevents as short as **1 ms**. Such short sounds are mostly perceived as **clicks**, with a distinguishable timbre, amplitude and spatial position.

---

# Xenakis

Conceives a granular vision for sound composition. Came up with the term **microsound** in 1960.

Mentions **Gabor** in *Formalized Music*, but later refers to Einstein as his inspiration.

*Concret PH* (1958) is made from recordings of burning charcoal, arranged in a dense and rich configuration with a simple macroform.

*Analogique B* is created from granular sine tones projected on three dimensional **screens**, with representations for frequency, amplitude and time.

---
class: light
---

# Screens

> "All sound is an integration of grains, of elementary sonic particles, of sonic quanta ... all sound, even continuous musical variation, is conceived as an assemblage of a large number of elementary sounds adequately disposed in time. In the attack, body, and decline of a complex sound, thousands of pure sounds appear in a more or less short interval of time ∆t..."

<div class="fig"><img src="/figures/screens-000.png" /></div>

<div class="src">(Iannis Xenakis, Formalized Music)</div>

---
layout: center
class: divider
---

Xenakis, Concret PH (1958)

<!--
Play it. Recordings of burning charcoal, and nothing else. Ask what the smallest audible
unit is before saying anything about grains.
-->

---
class: light
---

# Stockhausen

> "If the rate of beat is gradually increased beyond the time constant of the filter and the limits beyond which the ear can no longer differentiate, what started as a rhythmically repeated note becomes continuous. . . . We see a continuous transition between what might be called durational intervals which are characterized as rhythmic intervals and durational intervals characterized as pitch levels."

<div class="src">(Karlheinz Stockhausen, 1955)</div>

---

# Stockhausen

**Pitch and rhythm** can be considered as one and the same concept.

The serial method applied to rhythm as well as pitch. Creating a scale of durations that is interesting both logically and perceptually remains a hard problem.

---

# One Generator, Two Perceptions

The same impulse train, read at rising rates. Nothing changes but the rate.

```supercollider {*|1-2|4-5|7-8|*}
// up: a pulse becomes a tone
{ Impulse.ar(Line.kr(1, 120, 15)) }.play;

// down: a tone becomes a pulse again
{ Impulse.ar(XLine.kr(1000, 1, 5)) }.play;

// up and down, through the boundary twice
{ Impulse.ar(EnvGen.kr(Env.new([1, 1000, 1], [5, 5]))) }.play;
```

<span class="q">At what rate did you stop counting and start hearing a pitch?</span>

<!--
Run the first one and say nothing. Somewhere around 20 Hz the room stops hearing rhythm.
This is Stockhausen's sentence made audible, and it is the argument for the whole class.
-->

---

# Curtis Roads

Realized his first granular study in **1974** using the Music V synthesis language.

Has written his own programs for granular synthesis, first with Algol, then C, and recently with **SuperCollider**.

Author of many granular techniques such as **glisson**, **grainlet**, **trainlet** and **pulsar** synthesis. These are covered in detail in his book *Microsound*.

<span class="note">Class 03 is built on that taxonomy.</span>

---

# Curtis Roads

Has written many pieces with granular synthesis and microsound, such as *Nscor* (1980), *Half-life* (1999) and *Volt air* (2003).

---

# Horacio Vaggione

Gives attention to the interaction between **algorithmic processes** and musical composition.

The problem of **black box** algorithmic composition is that the only way to intervene is to edit the output. Vaggione thinks of *a plurality of diverse options* rather than a single algorithm.

This allows the composer to envisage *direct actions*, or interventions, to interact with the algorithm.

---

# Horacio Vaggione

Vaggione does not believe in *inner life* or *infinitesimal*, since these ideas concern space, while he sees things in the form of **time**.

Time as **irreversible**. A sound cannot be seen in terms of periodicity, but as a dynamic, energetic phenomenon.

The musical interest of a granular approach consists in the **musical treatment** of the elements present at the microscale.

---
layout: center
class: divider
---

Vaggione, Points Critiques (2011)

---
layout: center
class: divider
---

Blackburn, Petites étincelles (2015)

---
layout: center
class: divider
---

Gunnarsson, Ubieties (2015)

---

# Granular Synthesis

A **grain** is a microsonic event, typically lasting from 10 to 100 ms.

Each grain has a **waveform** and an **envelope**. The waveform is often a small portion of a sampled sound, but it can also be synthetic.

Thousands of grains are then played in succession, and they can also overlap, to form a higher level sound object.

If *n* is the number of controls needed per grain, and *d* is the number of grains per second, then the total number of parameters is *n* times *d*. Since *n* is normally greater than ten, and *d* can be up to a thousand, a **global strategy of organization** is required.

---

# Granular Synthesis

The characteristics of granular synthesis variants usually differ in the approach to **globally organizing** grains. The most important parameters are:

- **Density** of grains
- **Rate** of grain generation
- **Regularity** of grain generation
- **Duration** of each grain
- **Frequency**, **amplitude** and **waveform** of each grain

---
class: light
---

# Grains

<div class="shot"><img src="/figures/grains-000.png" /></div>

<div class="src">(Curtis Roads, Microsound)</div>

---

# Granular Synthesis

**Synchronous** granular synthesis is when each grain is generated at a regular interval or rate.

**Quasi-synchronous** granular synthesis is when intervals are slightly deviated, creating irregularity in the grain stream.

**Asynchronous** granular synthesis operates without regular intervals, and generates grain masses instead, by scattering grains according to a distribution algorithm.

---

# Granular Synthesis

The product of density and grain length is often referred to as the **fill factor**.

Density of grains can influence the perceived pitch of an event, and so can the grain envelope. In granular synthesis the control parameters are often related and **tightly coupled**.

<span class="q">If two knobs always move together, how many knobs are there really?</span>

---

# One Grain, Four Envelopes

The same sine grain under four different windows. Only the shape of the envelope changes.

```supercollider {*|3-5|7-9|11-13|*}
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

<!--
The envelope shape is used constantly in this course and almost never named. These are the
ten in Windows.scd, drawn from the numbers the file actually produces. Rect is the one to
play first, because the click at each edge is the whole argument for all the others.
-->

---

# Ten Windows, One Grain

The envelope is a buffer, and `GrainBuf` reads it as the grain's shape.

```supercollider {*|1-8|10-13|15-18|*}
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

<span class="note">`Env.welch` does not exist. `\welch` is a curve name for a segment, which is a different thing. All ten are in *Windows.scd*.</span>

<!--
Play rect, then hann, then swap back. The click is not a bug in the code, it is the
waveform being cut mid-cycle, and every other window on the previous slide exists to
avoid it. Then drop grdur to 4 ms and play rect against gauss: at that length the envelope
is the spectrum.
-->

---

# Reading a Buffer

Three ways with the same UGen. The arguments are the technique.

```supercollider {*|1-5|7-11|13-19|*}
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

<!--
The whole of GrainUGens.scd is variations on these three moves: where you read, how fast,
and how many at once. Play the second one twice, once with the envelope on both arguments
and once with it only on position.
-->

---
class: light
---

# Anatomy of a Grain

<div class="shot"><img src="/figures/grain-anatomy-000.svg" /></div>

<!--
Roads' figure 3.1, redrawn, with his three periodicities from page 94 underneath. Point at
each of the three and name the GrainBuf argument that sets it. The rest of this section is
that mapping worked through.
-->

---

# GrainBuf

The UGen that granulates a **buffer**. Ten arguments, and one sentence in the help file that explains all of them.

> "All args except `numChannels` and `trigger` are polled at grain creation time."

A grain reads every setting **once**, at the moment it is born, and then keeps those values until it dies. You cannot change a grain while it sounds.

<span class="note">`GrainSin`, `GrainFM` and `GrainIn` behave the same way. `TGrains` is the older sibling with fewer arguments and no envelope control.</span>

---
class: light
---

# Ten Arguments

<div class="shot"><img src="/figures/grainbuf-args-000.svg" /></div>

<!--
Only trigger is live. Eight are frozen at birth. numChannels and maxGrains cannot even be
changed after the SynthDef compiles, which catches people who try to make them synth
arguments.
-->

---

# One Grain at a Time

Before a cloud, a single grain, fired slowly enough to hear on its own.

```supercollider {*|1-2|4-6|*}
// one grain, roughly once a second, from a third of the way into the buffer
{ GrainBuf.ar(2, Impulse.kr(0.8), 0.08, ~voice.bufnum, 1, 0.3) * 0.6 }.play

// the same grain, with its length under the mouse
{ GrainBuf.ar(2, Impulse.kr(2), MouseX.kr(0.001, 0.2, \exponential),
	~voice.bufnum, 1, 0.3) * 0.6 }.play
```

<span class="q">Sweep the mouse left. Where does the grain stop being a sound and become a click?</span>

<!--
The answer is around 2 ms, and it is the same boundary as the first class: under 2 ms a
grain has more than 250 Hz of spectral spread, wider than a critical band, so pitch is gone
whatever the waveform inside it was.
-->

---
class: light
---

# Polled at Birth

<div class="shot"><img src="/figures/grainbuf-poll-000.svg" /></div>

<!--
This is measured, not drawn from intuition: a ramp in the buffer, pos swept by a Line, and
each grain came out holding a value 0.025 higher than the one before. A staircase. Say
plainly that this is the single most common source of confusion with GrainBuf.
-->

---

# The Staircase, Heard

The same sweep twice. Only the grain size and the rate change.

```supercollider {*|1-2|4-5|*}
// long grains, few of them: you hear eight fixed excerpts, not a scrub
{ GrainBuf.ar(2, Impulse.kr(2), 0.4, ~voice.bufnum, 1, Line.kr(0, 1, 4)) * 0.6 }.play

// short grains, many of them: the steps are too small to hear separately
{ GrainBuf.ar(2, Impulse.kr(60), 0.05, ~voice.bufnum, 1, Line.kr(0, 1, 4)) * 0.3 }.play
```

<span class="note">Smoothness is not a property of the UGen. It is what happens when the steps get small enough.</span>

---
class: light
---

# Where the Pointer Goes

<div class="shot"><img src="/figures/grainbuf-pointer-000.svg" /></div>

<!--
Roads' three selection orders, page 199: deterministic progression, statistical evolution,
random. He describes the granulator as a delay line with pointers moving through it, and
never draws it. This is that picture.
-->

---

# Four Ways to Move

`pos` is a fraction of the buffer, 0 to 1. Its speed has nothing to do with the grain rate.

```supercollider {*|1-2|4-5|7-8|10-14|*}
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

<!--
The last one is Roads' statistical evolution: probabilistically left to right rather than
strictly. Run the frozen one and move the mouse very slowly. That is the whole of freezing.
-->

---
class: light
---

# Fill Factor

<div class="shot"><img src="/figures/grain-density-000.svg" /></div>

<!--
Two numbers decide whether a cloud has holes in it, and they are not independent. Roads'
own thresholds at a 25 ms grain: under 15 a second reads as rhythm, 15 to 25 flutters,
25 to 50 loses the order of the grains, 50 to 100 becomes a texture band, over 100 a
continuous mass.
-->

---

# Density, Heard

Same grain length throughout. Only the rate changes.

```supercollider {*|1-2|4-5|7-8|10-11|*}
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

<span class="note">Curtis Roads, Composing Electronic Music: A New Aesthetic</span>

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
