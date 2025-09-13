////////////////////////////////////////////////////////////////
//
//                  Per-Grain Processing
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

SynthDef(\grainfold, { |buf=0, rate=1, start=0, amp=0.5, dur=0.3, pan=0, flo=0.0,fhi=1.0|
	var sig, shape, env, pos;
	shape = Env([0, amp, 0], [dur*0.5, dur*0.5], \sine);
	env = EnvGen.ar(shape, doneAction: 2);
	pos = start * BufFrames.ir(buf);
	sig = PlayBuf.ar(1, buf, rate * BufRateScale.ir(buf), 1, pos, 0);
	sig = Fold.ar(sig, flo, fhi);
	OffsetOut.ar(0, Pan2.ar(sig * env, pan));
}).add;

SynthDef(\grainbp, { |buf=0, rate=1, start=0, amp=0.5, dur=0.3, pan=0, bpf=100, bw=1.0|
	var sig, shape, env, pos;
	shape = Env([0, amp, 0], [dur*0.5, dur*0.5], \sine);
	env = EnvGen.ar(shape, doneAction: 2);
	pos = start * BufFrames.ir(buf);
	sig = PlayBuf.ar(1, buf, rate * BufRateScale.ir(buf), 1, pos, 0);
	sig = BBandPass.ar(sig, bpf, bw);
	OffsetOut.ar(0, Pan2.ar(sig * env, pan));
}).add;


)



( // Reverse and Folded

var dur=0.02, overlap=2.0, sample=~bikecat;

Routine {
	var total = sample.numFrames / sample.sampleRate;
	var times = ((total / dur) * overlap).asInteger.postln;

	times.do{|i|
		var next = dur / overlap;
		var start = (i * next) / total;

		s.makeBundle(0.1,
		{ Synth(\grainfold, [\buf, sample.bufnum, \dur, dur, \start, 1 - start, \flo, 0.0, \fhi, 2.0]) });
		next.wait;
	};

}.play;

)


( // Random filter and Bandpass

var dur=0.02, overlap=2.0, sample=~bikecat;

Routine {
	var total = sample.numFrames / sample.sampleRate * 2;
	var times = ((total / dur) * overlap).asInteger.postln;

	times.do{|i|
		var next = dur / overlap;
		var start = (i * next) / total;

		s.makeBundle(0.1,
			{ Synth(\grainbp, [\buf, sample.bufnum, \dur, dur, \start, 1.0.rand,
			\bpf, i.linlin(0,times, 100, 8000),
			\bw, 5
		]) });
		next.wait;
	};

}.play;

)
