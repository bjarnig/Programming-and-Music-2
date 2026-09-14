---
theme: seriph
addons:
  - ./shared
title: Programming and Music 2 — 04 Sound Transformation
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

<div class="deck-title">Sound Transformation</div>

<div class="sub">
  Programming and Music 2
  <a href="https://www.bjarni-gunnarsson.net">https://www.bjarni-gunnarsson.net</a>
</div>

---

# Sound Transformation

> "Making a good transformation is like writing a tune. There are no rules."

<span class="note">(Trevor Wishart)</span>

Sound transformation is the process of creating **timbral development** from one sound to another, sometimes described as metamorphosis from one point to another.

It can take place within a sound continuum, or between discrete sounds in a sequence.

It is a way of organising musical development: the way sounds in a piece relate to each other is through the change a sound undergoes.

---

# Sound Transformation

The nature of a sound calls for a specific type of transformation, so **materials and transformations are tightly coupled**.

Transformations can be used to generate **families**, or networks, of related sounds.

The set of potential transformations forms a composable network of outcomes. How those appear and relate can be a large part of the composition.

---

# Sound Transformation

**Identity**, **development**, **material state** and **mutation** are possible aspects to guide a transformation.

The work usually begins with detailed **analysis** of the sound, to find something worth taking hold of. To explore the inner qualities of a sound.

Used as a compositional method, transformation is a form of progression where new material is derived from old. Here it serves the **structural function of variation**.

---
class: light
---

# Zones of Morphosis

<div class="shot"><img src="/figures/morphosis-000.svg" /></div>

---

# Zones of Morphosis

> "Just as states of matter undergo critical phase transitions from solid to liquid to gas to plasma, sound phenomena can pass from one state to another. These zones of morphosis are of extreme interest from an aesthetic point of view, as they are intrinsically exciting and fascinating. Zones of morphosis can be seen as the places where a continuous change in a plastic medium confronts context dependent thresholds of human perception. They occur when a change in quantity in some parameter appears as a qualitative change to the listener."

<div class="src">(Curtis Roads, Composing Electronic Music)</div>

---

# Zones of Morphosis

> "By means of tape-speed change, pioneers like Stockhausen could speed up discrete melodies to the point where they lost their melodic quality and morphed into continuous timbres. In a similar manner, rhythms, when sped up, change state and morph into tones. Modulations like tremolo and vibrato, when sped up, morph into complex spectra."

<div class="src">(Curtis Roads, Composing Electronic Music)</div>

---

# Seven Points

Rajmil Fischman's list of what to consider when making a transformation.

1. **Differentiability**, the sounds must be perceived as A and B
2. **Similarity**, they should also have common properties
3. **Duration**, which should come from the sound type
4. **Linearity**, design the transformation curve from the material
5. **Spatial movement**, which can carry a transformation
6. **Diversions**, a third sound to distract during the process
7. **Context**, a transformation depends on where it came from

---
class: light
---

# Anatomy

<div class="shot"><img src="/figures/anatomy-000.svg" /></div>

---
layout: center
class: divider
---

CDP

---

# CDP

The **Composers Desktop Project** is a collection of sound transformation tools for creative musical work.

It offers detailed access to the multiple dimensions of a sound. Less a set of DSP routines than a toolbox of transformation processes, for a musique concrète practice or something like it.

CDP runs **offline**, in many cases faster than real time. The format is always the same: `program input output parameters`.

Common practice is to **chain** programs, feeding the output of one to the next, and to batch process.

---
class: light
---

# A Chain

<div class="shot"><img src="/figures/chain-000.svg" /></div>

---

# History

The Composers' Desktop Project has existed since **1986**.

It first ran on **Atari** machines and was ported to Windows in the early 90s. The early versions were command line only; SoundShaper, GrainMill and **Sound Loom** arrived late in the decade.

Later versions added macOS, multichannel files, and a catalogue that kept growing.

In **2014** CDP 7 was released as free software and the source was made public.

<span class="note">The install on the studio machine holds **232 programs**, most of which have several modes, which is where the larger counts in the literature come from.</span>

---
class: light
---

# Sound Loom

<div class="fig tall"><img src="/figures/soundloom-000.png" /></div>

