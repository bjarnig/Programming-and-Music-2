---
theme: seriph
addons:
  - ./shared
title: Programming and Music 2 — 05 Sound Transformation Examples
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

<div class="deck-title">Sound Transformation Examples</div>

<div class="sub">
  Programming and Music 2
  <a href="https://www.bjarni-gunnarsson.net">https://www.bjarni-gunnarsson.net</a>
</div>

---

# Format

Examples class for Sound Transformation.

There are different parts: **chaining** programs from SuperCollider, **breakpoint files** written by patterns, a **family** of sounds built from one source and more.

<span class="note">The code is in *Breakpoints.scd*, *CDPCross.scd* and *CDPGui.scd*. CDP must be installed, and `~bin` at the top of *Breakpoints.scd* must point at its programs.</span>

---
layout: center
class: divider
---

Chaining

---

# Waiting Process

Last class a command was handed to the terminal and SuperCollider executed it. A chain needs each program to finish before the next one starts, so this runner waits for CDP and returns the path of the file it made.

```supercollider
~bin = "~/cdpr8/_cdp/_cdprogs/".standardizePath;
~q = { |p| "\"" ++ p ++ "\"" };

~cdp = { |program, input, output, params = ""|
	var cmd = ~q.(~bin ++ program.split($ )[0]) + program.split($ )[1..].join(" ")
	         + ~q.(input) + ~q.(output) + params;
	var code;
	if(File.exists(output)) { File.delete(output) };
	code = cmd.systemCmd;
	if(code != 0) { "FAILED (%): %".format(code, cmd).postln };
	output
};
```

---

# Sequential Processes

Each call returns its output path, which is the next call's input.

```supercollider
(
var shred = ~cdp.("modify radical 2", ~src, ~out ++ "shred.wav", "16 0.15");
var ana   = ~cdp.("pvoc anal 1", shred, ~out ++ "shred.ana");
var blur  = ~cdp.("blur blur", ana, ~out ++ "blur.ana", "32");
var str   = ~cdp.("stretch time 1", blur, ~out ++ "stretch.ana", "2.0");
var out   = ~cdp.("pvoc synth", str, ~out ++ "chain.wav");
"% s in, % s out".format(~dur.(~src).round(0.01), ~dur.(out).round(0.01)).postln;
)
```

<span class="note">8.03 seconds in and 16.1 out, which is the stretch of 2.0. Three of the five files are spectral analyses and are large.</span>

---
hide: true
---

# Listening at Every Step

Every program leaves a file, and every file can be played. A chain is made by listening between the steps and deciding what the next one should be.

<span class="q">Which step changed the sound most, and which changed it least?</span>

---
layout: center
class: divider
---

Breakpoints

---

# Breakpoint Files

A breakpoint file is a text file of **time and value pairs**. Wherever CDP lets a parameter change over time it reads one in place of a number.

```text
0 1
4 0.5
8 2
```

Time is in seconds and the values are joined by straight lines. Because it is plain text, SuperCollider can write it.

<span class="note">*stretch time* says it in its own usage text: *Timestretch may itself vary over time.*</span>

---

# By Hand

Three pairs used as the speed of the sound.

```supercollider
(
var brk = ~brk.("hand", [[0, 1], [4, 0.5], [8, 2]]);
var out = ~cdp.("modify speed 1", ~src, ~out ++ "hand.wav", brk);
"% s in, % s out".format(~dur.(~src).round(0.01), ~dur.(out).round(0.01)).postln;
)
```

<span class="note">The speed falls to half and rises to double, which changes both pitch and length: 8.03 seconds in and 9.26 out.</span>

---

# By a Pattern

The same file, with the values chosen by a random walk.

```supercollider
(
var times = (0..16) * 0.5;
var walk  = Pbrown(0.5, 2.0, 0.25, 17).asStream.nextN(17);
var pairs = [times, walk].flop;
var brk   = ~brk.("walk", pairs);
var out   = ~cdp.("modify speed 1", ~src, ~out ++ "walk.wav", brk);
)
```

<span class="note">`Pbrown` moves at most 0.25 from the previous value and stays between 0.5 and 2.0. Every run writes a different file.</span>

---

# From an Envelope

A shape is drawn once, with its curves, and sampled every half second.

```supercollider
(
var env   = Env([1, 4, 1.5, 3], [3, 2, 3], [4, -4, 0]);
var times = (0..16) * 0.5;
var pairs = times.collect { |t| [t, env.at(t).round(0.001)] };
var brk   = ~brk.("env", pairs);
var out   = ~cdp.("modify speed 1", ~src, ~out ++ "env.wav", brk);
)
```

---

# By a Function

The logistic map as the speed. The parameter *r* rises from 3.2 to 3.99.

