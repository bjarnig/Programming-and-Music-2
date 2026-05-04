////////////////////////////////////////////////////////////////
//
//                          Cross
//
////////////////////////////////////////////////////////////////


// Load source sounds + a sampler player

(

~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
~aa = Buffer.read(s, ~path ++ "sounds/abstract/aa.wav");
~ab = Buffer.read(s, ~path ++ "sounds/abstract/ab.wav");
~ca = Buffer.read(s, ~path ++ "sounds/concrete/ca.wav");
~cb = Buffer.read(s, ~path ++ "sounds/concrete/cb.wav");


SynthDef(\sampler, { |out=0, buf=0|
	Out.ar(out, PlayBuf.ar(1, buf, BufRateScale.kr(buf), loop:1) ! 2);
}).add;


~through = { |effect, args, buf|
	Routine {
		var bus;
		effect.add; s.sync;
		bus = Bus.audio(s, 2);
		Synth(effect.name, [\in, bus, \out, 0] ++ args);
		Synth(\sampler, [\out, bus, \buf, buf ? ~ca]);
	}.play
};

)


// Amplitude to pulse-comb. Loud input opens the comb, quiet input closes it

(

~through.value(

	SynthDef(\crossPulse, { |in=0, out=0, freq=500|
		var sig, osc, verb, amp;
		sig = In.ar(in, 2);
		amp = Lag.kr(Amplitude.kr(sig), 0.1);
		osc = Splay.ar(Pulse.ar(Array.series(10, freq, 5))) * amp;
		verb = Mix.ar({ CombL.ar(osc, 0.05, rrand(0.02, 0.04), 10.rand) } ! 10);
		Out.ar(out, osc + (verb * 0.5));
	}),
	[],
	~ca
)

)


// Tartini pitch to multi-saw chorus through allpass diffusion

(

~through.value(

	SynthDef(\crossPitch, { |in=0, out=0|
		var sig, freq, hasFreq, amp, voice;
		sig = In.ar(in, 1) * 2;
		amp = Amplitude.kr(sig, 0.05, 0.05);
		# freq, hasFreq = Tartini.kr(sig, 0.93, 1024, 512, 512);
		voice = Mix.new(VarSaw.ar(freq * [0.5, 1, 2], 0, LFNoise1.kr(0.3, 0.1, 0.1), amp));
		6.do { voice = AllpassN.ar(voice, 0.040, [0.040.rand, 0.040.rand], 2) };
		Out.ar(out, voice);
	}),
	[],
	~ca
)

)


// Spectral vocoder — modulator's magnitudes shape a continuous carrier (mouse Y = pitch)

(

~through.value(

	SynthDef(\specVocode, { |in=0, out=0|
		var mod, car, modFft, carFft;
		mod = In.ar(in, 1);
		car = Saw.ar(MouseY.kr(60, 400, 1)) * 0.4;
		modFft = FFT(LocalBuf(1024), mod);
		carFft = FFT(LocalBuf(1024), car);
		carFft = PV_MagMul(carFft, modFft);
		Out.ar(out, IFFT(carFft) * 0.05 ! 2);
	}),
	[],
	~ca
)

)


// Four-band amplitude vocoder — classic "talking synth" with a saw + noise carrier

(

~through.value(

	SynthDef(\bandVocode, { |in=0, out=0|
		var mod, car, freqs, modBands, ampBands, carBands;
		mod = In.ar(in, 1);
		car = Saw.ar(80) + (WhiteNoise.ar * 0.4);
		freqs = [200, 800, 2000, 4500];
		modBands = BPF.ar(mod, freqs, 0.4);
		ampBands = Amplitude.ar(modBands, 0.005, 0.05);
		carBands = BPF.ar(car, freqs, 0.25) * ampBands * 8;
		Out.ar(out, carBands.sum ! 2);
	}),
	[],
	~ca
)

)


// Spectral centroid steers a resonant filter on a separate drone

(

~through.value(

	SynthDef(\centroidCross, { |in=0, out=0|
		var sig, fft, centroid, drone;
		sig = In.ar(in, 1);
		fft = FFT(LocalBuf(1024), sig);
		centroid = SpecCentroid.kr(fft).clip(80, 6000).lag(0.1);
		drone = Saw.ar([55, 55.2]) * 0.4;
		drone = RLPF.ar(drone, centroid, 0.2);
		Out.ar(out, drone * 2);
	}),
	[],
	~ab
)

)
