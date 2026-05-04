////////////////////////////////////////////////////////////////
//
//                       Listening
//
////////////////////////////////////////////////////////////////

(   // Load source sounds

~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
~aa = Buffer.read(s, ~path ++ "sounds/abstract/aa.wav");
~ab = Buffer.read(s, ~path ++ "sounds/abstract/ab.wav");
~ca = Buffer.read(s, ~path ++ "sounds/concrete/ca.wav");
~cb = Buffer.read(s, ~path ++ "sounds/concrete/cb.wav");

)


// Track pitch and amplitude with Pitch

(

b = ~ca;

{
	var snd, amp, freq, hasFreq;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	amp = Amplitude.ar(snd, 0.1, 0.1);
	# freq, hasFreq = Pitch.kr(snd);
	Saw.ar(freq.poll * [1, 1]) * amp + (snd * 0.5);
}.play

)


// Tartini for monophonic pitch, RunningSum as a smoothed amplitude

(

b = ~ca;

{
	var snd, amp, freq, hasFreq;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	amp = Lag.ar(RunningSum.ar(snd).linlin(-1, 1, 0.0, 0.8));
	# freq, hasFreq = Tartini.kr(snd);
	Saw.ar(freq.poll * [1, 2]) * amp;
}.play

)


// Loudness drives a noise band

(

b = ~ab;
~sb = Buffer.alloc(s, 1024, 1);

{
	var snd, fft, loudness;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	fft = FFT(~sb, snd);
	loudness = Loudness.kr(fft).linlin(0, 100, 0, 0.5);
	Pan2.ar(BrownNoise.ar(loudness.poll(10)));
}.play

)


// SpecCentroid + SpecFlatness drive a sine: centroid = brightness, flatness = noisiness

(

b = ~ab;
~sb = Buffer.alloc(s, 1024, 1);

{
	var snd, fft, centroid, flatness;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	fft = FFT(~sb, snd);
	centroid = SpecCentroid.kr(fft);
	flatness = SpecFlatness.kr(fft);
	SinOsc.ar(Lag.kr(centroid, 0.5), 0, flatness.poll);
}.play

)


// SpecPcile percentile bands: 50% (median freq) and 95% (where the energy ends)

(

b = ~ab;
~sb = Buffer.alloc(s, 1024, 1);

{
	var snd, fft, mid, top;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	fft = FFT(~sb, snd);
	mid = SpecPcile.kr(fft, 0.5).poll(2, "median");
	top = SpecPcile.kr(fft, 0.95).poll(2, "95%");
	SinOsc.ar([mid, top].lag(0.1), 0, 0.1);
}.play

)


// ZeroCrossing as a rough pitch estimate, AmpComp for equal loudness

(

b = ~ca;

{
	var snd, freq;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	freq = ZeroCrossing.ar(snd).poll;
	SinOsc.ar(freq, 0, AmpComp.ar(freq, 20).poll) ! 2;
}.play

)


// MFCC peek: 13-coefficient timbre fingerprint, mapped to oscillator bank

(

b = ~ab;
~sb = Buffer.alloc(s, 1024, 1);

{
	var snd, fft, coeffs;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	fft = FFT(~sb, snd);
	coeffs = MFCC.kr(fft, 13);
	Splay.ar(SinOsc.ar((coeffs * 200) + 200, 0, 0.05));
}.play

)