```supercollider
(
var x = 0.5, pairs;
pairs = (0..40).collect { |i|
	var r = i.linlin(0, 40, 3.2, 3.99);
	4.do { x = r * x * (1 - x) };
	[i * 0.2, (2 ** (x * 2 - 1)).round(0.001)]
};
~cdp.("modify speed 1", ~src, ~out ++ "logistic.wav", ~brk.("logistic", pairs));
)
```

<span class="note">Four iterations per breakpoint hide the cycles of period two and four, so the speed sits still until the map turns chaotic at *r* = 3.57, after about 3.7 seconds.</span>

---
class: light
---

# Three Ways of Writing a Curve

<div class="shot"><img src="/figures/breakpoints-000.svg" /></div>

---
layout: center
class: divider
hide: true
---

Form

---
hide: true
---

# Sequential and Morphic

Wishart calls forms made by juxtaposing fixed values **sequential forms**, and shapes articulated in the continuum **morphic forms**.

Notation describes sequential forms almost exclusively. A crescendo is the simplest morphic form, a linear motion from one state to another, and the score gives no way to describe how that motion goes.

A breakpoint file can write either.

---
class: light
hide: true
---

# Held and Joined

<div class="shot"><img src="/figures/sequential-morphic-000.svg" /></div>

---
hide: true
---

# Held and Joined

The same eight values, written twice.

```supercollider
(
var values = [1, 2, 0.7, 1.5, 0.5, 3, 1, 2];
var times  = (0..7);
var held   = values.collect { |v, i| [[i, v], [i + 0.99, v]] }.flatten(1);
var joined = [times, values].flop;
~cdp.("modify speed 1", ~src, ~out ++ "held.wav",   ~brk.("held",   held));
~cdp.("modify speed 1", ~src, ~out ++ "joined.wav", ~brk.("joined", joined));
)
```

<span class="note">The held version is 7.43 seconds long and the joined version 6.02.</span>

---
class: light
hide: true
---

# Interpolation

> "In this context, interpolation provides the sense of logical passage from one sonic area to another (as opposed to mere juxtaposition) which we also feel during tonal modulation."

<div class="src">(Trevor Wishart, Audible Design, 1994, p. 105)</div>

---
hide: true
---

# Morphic Gestures

Three motions between the same two speeds, with a different shape.

```supercollider
(
[[\fast_then_slow, -4], [\linear, 0], [\slow_then_fast, 4]].do { |pair|
	var name = pair[0], curve = pair[1];
	var env   = Env([1, 2], [8], curve);
	var pairs = (0..16).collect { |i| [i * 0.5, env.at(i * 0.5).round(0.001)] };
	~cdp.("modify speed 1", ~src, ~out ++ name ++ ".wav", ~brk.(name, pairs));
};
)
```

<span class="note">Wishart observes that different motion types have different perceptual qualities even within very short time frames. The three files are 4.67, 5.56 and 6.75 seconds long.</span>

<span class="q">Which of the three would you put at the start of a phrase, and which at the end?</span>

---
class: light
hide: true
---

# Structure and Expression

> "The distinction made between 'structure' and 'expression' is in fact an arbitrary, ideological divide."

<div class="src">(Trevor Wishart, Audible Design, 1994, p. 104)</div>

---
layout: center
class: divider
---

Cross Synthesis

---

# Cross Synthesis

The spectral amplitudes of the first file are replaced by those of the second. Both files are analysed first, and the result is a spectral file that has to be resynthesised.

```bash
pvoc anal 1   ca.wav        ca.ana
pvoc anal 1   cb.wav        cb.ana
combine cross ca.ana cb.ana cross.ana
pvoc synth    cross.ana     cross.wav
```

<span class="note">*CDPCross.scd* runs the same steps from SuperCollider and has *Diff*, which finds the difference of two spectra. The output here is 8.02 seconds, the length of the inputs.</span>

---
layout: center
class: divider
---

CDP.sc

---

# CDP.sc

<div class="cdpsc">
<img src="/figures/cdp-sc-000.png" />
<div>

A SuperCollider frontend for the **Composers Desktop Project**. Each process opens in a window with a slider for every parameter.

Time-domain, spectral and cross-synthesis processes, with batch processing of whole folders.

<span class="note"><a href="https://github.com/bjarnig/CDP.sc">github.com/bjarnig/CDP.sc</a></span>

</div>
</div>

<style>
.cdpsc { display: flex; gap: 2.5rem; align-items: center; margin-top: 0.6rem; }
.cdpsc img { height: 25rem; flex: none; }
</style>

---

# The Quark

The CDP quark wraps programs in windows with a slider for each parameter. *CDPGui.scd* has examples of the window.

