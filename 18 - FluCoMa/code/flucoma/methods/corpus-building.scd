////////////////////////////////////////////////////////////////
//
//                   slice - describe - store
//
////////////////////////////////////////////////////////////////

s.boot;

~sounds = thisProcess.nowExecutingPath.dirname +/+ "../../sounds/";
~jsonPath = thisProcess.nowExecutingPath.dirname +/+ "corpus_mfcc.json";


// Build the corpus — analyse every .wav in the sounds folder.

/* Slice each file with FluidBufNoveltySlice (textural change), describe
 with 13 MFCCs (drop coeff 0 to ignore loudness), reduce each
 slice's analysis to its mean, one 13-D vector per slice. */

(

s.waitForBoot({

	Routine({

		var files = (~sounds ++ "*.wav").pathMatch;
		var feat   = Buffer.alloc(s, 1);
		var stat   = Buffer.alloc(s, 1);
		var point  = Buffer.alloc(s, 1);
		var slices = Buffer.alloc(s, 1);

		~corpus    = FluidDataSet(s);
		~labels    = FluidLabelSet(s);
		~slicesMap = ();   // id → [startSamp, endSamp, srcBuf]

		"loading % files…".format(files.size).postln;

		files.do { |path|

			var name = PathName(path).fileNameWithoutExtension;
			var src  = Buffer.read(s, path);
			var fa;

			s.sync;

			FluidBufNoveltySlice.processBlocking(s, src,
				indices: slices,
				algorithm: \mfcc,
				threshold: 0.4,
				kernelSize: 11,
				minSliceLength: 5
			);

			fa = Array.fill(slices.numFrames, 0);
			slices.loadToFloatArray(action: { |a| fa = a });
			s.sync;

			fa.doAdjacentPairs { |start, end, i|

				var id = "%-%".format(name, i);

				FluidBufMFCC.processBlocking(s, src,
					startFrame: start,
					numFrames: end - start,
					features: feat, numCoeffs: 13, startCoeff: 1
				);
				FluidBufStats.processBlocking(s, feat, stats: stat, numChans: 12);
				FluidBufFlatten.processBlocking(s, stat,
					numFrames: 1, destination: point
				);

				~corpus.addPoint(id, point);
				~labels.addLabel(id, name);
				~slicesMap[id.asSymbol] = [start, end, src];

			};

			"  % → % slices".format(name, fa.size - 1).postln;

		};

		s.sync;

		~corpus.print;
		~corpus.write(~jsonPath, { "saved to %".format(~jsonPath).postln });

	}).play;

});

)


// The corpus is now an instrument. Pdef triggers a random slice every beat.

(

~playSlice = { |id|

	var entry = ~slicesMap[id.asSymbol];

	if (entry.notNil) {

		var start = entry[0], end = entry[1], src = entry[2];
		var dur = (end - start) / src.sampleRate;

		{
			var sig = PlayBuf.ar(1, src, BufRateScale.kr(src), startPos: start);
			var env = EnvGen.kr(
				Env([0, 1, 1, 0], [0.005, max(dur - 0.01, 0.01), 0.005]),
				doneAction: 2
			);
			(sig * env).dup * 0.7;
		}.play;

	};

};

)

(

Pdef(\corpus, Pbind(
	\type, \rest,
	\dur, Pwhite(0.1, 0.4),
	\callback, Pfunc({

		~corpus.dump({ |dict|

			var ids = dict["data"].keys.asArray;
			~playSlice.(ids.choose);

		});

	})
)).play;

)



// Reload the JSON

(

~corpus = FluidDataSet(s);
~corpus.read(~jsonPath, { "reloaded".postln; ~corpus.print });

)
