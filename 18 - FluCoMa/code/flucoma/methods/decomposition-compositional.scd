////////////////////////////////////////////////////////////////
//
//             Split, then recompose with patterns
//
////////////////////////////////////////////////////////////////


~sounds = thisProcess.nowExecutingPath.dirname +/+ "../../sounds/";


// Decompose catbike with HPSS, then split residual with transients.


(

s.waitForBoot({

	Routine({

		~src = Buffer.read(s, ~sounds +/+ "catbike.wav");
		s.sync;

		~harm = Buffer.alloc(s, 1);
		~perc = Buffer.alloc(s, 1);

		FluidBufHPSS.processBlocking(s, ~src,
			harmonic: ~harm, percussive: ~perc,
			harmFilterSize: 17, percFilterSize: 31);
		"HPSS done".postln;

		~trans = Buffer.alloc(s, 1);
		~tres  = Buffer.alloc(s, 1);

		FluidBufTransients.processBlocking(s, ~perc,
			transients: ~trans, residual: ~tres,
			threshFwd: 2.0, threshBack: 1.1);
		"transients done".postln;

	}).play;

});

)


// Three SynthDefs. One per component, each processed differently.


(

SynthDef(\grainHarm, { |out = 0, buf, amp = 0.5, rate = 1, dur = 0.4|

	var pos = Rand(0, BufFrames.kr(buf));
	var sig = PlayBuf.ar(1, buf, rate * BufRateScale.kr(buf), startPos: pos);
	var env = EnvGen.kr(Env.sine(dur), doneAction: 2);

	Out.ar(out, (sig * env * amp).dup);

}).add;

SynthDef(\hitPerc, { |out = 0, buf, amp = 0.7, gateLen = 0.15|

	var pos = Rand(0, BufFrames.kr(buf) - SampleRate.ir);  // safe-ish region
	var sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf), startPos: pos);
	var env = EnvGen.kr(Env([0, 1, 1, 0], [0.005, gateLen, 0.005]), doneAction: 2);

	sig = MoogFF.ar(sig, 4000, 0.3);

	Out.ar(out, (sig * env * amp).dup);

}).add;

SynthDef(\sparkTrans, { |out = 0, buf, amp = 0.9|

	var pos = Rand(0, BufFrames.kr(buf));
	var sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf), startPos: pos);
	var env = EnvGen.kr(Env.perc(0.001, 0.08), doneAction: 2);

	Out.ar(out, FreeVerb.ar(sig * env * amp, 0.6, 0.7, 0.4).dup);

}).add;

)


// Three patterns that play

(

Pdef(\harm, Pbind(
	\instrument, \grainHarm,
	\buf, Pfunc({ ~harm }),
	\dur, Pwhite(0.3, 0.7),
	\rate, Pwhite(0.85, 1.15),
	\amp, Pwhite(0.2, 0.4)
)).play(quant: 1);

)

(

Pdef(\perc, Pbind(
	\instrument, \hitPerc,
	\buf, Pfunc({ ~perc }),
	\dur, 0.125,
	\amp, Pseq([0.7, 0.3, 0.5, 0.4], inf),
	\gateLen, Pwhite(0.06, 0.14)
)).play(quant: 1);

)

(

Pdef(\spark, Pbind(
	\instrument, \sparkTrans,
	\buf, Pfunc({ ~trans }),
	\dur, Pwhite(0.5, 2.0),
	\amp, Pwhite(1.4, 1.9)
)).play(quant: 1);

)



// Change them ...

(

Pdef(\perc, Pbind(
	\instrument, \hitPerc,
	\buf, Pfunc({ ~perc }),
	\dur, Pseq([0.0625, 0.125, 0.125], inf),  // dotted 32nd
	\amp, Pseq([0.8, 0.4, 0.5, 0.3, 0.6, 0.2], inf),
	\gateLen, 0.04                             // very short bursts
));

)

(

Pdef(\harm, Pbind(
	\instrument, \grainHarm,
	\buf, Pfunc({ ~harm }),
	\dur, Pwhite(0.6, 1.4),
	\rate, Pseq([0.5, 0.75, 1.0, 1.5], inf),   // cycle through ratios
	\amp, 0.0                                   // muted
));

)
