////////////////////////////////////////////////////////////////
//
//                   Variants, as Patterns
//
////////////////////////////////////////////////////////////////

/* The variant files schedule their grains with a Routine: a loop that builds a
   Synth, waits, and repeats. This file does the same things with Patterns.

   The translation is mechanical. A Routine that does

       times.do { |i| Synth(\grain, [\dur, dur]); (dur/overlap).wait }

   is a Pbind with two keys:

       Pbind(\instrument, \grain, \dur, dur, \delta, dur/overlap)

   \dur is what the grain is told, \delta is how long the pattern waits before
   the next one. In a Routine those two are separate lines; in a Pbind they are
   two keys and can each be a pattern.

   What you gain: any parameter can be a stream, one grain can be derived from
   another with Pkey, several streams can run in parallel with Ppar, and the
   whole thing can be replaced while it sounds with Pdef.

   What you lose: the Routine's local variables. A linkage that was two lines of
   arithmetic becomes a Pkey expression, which is the subject of the last section.

   Amplitude follows the same rule as in class 02: grains do not sum in phase, so
   the level grows with the square root of the overlap. */

(
~path = (PathName(thisProcess.nowExecutingPath)).pathOnly ++ "samples/";
~voice = Buffer.read(s, ~path ++ "vocal.wav");
~bikecat = Buffer.read(s, ~path ++ "bikecat.wav");

// one grain amplitude for everything below, from the event's own dur and delta.
// min(1) because the correction is for overlap: when dur is shorter than delta
// the grains are separate and there is nothing to compensate for.
~amp = Pfunc { |e| 0.6 * sqrt((e[\delta] / e[\dur]).min(1)) };

// sine grains are coherent enough to partly sum in phase, unlike sampled ones,
// so the grainlet section takes the same figure with some headroom left
~gamp = ~amp * 0.7;
)


///////////////////////// The SynthDefs //////////////////////////

/* The same three as in the variant files, repeated here so this file runs on
   its own. Nothing in them knows about Routines or Patterns. */

(
SynthDef(\gliss, { |buf = 0, start = 0, amp = 0.5, dur = 0.3, pan = 0, from = 0.5, to = 4.0|
	var env = EnvGen.ar(Env([0, amp, 0], [dur*0.5, dur*0.5], \sine), doneAction: 2);
	var pos = start * BufFrames.ir(buf);
	var sig = PlayBuf.ar(1, buf, Line.ar(from, to, dur) * BufRateScale.ir(buf), 1, pos, 0);
	OffsetOut.ar(0, Pan2.ar(sig * env, pan));
}).add;

SynthDef(\trainlet, { |amp = 1.0, dur = 0.3, pan = 0, density = 20, harmonics = 10|
	var env = EnvGen.ar(Env.perc(dur*0.2, dur*0.8), doneAction: 2);
	var sig = Blip.ar(density, harmonics);
	OffsetOut.ar(0, Pan2.ar(sig * env, pan, amp));
}).add;

SynthDef(\grainlet, { |freq = 440, amp = 0.2, dur = 0.05, pan = 0, depth = 0|
	var env = EnvGen.ar(Env([0, amp, 0], [dur*0.5, dur*0.5], \sine), doneAction: 2);
	var sig = SinOsc.ar(freq) * env;
	var wet = FreeVerb.ar(sig, mix: depth, room: 0.7);
	OffsetOut.ar(0, Pan2.ar(wet, pan));
}).add;
)


///////////////////////////// Glisson ////////////////////////////

// the Routine example from Glisson.scd, written as a Pbind
(
Pdef(\gl, Pbind(
	\instrument, \gliss,
	\buf, ~voice.bufnum,
	\dur, 0.02,
	\delta, 0.01,
	\amp, ~amp,
	\start, Pseries(0, 0.002, 500),
	\from, Pseries(1.0, 0.002, 500),
	\to,   Pseries(2.0, 0.016, 500)
)).play;
)
Pdef(\gl).stop;


/* Magnetization, the six cases the diagram in the deck names. Each is one line
   different from the others, which is the argument for writing it this way. */

// deep: a wide interval on every glisson
(
Pdef(\gl, Pbind(\instrument, \gliss, \buf, ~voice.bufnum,
	\dur, 0.06, \delta, 0.02, \amp, ~amp, \start, Pwhite(0.1, 0.7),
	\from, Pwhite(0.5, 0.7), \to, Pwhite(3.0, 6.0), \pan, Pwhite(-0.8, 0.8))).play;
)

// shallow: the same, with the interval closed up
(
Pdef(\gl, Pbind(\instrument, \gliss, \buf, ~voice.bufnum,
	\dur, 0.06, \delta, 0.02, \amp, ~amp, \start, Pwhite(0.1, 0.7),
	\from, Pwhite(0.95, 1.05), \to, Pwhite(1.1, 1.25), \pan, Pwhite(-0.8, 0.8))).play;
)

// unidirectional: every glisson rises
(
Pdef(\gl, Pbind(\instrument, \gliss, \buf, ~voice.bufnum,
	\dur, 0.06, \delta, 0.02, \amp, ~amp, \start, Pwhite(0.1, 0.7),
	\from, 1.0, \to, Pwhite(2.0, 3.0), \pan, Pwhite(-0.8, 0.8))).play;
)

// bidirectional: up or down, decided per grain
(
Pdef(\gl, Pbind(\instrument, \gliss, \buf, ~voice.bufnum,
	\dur, 0.06, \delta, 0.02, \amp, ~amp, \start, Pwhite(0.1, 0.7),
	\from, 1.0, \to, Prand([0.35, 2.8], inf), \pan, Pwhite(-0.8, 0.8))).play;
)

