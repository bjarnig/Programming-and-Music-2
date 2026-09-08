---
theme: seriph
addons:
  - ./shared
title: Programming and Music 2 — 01 Introduction
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

<div class="deck-title">Programming and Music 2</div>

<div class="sub">
  Programming and Music 2
  <a href="https://www.bjarni-gunnarsson.net">https://www.bjarni-gunnarsson.net</a>
</div>

<!--
First class, 8 September 2026. Who is here: second-year bachelors with one year of
SuperCollider, and master students joining for the advanced content. Say once that the
class is the same for both and the assignments have two tracks.
-->

---
layout: center
class: divider
---

Class

---

# Course Content

The course covers **programming approaches** and the **aesthetics** of contemporary computer music.

The year runs in three **themes**: **Material** (microsound, non-standard synthesis, sound transformation), **Liveness** (live coding, feedback, live algorithms, network, space) and **Systems** (machine listening and learning, corpus composition, complex systems).

Students will gain a solid foundation in programming and using advanced musical algorithms while dealing with contemporary computer music, the paths it makes available, its aesthetics, and the problems it introduces.

---

# Objectives

At the end of this course, you:

- Can compose **sound** at the level of the grain and the sample, and **transform** recorded sound by procedure *(Material)*
- Can make use of **live algorithms** and processing through **live coding** approaches, and build a system that plays with you *(Liveness)*
- Are able to implement and apply **generative algorithms** such as networks, cellular automata and chaotic systems, and to use **machine listening** and **machine learning** within a musical context *(Systems)*

---

# Prerequisites

An interest in developing applications for computer music and related topics.

Having a good knowledge of **SuperCollider**, a computer that runs it or be willing to come to the Sonology studios to do so.

A firm knowledge of the basics of **programming** and creating application for music is a soft requirement.

<span class="note">One year of SuperCollider is assumed. Where a class needs something PM1 did not cover, it is introduced in that class.</span>

---

# Course Format

A **class** will usually focus on a specific **topic** or **theme**.

Part of the lesson will be a **presentation** of, and discussion on, the topic in question. Slides will be presented and pieces will be played.

The other part of the lesson will focus on **hands-on experimentation** in **SuperCollider** or any of the other featured environments.

Regular **workshops** for practical works will also take place.

**Discussion** and **interaction** should take place as much as possible.

<span class="note">If you can, bring your laptops to classes.</span>

---

# Assignments

An important part of the class is to work on the topics covered and learn how to use them in practice.

During the year there will be **three assignments**, one per theme, each worth 30 % of the final grade:

- **Material**: a granular study, a CDP suite from one sound, a stochastic waveform etude
- **Liveness**: a set of live-coding tools and a performance in the NML
- **Systems**: a process that listens, evolves, adapts or learns

Every assignment has two parts: work you **hand in**, code together with a short text on the approach and its value in a musical setting, and an **in-class assignment** where you write code from scratch in the room.

<!--
The in-class part is the one that shows what has actually stuck. Say that it is not a test:
it is the same work, done without a week to prepare and without anything to copy from.
-->

---
layout: center
class: divider
---

Topics

---

# Topics

<p style="text-align:center"><strong>- (01) Material -</strong></p>

01, Introduction<br>
02, Granularity<br>
03, Granular Examples<br>
04, Waveforms<br>
05, Waveforms Examples<br>
06, CDP<br>
07, CDP Examples<br>
08, Design Patterns

<p style="text-align:right"><em>Assignment 1 (30 %)</em></p>

<!--
Sound built from nothing first, from a recording second. Trevor Wishart is at Sonology on
14, 15 and 16 October: CDP on the 13th is the day before he arrives, CDP Examples on the
20th is the week after him.
-->

---

# Topics

<p style="text-align:center"><strong>- (02) Liveness -</strong></p>

