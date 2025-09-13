////////////////////////////////////////////////////////////////
//
//                          Glisson
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

SynthDef(\gliss, { |buf=0, start=0, amp=0.5, dur=0.3, pan=0, from=0.5,to=4.0|
	var sig, shape, env, pos;
	shape = Env([0, amp, 0], [dur*0.5, dur*0.5], \sine);
	env = EnvGen.ar(shape, doneAction: 2);
	pos = start * BufFrames.ir(buf);
	sig = PlayBuf.ar(1, buf, Line.ar(from,to,dur) * BufRateScale.ir(buf), 1, pos, 0);
	OffsetOut.ar(0, Pan2.ar(sig * env, pan));
}).add;

)



( // Glisson towards hi

var dur=0.02, overlap=2.0, sample=~voice;

Routine {
	var total = sample.numFrames / sample.sampleRate;
	var times = ((total / dur) * overlap).asInteger.postln;

	times.do{|i|
		var next = dur / overlap;
		var start = (i * next) / total;

		s.makeBundle(0.1,
		{ Synth(\gliss, [
				\buf, sample.bufnum,
				\dur, dur,
				\start, start,
				\from, i.linlin(0,times,1.0,2.0),
				\to, i.linlin(0,times,2.0,10.0)
		]) });
		next.wait;
	};

}.play;

)

(

SynthDef(\gliss, { |buf=0, start=0, amp=0.5, dur=0.3, pan=0, from=0.5,to=4.0|
	var sig, shape, env, pos;
	shape = Env([0, amp, 0], [dur*0.5, dur*0.5], \sine);
	env = EnvGen.ar(shape, doneAction: 2);
	pos = start * BufFrames.ir(buf);
	sig = PlayBuf.ar(1, buf, Line.ar(from,to,dur) * BufRateScale.ir(buf), 1, pos, 0);
	OffsetOut.ar(0, Pan2.ar(sig * env, pan));
}).add;

)

( // Glisson converging to center

var dur=0.02, overlap=2.0, sample=~voice;

Routine {
	var total = sample.numFrames / sample.sampleRate;
	var times = ((total / dur) * overlap).asInteger.postln;

	times.do{|i|
		var next = dur / overlap;
		var start = (i * next) / total;

		s.makeBundle(0.1,
		{ Synth(\gliss, [
				\buf, sample.bufnum,
				\dur, dur,
				\start, start,
				\from, Env([0.1,1,1], [times/2,times/2]).at(i),
				\to, Env([100,4,1], [times/2,times/2]).at(i)
		]) });
		next.wait;
	};

}.play;

)


( // Glisson layers

~glissons = {|times=10, dur=0.1, overlap=2.0, from=0.1, to=2, sample|

times.do {|n|

Routine {
	var total = sample.numFrames / sample.sampleRate;
	var times = ((total / dur) * overlap).asInteger.postln;

	times.do{|i|
		var next = dur / overlap;
		var start = (i * next) / total;

		n = n + 1;

		s.makeBundle(0.1,
		{ Synth(\gliss, [
			\buf, sample.bufnum,
			\dur, dur,
			\start, start,
			\from, Env([from*n,1,1], [times/2,times/2] * n).at(i),
			\to, Env([to*n,4,1], [times/2,times/2] * n).at(i)
		]) });
		next.wait;
	};

}.play;

}};

~glissons.value(5,sample:~voice)

)

