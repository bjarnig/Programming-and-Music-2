////////////////////////////////////////////////////////////////
//
//                      2D Sound Browser
//
////////////////////////////////////////////////////////////////


~sounds = thisProcess.nowExecutingPath.dirname +/+ "../../sounds/";


// Load one sound buffer.

~src = Buffer.read(s, ~sounds +/+ "branches.wav");
~src.numFrames.postln;


// Slice points using a real-time slicer first.

(

~rtSliceMonitor = {

	var sig    = PlayBuf.ar(1, ~src, BufRateScale.kr(~src), loop: 1);
	var trig   = FluidOnsetSlice.ar(sig, threshold: 0.5);
	var click  = EnvGen.ar(Env.perc(0.001, 0.05), trig) * PinkNoise.ar(0.6);

	(sig * 0.4 + click).dup;

}.play;

)


// Run the offline slicer. It collects sample indices into a buffer.

(

~slices = Buffer.alloc(s, 1);
FluidBufOnsetSlice.processBlocking(s, ~src, indices: ~slices, threshold: 0.5);
"FluidBufOnsetSlice done.".postln;

)

FluidWaveform(~src, ~slices, bounds: Rect(0, 0, 1200, 300));


// Code a way to play back individual slices

(

~playSlice = { |i|

	~slices.loadToFloatArray(action: { |fa|

		var start = fa[i];
		var dur = ((fa[i + 1] ?? { ~src.numFrames }) - start) / ~src.sampleRate;

		{
			var sig = PlayBuf.ar(1, ~src, BufRateScale.kr(~src), startPos: start);
			var env = EnvGen.kr(Env([0,1,1,0], [0.005, max(dur - 0.01, 0.01), 0.005]),
				doneAction: 2);
			(sig * env).dup;
		}.play;

	});

};

)

~playSlice.(0);
~playSlice.(3);
~playSlice.(7);


// Analyse each slice. Here with spectral centroid mean, a "brightness" descriptor.

(

~feat   = Buffer.alloc(s, 1);
~stat   = Buffer.alloc(s, 1);
~point  = Buffer.alloc(s, 1);
~ds     = FluidDataSet(s);
~map    = ();

~slices.loadToFloatArray(action: { |fa|

	Routine({

		fa = fa.add(~src.numFrames);

		fa.doAdjacentPairs { |start, end, i|

			var id = "s%".format(i);

			FluidBufSpectralShape.processBlocking(s, ~src,
				startFrame: start, numFrames: end - start,
				features: ~feat);

			FluidBufStats.processBlocking(s, ~feat, stats: ~stat, numChans: 1);
			FluidBufFlatten.processBlocking(s, ~stat, numFrames: 1, destination: ~point);

			~ds.addPoint(id, ~point);
			~map[id.asSymbol] = [start, end];

		};

		s.sync;
		"% slices analysed (centroid mean only)".format(~map.size).postln;

	}).play;

});

)


// Sort slices by centroid mean and listen low-to-high.

(

~ds.dump({ |d|

	var pairs = [];

	d["data"].keysValuesDo { |k, v|
		pairs = pairs.add([k.asSymbol, v[0]]);   // v[0] = centroid mean
	};

	~sortedIds = pairs.sort { |a, b| a[1] < b[1] }.collect(_[0]);

	"sorted % slices, low → high centroid".format(~sortedIds.size).postln;

});

)

// Audition them in centroid order:

(

Routine({

	~sortedIds.do { |id|

		var entry = ~map[id];
		var dur = (entry[1] - entry[0]) / ~src.sampleRate;

		{
			var sig = PlayBuf.ar(1, ~src, BufRateScale.kr(~src), startPos: entry[0]);
			var env = EnvGen.kr(Env([0,1,1,0], [0.005, max(dur - 0.01, 0.01), 0.005]),
				doneAction: 2);
			(sig * env).dup;
		}.play;

		(dur + 0.05).wait;

	};

}).play(AppClock);

)


// Add a second descriptor, loudness,  points are 2D and we can plot.

(

~loud = Buffer.alloc(s, 1);
~lstat = Buffer.alloc(s, 1);
~ds = FluidDataSet(s);   // start fresh

~slices.loadToFloatArray(action: { |fa|

	Routine({

		fa = fa.add(~src.numFrames);

		fa.doAdjacentPairs { |start, end, i|

			var id = "s%".format(i);
			var pt = Buffer.alloc(s, 2);   // 2-frame point: [centroid_mean, loudness_mean]

			FluidBufSpectralShape.processBlocking(s, ~src,
				startFrame: start, numFrames: end - start, features: ~feat);
			FluidBufStats.processBlocking(s, ~feat, stats: ~stat, numChans: 1);
			FluidBufCompose.processBlocking(s, ~stat,
				startFrame: 0, numFrames: 1, startChan: 0, numChans: 1,
				destination: pt, destStartFrame: 0, destStartChan: 0);

			FluidBufLoudness.processBlocking(s, ~src,
				startFrame: start, numFrames: end - start, features: ~loud);
			FluidBufStats.processBlocking(s, ~loud, stats: ~lstat, numChans: 1);
			FluidBufCompose.processBlocking(s, ~lstat,
				startFrame: 0, numFrames: 1, startChan: 0, numChans: 1,
				destination: pt, destStartFrame: 1, destStartChan: 0);

			~ds.addPoint(id, pt);
			~map[id.asSymbol] = [start, end];

		};

		s.sync;
		~ds.print;
		"2D analysis done".postln;

	}).play;

});

)


// Plot using FluidPlotter

(

~ds.dump({ |d|

	{
		~plot = FluidPlotter(nil, Rect(40, 40, 700, 700), d,
			xmin: 50, xmax: 10000, ymin: -60, ymax: 0);
	}.defer;

});

)


// Normalise the dataset before re-plotting and before fitting a KDTree.

(

~norm = FluidNormalize(s, 0, 1);
~dsN  = FluidDataSet(s);

~norm.fitTransform(~ds, ~dsN, {

	~dsN.dump({ |d|

		{
			~plot.close;
			~plot = FluidPlotter(nil, Rect(40, 40, 700, 700), d);
		}.defer;

		~tree = FluidKDTree(s);
		~tree.fit(~dsN, { "kdtree fit on normalised data".postln });

	});

});

)


// Mouse-driven query, drag the cursor in the plot, the nearest slice plays.

(

~ds.dump({ |d|

	var q = Buffer.alloc(s, 2);

	{

		~plot.close;

		~plot = FluidPlotter(nil, Rect(40, 40, 700, 700), nil,
			mouseMoveAction: { |view, x, y|

				q.setn(0, [x.clip(0, 1), y.clip(0, 1)]);

				~tree.kNearest(q, 1, { |id|

					var entry = ~map[id.asSymbol];
					var dur = (entry[1] - entry[0]) / ~src.sampleRate;

					{
						var sig = PlayBuf.ar(1, ~src, BufRateScale.kr(~src), startPos: entry[0]);
						var env = EnvGen.kr(Env([0,1,1,0], [0.01, max(dur - 0.02, 0.01), 0.01]),
							doneAction: 2);
						(sig * env).dup * 0.6;
					}.play;

					{ ~plot.highlight_(id) }.defer;

				});

			}
		);

		~dsN.dump({ |dd| { ~plot.dict_(dd) }.defer });

	}.defer;

});

)