09, Live Coding<br>
10, States and Transitions<br>
11, Analysis<br>
12, Feedback<br>
13, Live Algorithms<br>
14, Network Music<br>
15, Spatialisation<br>
16, Live Examples

<p style="text-align:right"><em>Assignment 2 (30 %)</em></p>

---

# Topics

<p style="text-align:center"><strong>- (03) Systems -</strong></p>

17, FluCoMa<br>
18, Machine Learning<br>
19, Corpus Composition<br>
20, System Design<br>
21, Sonification<br>
22, Chaos<br>
23, Grammars and Fractals<br>
24, Complexity

<p style="text-align:right"><em>Assignment 3 (30 %)</em></p>

---
layout: center
class: divider
---

Computer Music

---

# Music with Computers

What is special to the making of music with computers?

- **Speed** of execution
- **Accuracy** of output
- Escape human **judgement** and **biases**
- Exploration of **formalized** ideas
- Testing of **compositional models**
- Execute tasks with **high order of magnitudes**
- Experimenting with **organizational principles**
- **Algorithmic control** for all details of a problem

*"To do things that without the computer could not be done."*
(Paul Berg)

---

# Music with Computers

What are possible **pitfalls** when making music with computers?

- Lack of **judgement** regarding its output
- Belief that an idea can **guarantee interesting results**
- **Lack of interaction** with algorithmic methods
- **Complexity problems** due to the multitude of tasks
- Lack of **possible responses** in disappointing scenarios
- Difficulties in **relating** *material*, *structure* and *form*

*"When you become aware of technique, the music is failing"*
(John Wall)

---

# Programming

Necessary to do anything **really new** in computer music or should be left to system designers?

Requires a perhaps slightly **different mindset** of problem solving compared to composing music?

Becomes dominant during the creative process in such a way that its **goals** become more important than the initial musical ones?

---

# Programming and Music

Many concepts relate programming and music:

- **Hierarchy** of levels
- **Complexity** of relationships
- **Simultaneous happening** of events
- **Abstraction** of details
- **Structure** of entities
- **Modularisation** of components
- **Reference** to external ideas

---

# Composing Sound

Music exists at **different levels** of time at any given moment.

It is common to distinguish between micro, meso and macro time but many other possible timeframes are imaginable.

<span class="q">Is there a difference between **composing music** and **composing sounds?**</span>

If a music is not based on notes, does it make sense to think of what happens beneath or above the note?

Could we think of the **sounds a music creates** instead of which music sounds create?

---

# Parametrical thinking

A **parameter** is one of the variables that controls the outcome of a system.

**Attributes of a process** are converted to values representing its state where its properties and variability control the value settings.

**Parametrical thinking** enables **limits**, **boundaries**, **parameter spaces** and **mapping** from one to the other.

**Parameter mappings** include *one-to-many*, *many-to-one* and *many-to-many*.

---

# Composition or Music Theory

In **algorithmic composition** much discussion has been on how to program software that generates "plausible" results that appear to be in a *certain style* or to *emulate a composer*.

One belief states that computers should "learn" a musical structure and then reproduce it. The idea itself prevents invention but encourages copying of ideas.

A possible confusion is between the different goals of composition on the one hand and music theory or artificial intelligence on the other.

---

# Approaches

**The working process** and its different possible approaches is important both when **developing** software and **creating** music.

Two opposite poles are the *top-down approach* and the *bottom-up approach*.

The computer is an ideal tool for **inspecting** different aspects at multiple stages of the creation process.

The study of what happens during the evolution of a musical composition made with a computer can give birth to new methods and ways of making music

---
layout: center
class: divider
---

Material

---

# Material

**Composing the sound** instead of composing with sounds. The first eight classes focus on what lies beneath the note: the **grain**, the **sample**, and the **transformation** of sound.

- **Granularity**: sound as particles
- **Non-standard synthesis**: waveforms described by rule (Xenakis, Brün, Koenig)
- **Sound transformation**: CDP, one source and many outputs, choosing afterwards
- **Design patterns**: the architecture of sound processes

