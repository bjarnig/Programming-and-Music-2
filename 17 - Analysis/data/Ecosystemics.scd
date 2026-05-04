////////////////////////////////////////////////////////////////
//
//                       Ecosystemics
//
////////////////////////////////////////////////////////////////


// Spectral self-listening, the loop's centroid filters its own feedback path

(

Ndef(\spectralEco, { |amp = 0|
	var seed, sig, fft, centroid, cutoff;
	seed = Dust.ar(8) * amp;
	sig = seed ! 2 + LocalIn.ar(2);
	fft = FFT(LocalBuf(1024), sig.sum);
	centroid = SpecCentroid.kr(fft).clip(80, 4000).lag(1.0);
	cutoff = centroid.linexp(80, 4000, 8000, 200);
	sig = LPF.ar(sig, cutoff);
	sig = DelayC.ar(sig, 0.5, 0.15);
	sig = LeakDC.ar(sig);
	LocalOut.ar(sig * 0.92);
	SendReply.kr(Impulse.kr(2), '/eco', [centroid, cutoff]);
	sig * 0.4;
}).play;

OSCdef(\eco, { |msg|
	"centroid: % Hz  cutoff: % Hz".format(msg[3].round(1), msg[4].round(1)).postln
}, '/eco');

)

Ndef(\spectralEco).set(\amp, 1);
Ndef(\spectralEco).set(\amp, 0);
Ndef(\spectralEco).clear; OSCdef(\eco).free;


// Envelope follower regulates a band-passed loop

(

Ndef(\envLoop, { |amp = 0|
	var input, sig, env, fb;
	input = Dust.ar(100) * amp;
	sig = input ! 2 + LocalIn.ar(2);
	env = Amplitude.ar(sig, 0.01, 0.3);
	fb = (0.15 * (env < 0.3)) - (0.4 * (env > 0.7));
	sig = BBandPass.ar(sig, LFNoise1.ar(3).exprange(500, 2000), 0.6);
	sig = DelayC.ar(sig, 1, LFNoise1.ar(5).range(0.05, 0.3));
	LocalOut.ar(sig * fb.clip(0, 1.2));
	sig * 0.75;
}).play;

)

Ndef(\envLoop).set(\amp, 1);
Ndef(\envLoop).set(\amp, 0);
Ndef(\envLoop).clear;