```supercollider
Quarks.install("https://github.com/bjarnig/CDP.sc");
CDPBase.checkCDPInstalled;
CDPBase.setCDPPath("~/cdpr8/_cdp/_cdprogs");
```

<span class="note">If CDP works in the terminal and not in SuperCollider, the path is the usual cause, because SuperCollider does not read the shell configuration.</span>

---

# A Window

A window is described by the program, a title, the folder of sounds and one entry per parameter. Each entry gives the flag that precedes the value and the range of its slider.

```supercollider
CDPGui("distort repeat", "Repeat", ~directory, [
	(name: "repeat", prepend: "",   spec: ControlSpec(4, 32, \linear, 1)),
	(name: "group",  prepend: "-c", spec: ControlSpec(10, 250, \linear, 1))
]);
```

<span class="note">Spectral programs open in *CDPFft*, which adds Analyze and Synthesize, and two-input programs in *CDPCross*.</span>

---
layout: center
class: divider
---

Families

---

# One Source

*Tongues of Fire* grew from a two-second vocal utterance, organised as a **tree** with the first sound as its root. *Imago* grew from one clink of two wineglasses, and every other sound in it comes from that sample.

A family is the same idea at the scale of a class: one source, and many sounds that are audibly related to it.

<span class="q">What makes two sounds related enough to belong to one family?</span>

---

# A Family in Code

Eight members, each a shred followed by a walk in the speed. The seed is the only difference.

```supercollider
n.do { |i|
	var seed = 100 + i;
	var repeats, chunk, walk, shred, out;
	thisThread.randSeed = seed;
	repeats = rrand(4, 16);
	chunk   = rrand(0.1, 0.8).round(0.01);
	walk    = Pbrown(0.5, 2.0, 0.3, 17).asStream.nextN(17);

	shred = ~cdp.("modify radical 2", ~src, dir ++ "shred_%.wav".format(i),
		"% %".format(repeats, chunk));
	out   = ~cdp.("modify speed 1", shred, dir ++ "member_%.wav".format(i),
		~brk.("family/walk_%".format(i), [(0..16) * 0.5, walk].flop));

	log.write("member % seed % shred % % duration %\n".format(
		i, seed, repeats, chunk, ~dur.(out).round(0.01)));
};
```

---

# The Log

```text
member 0 seed 100 shred 5 0.72 duration 6.43
member 1 seed 101 shred 6 0.28 duration 6.0
member 2 seed 102 shred 16 0.21 duration 6.98
member 3 seed 103 shred 6 0.25 duration 5.17
member 4 seed 104 shred 15 0.72 duration 7.48
member 5 seed 105 shred 14 0.66 duration 11.09
member 6 seed 106 shred 5 0.57 duration 7.73
member 7 seed 107 shred 14 0.21 duration 4.88
```

The seed fixes the parameters and the breakpoints, and the log keeps them. CDP shreds differently on every run, so a member can be described again and cannot be remade exactly.

<span class="note">Keep the files you like.</span>

---
hide: true
---

# Sorting

Listen to the family in order, and then in another order. Group the members by what they share, and name each group with one word. The groups are the sections of a study, and the order of the groups is its form.

<span class="q">Which member belongs to no group, and does it have to be thrown away?</span>

---
layout: center
class: divider
---

<Listen file="bjarnig-dried-up.mp3">Bjarni Gunnarsson - Dried Up (2008)</Listen>

---

# Dried Up

The material comes from **synthetic percussion**, composed bottom-up by arranging sounds and their variants into gestural phrases.

The transformations are made mainly with CDP: waveset distortion (delete, repeat, multiply and divide) and extend (zigzag, random walks and scramble). Simple algorithmic processes choose between treatments and between sequences of treatments.

The gritty surface of the piece is a direct artefact of the manipulations.

---
hide: true
---

# Assignment 1

Assignment 1 includes a **CDP suite** built from one sound and a **three-minute etude**. The exercises today are the first steps towards both.

<span class="note">The brief is issued with the rest of the assignment.</span>

---
layout: center
class: divider
---

Exercises

---

# Exercises

1. Write a breakpoint file with a pattern and use it as the speed or the stretch of one sound. Run it with two different seeds and compare.
2. Apply *distort repeat* and *distort delete* to the same sound and compare how each changes the length and the surface of the **wavesets**.
3. Run *distort divide* and *distort multiply* on a pitched sound and on a noisy one, and describe which source keeps more of its character.
4. Chain three **waveset** distortions with `~cdp`, for example *omit*, *telescope* and *average*, and listen to the file after each step.
5. Make a **family** of eight sounds from one source using at least two programs. Keep the log and the files.
6. **Cross synthesize** two sounds from your family. Transform one of them first and cross again.

<span class="workshop">- workshop -</span>