<!--
The working habit of the whole year is set here: generate a family, keep everything,
sort afterwards. Assignment 1 asks for exactly that.
Trevor Wishart is at Sonology in October and the CDP classes sit around that visit; say it
aloud rather than promising a date on a slide.
-->

---

# Time Scales of Music

1. **Infinite** (the ideal time span of mathematical durations)
2. **Supra** (beyond that of an individual composition: months, years, decades)
3. **Macro** (overall musical architecture or form, measured in minutes or hours)
4. **Meso** (groupings of sound objects into hierarchies of phrase structures)
5. **Sound object** (a basic unit of musical structure, generalizing the traditional note)
6. **Micro** (particles on a time scale that extends down to the threshold of perception)
7. **Sample** (the atomic level of digital audio systems)
8. **Subsample** (fluctuations on a time scale too brief to be properly perceived)
9. **Infinitesimal** (the ideal time span of mathematical durations)

*Curtis Roads, Microsound.*

---
class: light
---

# Particles

> "Beneath the level of the note lies the realm of sound particles. Each particle is a pinpoint of sound. Recent advances let us probe and manipulate this microacoustical world. Sound particles dissolve the rigid bricks of musical composition, the notes and their intervals, into more fluid and supple materials."

<div class="src">(Curtis Roads, Microsound, 2001)</div>
<div class="fig"><img src="/figures/roads-000.png" /></div>

---
class: light
---

# Xenakis

> "Instead of starting from the unit element concept and its tireless iteration and from the increasing irregular superposition of such iterated unit elements, we can start from a disorder concept and then introduce means that would increase or reduce it. This is like saying that we take the inverse road : We do not wish to construct a complex sound edifice by using discontinuous unit elements (bricks = sine or other functions); we wish to construct sounds with continuous variations that are not made out of unit elements. This method would use stochastic variations of the sound pressure directly. "

<div class="src">(Xenakis, Formalized Music)</div>
<div class="fig"><img src="/figures/xenakis-002.png" /></div>

---
class: light
---

# Material

> "The Cologne studio looked down on composers that "only" had form problems. "Material fetishism" dates from then and could be understood as "form fetishism". Form was not mentioned at all, everything was material; sounds as well as the serial methods. Form was seen more as an automatic consequence of the treatment of material than as an independent category to which the fashioning of sounds ought to be subordinate. When forms were exposed at all they were simple concepts such as the crossform in Kreuzpiel or the group in Gruppen, in both cases they were derived from the treatment of the material. "

<div class="src">(Koenig, Genesis of Form)</div>
<div class="fig"><img src="/figures/koenig-000.png" /></div>

---
class: light
---

# Microtime

> "All compositional manipulations articulating relations between different temporal levels depend essentially on the paradigm adopted by the composer. Evidently, a decision has to be made concerning the status and the nature of these interactions: to consider them as taking place in a continuum organized as a fixed hierarchy [...] or to assume the existence of discontinuities, of nonlinearities, considering (in the last case) microtime, macrotime, and all intermediate dimensions as disjoint (or relative) realms."

<div class="src">(Vaggione, interview with Budon)</div>
<div class="fig"><img src="/figures/vaggione-000.png" /></div>

---
class: light
---

# Transformation

> "Sounds had a life of their own which had to be respected."

> "It is not possible to predict, except in the most obvious ways, what will arise when one begins to transform the sounds."

<div class="src">(Trevor Wishart, 2009)</div>
<div class="fig"><img src="/figures/cdp-000.png" /></div>

<!--
Wishart's own tool, Sound Loom, the front end of CDP. Both quotes from the Unidentified
Sound Object interview. He is here in October.
-->

---
layout: center
class: divider
---

Liveness

---

# Liveness

