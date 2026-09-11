////////////////////////////////////////////////////////////////
//
//                          Grainlet
//
////////////////////////////////////////////////////////////////

/* The fourth species, and the one that is not really a sound. Roads:
   "The fundamental notion of grainlet synthesis is that any parameter of
   synthesis can be made dependent on (or linked to) any other parameter."
   So there is no grainlet UGen. There is a grain, and a set of rules
   saying which of its parameters follow which. Everything below uses the
   same SynthDef; only the linkages change. */

s.boot


///////////////////////// One instrument ///////////////////////

( // the same grain throughout: nothing here knows about linkage
SynthDef(\grainlet, { |freq = 440, amp = 0.2, dur = 0.05, pan = 0, depth = 0|
	var env = EnvGen.ar(Env([0, amp, 0], [dur * 0.5, dur * 0.5], \sine), doneAction: 2);
	var sig = SinOsc.ar(freq) * env;
	var wet = FreeVerb.ar(sig, mix: depth, room: 0.7);
	OffsetOut.ar(0, Pan2.ar(wet, pan));
}).add;
)

// one grainlet, to hear the material before any rule is applied
Synth(\grainlet, [\freq, 440, \dur, 0.08])


//////////////////// No linkage: the control /////////////////////

/* Frequency and duration chosen independently. This is ordinary granular
   synthesis, and it is the thing the next blocks depart from. */

(
Routine({
	200.do {
		Synth(\grainlet, [
			\freq, exprand(200, 4000),
			\dur, rrand(0.01, 0.12),
			\pan, rrand(-1.0, 1.0)
		]);
		0.04.wait;
	};
}).play;
)


///////////// Linkage 1: duration follows frequency /////////////

/* Roads' first example, and the wavelet relationship: high grains short,
   low grains long. One line of arithmetic turns a cloud into a texture
   with a consistent internal logic. */

(
Routine({
	200.do {
		var freq = exprand(200, 4000);
		var dur  = freq.explin(200, 4000, 0.12, 0.008);   // inverse link
		Synth(\grainlet, [\freq, freq, \dur, dur, \pan, rrand(-1.0, 1.0)]);
		0.04.wait;
	};
}).play;
)

// the same link, reversed: high grains long. Listen to how much heavier it is.
(
Routine({
	200.do {
		var freq = exprand(200, 4000);
		var dur  = freq.explin(200, 4000, 0.008, 0.12);   // direct link
		Synth(\grainlet, [\freq, freq, \dur, dur, \pan, rrand(-1.0, 1.0)]);
		0.04.wait;
	};
}).play;
)


///////////// Linkage 2: depth follows start time ///////////////

/* Roads' second example from figure 4.3: later grains get more
   reverberation, so the cloud recedes as it goes. */

(
Routine({
	var n = 200;
	n.do { |i|
		Synth(\grainlet, [
			\freq, exprand(200, 4000),
			\dur, 0.05,
			\depth, i.linlin(0, n, 0.0, 0.9),            // direct link to time
			\amp, i.linlin(0, n, 0.22, 0.10),
			\pan, rrand(-1.0, 1.0)
		]);
		0.04.wait;
	};
}).play;
)


///////////// Linkage 3: two links at once //////////////////////

/* Duration follows frequency, and pan follows frequency as well, so the
   cloud is spread out by register. Two rules, and the cloud now has a
   shape you did not describe directly. */

(
Routine({
	200.do {
		var freq = exprand(120, 6000);
		Synth(\grainlet, [
			\freq, freq,
			\dur, freq.explin(120, 6000, 0.14, 0.006),
			\pan, freq.explin(120, 6000, -0.9, 0.9),
			\amp, freq.explin(120, 6000, 0.10, 0.24)
		]);
		0.03.wait;
	};
}).play;
)


///////////// Linkage as data, not as code //////////////////////

/* The point of the technique is that the links are a structure you can
   edit, not statements buried in a loop. Here they are a dictionary of
   functions, one per parameter, each given the grain's index and its
   frequency. Add a key and you have added a link. */

(
~links = (
	dur:   { |i, n, freq| freq.explin(120, 6000, 0.14, 0.006) },
	pan:   { |i, n, freq| freq.explin(120, 6000, -0.9, 0.9) },
	depth: { |i, n, freq| i / n * 0.8 },
	amp:   { |i, n, freq| 0.2 * (1 - (i / n * 0.5)) }
);

~cloud = { |n = 240, wait = 0.03|
	Routine({
		n.do { |i|
			var freq = exprand(120, 6000);
			var args = [\freq, freq];
			~links.keysValuesDo { |k, f| args = args ++ [k, f.value(i, n, freq)] };
			Synth(\grainlet, args);
			wait.wait;
		};
	}).play;
};
)

~cloud.value

// remove a link and hear what it was doing
(
~links.removeAt(\dur);
~cloud.value;
)

CmdPeriod.run
