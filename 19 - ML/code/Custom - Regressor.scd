
////////////////////////////////////////////////////////////////
//
//             Multi-Layer Perceptron neural network.
//
////////////////////////////////////////////////////////////////

Ndef.clear;

( // An arbitrary example of a sound with many parameters

	Ndef(\sawsc, {|freq=80,mfreqa=19,mfreqb=12,filtmod=10,filtfrom=100,filtto=900,
		bwmod=20, amp=1.4, fmod=200,ffrom=20,fto=350,index=0.8,amp2=0.125|
		var bwfrom=7,bwto=11,hpf=80, snd;

		snd = HPF.ar(
			BBandStop.ar(Saw.ar(LFNoise1.ar([mfreqa,mfreqb]).range(freq,freq*2), 0.2).fold2(
			SinOsc.ar( [freq + 6, freq + 4, freq + 2, freq + 8])),
			LFNoise1.ar([filtmod*1.2,filtmod*1.4,filtmod]).range(filtfrom,filtto),
			SinOsc.ar(bwmod).range(bwfrom,bwto)
		), hpf) * amp;

		snd + (PMOsc.ar(freq/8,
			Lag.ar(
				LFDClipNoise.ar(fmod).range(ffrom,fto), 0.001),
			index, 0, [0.001,1]) * amp2)
	}).play;
)

( // Initialize Datasets and Buffers

	~controldata = FluidDataSet(s);
	~ndefdata = FluidDataSet(s);
	~controlbuf = Buffer.alloc(s,2);
	~ndefbuf = Buffer.alloc(s,8);
	~counter = 0;
)


( // Create the specs for the Ndef

	~specs = List();
	~specs.add(ControlSpec(10, 50));
	~specs.add(ControlSpec(10, 30));
	~specs.add(ControlSpec(10, 30));
	~specs.add(ControlSpec(100, 500));
	~specs.add(ControlSpec(500, 1500));
	~specs.add(ControlSpec(10, 50));
	~specs.add(ControlSpec(200, 600));
	~specs.add(ControlSpec(0.2, 1.0));
)

( // Randomize the parameter values to explore the sound states

~randomize = {

	Ndef(\sawsc).xset(\freq, ~specs[0].map(1.0.rand));
	Ndef(\sawsc).xset(\mfreqa, ~specs[1].map(1.0.rand));
	Ndef(\sawsc).xset(\mfreqb, ~specs[2].map(1.0.rand));
	Ndef(\sawsc).xset(\filtfrom, ~specs[3].map(1.0.rand));
	Ndef(\sawsc).xset(\filtto, ~specs[4].map(1.0.rand));
	Ndef(\sawsc).xset(\ffrom, ~specs[5].map(1.0.rand));
	Ndef(\sawsc).xset(\fto, ~specs[6].map(1.0.rand));
	Ndef(\sawsc).xset(\index, ~specs[7].map(1.0.rand));
};

~randomize.value();

)

( // Add a point to both data sets using the same id

~addpoint = {

	var id = "point-%".format(~counter);

	// 8 dimensions of the Ndef
	~ndefbuf.setn(0, [

		~specs[0].unmap(Ndef(\sawsc).get(\freq)),
		~specs[1].unmap(Ndef(\sawsc).get(\mfreqa)),
		~specs[2].unmap(Ndef(\sawsc).get(\mfreqb)),
		~specs[3].unmap(Ndef(\sawsc).get(\filtfrom)),
		~specs[4].unmap(Ndef(\sawsc).get(\filtto)),
		~specs[5].unmap(Ndef(\sawsc).get(\ffrom)),
		~specs[6].unmap(Ndef(\sawsc).get(\fto)),
		~specs[7].unmap(Ndef(\sawsc).get(\index))

	]);

	// Print it for debugging
	~ndefbuf.getn(0, 8, {|msg| ("## params: " + msg).postln;

		// 2 dimensions for the control
		~controlbuf.setn(0, [msg.sum / 8, msg.sum / 16]);
		~controlbuf.getn(0, 2, {|msg| ("## control: " + msg).postln;


		// Add the buffers to the Dataset
		~controldata.addPoint(id, ~controlbuf);
		~ndefdata.addPoint(id, ~ndefbuf);

		// Increase the counter to be used for next point id
		~counter = ~counter + 1;

		})
	})
};

~addpoint.value;

)

( // Create the NN regressors

~mlp = FluidMLPRegressor(s,
		[7],
		activation:FluidMLPRegressor.sigmoid,
		outputActivation:FluidMLPRegressor.sigmoid,
		maxIter: 1000,
		learnRate:0.1,
		batchSize:1,
		validation:0
	);
)

( // Add points

	{
		20.do {
			~randomize.value;
			1.0.wait;
			~addpoint.value;
		}

	}.fork;

)

( // Once we have enough data points we can train the Neural Network

~mlp.fit(~controldata, ~ndefdata, { |loss| loss.postln });

)

( // When trained, the NN can predict outputs based on a given input

~controlbuf.setn(0, [1.0.rand.postln, 1.0.rand.postln]);

~mlp.predictPoint(~controlbuf, ~ndefbuf,{
	~ndefbuf.getn(0,8,{
		arg prediction; prediction.postln;

		Ndef(\sawsc).xset(\freq, ~specs[0].map(prediction[0]).postln);
		Ndef(\sawsc).xset(\mfreqa, ~specs[1].map(prediction[1]));
		Ndef(\sawsc).xset(\mfreqb, ~specs[2].map(prediction[2]));
		Ndef(\sawsc).xset(\filtfrom, ~specs[3].map(prediction[3]));
		Ndef(\sawsc).xset(\filtto, ~specs[4].map(prediction[4]));
		Ndef(\sawsc).xset(\ffrom, ~specs[5].map(prediction[5]));
		Ndef(\sawsc).xset(\fto, ~specs[6].map(prediction[6]));
		Ndef(\sawsc).xset(\index, ~specs[7].map(prediction[7]));

	});
});

)