**Writing the music while it plays.** The second eight classes are about systems that run in front of people: a program that changes itself, a process that listens to itself, a machine that answers, multiple machines in one room.

- **Live coding**: JitLib and proxies; moving between states without stopping
- **Analysis** as a live instrument, and **feedback** as a system that listens to itself
- **Live algorithms**: a machine partner that interacts and evolves
- **Network music** and **spatialisation**: multiple machines, multiple speakers
- **Live examples**: the workflow of a performance, and what the audience sees

<span class="note">The performance for assignment 2 takes place in the NML.</span>

---
class: light
---

# Show us your screens

> "Obscurantism is dangerous. Show us your screens."

> "Programs are instruments that can change themselves."

> "Code should be seen as well as heard, underlying algorithms viewed as well as their visual outcome."

<div class="src">(TOPLAP, ManifestoDraft, 2004)</div>
<div class="fig"><img src="/figures/toplap-000.png" /></div>

---
class: light
---

# Causality

> Live coding "deeply connects algorithmic causality with the perceived outcome and by deconstructing the idea of the temporal dichotomy of tool and product it allows code to be brought into play as an artistic process."

<div class="src">(Collins, McLean, Rohrhuber, Ward, Live Coding in Laptop Performance, 2003)</div>
<div class="fig"><img src="/figures/collins-000.png" /></div>

<!--
The table is from the same paper: pros and cons of live coding performance, 2003.
-->

---
class: light
---

# Just in Time

> "Just in time programming … includes the programming activity in the program's operation. A program is not taken as a tool that is made first to be productive later, but instead as a dynamic construction process of description and conversation."

<div class="src">(Julian Rohrhuber, Algorithms Today, 2005)</div>
<div class="fig"><img src="/figures/rohrhuber-000.png" /></div>

---
class: light
---

# Interface

> "Sound becomes an 'interface' between us and the space: sound is energy (mechanical, acoustic, electro-acoustics), but it also bears an 'informational' signature of spaces and bodies from which they emanate."

> "Space and technical infrastructure are 'structurally coupled', to use a term from cybernetics and other systemic sciences, ecology included."

<div class="src">(Agostino Di Scipio)</div>
<div class="fig"><img src="/figures/interface-000.svg" /></div>

<!--
Feedback and space in one breath: a feedback system on stage listens to the room it is in.
Classes 12 and 15.
-->

---
class: light
---

# Player

> "In Voyager, the computer system is not an instrument, and therefore cannot be controlled by a performer. Rather, the system is a multi-instrumental player with its own instrument."

> "The machine does not really know if it is improvising or composing, and that is really a political and ideological decision."

<div class="src">(George Lewis, Too Many Notes, 2000; interview, 2022)</div>
<div class="fig"><img src="/figures/player-000.svg" /></div>

<!--
Class 13, Live Algorithms. The question for the block: instrument or player? Rowe's other
axes: score-driven or performance-driven; transformative, generative or sequenced response.
-->

---

# Live Coding

<div class="shot">
  <img src="/figures/livecoding-000.png" alt="ProxySpace session" />
</div>

<div class="caption">a ProxySpace session, mid-set</div>

---
layout: center
class: divider
---

Systems

---

# Systems

**A process that listens, evolves, adapts or learns**, and is then left running. The last eight classes build systems rather than patches.

- **Machine listening** and **FluCoMa**: organising a body of sound by what it sounds like
- **Machine learning**: regression, classification, and what the model does not know
- **Corpus composition**: a piece from a database rather than from synthesis
- **System design**: components, interfaces and state; the architecture of a musical system
- **Sonification**, **chaos**, **grammars**, **complexity**: the generative models

---
class: light
---

# Surprise

> "[I am interested in] electroacoustic, digital and social systems that can surprise me."

> "Machines take me by surprise with great frequency."

<div class="src">(Alberto de Campo, 2025; Alan Turing, 1950)</div>
<div class="fig"><img src="/figures/bifurcation-000.png" /></div>

