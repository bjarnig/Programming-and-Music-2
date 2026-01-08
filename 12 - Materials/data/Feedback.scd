////////////////////////////////////////////////////////////////
//
//                        Feedback
//
////////////////////////////////////////////////////////////////


// Feedback A

(
	Ndef(\fb).fadeTime = 3;
	Ndef(\fb, {| feedback=1.0001, delay=0.0945|
		var sig, input, first, second;

		// Signal to process
		sig = LorenzL.ar(3000);

		// Local in, 4 channels
		input = sig + LocalIn.ar(4);
		first = input.clump(2)[0];
		second = input.clump(2)[1];

		// OnePole filter, the feedback coefficient is effective
		first = OnePole.ar(first, first.linlin(-1.0,1.0,0.0,1.0));
		second = OnePole.ar(second, second.linlin(-1.0,1.0,1.0,0.0));

		// Delay it
		first = DelayC.ar(first, 1, LFNoise2.ar(0.13).range(delay,delay*1.1));
		second = DelayC.ar(second, 1, LFNoise2.ar(0.17).range(delay*1.2,delay*1.3));

		// Local out
		LocalOut.ar( (first ++ second) * feedback * rrand(0.99,0.99999));

		// Sound out
		Limiter.ar( Splay.ar( first ++ second ))

	}).play;

)


// Feedback B

(
	Ndef(\fb).fadeTime = 2;
	Ndef(\fb, {| feedback=1.0001, delay=0.01|
		var sig, input, snd;

	    // Input
		sig = Saw.ar(10);
		input = sig + LocalIn.ar(8);

	    // Process and Delay
	    snd = input.fold2(SinOsc.ar( { 1000.rand } ! 8 ));
		snd = DelayC.ar(snd, 1, LFNoise2.ar( { 20.rand } ! 8).range(delay,delay*1.1));

	    // Outputs
	    LocalOut.ar( snd * feedback * rrand(0.99,0.99999));
		Limiter.ar( Splay.ar(snd) * 0.1)

	}).play;

	 // Sequence and Vary
	{
		inf.do {
			" ** vary ".postln;
			Ndef(\fb).set(\feedback, rrand(1.001, 1.01));
			rrand(3,6).wait;
			Ndef(\fb).set(\feedback, rrand(0.6, 0.8));
			rrand(1,3).wait;
		}
	}.fork

)


// Feedback C

(
	Ndef(\fb).fadeTime = 0.8;
	Ndef(\fb, {| feedback=1.0001, delay=0.02|
	var sig, input, snd;

	// Input
	sig = Saw.ar(80);
	input = sig + LocalIn.ar(8);

	// Process and Delay
	snd = SoftClipAmp8.ar(BBandPass.ar(input, { 2000.rand } ! 8),  sig.linlin(-1.0,1.0, 14.rand, 18.rand));
	snd = DelayC.ar(snd, 1, LFNoise2.ar( { 20.rand } ! 8).range(delay,delay*1.1));

	// Outputs
	LocalOut.ar( snd * feedback * rrand(0.9999,0.999999));
	Limiter.ar( Splay.ar(snd) * 0.1)

	}).play;

	// Sequence and Vary
	{
		inf.do {
			Ndef(\fb).xset(\feedback, rrand(1.001, 1.01));
			rrand(3,6).wait;
			Ndef(\fb).xset(\feedback, rrand(0.6, 0.8));
			rrand(1,3).wait;
		}
	}.fork

)

(
	// Synthesis model

	Ndef(\stdn, {
		var sd = SampleDur.ir * 0.5;
		var size = 5, from = 1, to = 25;
		var modFreq = 10, modFrom = 5, modTo = 7;

		DemandEnvGen.ar(
			Dseq([1, [-1, 0.5]], inf),
			Dseq(Array.rand(size,from,to), inf) * sd
		).atan(SinOsc.ar(LFNoise0.ar(modFreq).range(modFrom, modTo))) * 0.5;
	});

    // Feedback Processor

	Ndef(\fbx,
	{| in=0, out=0, feedback=0.98, delay=0.08, shiftFreq=2, shiftDens=0.1|
		var sig, input, first, second, freq=15;

		// signal to process
		sig = Ndef(\stdn).ar;

		// local in, 4 channels
		input = sig + LocalIn.ar(4);

		// 1 - 2
		first = input.clump(2)[0];
		first = FreqShift.ar(first, LFNoise1.ar(0.7).range(10,30));

		// 3 -4
		second = input.clump(2)[1];
		second = MostChange.ar(first, FreqShift.ar(first, LFNoise1.ar(20).range(10,40)));

		// delay it
		first = DelayC.ar(first, 1, LFNoise1.ar(0.1).range(0.04,0.09));
		second = DelayC.ar(second, 1, LFNoise1.ar(0.1).range(0.08,0.11));

		// local out
		LocalOut.ar( (first ++ second) * feedback);

		Out.ar(out, CombC.ar( Splay.ar( first ++ second ) * 0.2, 0.1, 0.1, 0.2))

	}).play;

)