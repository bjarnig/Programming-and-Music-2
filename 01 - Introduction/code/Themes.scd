////////////////////////////////////////////////////////////////
//
//                 Three Themes, one taste each
//
////////////////////////////////////////////////////////////////

/* One short example per theme, so the whole year can be heard in the
   first class. Nothing here needs a sound of your own: the Systems
   example reads a11wlk01.wav, the sample that ships with SuperCollider
   and turns up all over its help files. */

Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)

( // the sample that ships with SuperCollider, used by the Systems example
~voice = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
)


////////////////////////// Material ///////////////////////////

/* Non-standard synthesis: no oscillator, and no model of an instrument.
   A demand stream supplies the waveform one sample at a time, so the
   numbers are the sound. Classes 04 and 05. */


( // Demand and server side patterns for a waveform

{   var trig, movement;
	trig = Impulse.ar(400);
	movement = Dbrown(-1,1,0.8,inf);
	Demand.ar(trig, 0, movement) ! 2 * 0.5;
}.play;
)


// Sawtooth wave: one rising ramp that resets

(

{
	var levels = Dseq([Dseries(-1.0, 0.02, 100)],inf);
	var durations = SampleDur.ir * 5;
	DemandEnvGen.ar(levels, durations) ! 2 * 0.3;
}.play

)


// A waveform composed of five different segments

(

{
	var levels = Dseq([
		Dseries(-1, 0.04, 50),                     // sawtooth up
		Dseries(-1, 0.04, 50),                     // triangle up half
		Dseries(1, -0.04, 50),                     // triangle down half
		Dstutter(25, Dseq([1, -1], 6)),           // square wave (6 cycles, 25 samples each)
		Dgeom(0.01, 1.08, 50)                      // exponential ramp
	], inf);

	var durations = SampleDur.ir * 5;
	var sig = DemandEnvGen.ar(levels, durations);
	sig = sig.clip(-1, 1);  // safety clip

	sig ! 2 * 0.3;

}.play

)


// The same structure with the breakpoints left to a random walk

{Gendy1.ar(ampdist: 10, ddparam: 0.001, minfreq: 200) * 0.5}.play


////////////////////////// Liveness ///////////////////////////

/* A running system with addressable parts. Nothing stops while it is
   rewritten. Classes 09 and 10. */


( // a source, and a pattern that sets its frequency
Ndef(\a);
Ndef(\a)[0] = {|freq=80| Saw.ar(freq!2,0.1) };
Ndef(\a)[2] = {|freq=80| SinOsc.ar(freq!2 * 0.5,0,0.1) };
Ndef(\a)[1] = \set -> Pbind(\dur, 0.1, \freq, Pwhite(40,400));
Ndef(\a).play
)

( // a filter added to a proxy that is already playing
Ndef(\c).play;
Ndef(\c).fadeTime = 2;
Ndef(\c)[0] = {|freq=90| Saw.ar(freq!2,0.1) };
Ndef(\c)[2] = \filter -> {|in| LPF.ar(in, LFNoise1.ar(8).range(100,800)) };
Ndef(\c)[3] = {|freq=900| Saw.ar(freq!2,0.1) };
)

// or .filter
Ndef(\saw, { Saw.ar(100!2) }).play
Ndef(\saw).filter(1, {arg in; LPF.ar(in, 900)})

Ndef.clear(3)


////////////////////////// Systems ////////////////////////////

/* A machine that listens, and a sound that follows what it heard.
   Classes 11 and 17 to 20. */


// Track pitch and amplitude with Pitch

(

b = ~voice;

{
	var snd, amp, freq, hasFreq;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop:1);
	amp = Amplitude.ar(snd, 0.1, 0.1);
	# freq, hasFreq = Pitch.kr(snd);
	Saw.ar(freq.poll * [1, 1]) * amp + (snd * 0.5);
}.play

)
