////////////////////////////////////////////////////////////////
//
//        FluidDataSet, FluidLabelSet, save/load, query
//
////////////////////////////////////////////////////////////////


/*

Create a DataSet, add points, print, dump to a SC dictionary
Each point is uploaded via a 1-channel Buffer of N frames,
where N = the dimensionality of the dataset.

*/

(

~ds  = FluidDataSet(s);
~buf = Buffer.alloc(s, 2);  // 2D points

Routine({

	[
		[\a, [0.1, 0.2]],
		[\b, [0.4, 0.9]],
		[\c, [0.7, 0.3]],
		[\d, [0.9, 0.8]]
	].do{ |pair|
		~buf.setn(0, pair[1]);
		s.sync;
		~ds.addPoint(pair[0], ~buf);
	};

	s.sync;
	~ds.print;
	~ds.dump({ |dict| "dumped: %".format(dict).postln });

}).play;

)


/*

Save a DataSet to JSON, clear, reload
Persistence at the level of the DataSet
(same JSON file works)

*/

(

~path = thisProcess.nowExecutingPath.dirname +/+ "tiny_ds.json";
~ds2  = FluidDataSet(s);
~buf  = Buffer.alloc(s, 2);

Routine({

	[
		[\p1, [0.0, 1.0]],
		[\p2, [1.0, 0.0]],
		[\p3, [0.5, 0.5]]
	].do{ |pair|
		~buf.setn(0, pair[1]);
		s.sync;
		~ds2.addPoint(pair[0], ~buf);
	};

	s.sync;

	~ds2.write(~path, {
		"saved to %".format(~path).postln;

		~ds2.clear({
			"cleared, now empty:".postln;

			~ds2.print({
				~ds2.read(~path, {
					"reloaded:".postln;
					~ds2.print;
				});
			});
		});
	});

}).play;

)


/*

FluidLabelSet — id -> string label
LabelSets are the targets for classifiers. Same id space as the DataSet
they pair with.

*/

(

~labels = FluidLabelSet(s);

Routine({

	#[
		[\p1, "cat"],
		[\p2, "dog"],
		[\p3, "cat"],
		[\p4, "bird"]
	].do{ |pair|
		~labels.addLabel(pair[0], pair[1]);
	};

	s.sync;
	~labels.print;
	~labels.getLabel(\p2, { |lbl| "p2 -> %".format(lbl).postln });

}).play;

)


// FluidDataSetQuery, filtering and column selection

(

~src = FluidDataSet(s);
~out = FluidDataSet(s);
~q   = FluidDataSetQuery(s);
~buf = Buffer.alloc(s, 3);

Routine({

	// 3D points: (loudness, brightness, pitch)
	[
		[\a, [0.1, 0.8, 220]],
		[\b, [0.6, 0.4, 440]],
		[\c, [0.9, 0.9, 880]],
		[\d, [0.3, 0.2, 110]]
	].do{ |pair|
		~buf.setn(0, pair[1]);
		s.sync;
		~src.addPoint(pair[0], ~buf);
	};

	s.sync;
	"original:".postln; ~src.print;

	// keep only rows where column 0 (loudness) > 0.5, copy all 3 columns
	~q.filter(0, ">", 0.5);

	~q.addRange(0, 3);

	~q.transform(~src, ~out, {
		"filtered (loudness > 0.5):".postln;
		~out.print;
	});

}).play;

)


// FluidDataSetWr.kr, real-time DataSet capture from a SynthDef

(

{

~ds    = FluidDataSet(s);
~xyBuf = Buffer.alloc(s, 2);   // server-side; FluidDataSetWr needs a real bufnum, not LocalBuf
~ids   = 0;

s.sync;

// Seed the dataset so FluidDataSetWr knows the point size (2) on its first
// write. FluidDataSet has no "declare dimensions" constructor — the first
// addPoint locks the size. The seed gets deleted at the end of this block.
~ds.addPoint(\__seed, ~xyBuf);

s.sync;

// Streams MouseX/MouseY into the dataset whenever the record gate is open
SynthDef(\xyCapture, { |ds, buf, idStart = 0, record = 0, rate = 20|
	var trig = Impulse.kr(rate) * record;
	var idx  = idStart + PulseCount.kr(trig) - 1;     // 0, 1, 2, … on each rising edge
	var xy   = [MouseX.kr(0, 1), MouseY.kr(0, 1)];
	FluidKrToBuf.kr(xy, buf);
	FluidDataSetWr.kr(ds, idNumber: idx, buf: buf, trig: trig);
	Poll.kr(trig, idx, \captured_id);
}).add;

s.sync;

~cap = Synth(\xyCapture, [\ds, ~ds, \buf, ~xyBuf, \idStart, ~ids, \record, 0, \rate, 20]);

}.fork

)

// Drag the mouse around to get a feel for what's about to be captured,
// then open the gate. Move the cursor in different shapes, then close
// the gate.

~cap.set(\record, 1);   // start capturing 20 points/sec
~cap.set(\record, 0);   // stop

// Drop the seed point used to declare the dataset's dimensionality,
// then inspect what was actually captured.
~ds.deletePoint(\__seed);
~ds.print;
~ds.size({ |n| ("captured % points".format(n)).postln; ~ids = n });

// Stop the capture synth when done.
~cap.free;
