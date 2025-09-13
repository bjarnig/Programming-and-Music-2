////////////////////////////////////////////////////////////////
//
//                    Granular Routines
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

SynthDef(\grain, { |buf=0, rate=1, start=0, amp=0.5, dur=0.3, pan=0|
	var sig, shape, env, pos;
	shape = Env([0, amp, 0], [dur*0.5, dur*0.5], \sine);
	env = EnvGen.ar(shape, doneAction: 2);
	pos = start * BufSamples.ir(buf);
	sig = PlayBuf.ar(1, buf, rate * BufRateScale.ir(buf), 1, pos, 0);
	OffsetOut.ar(0, Pan2.ar(sig * env, pan));
}).add;

)



// Use Routines for accurate timing, play through a sound
(
Routine({
	var times = 1000;
	times.do{|i|
		i.postln;
		Synth(\grain, [\dur, 0.1, \buf, ~voice.bufnum, \start, i/times]);
		0.01.wait;
	};
}).play;
)




// Randomize start times
(
Routine({
	var times, start;
	times = 100000;
	times.do{|i|
		start = rrand(0.0, 0.1);
		Synth(\grain, [\dur, 0.1, \buf, ~bikecat.bufnum, \start, start]);
		0.01.wait;
	};
}).play;
)




// Reconstruct a sound
(
Routine({
	var next, rate, start, times, total, dur=0.2, overlap=2;
	total = ~voice.numFrames / ~voice.sampleRate;
	times = ((total / dur) * overlap).asInteger;
	times.do{|i|
		next = dur / overlap;
		start = (i * next) / total;
		s.makeBundle(0.1,
		{ Synth(\grain, [\buf, ~voice.bufnum, \dur, dur, \start, start]) });
		next.wait;
	};
}).play;
)




// Timestretch
(
Routine({
	var next, rate, start, times, total, dur=0.06, overlap=2, stretch=8;
	total = ~voice.numFrames / ~voice.sampleRate;
	times = (((total / dur) * overlap) * stretch).asInteger;
	times.do{|i|
		next = dur / overlap;
		start = ((i * next) / total) / stretch;
		s.makeBundle(0.1,
		{ Synth("grain", [\buf, ~voice.bufnum, \dur, dur, \start, start]) });
		next.wait;
	};
}).play;
)




// Morph between sounds
(
Routine({
	var next, rate, start, times, total, dur=0.06, overlap=2, stretch=0.75, buf;
	total = ~voice.numFrames / ~voice.sampleRate;
	times = (((total / dur) * overlap) * stretch).asInteger;
	times.do{|i|
		next = dur / overlap;
		start = ((i * next) / total) / stretch;
		buf = [~voice.bufnum, ~bikecat.bufnum]
		.wchoose([i.linlin(0, times, 0, 1), i.linlin(0, times, 1, 0)]);
		s.makeBundle(0.1, {
		Synth("grain", [\buf, buf, \dur, dur, \start, start]) });
		next.wait;
	};
}).play;
)




// Randomize sound and start position
(
Routine({
	var times, start, buf;
	times = 10000;
	times.do{|i|
		start = rrand(0.0, 1.0);

		if(0.4.coin, {
			buf = ~voice.bufnum;
		}, {
			buf = ~bikecat.bufnum;
		});

		if(0.2.coin, {
			start = rrand(0.1, 0.4);
		}, {
			start = rrand(0.6, 0.8);
		});

		Synth(\grain, [\dur, 0.15, \buf, buf, \start, start]);
		0.01.wait;
	};
}).play;
)
