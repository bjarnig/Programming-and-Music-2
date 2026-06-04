////////////////////////////////////////////////////////////////
//
//                   Hybrids of two files
//
////////////////////////////////////////////////////////////////


~sounds = thisProcess.nowExecutingPath.dirname +/+ "../../sounds/";


// FluidBufNMFCross, vocal target, texture source.

(

s.waitForBoot({

	Routine({

		~target = Buffer.read(s, ~sounds +/+ "vocal.wav");
		~source = Buffer.read(s, ~sounds +/+ "texture.wav");
		s.sync;

		~xsynth = Buffer.alloc(s, 1);

		"crossing… (this can take a while)".postln;

		FluidBufNMFCross.processBlocking(s, ~source, ~target, ~xsynth,
			timeSparsity: 4,
			polyphony: 3,
			continuity: 20,
			windowSize: 2048,
			action: { "cross-synthesis done.".postln }
		);

	}).play;

});

)

// Compare:
{ PlayBuf.ar(1, ~target, BufRateScale.kr(~target), doneAction: 2).dup }.play;  // target
{ PlayBuf.ar(1, ~source, BufRateScale.kr(~source), doneAction: 2).dup }.play;  // source palette
{ PlayBuf.ar(1, ~xsynth, BufRateScale.kr(~xsynth), doneAction: 2).dup }.play;  // hybrid


// Granulate the hybrid

(

SynthDef(\xgrain, { |out = 0, buf, amp = 0.5, dur = 0.2, posJit = 0.5, rate = 1|

	var pos = Rand(0, BufFrames.kr(buf) - (SampleRate.ir * dur));
	var sig = PlayBuf.ar(1, buf, rate * BufRateScale.kr(buf), startPos: pos);
	var env = EnvGen.kr(Env.sine(dur), doneAction: 2);

	Out.ar(out, (sig * env * amp).dup);

}).add;

)

(

Pdef(\cloud, Pbind(
	\instrument, \xgrain,
	\buf, Pfunc({ ~xsynth }),
	\dur, Pwhite(0.04, 0.2),
	\rate, Prand([0.5, 0.75, 1.0, 1.5, 2.0], inf),
	\amp, Pwhite(0.2, 0.5)
)).play;

)



// FluidBufCompose, layer the original target on top of the hybrid.

(

~mix = Buffer.alloc(s, ~xsynth.numFrames);

Routine({

	FluidBufCompose.processBlocking(s, ~xsynth, destination: ~mix);
	s.sync;

	// Splice 1 s of the original vocal in 4 places
	(0..3).do { |i|

		var pos = i * ~mix.sampleRate * 4;

		FluidBufCompose.processBlocking(s, ~target,
			startFrame: 0, numFrames: ~target.sampleRate.asInteger,
			gain: -6.dbamp,
			destination: ~mix, destStartFrame: pos.asInteger,
			destGain: 0.7
		);

	};

	"compose done".postln;

}).play;

)

{ PlayBuf.ar(1, ~mix, BufRateScale.kr(~mix), doneAction: 2).dup }.play;


// Change the cross-synth params and re-run.

(

~xsynth = Buffer.alloc(s, 1);

FluidBufNMFCross.processBlocking(s, ~source, ~target, ~xsynth,
	timeSparsity: 1,
	polyphony: 5,
	continuity: 50,
	windowSize: 2048,
	action: { "re-cross done.".postln }
);

)

~xsynth.play
