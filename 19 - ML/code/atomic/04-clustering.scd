////////////////////////////////////////////////////////////////
//
//                   KMeans, KDTree, SKMeans
//
////////////////////////////////////////////////////////////////

s.boot;


// FluidKMeans — partition into k clusters


(

~ds = FluidDataSet(s);
~km = FluidKMeans(s, numClusters: 3);
~buf = Buffer.alloc(s, 2);
~q   = Buffer.alloc(s, 2);

Routine({

	// 3 obvious clusters in 2D
	[
		[\a1, [0.0, 0.0]],   [\a2, [0.1, 0.05]],  [\a3, [0.05, 0.1]],
		[\b1, [1.0, 1.0]],   [\b2, [0.95, 1.05]], [\b3, [1.05, 0.95]],
		[\c1, [0.0, 1.0]],   [\c2, [0.05, 0.95]], [\c3, [0.0, 1.05]]
	].do{ |pair|
		~buf.setn(0, pair[1]);
		s.sync;
		~ds.addPoint(pair[0], ~buf);
	};

	s.sync;

	~km.fit(~ds, {
		"fitted 3 clusters".postln;

		~q.setn(0, [0.98, 1.02]);
		~km.predictPoint(~q, { |c|
			"point (0.98, 1.02) -> cluster %".format(c).postln;
		});
	});

}).play;

)


// FluidKDTree — nearest-neighbour lookup

// kNearest returns ids; kNearestDist returns distances.

(

~ds   = FluidDataSet(s);
~tree = FluidKDTree(s);
~buf  = Buffer.alloc(s, 2);
~q    = Buffer.alloc(s, 2);

Routine({

	[
		[\p1, [0.0, 0.0]],
		[\p2, [1.0, 0.0]],
		[\p3, [0.0, 1.0]],
		[\p4, [1.0, 1.0]],
		[\p5, [0.5, 0.5]]
	].do{ |pair|
		~buf.setn(0, pair[1]);
		s.sync;
		~ds.addPoint(pair[0], ~buf);
	};

	s.sync;

	~tree.fit(~ds, {

		~q.setn(0, [0.6, 0.6]);

		~tree.kNearest(~q, 3, { |ids|
			"3 nearest ids: %".format(ids).postln;
		});

		~tree.kNearestDist(~q, 3, { |dists|
			"distances: %".format(dists).postln;
		});

	});

}).play;

)


// FluidSKMeans — spherical k-means (clusters by direction)

// encodingThreshold > 0 makes the cluster assignment sparse (assigns 0 if
// no cluster is "close enough" by cosine similarity).

(

~ds = FluidDataSet(s);
~sk = FluidSKMeans(s, numClusters: 3, encodingThreshold: 0.0, maxIter: 100);
~buf = Buffer.alloc(s, 2);
~q   = Buffer.alloc(s, 2);

Routine({

	[
		[\a1, [0.0, 0.0]],   [\a2, [0.1, 0.05]],  [\a3, [0.05, 0.1]],
		[\b1, [1.0, 1.0]],   [\b2, [0.95, 1.05]], [\b3, [1.05, 0.95]],
		[\c1, [0.0, 1.0]],   [\c2, [0.05, 0.95]], [\c3, [0.0, 1.05]]
	].do{ |pair|
		~buf.setn(0, pair[1]);
		s.sync;
		~ds.addPoint(pair[0], ~buf);
	};

	s.sync;

	~sk.fit(~ds, {
		"SKMeans fit".postln;

		~q.setn(0, [0.98, 1.02]);
		~sk.predictPoint(~q, { |c|
			"point (0.98, 1.02) -> cluster %".format(c).postln;
		});
	});

}).play;

)
