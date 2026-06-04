////////////////////////////////////////////////////////////////
//
//             Normalize, Standardize, RobustScale
//
////////////////////////////////////////////////////////////////

s.boot;


// FluidNormalize — to [0, 1]


(

~src  = FluidDataSet(s);
~dst  = FluidDataSet(s);
~norm = FluidNormalize(s, 0, 1);
~buf  = Buffer.alloc(s, 2);

Routine({

	// column 0 spans 0..1000, column 1 spans 0..1 — very different scales
	#[
		[\a, [10,    0.1]],
		[\b, [500,   0.5]],
		[\c, [1000,  0.9]],
		[\d, [250,   0.3]]
	].do{ |pair|
		~buf.setn(0, pair[1]);
		s.sync;
		~src.addPoint(pair[0], ~buf);
	};

	s.sync;
	"raw:".postln; ~src.print;

	~norm.fitTransform(~src, ~dst, {
		"normalized to 0..1:".postln;
		~dst.print;
	});

}).play;

)


// FluidStandardize — mean 0, unit variance

(

~src  = FluidDataSet(s);
~dst  = FluidDataSet(s);
~std  = FluidStandardize(s);
~buf  = Buffer.alloc(s, 2);

Routine({

	#[
		[\a, [10.0, -3.0]],
		[\b, [12.0, -2.5]],
		[\c, [11.5, -3.2]],
		[\d, [13.0, -2.8]],
		[\e, [10.5, -3.1]]
	].do{ |pair|
		~buf.setn(0, pair[1]);
		s.sync;
		~src.addPoint(pair[0], ~buf);
	};

	s.sync;
	"raw:".postln; ~src.print;

	~std.fitTransform(~src, ~dst, {
		"standardized (mean ~ 0, stdev ~ 1):".postln;
		~dst.print;
	});

}).play;

)


// FluidRobustScale — median / IQR, resistant to outliers

// Notice how the 999.0 outlier in column 0 doesn't crush the rest of the
// column the way it would under Normalize.

(

~src = FluidDataSet(s);
~dst = FluidDataSet(s);
~rs  = FluidRobustScale(s);
~buf = Buffer.alloc(s, 2);

Routine({

	#[
		[\a, [1.0,    0.10]],
		[\b, [2.0,    0.20]],
		[\c, [3.0,    0.30]],
		[\d, [4.0,    0.40]],
		[\e, [999.0,  0.50]]   // outlier in column 0
	].do{ |pair|
		~buf.setn(0, pair[1]);
		s.sync;
		~src.addPoint(pair[0], ~buf);
	};

	s.sync;
	"raw (with outlier):".postln; ~src.print;

	~rs.fitTransform(~src, ~dst, {
		"robust-scaled (outlier no longer dominates):".postln;
		~dst.print;
	});

}).play;

)