// diverging: all from one centre, outward
(
Pdef(\gl, Pbind(\instrument, \gliss, \buf, ~voice.bufnum,
	\dur, 0.08, \delta, 0.02, \amp, ~amp, \start, Pwhite(0.1, 0.7),
	\from, 1.0, \to, Pwhite(0.3, 3.5), \pan, Pwhite(-0.8, 0.8))).play;
)

// converging: from anywhere, in to one centre
(
Pdef(\gl, Pbind(\instrument, \gliss, \buf, ~voice.bufnum,
	\dur, 0.08, \delta, 0.02, \amp, ~amp, \start, Pwhite(0.1, 0.7),
	\from, Pwhite(0.3, 3.5), \to, 1.0, \pan, Pwhite(-0.8, 0.8))).play;
)

Pdef(\gl).stop;


//////////////////////////// Trainlet ////////////////////////////

// the Routine example from Trainlet.scd, as a Pbind
(
Pdef(\tr, Pbind(
	\instrument, \trainlet,
	\dur, 0.05,
	\delta, 0.025,
	\amp, ~amp,
	\density, Pwhite(1, 10),
	\harmonics, 1000
)).play;
)

// harmonics as a stream: the trainlet moves from a click to a pitch
(
Pdef(\tr, Pbind(\instrument, \trainlet, \dur, 0.05, \delta, 0.025, \amp, ~amp,
	\density, 40, \harmonics, Pseg(Pseq([1, 200, 1], inf), 6, \exp))).play;
)

// density as a stream, with the harmonics held: the formant stays, the pitch moves
(
Pdef(\tr, Pbind(\instrument, \trainlet, \dur, 0.06, \delta, 0.03, \amp, ~amp,
	\density, Pbrown(5, 200, 12), \harmonics, 60, \pan, Pwhite(-1.0, 1.0))).play;
)

Pdef(\tr).stop;


//////////////////////////// Grainlet ////////////////////////////

/* This is where a pattern says the thing more directly than a Routine does. A
   linkage is a dependency between two parameters, and Pkey is a reference to a
   value already decided in this event. The rule becomes one key. */

// no linkage: the control. Frequency and duration chosen independently
(
Pdef(\gr, Pbind(\instrument, \grainlet, \delta, 0.04,
	\freq, Pexprand(200, 4000), \dur, Pwhite(0.01, 0.12),
	\amp, ~gamp, \pan, Pwhite(-1.0, 1.0))).play;
)

// linkage 1: duration follows frequency, so high grains are short
(
Pdef(\gr, Pbind(\instrument, \grainlet, \delta, 0.04,
	\freq, Pexprand(200, 4000),
	\dur, Pkey(\freq).explin(200, 4000, 0.12, 0.008),
	\amp, ~gamp, \pan, Pwhite(-1.0, 1.0))).play;
)

// the same link reversed: high grains long, which is much heavier
(
Pdef(\gr, Pbind(\instrument, \grainlet, \delta, 0.04,
	\freq, Pexprand(200, 4000),
	\dur, Pkey(\freq).explin(200, 4000, 0.008, 0.12),
	\amp, ~gamp, \pan, Pwhite(-1.0, 1.0))).play;
)

// linkage 2: reverberation follows time, so the cloud recedes as it goes
(
Pdef(\gr, Pbind(\instrument, \grainlet, \delta, 0.04,
	\freq, Pexprand(200, 4000), \dur, 0.05, \amp, ~gamp,
	\pan, Pwhite(-1.0, 1.0),
	\depth, Pseg(Pseq([0, 0.9], inf), 12, \lin))).play;
)

// two linkages at once: duration from frequency, pan from frequency
(
Pdef(\gr, Pbind(\instrument, \grainlet, \delta, 0.03,
	\freq, Pexprand(200, 4000),
	\dur, Pkey(\freq).explin(200, 4000, 0.12, 0.008),
	\pan, Pkey(\freq).explin(200, 4000, -1.0, 1.0),
	\amp, ~gamp)).play;
)

Pdef(\gr).stop;


//////////////////////// Variants together ///////////////////////

/* Ppar runs streams at the same time. Each keeps its own delta, so the variants
   do not have to agree about rate. */

(
Pdef(\both, Ppar([
	Pbind(\instrument, \grainlet, \delta, 0.05, \freq, Pexprand(300, 3000),
		\dur, Pkey(\freq).explin(300, 3000, 0.1, 0.01), \amp, ~gamp,
		\pan, Pwhite(-1.0, -0.2)),
	Pbind(\instrument, \gliss, \buf, ~bikecat.bufnum, \delta, 0.12,
		\dur, 0.25, \amp, ~amp, \start, Pwhite(0.0, 0.8),
		\from, 1.0, \to, Prand([0.5, 2.0], inf), \pan, Pwhite(0.2, 1.0))
])).play;
)

/* A Pdef can be replaced while it sounds. Evaluate the block above, then the one
   below, and the change happens at the next bar without a gap. */

(
Pdef(\both, Ppar([
	Pbind(\instrument, \trainlet, \delta, 0.06, \dur, 0.1, \amp, ~amp,
		\density, Pbrown(4, 60, 6), \harmonics, 400, \pan, Pwhite(-1.0, 0.0)),
	Pbind(\instrument, \gliss, \buf, ~voice.bufnum, \delta, 0.08,
		\dur, 0.2, \amp, ~amp, \start, Pbrown(0.0, 1.0, 0.05),
		\from, Pwhite(0.8, 1.2), \to, Pwhite(0.8, 1.2), \pan, Pwhite(0.0, 1.0))
])).play;
)

Pdef(\both).stop;

CmdPeriod.run;
