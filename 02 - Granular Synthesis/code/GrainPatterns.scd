////////////////////////////////////////////////////////////////
//
//                    Granular Patterns
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)


////////////////////// Buffers & SynthDef ///////////////////////

(

~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
~path = ~path ++ "samples/";
~voice = Buffer.read(s, ~path ++ "vocal.wav");
~bikecat = Buffer.read(s, ~path ++ "bikecat.wav");

// One synth per grain.

SynthDef(\grain, { |buf=0, rate=1, start=0, amp=0.5, dur=0.3, pan=0, curve=0|
	var sig, shape, env, pos;
	shape = Env([0, amp, 0], [dur*0.5, dur*0.5], [curve, curve.neg]);
	env = EnvGen.ar(shape, doneAction: 2);
	pos = start * BufSamples.ir(buf);
	sig = PlayBuf.ar(1, buf, rate * BufRateScale.ir(buf), 1, pos, 0);
	OffsetOut.ar(0, Pan2.ar(sig * env, pan));
}).add;

)


// Play through a sound (linear progression)
(
var n = 1000;
var dur = 0.1;
var delta = 0.01;

Pbind(
	\instrument, \grain,
	\buf, ~voice.bufnum,
	\dur, dur,
	\delta, delta,
	\amp, 0.5,
	\pan, 0,
	\start, Pseries(0, 1/n, n)
).play;
)



// Randomize start times
(
var n = 100000;
var dur = 0.1;
var delta = 0.01;

Pbind(
	\instrument, \grain,
	\buf, ~bikecat.bufnum,
	\dur, dur,
	\delta, delta,
	\amp, 0.5,
	\pan, 0,
	\start, Pwhite(0.0, 0.1, n)
).play;
)



// Reconstruct a sound
(
var dur = 0.2;
var ovlp = 2;
var totaldur = ~voice.duration;
var next = dur / ovlp;
var n = (totaldur / dur * ovlp).asInteger;
var startIncrement = next / totaldur;

Pbind(
	\instrument, \grain,
	\buf, ~voice.bufnum,
	\dur, dur,
	\delta, next,
	\amp, 0.5,
	\pan, 0,
	\start, Pseries(0, startIncrement, n)
).play;
)



// Timestretch
(
var dur = 0.05;
var ovlp = 2;
var stretch = 8;
var totaldur = ~voice.numFrames / ~voice.sampleRate;
var next = dur / ovlp;
var n = (totaldur / dur * ovlp * stretch).asInteger;
var startIncrement = next / totaldur / stretch;

Pbind(
	\instrument, \grain,
	\buf, ~voice.bufnum,
	\dur, dur,
	\delta, next,
	\amp, 0.5,
	\pan, 0,
	\start, Pseries(0, startIncrement, n)
).play;
)



// Morph between sounds
(
var dur = 0.06;
var ovlp = 2;
var stretch = 0.75;
var totaldur = ~voice.numFrames / ~voice.sampleRate;
var next = dur / ovlp;
var n = (totaldur / dur * ovlp * stretch).asInteger;
var startIncrement = next / totaldur / stretch;

Pbind(
	\instrument, \grain,
	\dur, dur,
	\delta, next,
	\amp, 0.5,
	\pan, 0,
	\start, Pseries(0, startIncrement, n),
	// Morph probability from voice to bikecat over time
	\counter, Pseries(0, 1, n),
	\buf, Pfunc { |ev|
		var prob = ev[\counter].linlin(0, n, 0, 1);
		[~voice.bufnum, ~bikecat.bufnum].wchoose([1-prob, prob])
	}
).play;
)



