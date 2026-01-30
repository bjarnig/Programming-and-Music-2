////////////////////////////////////////////////////////////////
//
//            JITLib - Advanced Processing Techniques
//
////////////////////////////////////////////////////////////////

Ndef.clear;

/* - 0. The Source - */


(

Ndef(\source, {
	|ser=500, step=2.5, amp=1.0, sdm=0.5, mf=0.008|
	var sd = SampleDur.ir * sdm;
	Limiter.ar(DemandEnvGen.ar(
		Dseq([Dseries(-0.5, [0.1,-0.1], ser)], inf),
		sd * Dbrown(1, 7, 2.5)
	) * mf) * amp
});

)


/* - 1. External Filtering - */


( // Bandstop filter sweeps

Ndef(\filtered1, {
	var snd = Ndef(\source).ar;
	var brj = BBandStop.ar(
		snd,
		LFNoise1.ar(4).range(200, 8000),
		LFNoise1.ar(0.5).range(3, 12)
	);
	var lop = BLowPass4.ar(
		brj,
		LFNoise1.ar(2).range(20, 18000),
		LFNoise1.ar(0.5).range(0.2, 0.3)
	);
	Splay.ar(lop);
}).play;

)

Ndef(\filtered1).clear;

( // Resonant bandpass cascade

Ndef(\filtered2, {
	var snd = Ndef(\source).ar;
	var freqs = Array.geom(8, 100, 1.5);
	freqs.collect { |freq|
		BPF.ar(snd, freq * LFNoise1.kr(0.1).range(0.8, 1.2), 0.1)
	}.sum;
}).play;

)

Ndef(\filtered2).clear;



/* - 2. Nonlinear Processing - */


( // Fold2 with modulating threshold

Ndef(\folder, {
	var snd = Ndef(\source).ar;
	var folded = snd.fold2(SinOsc.ar(0.1).range(0.1, 0.8));
	folded.dup;
}).play;

)


( // Multiple waveshaping options

Ndef(\shaper, {
	var snd = Ndef(\source).ar * 10;
	snd.softclip * 0.3;  // Try: fold2, wrap2, clip2, tanh, distort, softclip
}).play;

)

Ndef(\shaper, { var snd = Ndef(\source).ar * 30; snd.clip2 * 0.3 });
Ndef(\shaper, { var snd = Ndef(\source).ar * 10; snd.wrap2(0.5) * 0.3 });

Ndef(\shaper).clear;



/* - 3. Spectral Processing - */


( // FFT freeze

Ndef(\freezer, { |freezeRate = 4|
	var sig = Ndef(\source).ar;
	var chain = FFT(LocalBuf(2048), sig);
	var freeze = PV_Freeze(chain, LFPulse.kr(freezeRate));
	IFFT(freeze).dup;
}).play;

)

Ndef(\freezer).set(\freezeRate, 8);
Ndef(\freezer).set(\freezeRate, 0.5);

Ndef(\freezer).clear;


( // Spectral bin scrambling

Ndef(\scramble, {
	var sig = Ndef(\source).ar;
	var chain = FFT(LocalBuf(2048), sig);
	var bins = PV_BinScramble(chain,
		LFNoise0.kr(2).range(0.0, 1.0),
		LFNoise0.kr(0.5).range(0.0, 1.0)
	);
	IFFT(bins);
}).play;

)

Ndef(\scramble).clear;


( // Magnitude smear

Ndef(\smear, {
	var sig = Ndef(\source).ar;
	var chain = FFT(LocalBuf(2048), sig);
	var smeared = PV_MagSmear(chain, LFNoise2.kr(10.1).range(1, 20));
	IFFT(smeared);
}).play;

)

Ndef(\smear).clear;



/* - 4. Multi-Band Processing - */

(
Ndef(\multiband, {
	var snd = Ndef(\source).ar;
	var low, mid, high;

	// Split into bands
	low = LPF.ar(snd, 400);
	mid = BPF.ar(snd, 1200, 1);
	high = HPF.ar(snd, 3000);

	// Process each band differently
	low = low * 1.5;
	mid = (mid * 10).fold2(0.3);
	high = high * LFNoise1.kr(10);

	// Recombine
	(low + mid + high);
}).play;
)

Ndef(\multiband).clear;



( // Crossover with independent effects

Ndef(\xover, {
	var snd = Ndef(\source).ar;
	var low, mid, high;

	low = LPF.ar(snd, 300);
	mid = BPF.ar(snd, 1500, 0.5);
	high = HPF.ar(snd, 5000);

	// Different delays per band
	low = low + CombN.ar(low, 0.5, 0.3, 2);
	mid = mid + CombN.ar(mid, 0.3, 0.15, 1.5);
	high = high + AllpassN.ar(high, 0.1, 0.05, 1);

	Mix([low, mid, high]);
}).play;

)

Ndef(\xover).clear;


/* - 5. Sidechain Compression - */


( // Kick drum ducks the pad

// Kick trigger
Ndef(\kick, {
	var trig = Dust.ar(2);
	var env = EnvGen.ar(Env.perc(0.1, 0.5), trig);
	SinOsc.ar(60, 0, env);
}).play;

// Pad with sidechain
Ndef(\pad, {
	var sig = Ndef(\source).ar;
	var kickSig = Ndef(\kick).ar;
	var amp = Amplitude.kr(kickSig, 0.01, 0.1);
	var duck = amp.linlin(0, 0.5, 1, 0.3).lag(0.05);
	sig * duck;
}).play;

)

Ndef(\kick).clear;
Ndef(\pad).clear;


( // Rhythmic ducking with Compander

Ndef(\pulse, { Saw.ar(freq:LFNoise1.ar(10).range(1,5), amp:0.2) });

Ndef(\ducked, {
	var sig = Ndef(\source).ar;
	var control = Ndef(\pulse).ar;
	Compander.ar(sig, control,
		thresh: 0.1,
		slopeBelow: 1,
		slopeAbove: 0.3,
		clampTime: 0.01,
		relaxTime: 0.1
	).dup;
}).play;

)

Ndef(\ducked).clear;
Ndef(\pulse).clear;
