////////////////////////////////////////////////////////////////
//
//              Working at the sample level
//
////////////////////////////////////////////////////////////////

/* Not another synthesis method. This file is about how the method is used.
   Non-standard synthesis has no acoustic model to aim at, so there is nothing
   to realise and no correct result to approach. What there is instead is a
   starting point, a change, and a listen. The four sections below are the
   working habits that make that productive rather than aimless. */

s.boot


/////////////////////// A seeded accident //////////////////////

/* The first problem with a random generator is that the good result cannot be
   found again. A generator written by hand takes a seed, so the same number
   returns the same waveform, sample for sample. Checked: two renders of the
   script below with seed 7 were bit-identical, and seed 8 gave a completely
   different waveform. An accident you can return to is worth more than a new
   accident. */

(
DynGenDef(\seeded, "
@init
r = _seed;

@sample
r = r * 1103515245 + 12345;
r = r - floor(r / 2147483648) * 2147483648;
c += 1;
c >= _len ? (c = 0; v = (r / 2147483648) * 2 - 1);
out0 = v;
").send;
)

// the same seed, twice: the same sound
{ DynGen.ar(1, \seeded, params: [seed: 7, len: 60]) * 0.3 ! 2 }.play

{ DynGen.ar(1, \seeded, params: [seed: 7, len: 60]) * 0.3 ! 2 }.play

// one number changed, and it is a different piece of material
{ DynGen.ar(1, \seeded, params: [seed: 8, len: 60]) * 0.3 ! 2 }.play

// walk the seeds and keep the ones worth keeping
(
Routine({
	(1..20).do { |i|
		var x;
		("seed " ++ i).postln;
		x = { DynGen.ar(1, \seeded, params: [seed: i, len: 60]) * 0.3 ! 2 }.play;
		2.wait;
		x.free;
		0.2.wait;
	};
}).play(AppClock);
)

CmdPeriod.run


///////////////////////// Constraints //////////////////////////

/* A limit is a generator. Restricting the material forces the search into a
   part of the space that would not be reached by adding things. Three limits
   on the same construction. */

// only integers, so the amplitude has three values and nothing between them
(
DynGenDef(\ints, "c += 1; c >= _len ? (c = 0; v = floor(rand() * 3) - 1); out0 = v * 0.5;").send;
)

{ DynGen.ar(1, \ints, params: [len: MouseX.kr(3, 400, \exponential)]) * 0.4 ! 2 }.play

// only one operation and one variable
(
DynGenDef(\oneop, "w += _step; w > 1 ? w -= 2; out0 = w;").send;
)

{ DynGen.ar(1, \oneop, params: [step: MouseX.kr(0.0002, 0.2, \exponential)]) * 0.3 ! 2 }.play

// no multiplication anywhere, only addition, comparison and assignment
(
DynGenDef(\addonly, "
a += _step;
a > 1 ? (a = -1; b += _step2);
b > 1 ? b = -1;
out0 = a + b > 1 ? (a + b - 2) : (a + b < -1 ? (a + b + 2) : (a + b));
").send;
)

{ DynGen.ar(1, \addonly, params: [step: 0.013, step2: 0.002]) * 0.25 ! 2 }.play

CmdPeriod.run


//////////////////////// Failure modes /////////////////////////

/* At the sample level the usual failures are not bugs, they are the edges of
   the technique, and they are all audible. Know what each one sounds like and
   how to see it, because you will meet all three. */

// 1. DC offset. An unbounded walk drifts away from zero and stays there.
//    Measured over 16384 samples: mean 0.04, ending at 0.08. On a large
//    system this is inaudible and dangerous.
(
DynGenDef(\drift, "w += (rand() * 2 - 1) * _step; out0 = w * 0.1;").send;
)

{ DynGen.ar(1, \drift, params: [step: 0.01]) ! 2 }.play

// the fix is a leak toward zero. Same walk, mean back to -0.001.
(
DynGenDef(\fixed, "w += (rand() * 2 - 1) * _step; w = w - (w * _leak); out0 = w * 0.1;").send;
)

{ DynGen.ar(1, \fixed, params: [step: 0.01, leak: 0.0005]) ! 2 }.play

// see it rather than trust it: plot the walk
(
{ var w = 0;
	Signal.newFrom(4096.collect { w = w + (1.0.rand2 * 0.01) }).plot("unbounded walk");
}.value;
)

// 2. Aliasing. Terms above Nyquist fold back down and do not sound like a
//    mistake, they sound like extra partials in the wrong places.
(
DynGenDef(\alias, "
phase += 2*$pi * _freq / srate;
phase >= (2*$pi) ? phase -= 2*$pi;
out0 = sin(phase * _mult);
").send;
)

// sweep the multiplier past Nyquist and listen for the descent
{ DynGen.ar(1, \alias, params: [freq: 220, mult: Line.kr(1, 200, 20)]) * 0.2 ! 2 }.play

// 3. Blow-up. Feedback above unity grows without limit. Keep the amplitude
//    low and a limiter after it while experimenting.
(
DynGenDef(\blow, "y = (y * _g) + (rand() * 0.0001); out0 = y;").send;
)

{ Limiter.ar(DynGen.ar(1, \blow, params: [g: 1.00002]) * 0.2, 0.5) ! 2 }.play

CmdPeriod.run


/////////////////////// Sweeping a parameter ///////////////////

/* Rather than choosing a value, listen to the whole range once. The map is
   more useful than any point on it, and it is quicker than guessing. */

(
DynGenDef(\space, "
c += 1;
c >= _len ? (c = 0; v = floor(rand() * _levels) / (_levels - 1) * 2 - 1);
out0 = v;
").send;
)

// two axes, swept slowly, so the whole space is heard in half a minute
(
{ DynGen.ar(1, \space, params: [
	len: XLine.kr(3, 600, 30),
	levels: Line.kr(2, 24, 30).round(1)
]) * 0.3 ! 2 }.play
)

CmdPeriod.run
