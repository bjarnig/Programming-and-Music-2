////////////////////////////////////////////////////////////////
//
//                       Triggers
//
////////////////////////////////////////////////////////////////


(   // Load source sounds

~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
~aa = Buffer.read(s, ~path ++ "sounds/abstract/aa.wav");
~ab = Buffer.read(s, ~path ++ "sounds/abstract/ab.wav");
~ca = Buffer.read(s, ~path ++ "sounds/concrete/ca.wav");
~cb = Buffer.read(s, ~path ++ "sounds/concrete/cb.wav");

)


// Onsets: detect attacks and bleep on each

(

b = ~ca;
~sb = Buffer.alloc(s, 512);

{
	var snd, fft, onset, bleep;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	fft = FFT(~sb, snd);
	onset = Onsets.kr(fft, MouseX.kr(0, 1), \complex);
	bleep = SinOsc.ar(880) * EnvGen.kr(Env.perc(0.001, 0.1, 0.2), onset);
	((snd * 0.4) + bleep).dup;
}.play

)


// Onsets via OSC, receive each event in the language

(

b = ~ca;
~sb = Buffer.alloc(s, 512);

~onsetResp = OSCFunc({ |msg, time| [time, msg].postln }, '/onset');

{
	var snd, fft, onset;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	fft = FFT(~sb, snd);
	onset = Onsets.kr(fft, 0.5, \complex);
	SendReply.kr(onset, '/onset');
	snd ! 2 * 0.5;
}.play

)


// Onsets trigger a grain

(

b = ~ca;
~sb = Buffer.alloc(s, 512);

{
	var snd, fft, onset, grain;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	fft = FFT(~sb, snd);
	onset = Onsets.kr(fft, 0.4, \complex);
	grain = TGrains.ar(2, onset, b, LFNoise1.kr(2).range(0.5, 2), 0, 0.5, 0, 0.3);
	(snd * 0.1 ! 2) + grain;

}.play

)


// BeatTrack drives a filter sweep on the source itself — beats reveal its body

(

b = ~ca;
~sb = Buffer.alloc(s, 512);

{
	var snd, fft, beat, half, env, sweepHi, sweepLo;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	# beat, half, _, _ = BeatTrack.kr(FFT(~sb, snd));
	env = Decay.kr(beat, 0.5);
	sweepHi = BPF.ar(snd, env.linexp(0, 1, 400, 4000), 0.3) * 6;
	sweepLo = BPF.ar(snd, Decay.kr(half, 1.2).linexp(0, 1, 80, 600), 0.4) * 4;
	(snd * 0.3 ! 2) + Pan2.ar(sweepHi, 0.4) + Pan2.ar(sweepLo, -0.4);
}.play

)


// KeyTrack: estimate the key (0-11) and play the tonic as a drone

(

b = ~aa;
~sb = Buffer.alloc(s, 4096, 1);

{
	var snd, fft, key, freq;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	fft = FFT(~sb, snd);
	key = KeyTrack.kr(fft).poll(2, "key");
	freq = (key + 60).midicps;
	(snd * 0.3 ! 2) + (Saw.ar(Lag.kr(freq, 0.5) * [1, 2]) * 0.05);
}.play

)


// Peak / PeakFollower / RunningMax — the running max becomes a tempo

(

b = ~ca;

{
	var snd, peak, follow, runmax;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	peak = Peak.ar(snd);
	follow = PeakFollower.ar(snd);
	runmax = RunningMax.ar(snd).linlin(0, 1, 20, 100).poll;
	Impulse.ar(runmax, 0, follow) ! 2;
}.play

)


// Median for stable envelope, drives clicks

(

b = ~ca;

{
	var snd, env;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	env = Median.ar(3, snd.abs).linlin(-1, 1, 10, 1000).poll;
	Impulse.ar(env, 0, 0.1) ! 2;
}.play

)


// Schmidt trigger: fires only when amp crosses a hi/lo gate (hysteresis)

(

b = ~ca;

{
	var snd, amp, gate, ping;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	amp = Amplitude.ar(snd);
	gate = Schmidt.ar(amp, 0.05, 0.15);
	ping = SinOsc.ar(1200) * Decay2.ar(HPZ1.ar(gate), 0.001, 0.2);
	(snd * 0.3 ! 2) + ping;
}.play

)
