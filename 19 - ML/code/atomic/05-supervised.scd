////////////////////////////////////////////////////////////////
//
//             KNN + MLP, classifier and regressor
//
////////////////////////////////////////////////////////////////

s.boot;


// FluidKNNClassifier — predict the label of a 2D point by 3-nearest vote

// 3 "a" points cluster bottom-left, 3 "b" points cluster top-right.

(

~ds     = FluidDataSet(s);
~labels = FluidLabelSet(s);
~knn    = FluidKNNClassifier(s, numNeighbours: 3);
~buf    = Buffer.alloc(s, 2);
~q      = Buffer.alloc(s, 2);

Routine({

	[
		[\p1, [0.0,  0.10], "a"],
		[\p2, [0.1,  0.0],  "a"],
		[\p3, [0.05, 0.15], "a"],
		[\p4, [0.9,  0.95], "b"],
		[\p5, [1.0,  0.9],  "b"],
		[\p6, [0.95, 1.0],  "b"]
	].do{ |row|
		~buf.setn(0, row[1]);
		s.sync;
		~ds.addPoint(row[0], ~buf);
		~labels.addLabel(row[0], row[2]);
	};

	s.sync;

	~knn.fit(~ds, ~labels, {
		"fitted KNN classifier".postln;

		~q.setn(0, [0.05, 0.05]);
		~knn.predictPoint(~q, { |label|
			"(0.05, 0.05) -> %".format(label).postln;  // expect "a"
		});

		~q.setn(0, [0.92, 0.97]);
		~knn.predictPoint(~q, { |label|
			"(0.92, 0.97) -> %".format(label).postln;  // expect "b"
		});
	});

}).play;

)


// FluidKNNRegressor — local averaging, 1D in -> 1D out

// Training data: y = 2x. Predictions are the mean of the k nearest training y's.

(

~xs  = FluidDataSet(s);
~ys  = FluidDataSet(s);
~knn = FluidKNNRegressor(s, numNeighbours: 2);
~xb  = Buffer.alloc(s, 1);
~yb  = Buffer.alloc(s, 1);
~q   = Buffer.alloc(s, 1);
~r   = Buffer.alloc(s, 1);

Routine({

	[[0.0, 0.0], [0.2, 0.4], [0.4, 0.8], [0.6, 1.2], [0.8, 1.6], [1.0, 2.0]].do{ |row, i|
		var id = "p%".format(i);
		~xb.setn(0, [row[0]]); s.sync; ~xs.addPoint(id, ~xb);
		~yb.setn(0, [row[1]]); s.sync; ~ys.addPoint(id, ~yb);
	};

	s.sync;

	~knn.fit(~xs, ~ys, {
		"fitted KNN regressor".postln;

		~q.setn(0, [0.5]);
		~knn.predictPoint(~q, ~r, {
			~r.getn(0, 1, { |val|
				"x = 0.5 -> y ~ % (true 1.0)".format(val).postln;
			});
		});
	});

}).play;

)


// FluidMLPClassifier — neural net classifier on the same 2D toy data

// activation: 1 = sigmoid. Loss is posted by the fit callback;
// re-evaluate to keep training.

(

~ds     = FluidDataSet(s);
~labels = FluidLabelSet(s);
~mlp    = FluidMLPClassifier(s,
	hiddenLayers: [4],
	activation: 1,
	maxIter: 1000,
	learnRate: 0.1,
	momentum: 0.9,
	batchSize: 2,
	validation: 0
);
~buf = Buffer.alloc(s, 2);
~q   = Buffer.alloc(s, 2);

Routine({

	[
		[\p1, [0.0,  0.1],  "a"],
		[\p2, [0.1,  0.0],  "a"],
		[\p3, [0.05, 0.15], "a"],
		[\p4, [0.9,  0.95], "b"],
		[\p5, [1.0,  0.9],  "b"],
		[\p6, [0.95, 1.0],  "b"]
	].do{ |row|
		~buf.setn(0, row[1]);
		s.sync;
		~ds.addPoint(row[0], ~buf);
		~labels.addLabel(row[0], row[2]);
	};

	s.sync;

	~mlp.fit(~ds, ~labels, { |loss|
		"final training loss: %".format(loss).postln;

		~q.setn(0, [0.05, 0.05]);
		~mlp.predictPoint(~q, { |label|
			"(0.05, 0.05) -> %".format(label).postln;
		});

		~q.setn(0, [0.95, 0.95]);
		~mlp.predictPoint(~q, { |label|
			"(0.95, 0.95) -> %".format(label).postln;
		});
	});

}).play;

)


// FluidMLPRegressor — learn a non-linear 1D -> 1D mapping (sine)

// Inputs in [0, 1], targets are sin(2*pi*x) mapped to [0, 1] (sigmoid output).
// Re-evaluate the fit block multiple times to keep training.

(

~xs  = FluidDataSet(s);
~ys  = FluidDataSet(s);
~mlp = FluidMLPRegressor(s,
	hiddenLayers: [8, 8],
	activation: FluidMLPRegressor.sigmoid,
	outputActivation: FluidMLPRegressor.sigmoid,
	maxIter: 2000,
	learnRate: 0.1,
	batchSize: 2,
	validation: 0
);
~xb = Buffer.alloc(s, 1);
~yb = Buffer.alloc(s, 1);
~q  = Buffer.alloc(s, 1);
~r  = Buffer.alloc(s, 1);

Routine({

	8.do{ |i|
		var x = i / 7;
		var y = (sin(2pi * x) * 0.5) + 0.5;  // map sine to 0..1
		var id = "p%".format(i);
		~xb.setn(0, [x]); s.sync; ~xs.addPoint(id, ~xb);
		~yb.setn(0, [y]); s.sync; ~ys.addPoint(id, ~yb);
	};

	s.sync;

	~mlp.fit(~xs, ~ys, { |loss|
		"loss: %".format(loss).postln;

		[0.0, 0.25, 0.5, 0.75].do{ |x|
			~q.setn(0, [x]);
			~mlp.predictPoint(~q, ~r, {
				~r.getn(0, 1, { |v|
					var truth = (sin(2pi * x) * 0.5) + 0.5;
					"x=% pred=% truth=%".format(x, v, truth).postln;
				});
			});
		};
	});

}).play;

)