<!--
The frame for the whole block: a deterministic system that surprises its own author.
-->

---
class: light
---

# Sonological Emergence

> "The conceptual separation of composition (or, responsibility on premises and conditions, in my wording) and music (sonic features arising from premises and conditions) perhaps attests to a shared perspective. The implication is that sound is the epiphenomenon of a lower-level process: you design a low-level process, and the interactions and interferences among particle components taking part in the process are heard as a dynamic shape of sound, a process of sonological emergence. "

<div class="src">(Agostino Di Scipio, 2005)</div>
<div class="fig"><img src="/figures/discipio-000.png" /></div>

---
class: light
---

# Weak Emergence

> "An innocent form of emergence, what I call 'weak emergence', is now a commonplace in a thriving interdisciplinary nexus of scientific activity, sometimes called the 'sciences of complexity', that include connectionist modelling, non-linear dynamics (popularly known as 'chaos' theory), and artificial life."

<div class="src">(Mark Bedau, Weak Emergence, 1997)</div>
<div class="fig"><img src="/figures/life-000.png" /></div>

<!--
When a composer says a patch surprised them, this is the claim being made: the result
follows from the rules, but only by running them. Class 24.
-->

---
class: light
---

# Metacreation

> "Pursuing a-life's promise of emergence, these artists produce not only artworks, but generative and creative processes: here creation becomes metacreation."

<div class="src">(Mitchell Whitelaw, Metacreation: Art and Artificial Life, 2004)</div>
<div class="fig"><img src="/figures/wolfram-000.png" /></div>

---
class: light
---

# Instrument

> "…secularise AI from the ideological status of intelligent machine to one of knowledge instrument."

<div class="src">(Matteo Pasquinelli and Vladan Joler, The Nooscope Manifested)</div>
<div class="fig"><img src="/figures/network-000.png" /></div>

<!--
Classes 17 to 19: machine listening and learning as instruments you build and tune,
not as an intelligence you consult.
-->

---
class: light
---

# Agency

> "The presumption that there is an agency, desire, or will belonging to the self and clearly distinguished from the "wills of others" is undercut in the posthuman, for the posthuman's collective heterogeneous quality implies a distributed cognition located in disparate parts that may be in only tenuous communication with one another. […] If "human essence is freedom from the wills of others," the posthuman is "post" not because it is necessarily unfree but because there is no a priori way to identify a self-will that can be clearly distinguished from an other-will."

<div class="src">(Katherine Hayles)</div>
<div class="fig"><img src="/figures/hayles-000.png" /></div>

---
class: light
---

# Assimilation

> "After the different waves of cybernetics, after information and control theory, semiotics and linguistics, cognitive science and artificial intelligence, we are reaching a point … intensified constructivism, or by a renewed realism, both of which de-emphasise the human subject and the categorial split between humans and machines.
> From this standpoint, the interesting question is not so much whether machines can be creative or artistic, but rather how the exchange and assimilation processes between human and machine are structured, and how they can give rise to an aesthetics."

<div class="src">(Hans Holger Rutz)</div>
<div class="fig"><img src="/figures/rutz-000.png" /></div>

---
class: light
---

# Anticommunication

> "A relation between persons and things which emerges and is maintained through messages requiring and permitting not yet available encoding and decoding systems or mechanisms."

> "Anticommunication is an attempt at saying something, not a refusal to say it. Communication is achievable by learning from language how to say something. Anticommunication is an attempt at respectfully teaching language to say it."

<div class="src">(Herbert Brün)</div>
<div class="fig"><img src="/figures/brun-000.png" /></div>

---
class: light
---

# Contagion

> "There is a concrete culture, an aesthetic and a mode of thought, specific to the computational production of new probabilities.[…] contagion is taken here to define the quasi-finitude of algorithmic objects: the fact that these objects are spatiotemporal actualities which cannot be summed up in smaller programs, and which do not result from the sum of their parts."

