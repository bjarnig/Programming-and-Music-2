////////////////////////////////////////////////////////////////
//
//                          FFT
//
////////////////////////////////////////////////////////////////

(   // Load source sounds

~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
~aa = Buffer.read(s, ~path ++ "sounds/abstract/aa.wav");
~ab = Buffer.read(s, ~path ++ "sounds/abstract/ab.wav");
~ca = Buffer.read(s, ~path ++ "sounds/concrete/ca.wav");
~cb = Buffer.read(s, ~path ++ "sounds/concrete/cb.wav");

)


// The chain

(

b = ~ab;
~sb = Buffer.alloc(s, 1024, 1);

{
	var snd, fft;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	fft = FFT(~sb, snd);
	IFFT(fft) ! 2;
}.play

)


// FFT as analysis

(

b = ~ab;
~sb = Buffer.alloc(s, 1024, 1);

{
	var snd, fft;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	fft = FFT(~sb, snd);
	Loudness.kr(fft).poll(2, "loudness");
	SpecCentroid.kr(fft).poll(2, "centroid");
	SpecFlatness.kr(fft).poll(2, "flatness");
	snd ! 2 * 0.4;
}.play

)


// PV_BrickWall as a swept low/high pass: -1 to 0 = lowpass, 0 to 1 = highpass

(

b = ~ab;
~sb = Buffer.alloc(s, 1024, 1);

{
	var snd, fft;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	fft = FFT(~sb, snd);
	fft = PV_BrickWall(fft, MouseX.kr(-1, 1));
	IFFT(fft) ! 2;
}.play

)


// PV_MagFreeze: random spectral freeze fired by a noise generator

(

b = ~ab;
~sb = Buffer.alloc(s, 1024, 1);

{
	var snd, fft;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	fft = FFT(~sb, snd);
	fft = PV_MagFreeze(fft, ToggleFF.kr(Dust.kr(2)));
	IFFT(fft) ! 2;
}.play

)

// Cross-spectral multiplication: source A's magnitudes shaped by source B's

(

b = ~ab; c = ~ca;
~sa = Buffer.alloc(s, 1024, 1);
~scb = Buffer.alloc(s, 1024, 1);

{
	var sigA, sigB, chainA, chainB;
	sigA = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	sigB = PlayBuf.ar(1, c, BufRateScale.kr(c), loop:1);
	chainA = FFT(~sa, sigA);
	chainB = FFT(~scb, sigB);
	chainA = PV_MagMul(chainA, chainB);
	IFFT(chainA) * 0.25 ! 2;
}.play

)

// pvcollect: per-bin processing in the language. A swept bandpass on bin index

(

b = ~ab;
~sb = Buffer.alloc(s, 1024, 1);

{
	var snd, fft;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	fft = FFT(~sb, snd);
	fft = fft.pvcollect(~sb.numFrames, { |mag, phase, index|
		if((index - LFPar.kr(0.1).range(2, ~sb.numFrames / 20)).abs < 10, mag, 0);
	}, frombin: 0, tobin: 250, zeroothers: 1);
	IFFT(fft) * 0.5 ! 2;
}.play

)
