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
~hydro = Buffer.read(s, ~path ++ "hydro.wav");

SynthDef(\grain, { |buf=0, rate=1, start=0, amp=0.5, dur=0.3, pan=0|
	var sig, shape, env, pos;
	shape = Env([0, amp, 0], [dur*0.5, dur*0.5], \sine);
	env = EnvGen.ar(shape, doneAction: 2);
	pos = start * BufFrames.ir(buf);
	sig = PlayBuf.ar(1, buf, rate * BufRateScale.ir(buf), 1, pos, 0);
	OffsetOut.ar(0, Pan2.ar(sig * env, pan));
}).add;

)



( // Reconstruction

var dur=0.02, overlap=2.0, sample=~voice;

Routine {
	var total = sample.numFrames / sample.sampleRate;
	var times = ((total / dur) * overlap).asInteger.postln;

	times.do{|i|
		var next = dur / overlap;
		var start = (i * next) / total;

		s.makeBundle(0.1,
		{ Synth(\grain, [\buf, sample.bufnum, \dur, dur, \start, start]) });
		next.wait;
	};

}.play;

)