<div class="src">(Luciana Parisi)</div>
<div class="fig"><img src="/figures/parisi-000.png" /></div>

---

# Complex Systems

<div class="shot">
  <img src="/figures/automata-000.png" alt="cellular automata" />
</div>

<div class="caption">cellular automata, class 24</div>

---
layout: center
class: divider
---

Code

---

# Material

Writing the waveform itself, sample by sample.

```supercollider
( // sawtooth: one rising ramp that resets
{
	var levels = Dseq([Dseries(-1.0, 0.02, 100)],inf);
	var durations = SampleDur.ir * 5;
	DemandEnvGen.ar(levels, durations) ! 2 * 0.3;
}.play
)
( // then a waveform composed of five segments
{
	var levels = Dseq([
		Dseries(-1, 0.04, 50),            // sawtooth up
		Dseries(-1, 0.04, 50),            // triangle up half
		Dseries(1, -0.04, 50),            // triangle down half
		Dstutter(25, Dseq([1, -1], 6)),   // square wave, 6 cycles
		Dgeom(0.01, 1.08, 50)             // exponential ramp
	], inf);
	var durations = SampleDur.ir * 5;
	DemandEnvGen.ar(levels, durations).clip(-1, 1) ! 2 * 0.3;
}.play
)
```

<!--
Run from 01 - Introduction/code/Themes.scd. No oscillator and no model of an instrument:
the numbers are the waveform, and a demand stream supplies them one sample at a time. This
is the class 04 lineage, Xenakis and Brün and Koenig, in two blocks. Play the saw first so
the composite is heard as the same machine with a longer list.
-->

---

# Liveness

A source, a pattern that sets it, a filter added while it plays.

```supercollider
( // -> \set
Ndef(\a);
Ndef(\a)[0] = {|freq=80| Saw.ar(freq!2,0.1) };
Ndef(\a)[2] = {|freq=80| SinOsc.ar(freq!2 * 0.5,0,0.1) };
Ndef(\a)[1] = \set -> Pbind(\dur, 0.1, \freq, Pwhite(40,400));
Ndef(\a).play
)

( // -> \filter, added to the running proxy
Ndef(\c).play;
Ndef(\c).fadeTime = 2;
Ndef(\c)[0] = {|freq=90| Saw.ar(freq!2,0.1) };
Ndef(\c)[2] = \filter -> {|in| LPF.ar(in, LFNoise1.ar(8).range(100,800)) };
)
```

<!--
Nothing stops. The slot index is the whole idea of block 2: a running system with
addressable parts.
-->

---

# Systems

A sound listened to, and a second sound that follows what was heard.

```supercollider
( // Track pitch and amplitude with Pitch
b = ~voice;
{
	var snd, amp, freq, hasFreq;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	amp = Amplitude.ar(snd, 0.1, 0.1);
	# freq, hasFreq = Pitch.kr(snd);
	Saw.ar(freq.poll * [1, 1]) * amp + (snd * 0.5);
}.play
)
```

<span class="note">All three blocks are in *Themes.scd*, in this class's code folder.</span>

<!--
A listening machine in nine lines. Block 3 asks what it misses, and what to do with what
it hears.
-->

---
layout: center
class: divider
---

Exercises

---

# Exercises

Three, one per example. Start from the code in *Themes.scd*.

1. **Material.** Change the list of segments in the composite waveform: add one, remove one, or reorder them. Listen for what changes and what does not.
2. **Liveness.** Build a source with an `Ndef`, play it, then add a filter to it and change that filter, all without stopping the sound.
3. **Systems.** Take the pitch and amplitude the analysis reports, and use them to drive a synth of your own instead of the saw.

<!--
Small on purpose. The point is that all three run in the first week, not that they are
finished pieces. Whatever they bring back sets the level for assignment 1.
-->

---
layout: center
class: divider
---

&nbsp;
