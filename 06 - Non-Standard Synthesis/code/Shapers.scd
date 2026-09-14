////////////////////////////////////////////////////////////////
//
//                      Waveshapers
//
////////////////////////////////////////////////////////////////

/* Seven saturators, ported from the gen~ sigmoid patchers. Each takes a
   bipolar input and returns a bipolar output: f(0) = 0, f(±1) is close to
   ±1, and all of them are odd-symmetric, so they add odd harmonics and
   leave even ones alone. They are written as plain functions, so the same
   definition plots in the language and runs at audio rate. */

s.boot


//////////////////////// The seven curves //////////////////////

(
~sigmoid = (
	tanh:      { |x| x.tanh },
	atan:      { |x| (x * 0.5pi).atan / 0.5pi },
	cubic:     { |x| var c = x.clip(-1, 1); ((3 * c) - c.cubed) / 2 },
	gudermann: { |x| (x * 0.25pi).tanh.atan * (4 / pi) },
	logistic:  { |x| var e = (x * -2).exp; (1 - e) / (1 + e) },
	softclip:  { |x| x / (1 + x.abs) },
	algebraic: { |x| x / (1 + (x * x)).sqrt }
);

~order = [\tanh, \atan, \cubic, \gudermann, \logistic, \softclip, \algebraic];
)

// the transfer curve of each, over the input range -3 to 3
(
~order.do { |k|
	var n = 400;
	Signal.newFrom(n.collect { |i| ~sigmoid[k].(i.linlin(0, n - 1, -3.0, 3.0)) })
		.plot(k.asString ++ "  (input -3 to 3)");
};
)

// logistic is tanh written a second way: the difference should be nil
(
var d = 200.collect { |i|
	var x = i.linlin(0, 199, -3.0, 3.0);
	(~sigmoid[\logistic].(x) - ~sigmoid[\tanh].(x)).abs;
}.maxItem;
("largest difference between logistic and tanh: " ++ d).postln;
)


///////////////////// The same functions, heard ////////////////

/* The functions are polymorphic, so the definitions above run unchanged
   on a UGen. Drive a sine into one and raise the input gain: at low gain
   the curve is nearly straight and nothing happens, and the harmonics
   arrive as the input is pushed past the bend. */

(
SynthDef(\shape, { |gain = 1, freq = 220, amp = 0.2, which = 0|
	var sig = SinOsc.ar(freq) * gain;
	var shaped = Select.ar(which, [
		sig.tanh,
		(sig * 0.5pi).atan / 0.5pi,
		{ var c = sig.clip(-1, 1); ((3 * c) - c.cubed) / 2 }.value,
		(sig * 0.25pi).tanh.atan * (4 / pi),
		sig / (1 + sig.abs),
		sig / (1 + (sig * sig)).sqrt
	]);
	Out.ar(0, (shaped * amp) ! 2);
}).add;
)

// no saturation: the input never reaches the bend
Synth(\shape, [\which, 0, \gain, 0.3])

// hard into tanh
Synth(\shape, [\which, 0, \gain, 12])

// the gain swept, so the spectrum opens out and closes again
(
{ var sig = SinOsc.ar(220) * XLine.kr(0.2, 30, 12);
	(sig.tanh * 0.2) ! 2 }.play
)

// the same sweep through the softclip, which bends more gently
(
{ var sig = SinOsc.ar(220) * XLine.kr(0.2, 30, 12);
	((sig / (1 + sig.abs)) * 0.2) ! 2 }.play
)

CmdPeriod.run


//////////////////// A curve stored in a buffer ////////////////

/* The classic SuperCollider way: write the transfer function into a
   buffer once and let Shaper read it. The curve becomes data, so it can
   be drawn, generated or analysed like any other buffer. */

(
~mkShaper = { |func, size = 1024|
	var sig = Signal.newFrom(size.collect { |i|
		func.value(i.linlin(0, size - 1, -1.0, 1.0))
	});
	Buffer.sendCollection(s, sig.asWavetableNoWrap, 1);
};

~curves = ();
~order.do { |k| ~curves[k] = ~mkShaper.(~sigmoid[k]) };
s.sync;
)

// Shaper indexes the buffer with the input signal
(
{ var sig = SinOsc.ar(180) * Line.kr(0.2, 1.0, 10);
	Shaper.ar(~curves[\cubic].bufnum, sig) * 0.2 ! 2 }.play
)

// a curve that is not a saturator at all: Chebyshev polynomials, which
// map a sine of amplitude 1 onto a chosen harmonic series
(
~cheb = Buffer.alloc(s, 1024, 1, { |b| b.chebyMsg([1, 0, 0.4, 0, 0.2]) });
)

(
{ var sig = SinOsc.ar(180) * Line.kr(0.05, 1.0, 12);
	Shaper.ar(~cheb.bufnum, sig) * 0.2 ! 2 }.play
)

CmdPeriod.run
