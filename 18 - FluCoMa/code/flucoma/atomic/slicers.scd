////////////////////////////////////////////////////////////////
//
//                 Segment a buffer into events
//
////////////////////////////////////////////////////////////////


~sounds = thisProcess.nowExecutingPath.dirname +/+ "../../sounds/";


/*

  All four slicers fill an "indices" buffer with sample positions where they
  detected a slice point. They differ in what kind of "change" they look for:

   FluidBufOnsetSlice      — spectral-difference onsets (percussive material)
   FluidBufNoveltySlice    — novelty curve over a chosen feature
   FluidBufAmpSlice        — amplitude gating with fast/slow envelopes
   FluidBufTransientSlice  — autoregressive transient detection

   Loads the indices, then schedules a Routine that plays each detected segment in turn.

*/


// Audition all helper

(

~auditionAll = { |src, idx, gap = 0.01|

	idx.loadToFloatArray(action: { |fa|

		Routine({

			"auditioning % slices…".format(fa.size).postln;

			fa.do { |startSamp, i|

				var endSamp = fa[i + 1] ?? { src.numFrames };
				var dur = (endSamp - startSamp) / src.sampleRate;
				dur.postln;

				{
					var sig = PlayBuf.ar(1, src, BufRateScale.kr(src), startPos: startSamp);
					var sin = SinOsc.ar(400,0,0.3) * EnvGen.ar(Env.perc(0.01,0.02));
					var env = EnvGen.kr(
						Env([0, 1, 1, 0], [0.005, dur + 0.01, 0.005]),
						doneAction: 2
					);
					((sig + sin) * env).dup * 0.7;
				}.play;

				(dur + gap).wait;

			};

			"done.".postln;

		}).play;

	});

};

)


// Play a single slice by index.


(

~playSlice = { |src, idx, i = 0|

	idx.loadToFloatArray(action: { |fa|

		var start = fa[i];
		var end   = fa[i + 1] ?? { src.numFrames };
		var dur   = (end - start) / src.sampleRate;

		{
			var sig = PlayBuf.ar(1, src, BufRateScale.kr(src), startPos: start);
			var sin = SinOsc.ar(400,0,0.3) * EnvGen.ar(Env.perc(0.01,0.02));
			var env = EnvGen.kr(
				Env([0, 1, 1, 0], [0.005, dur - 0.01, 0.005]),
				doneAction: 2
			);
			((sig + sin) * env).dup * 0.7;
		}.play;

	});

};

)


// FluidBufOnsetSlice, percussive onsets

~branches = Buffer.read(s, ~sounds +/+ "branches.wav");

(

~onsetIdx = Buffer.alloc(s, 1);
FluidBufOnsetSlice.processBlocking(s, ~branches, indices: ~onsetIdx, threshold: 0.5);
"FluidBufOnsetSlice done.".postln;

)

// Plot
FluidWaveform(~branches, ~onsetIdx, bounds: Rect(0, 0, 1200, 300));


// Play one
~playSlice.(~branches, ~onsetIdx, 13);


// Play all
~auditionAll.(~branches, ~onsetIdx);


// Count them
~onsetIdx.loadToFloatArray(action: { |fa| ("Found % onset slices".format(fa.size)).postln });




// FluidBufNoveltySlice, novelty over a chosen analysis feature

/* algorithm, options:

\spectrum  — raw spectral change (default)
\mfcc      — timbral change (less sensitive to pitch)
\chroma    — pitch-class change (good for harmonic music)
\pitch     — pitched-note change
\loudness  — energy change

*/

(

~noveltyIdx = Buffer.alloc(s, 1);
FluidBufNoveltySlice.processBlocking(s, ~branches,
	indices: ~noveltyIdx,
	algorithm: \mfcc,
	threshold: 0.1,
	kernelSize: 11,
	minSliceLength: 5);
"FluidBufNoveltySlice done.".postln;

)

FluidWaveform(~branches, ~noveltyIdx, bounds: Rect(0, 0, 1200, 300));

~auditionAll.(~branches, ~noveltyIdx);

~playSlice.(~branches, ~noveltyIdx, 2);

~noveltyIdx.loadToFloatArray(action: { |fa| ("Found % novelty slices".format(fa.size)).postln });



// FluidBufAmpSlice, gate-style amplitude slicing

/* Two envelope followers (fast vs slow) cross when the signal "starts" or "ends" */

~vocal = Buffer.read(s, ~sounds +/+ "vocal.wav");

(

~ampIdx = Buffer.alloc(s, 1);
FluidBufAmpSlice.processBlocking(s, ~vocal,
	indices: ~ampIdx,
	fastRampUp: 10,    fastRampDown: 2205,
	slowRampUp: 4410,  slowRampDown: 4410,
	onThreshold: 10,   offThreshold: 5,
	floor: -40,        minSliceLength: 4410,
	highPassFreq: 20);
"FluidBufAmpSlice done.".postln;

)

FluidWaveform(~vocal, ~ampIdx, bounds: Rect(0, 0, 1200, 300));

~auditionAll.(~vocal, ~ampIdx);

~playSlice.(~vocal, ~ampIdx, 0);

~ampIdx.loadToFloatArray(action: { |fa| ("Found % amplitude slices".format(fa.size)).postln });



// FluidBufTransientSlice, sample-accurate transients

~catbike = Buffer.read(s, ~sounds +/+ "catbike.wav");

(

~transIdx = Buffer.alloc(s, 1);
FluidBufTransientSlice.processBlocking(s, ~catbike,
	indices: ~transIdx,
	threshFwd: 2.0,
	threshBack: 1.1,
	minSliceLength: 1000);
"FluidBufTransientSlice done.".postln;

)

FluidWaveform(~catbike, ~transIdx, bounds: Rect(0, 0, 1200, 300));

~auditionAll.(~catbike, ~transIdx);

~playSlice.(~catbike, ~transIdx, 1);

~transIdx.loadToFloatArray(action: { |fa| ("Found % transient slices".format(fa.size)).postln });




/* trigger random slices live */

(

~indices = nil;  // will be filled below

~onsetIdx.loadToFloatArray(action: { |fa| ~indices = fa });

Tdef(\randomSlice, {

	loop {

		if (~indices.notNil) {

			var i = ~indices.size.rand;
			~playSlice.(~branches, ~onsetIdx, i);

		};

		0.2.wait;

	};

}).play(AppClock);

)