// Randomize sound and start position
(
var n = 10000;
var dur = 0.15;
var delta = 0.01;

Pbind(
	\instrument, \grain,
	\dur, dur,
	\delta, delta,
	\amp, 0.5,
	\pan, 0,
	// 40% chance voice, 60% chance bikecat
	\buf, Pwrand([~voice.bufnum, ~bikecat.bufnum], [0.4, 0.6], n),
	// 20% chance range 0.1-0.4, 80% chance range 0.6-0.8
	\start, Pwrand(
		[Pwhite(0.1, 0.4, 1), Pwhite(0.6, 0.8, 1)],
		[0.2, 0.8],
		n
	)
).play;
)



///////////////////// Per grain variation ///////////////////////

// one grain amplitude for all of them, from whatever dur and delta the event has
~amp = Pfunc { |e| 0.9 * sqrt(e[\delta] / e[\dur]) };


// Pan: each grain lands is a different position.
(
var n = 400, dur = 0.12, delta = 0.02;
Pbind(
	\instrument, \grain,
	\buf, ~voice.bufnum,
	\dur, dur,
	\delta, delta,
	\amp, ~amp,
	\start, Pseries(0, 1/n, n),
	\pan, Pwhite(-1.0, 1.0)
).play;
)


// Rate: a cloud around the original pitch, in semitones
(
var n = 400, dur = 0.15, delta = 0.02;
Pbind(
	\instrument, \grain,
	\buf, ~voice.bufnum,
	\dur, dur,
	\delta, delta,
	\amp, ~amp,
	\start, Pwhite(0.2, 0.6),
	\pan, Pwhite(-0.8, 0.8),
	\rate, Pwhite(-5, 5).midiratio
).play;
)


// Rate quantised to a chord, so the cloud has a harmony rather than a band
(
var n = 400, dur = 0.2, delta = 0.03;
Pbind(
	\instrument, \grain,
	\buf, ~voice.bufnum,
	\dur, dur,
	\delta, delta,
	\amp, ~amp,
	\start, Pwhite(0.2, 0.6),
	\pan, Pwhite(-0.8, 0.8),
	\rate, Prand([-12, -5, 0, 7, 12, 19], inf).midiratio
).play;
)


// Duration: short grains are noisy, long ones keep the source audible.
(
var delta = 0.02;
Pbind(
	\instrument, \grain,
	\buf, ~voice.bufnum,
	\dur, Pwhite(0.01, 0.3),
	\delta, delta,
	\amp, ~amp,
	\start, Pwhite(0.2, 0.6),
	\pan, Pwhite(-0.8, 0.8)
).play;
)


// Envelope: the same grains, swept from percussive to soft to reversed
(
var dur = 0.12, delta = 0.02;
Pbind(
	\instrument, \grain,
	\buf, ~voice.bufnum,
	\dur, dur,
	\delta, delta,
	\amp, ~amp,
	\start, Pwhite(0.2, 0.6),
	\pan, Pwhite(-0.8, 0.8),
	\curve, Pseg(Pseq([8, -8, 8], inf), 6, \lin)
).play;
)


// Density: delta itself is a pattern, so the cloud thins and thickens
(
var dur = 0.12;
Pbind(
	\instrument, \grain,
	\buf, ~voice.bufnum,
	\dur, dur,
	\delta, Pseg(Pseq([0.005, 0.12, 0.005], inf), 8, \exp),
	\amp, ~amp,
	\start, Pwhite(0.2, 0.6),
	\pan, Pwhite(-0.8, 0.8)
).play;
)


// Everything at once: one grain, six independent decisions
(
var dur = 0.12, delta = 0.015;
Pbind(
	\instrument, \grain,
	\buf, Pwrand([~voice.bufnum, ~bikecat.bufnum], [0.7, 0.3], inf),
	\dur, Pwhite(0.03, 0.25),
	\delta, delta,
	\amp, ~amp,
	\start, Pbrown(0.0, 1.0, 0.03),
	\pan, Pwhite(-1.0, 1.0),
	\rate, Prand([-12, -5, 0, 0, 7, 12], inf).midiratio,
	\curve, Pwhite(-6.0, 6.0)
).play;
)

CmdPeriod.run;
