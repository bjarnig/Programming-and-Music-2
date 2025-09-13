////////////////////////////////////////////////////////////////
//
//                     Binary Operations
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)


///////////////////////// Binary operations /////////////////////

// LeastChange, Output the input that changed least.
{ LeastChange.ar(SinOsc.ar(100), Saw.ar(15)) * 0.2 }.play;


// Whitenoise pulses
{ WhiteNoise.ar(0.4).amclip(SinOsc.ar(100)) }.play;


// Threshold a sine wave with respect to another
{ SinOsc.ar(100).thresh(SinOsc.ar()) }.play;


// Ring modulation between LFSaw and LFnoise only when LFNoise2's polarity is negative
{ LFNoise2.ar(400).scaleneg(LFSaw.ar(1000)) }.play;


// Compare a sine wave with white noise to generate a rectangular wave
{ LeakDC.ar(SinOsc.ar(1000) < WhiteNoise.ar()) }.play;


// Modulate with Noise with Saw
{ WhiteNoise.ar(0.4).amclip(Saw.ar(Line.ar(1, 500, 15))) }.play;


// Threshold a Pulse wave with a Sine wave
{ Pulse.ar(50).thresh(SinOsc.ar(1000)) }.play;


// Fold a Blipe with a Sine
{ Blip.ar(100,150).fold2(SinOsc.ar(Line.ar(10, 100, 20) ) ) }.play


// Modulo a Saw wave with a LFNoise1
{ Saw.ar([20, 10]).mod(LFNoise1.ar(1000)) * 0.1 }.play;

/*  See also: */

.fold2
.wrap2
.distort
.softclip
.amclip
.scaleneg
.mod
.pow
.ramp
.sin
.cos
.tan
.tanh
.asin
.acos
.atan
.ring1
.excess
.squared
.cubed
.sqrt
.exp
.log
.difsqr
.clip2
.sumsqr
.absdif
