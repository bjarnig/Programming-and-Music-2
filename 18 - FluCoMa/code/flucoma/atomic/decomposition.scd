////////////////////////////////////////////////////////////////
//
//                Decompose components
//
////////////////////////////////////////////////////////////////


~sounds = thisProcess.nowExecutingPath.dirname +/+ "../../sounds/";


// Load sources

(

s.waitForBoot({

	~catbike = Buffer.read(s, ~sounds +/+ "catbike.wav");
	~melodie = Buffer.read(s, ~sounds +/+ "melodie.wav");
	~texture = Buffer.read(s, ~sounds +/+ "texture.wav");

	s.sync;
	"buffers loaded — ready".postln;

});

)


// FluidBufHPSS — harmonic vs percussive separation

/*

Median filter horizontally on the spectrogram,  harmonic component.
Median filter vertically, percussive component.
harmFilterSize and percFilterSize control how aggressive each cut is.

*/

(

~harm = Buffer.alloc(s, 1);
~perc = Buffer.alloc(s, 1);

FluidBufHPSS.processBlocking(s, ~catbike,
	harmonic: ~harm,
	percussive: ~perc,
	harmFilterSize: 17,
	percFilterSize: 31,
	action: { "HPSS done.".postln });

)

// Hear each in isolation

{ PlayBuf.ar(1, ~catbike, BufRateScale.kr(~catbike), doneAction: 2).dup }.play;  // original
{ PlayBuf.ar(1, ~harm,    BufRateScale.kr(~harm),    doneAction: 2).dup }.play;  // harmonic
{ PlayBuf.ar(1, ~perc,    BufRateScale.kr(~perc),    doneAction: 2).dup }.play;  // percussive

(

{

	var x = MouseX.kr(-1, 1).lag(0.05);
	var h = PlayBuf.ar(1, ~harm, BufRateScale.kr(~harm), loop: 1);
	var p = PlayBuf.ar(1, ~perc, BufRateScale.kr(~perc), loop: 1);

	x.poll(2, label: \harm_to_perc);

	XFade2.ar(h, p, x, 0.7).dup;

}.play;

)



// FluidBufSines — sinusoidal partials vs residual

// Tracks stable spectral peaks across frames. Anything that survives as a
// stable partial goes into `sines`; everything else (including transients
// and noise) lands in `residual`.

(

~sines    = Buffer.alloc(s, 1);
~residual = Buffer.alloc(s, 1);

FluidBufSines.processBlocking(s, ~melodie,
	sines: ~sines,
	residual: ~residual,
	detectionThreshold: -40,
	minTrackLen: 15,
	action: { "Sines/residual done.".postln });

)

// Hear each part

{ PlayBuf.ar(1, ~melodie,  BufRateScale.kr(~melodie),  doneAction: 2).dup }.play;  // original
{ PlayBuf.ar(1, ~sines,    BufRateScale.kr(~sines),    doneAction: 2).dup }.play;  // partials
{ PlayBuf.ar(1, ~residual, BufRateScale.kr(~residual), doneAction: 2).dup }.play;  // residual


// Crossfade sines ↔ residual with the mouse.

(

~sinesMix = {

	var x = MouseX.kr(-1, 1).lag(0.05);
	var snd1 = PlayBuf.ar(1, ~sines,    BufRateScale.kr(~sines),    loop: 1);
	var snd2 = PlayBuf.ar(1, ~residual, BufRateScale.kr(~residual), loop: 1);

	x.poll(2, label: \sines_to_residual);

	XFade2.ar(snd1, snd2, x, 0.7).dup;

}.play;

)


// FluidBufTransients — transient extraction (sample-accurate)

(

~trans     = Buffer.alloc(s, 1);
~tresidual = Buffer.alloc(s, 1);

FluidBufTransients.processBlocking(s, ~catbike,
	transients: ~trans,
	residual: ~tresidual,
	threshFwd: 2.0,
	threshBack: 1.1,
	action: { "Transients/residual done.".postln });

)

// Hear each part.
{ PlayBuf.ar(1, ~catbike,   BufRateScale.kr(~catbike),   doneAction: 2).dup }.play;  // original
{ PlayBuf.ar(1, ~trans,     BufRateScale.kr(~trans),     doneAction: 2).dup }.play;  // transients
{ PlayBuf.ar(1, ~tresidual, BufRateScale.kr(~tresidual), doneAction: 2).dup }.play;  // residual



// Crossfade, and reverb to differentiate

(

~transMix = {

	var x = MouseX.kr(-1, 1).lag(0.05);
	var t = PlayBuf.ar(1, ~trans,     BufRateScale.kr(~trans),     loop: 1);
	var r = PlayBuf.ar(1, ~tresidual, BufRateScale.kr(~tresidual), loop: 1);

	r = FreeVerb.ar(r, 0.6, 0.8, 0.4);  // noise tail blooms

	x.poll(2, label: \trans_to_residual);

	XFade2.ar(t, r, x, 0.7).dup;

}.play;

)



// FluidBufNMF — non-negative matrix factorisation into N components

/* NMF learns N "spectral templates" (bases) and how loud each is over time
  (activations), such that bases × activations ≈ original spectrogram.
  `resynth` is a multi-channel buffer with one channel per component. */

(

// Empty Buffer; FluCoMa allocates it server-side as (numFrames × components).
~resynth = Buffer(s);

FluidBufNMF.processBlocking(s, ~texture,
	resynth: ~resynth,
	components: 3,
	iterations: 100,
	resynthMode: 1,            // 0 = don't resynthesise (silence!); 1 = fill resynth buffer
	action: {
		~resynth.updateInfo({ |b|
			("resynth: %ch × %frames".format(b.numChannels, b.numFrames)).postln;
		});
	}
);

)


// SynthDef with one level per component, all running together.

(

SynthDef(\nmfMix, { |amp0 = 1, amp1 = 1, amp2 = 1, masterAmp = 0.6|

	var sig = PlayBuf.ar(3, ~resynth, BufRateScale.kr(~resynth), loop: 1);
	var mix = (sig[0] * amp0) + (sig[1] * amp1) + (sig[2] * amp2);

	// Poll the running mix so you see what's loudest.
	Amplitude.kr(sig[0]).poll(2, label: \comp0);
	Amplitude.kr(sig[1]).poll(2, label: \comp1);
	Amplitude.kr(sig[2]).poll(2, label: \comp2);

	Out.ar(0, (mix * masterAmp).dup);

}).add;

)

~mix = Synth(\nmfMix);

// Solo each component:
~mix.set(\amp0, 1, \amp1, 0, \amp2, 0);
~mix.set(\amp0, 0, \amp1, 1, \amp2, 0);
~mix.set(\amp0, 0, \amp1, 0, \amp2, 1);

// All together:
~mix.set(\amp0, 1, \amp1, 1, \amp2, 1);

// Drop one:
~mix.set(\amp0, 0, \amp1, 1, \amp2, 1);

~mix.free;



// MouseX selects which component is foreground

(

~mouseMix = {

	var sel = MouseX.kr(0, 2.999);
	var fade = 1 - MouseY.kr(0, 1).lag(0.05);
	var sig = PlayBuf.ar(3, ~resynth, BufRateScale.kr(~resynth), loop: 1);

	var amps = [
		Select.kr(sel.floor, [1.0, fade, fade]),
		Select.kr(sel.floor, [fade, 1.0, fade]),
		Select.kr(sel.floor, [fade, fade, 1.0])
	];

	((sig[0] * amps[0]) + (sig[1] * amps[1]) + (sig[2] * amps[2])).dup * 0.6;

}.play;

)
