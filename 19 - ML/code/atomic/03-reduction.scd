////////////////////////////////////////////////////////////////
//
//                  PCA, UMAP, MDS, FluidGrid
//
////////////////////////////////////////////////////////////////

s.boot;


// FluidPCA — 5D -> 2D, reports explained variance


(

~src = FluidDataSet(s);
~dst = FluidDataSet(s);
~pca = FluidPCA(s, 2);
~buf = Buffer.alloc(s, 5);

Routine({

	// 6 hand-typed 5D points; columns are correlated so PCA compresses well
	[
		[\p1, [1.0, 2.0, 3.0, 4.0, 5.0]],
		[\p2, [2.0, 4.0, 6.0, 8.0, 10.0]],
		[\p3, [1.5, 3.0, 4.5, 6.0, 7.5]],
		[\p4, [0.5, 1.0, 1.5, 2.0, 2.5]],
		[\p5, [3.0, 6.1, 8.9, 12.0, 15.2]],
		[\p6, [0.2, 0.4, 0.6, 0.8, 1.0]]
	].do{ |pair|
		~buf.setn(0, pair[1]);
		s.sync;
		~src.addPoint(pair[0], ~buf);
	};

	s.sync;

	~pca.fitTransform(~src, ~dst, { |variance|
		"explained variance: %".format(variance).postln;
		"reduced to 2D:".postln;
		~dst.print;
	});

}).play;

)


// FluidUMAP — 5D -> 2D, preserves local neighbourhoods

// numNeighbours: how many points define "local" (small = tight clusters)
// minDist:       how tightly points may pack in the output

(

~src  = FluidDataSet(s);
~dst  = FluidDataSet(s);
~umap = FluidUMAP(s, 2, numNeighbours: 3, minDist: 0.1);
~buf  = Buffer.alloc(s, 5);

Routine({

	[
		[\a1, [1.0, 1.0, 1.0, 0.0, 0.0]],
		[\a2, [1.1, 0.9, 1.0, 0.1, 0.0]],
		[\a3, [0.9, 1.1, 0.9, 0.0, 0.1]],
		[\b1, [0.0, 0.0, 0.0, 1.0, 1.0]],
		[\b2, [0.1, 0.0, 0.1, 0.9, 1.0]],
		[\b3, [0.0, 0.1, 0.0, 1.0, 0.9]]
	].do{ |pair|
		~buf.setn(0, pair[1]);
		s.sync;
		~src.addPoint(pair[0], ~buf);
	};

	s.sync;

	~umap.fitTransform(~src, ~dst, {
		"UMAP 2D embedding (a-cluster vs b-cluster should separate):".postln;
		~dst.print;
	});

}).play;

)


// FluidMDS — 5D -> 2D, preserves pairwise distances


(

~src = FluidDataSet(s);
~dst = FluidDataSet(s);
~mds = FluidMDS(s, 2);
~buf = Buffer.alloc(s, 5);

Routine({

	[
		[\a1, [1.0, 1.0, 1.0, 0.0, 0.0]],
		[\a2, [1.1, 0.9, 1.0, 0.1, 0.0]],
		[\a3, [0.9, 1.1, 0.9, 0.0, 0.1]],
		[\b1, [0.0, 0.0, 0.0, 1.0, 1.0]],
		[\b2, [0.1, 0.0, 0.1, 0.9, 1.0]],
		[\b3, [0.0, 0.1, 0.0, 1.0, 0.9]]
	].do{ |pair|
		~buf.setn(0, pair[1]);
		s.sync;
		~src.addPoint(pair[0], ~buf);
	};

	s.sync;

	~mds.fitTransform(~src, ~dst, {
		"MDS 2D embedding:".postln;
		~dst.print;
	});

}).play;

)


// FluidGrid — snap already-2D scattered points onto a regular grid

// Use as the last step before a 2D plotter when you want unique, non-overlapping
// cells. Grid expects 0..1 input; chain Normalize -> Grid.

(

~src  = FluidDataSet(s);
~dst  = FluidDataSet(s);
~norm = FluidNormalize(s, 0, 1);
~grid = FluidGrid(s, oversample: 1.2);
~buf  = Buffer.alloc(s, 2);

Routine({

	[
		[\a, [0.12, 0.34]], [\b, [0.71, 0.22]], [\c, [0.45, 0.88]],
		[\d, [0.05, 0.91]], [\e, [0.66, 0.55]], [\f, [0.83, 0.10]],
		[\g, [0.31, 0.60]], [\h, [0.92, 0.77]], [\i, [0.20, 0.05]]
	].do{ |pair|
		~buf.setn(0, pair[1]);
		s.sync;
		~src.addPoint(pair[0], ~buf);
	};

	s.sync;
	"before:".postln; ~src.print;

	~norm.fitTransform(~src, ~dst, {
		~grid.fitTransform(~dst, ~dst, {
			"after gridify:".postln;
			~dst.print;
		});
	});

}).play;

)