<div class="src">(Trevor Wishart's own front end)</div>

---
class: light
---

# Four Categories

<div class="shot"><img src="/figures/categories-000.svg" /></div>

---

# Function Groups

The documentation divides the suite into **36 function groups**, and divides those by **domain**: programs that read a soundfile, and programs that read an analysis file.

**Time domain**, 19 groups: `DISTORT` `ENVEL` `ENVNU` `EXTEND` `FILTER` `GRAIN` `HOUSEKEEP` `MODIFY` `MULTICHANNEL` `MULTICHANNEL TOOLKIT` `PSOW` `RETIME` `REVERB` `SFEDIT` `SNDINFO` `SUBMIX` `SYNTH` `SYSUTILS` `TEXTURE`

**Spectral domain**, 17 groups: `BLUR` `COMBINE` `FOCUS` `FORMANTS` `HILITE` `MORPH` `ONEFORM` `PITCH` `PITCHINFO` `PVOC` `REPITCH` `SPEC` `SPECFNU` `SPECINFO` `SPECNU` `STRANGE` `STRETCH`

A group is usually one program holding many functions, so the number of processes is far larger than the number of groups.

<span class="note">The chain used four of these: `MODIFY` and `PVOC` to cross between the domains, then `BLUR` and `STRETCH`. The documentation is in `cdpr8/docs`, and `docs/html/cdpgroups.htm` is the page this list comes from.</span>

---

# Installing

The project site is *composersdesktop.com*, and the free release is at *unstablesound.net/cdp.html*.

The installer puts the core files in a **`cdpr8`** folder in your home directory, sets the environment variable the programs need, and adds them to your `PATH`.

On some versions of macOS the path has to be set by hand:

```bash
nano ~/.zshrc

PATH=$HOME/cdpr8/_cdp/_cdprogs:$PATH
export PATH
```

<span class="note">Check it with `modify`, which should print its usage rather than *command not found*. The binaries still report themselves as Release 7.1.</span>

<span class="workshop">- install it now -</span>

---

# Running It From Here

SuperCollider is used to build the command string and hand it to the shell. The programs are external, so there are no buffers to load, only paths.

```supercollider
(
~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
~vocal = ~path ++ "source/vocal.wav";
q = "\"";

~runner = { |program, input, output, params|
	var command = program + q ++ input ++ q + q ++ output ++ q + params;
	command.postln;
	command.runInTerminal;
};
)
```

<span class="note">Everything in *CDP.scd* is built on that one function. The waveset material is in *Wavesets.scd*, *WavesetsSelection.scd* and *WavesetsEx.scd*.</span>

---

# One Process

*Shred*: the file is segmented at random and the segments reordered by a permutation.

```supercollider
(
var output = ~path ++ "output/fire/shredbx.wav";
var repeats = "16", chunklen = "0.15";
~runner.value("modify radical 2", ~vocal, output, repeats + chunklen);
)
```

The two numbers are the whole instrument: how many times to go through, and how long a segment is.

<span class="q">Which of those two changes the material, and which changes the form?</span>

---

# Two Domains

Half the catalogue works on a **soundfile** and half on a **spectral analysis** of one. A spectral program will refuse a `.wav`.

`pvoc anal` converts a soundfile into an analysis file, and `pvoc synth` converts it back. Everything spectral happens between those two.

```bash
pvoc anal 1    shred.wav    shred.ana
blur blur      shred.ana    blurred.ana     32
stretch time 1 blurred.ana  stretched.ana   2.0
pvoc synth     stretched.ana final.wav
```

<span class="note">Analysis files are large: the ten second example above becomes 15 MB, and 30 MB once stretched.</span>

---
layout: center
class: divider
---

Trevor Wishart

---

# Trevor Wishart

English composer, based in York. Interested in the human voice and its transformation.

The main user and developer of the CDP system.

Author of **On Sonic Art**, on the possibilities offered by sound art, transformation and sound landscapes; **Audible Design**, a detailed account of transformation instruments and their use; and **Sound Composition**, on the thinking and the formal ideas behind his pieces.

---

# Trevor Wishart

Influenced by Xenakis, and initially a composer of serial music. When his father, who worked in a factory, died, he became interested in working with recorded sound and transforming it.

He believes in **audible** transformations over time: that these create heard relationships among the sounds of a piece and a sense of unification.

His approach to structure comes from the idea of **sound metamorphosis**.

---

# Wavesets

Wishart developed **waveset distortion** while composing *Tongues of Fire*, and set the family of transformations out in **Audible Design**.

A **waveset** is the signal between one upward zero crossing and the next, so it holds two half-wavesets. In a complex sound it is not a wavecycle: one period can hold several wavesets, of unequal length.

The transformations are **signal-dependent** by definition, since the boundaries come from the sound rather than from an external process. Repetition stretches time, omission thins the sound, substitution puts another shape of the same length in place of each waveset, and reversal, shuffling and shaking reorder or perturb them.

---
class: light
---

# Wavesets

<div class="shot"><img src="/figures/wavesets-algo-000.svg" /></div>

---
class: light
---

# Waveset Transposition

<div class="shot"><img src="/figures/wishart-wavesets-000.png" /></div>

<div class="src">(Trevor Wishart, transposition by waveset replacement)</div>

---

# Waveset Analysis

The analysis first. Everything after it is list operations.

```supercollider
// analyse a file into wavesets
w = Wavesets.from(~path ++ "sounds/bikecat.wav");

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

# Waveset Playback

Playback takes a start and a length, so any ordering of the list is playable.

```supercollider
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

<span class="note">Played in order at rate 1 this reconstructs the source. The last line takes every fourth waveset at half speed, and that one change is a transposition. *WavesetsSelection.scd* has selection by amplitude and by length, and scrubbing.</span>

---
class: light
---

# Gesture and Counterpoint

<div class="fig tall"><img src="/figures/wishart-counterpoint-000.png" /></div>

<div class="src">(Trevor Wishart)</div>

---

# Ideas

Points from Wishart worth arguing with.

Music should connect composer and listener so that a clear meaning is communicated. *"Music is not an object that sits in the world, it is an object that connects to something."*

We can only follow about **three layers** at once. Beyond that, focus is lost.

Explore everything a sound can offer through transformation **before** starting to compose with it.

The **tail** of a sound should be alive, through tremolo or subtle pitch change.

---

# Ideas

He composes entirely within CDP, mixing each phrase of the music independently.

Each sound is unique and defined by its own characteristics, so transformation should be **guided by those** rather than applied uniformly.

**Temporal evolution** of a process matters, otherwise a transformation is only an effect.

For sound composition the basic metaphor has to change from **architecture to chemistry**.

A successful transformation needs an aurally perceptible relationship between source and destination.

<span class="q">Three layers. Is that a fact about hearing, or about his music?</span>

---

# On Form

> "Clearly stating the principal materials is important for the listener in a context where a traditional musical language is not being used... But all sound materials are different, and it is not possible to predict, except in the most obvious ways, what will arise when one begins to transform the sounds. So I spend a lot of time, exploring, playing with, the sources, transforming them, and transforming the transformations, and gradually a formal scheme appropriate to what I discover, and to those particular materials, crystallizes in the studio."

<div class="src">(Trevor Wishart)</div>

---
layout: center
class: divider
---

Wishart, Tongues of Fire (1994)

---

# Tongues of Fire

The first piece Wishart completed on a desktop PC alone.

All the material comes from a **single recording of his own voice**, a few seconds long.

The catalogue of processes applied to it is, in effect, the CDP catalogue. *Shred*, waveset distortion, brassage, spectral work, and the rest.

<span class="note">The source recording and several of the processes are in *CDP.scd*, under the piece's own name.</span>

---
layout: center
class: divider
---

Wishart, American Triptych (1999)

---

# American Triptych

A commission from the GRM in Paris, built on the recorded voices of three American figures: Martin Luther King, Elvis Presley and Neil Armstrong.

The transformations work on speech, so the identity of the speaker is the material that has to survive, or be lost on purpose.

---
layout: center
class: divider
---

Wishart, Imago (2002)

---

# Imago

Made initially for Jonty Harrison's fiftieth birthday.

The entire piece is derived from a **single short sound**: two glasses touching.

Everything else is what transformation made of it.

<span class="q">An eight-second source and a twenty-five minute piece. Where does the new material come from?</span>

---

# Next Steps

The examples class: chaining processes, cross-synthesis, and the CDP quark from SuperCollider.

<span class="note">Trevor Wishart is at Sonology on 14, 15 and 16 October. Bring something you made with this.</span>

---
layout: center
class: divider
---

Exercises

---

# Exercises

1. Choose a short sound and **extend** it, using `drunk`, `zigzag` or another extension method, until it is at least ten times its original length.

2. Take one source and build a **family** of eight related sounds from it. Keep the chain that made each one.

3. Make one transformation from A to B where both ends stay recognisable, and one where B has lost all trace of A. Say which was harder.

4. Chain at least **four** programs, listening to every intermediate file, and keep the one you did not expect.

---

# Exercises

5. Implement a pattern process for **waveset distortion** that uses different patterns to control the play rate and the repeats parameters.

6. Implement a pattern process for waveset distortion that adds a **per-waveset transformation**, such as a filter, a glissando or a binary transformation.

<span class="workshop">- workshop -</span>
