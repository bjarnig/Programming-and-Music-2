////////////////////////////////////////////////////////////////
//
//              DynGen, the waveform written directly
//
////////////////////////////////////////////////////////////////

/* Brün, Koenig and Berg composed the waveform sample by sample, offline,
   on machines that took minutes to produce seconds. DynGen puts the same
   operation on the server: it compiles EEL2 code into the audio graph, runs
   it once per sample, and lets the code be replaced while it is sounding.
   Nothing below uses an oscillator UGen. Every waveform is arithmetic.
   Requires SuperCollider 3.14 and the DynGen extension. */

s.boot


///////////////////////// A sine by hand ///////////////////////

/* No SinOsc. A phase accumulator, wrapped, and the sine of it. This is the
   baseline the rest of the file departs from. */

(
DynGenDef(\bySine, "
phase += 2*$pi * _freq / srate;
phase >= (2*$pi) ? phase -= 2*$pi;
out0 = sin(phase);
").send;
)

{ DynGen.ar(1, \bySine, params: [freq: 220]) * 0.2 ! 2 }.play

CmdPeriod.run


///////////////// Instructions, not a function /////////////////

/* After Berg's PILE and ASP: the waveform is decided by conditions rather
   than described by a formula. A value walks by a fixed step and turns
   around when it reaches a barrier, so the shape is a consequence of the
   rules and not of a curve. */

(
DynGenDef(\instr, "
@init
dir = 1;
val = 0;

@sample
val += dir * _step;
val >= _barrier ? (val = _barrier; dir = -1);
val <= -_barrier ? (val = -_barrier; dir = 1);
out0 = val;
").send;
)

// a triangle, arrived at without ever naming a triangle
{ DynGen.ar(1, \instr, params: [step: 0.01, barrier: 1.0]) * 0.2 ! 2 }.play

// a smaller barrier is a higher pitch, because the walk turns sooner
{ DynGen.ar(1, \instr, params: [step: 0.01, barrier: MouseX.kr(0.02, 1.0)]) * 0.2 ! 2 }.play

CmdPeriod.run


/////////////// Dynamic stochastic synthesis ///////////////////

/* Xenakis' GENDY, in its essential form: a breakpoint is reached, a new
   duration and a new amplitude are drawn by a random walk, both walks are
   held inside barriers, and the signal moves linearly to the new point.
   The waveform is never the same twice and never leaves the barriers. */

(
DynGenDef(\gendy, "
@init
dur = 100;
count = 0;
from = 0;
to = 0;

@sample
count += 1;
count >= dur ? (
  count = 0;
  from = to;
  // amplitude random walk, reflected at the barriers
  amp += (rand() * 2 - 1) * _ampStep;
  amp > _ampBarrier ? amp = _ampBarrier;
  amp < -_ampBarrier ? amp = -_ampBarrier;
  to = amp;
  // duration random walk, clipped to a minimum and a maximum
  dur += (rand() * 2 - 1) * _durStep;
  dur = max(_durMin, min(_durMax, dur));
);
out0 = from + ((to - from) * (count / dur));
").send;
)

// twelve to two hundred samples a segment: a rough, pitched band
(
{ DynGen.ar(1, \gendy, params: [
	ampStep: 0.3, ampBarrier: 1.0, durStep: 8, durMin: 12, durMax: 200
]) * 0.2 ! 2 }.play
)

// longer segments: the same algorithm becomes a slow, noisy contour
(
{ DynGen.ar(1, \gendy, params: [
	ampStep: 0.2, ampBarrier: 1.0, durStep: 200, durMin: 400, durMax: 4000
]) * 0.2 ! 2 }.play
)

// the barriers under the mouse, which is the parameter Xenakis cared about
(
{ DynGen.ar(1, \gendy, params: [
	ampStep: MouseY.kr(0.01, 1.0), ampBarrier: 1.0,
	durStep: 8, durMin: MouseX.kr(4, 300), durMax: 400
]) * 0.2 ! 2 }.play
)

CmdPeriod.run


///////////////// An iterated nonlinear function ///////////////

/* One equation applied to its own output, once per sample: the logistic map
   from class 22, running at 44100 iterations a second instead of a few per
   bar. The orbit itself is the signal. */

(
DynGenDef(\iterated, "
@init
y = 0.5;

@sample
y = _r * y * (1 - y);
out0 = (y * 2) - 1;
").send;
)

// r below 3.0 settles, and the output is silence with a click at the start
{ DynGen.ar(1, \iterated, params: [r: 2.8]) * 0.2 ! 2 }.play

// past 3.57 it never repeats, and the result is broadband noise
{ DynGen.ar(1, \iterated, params: [r: 3.9]) * 0.2 ! 2 }.play

// swept through the bifurcations
{ DynGen.ar(1, \iterated, params: [r: Line.kr(2.8, 4.0, 20)]) * 0.2 ! 2 }.play

CmdPeriod.run


///////////////// Functional Iteration Synthesis ////////////////

/* Di Scipio's own method, which is not the block above. There the iteration
   runs across samples. Here it runs inside one: at every sample tick the sine
   map is applied n times to a starting value x0, and the nth iterate is that
   sample. The parameters are r, x0 and n; the function is not one of them.

   x0 arrives as the input, so a control signal scanning it is a path drawn
   across the surface of nth iterates. Only a closed path gives a periodic
   signal. Checked against the arithmetic: five settings of x0, r and n match
   the values computed offline to float32 precision. */

(
DynGenDef(\fis, "
x = in0;
loop(_n, x = sin(_r * x));
out0 = x;
").send;
)

// n = 2, a smooth surface, in the window of the paper's first figure
{ DynGen.ar(1, \fis, LFSaw.ar(110).range(0.2, 0.4), params: [r: 3.2, n: 2]) * 0.3 ! 2 }.play

// n = 7, the same scan across a surface full of hills and valleys
{ DynGen.ar(1, \fis, LFSaw.ar(110).range(0.2, 0.4), params: [r: 3.2, n: 7]) * 0.3 ! 2 }.play

// the whole window at r = 4: the dense texture the paper reports around n = 9
{ DynGen.ar(1, \fis, LFSaw.ar(40).range(0.0, 1.0), params: [r: 4.0, n: 9]) * 0.3 ! 2 }.play

// orbital velocity: the same surface scanned more slowly is a lower sound
(
{ DynGen.ar(1, \fis, LFSaw.ar(MouseX.kr(4, 400, \exponential)).range(0.0, 1.0),
	params: [r: 4.0, n: 7]) * 0.3 ! 2 }.play
)

// the iterate order under the mouse, which is where the bandwidth comes from
(
{ DynGen.ar(1, \fis, LFSaw.ar(110).range(0.0, 1.0),
	params: [r: 3.6, n: MouseX.kr(1, 10).round]) * 0.3 ! 2 }.play
)

CmdPeriod.run


////////////////// The code is data ///////////////////////////

/* A DynGenDef is a string. It can be assembled, stored, chosen from a list,
   or generated by another program, which is the SAWDUST idea with the
   machine of 1976 replaced. Redefine and play again to hear the change.
   Note: the DynGen documentation says a running synth picks up a new
   definition of the same name. That did not happen on this machine with
   SC 3.14: a synth started with `{ }.play` kept its original code after the
   definition was replaced, checked by measuring the output. Re-evaluate the
   synth after redefining. */

(
~partials = { |n|
	var terms = Array.fill(n, { |i|
		"(" ++ (1 / (i + 1)) ++ " * sin(" ++ (i + 1) ++ " * phase))"
	});
	"phase += 2*$pi * _freq / srate;\n"
	++ "phase >= (2*$pi) ? phase -= 2*$pi;\n"
	++ "out0 = " ++ terms.join(" + ") ++ ";";
};
)

// look at what was generated before sending it
~partials.(4).postln;

// one partial: a sine
(
DynGenDef(\built, ~partials.(1)).send;
x = { DynGen.ar(1, \built, params: [freq: 110]) * 0.2 ! 2 }.play;
)

// eight partials, which is a sawtooth built by hand
(
x.free;
DynGenDef(\built, ~partials.(8)).send;
x = { DynGen.ar(1, \built, params: [freq: 110]) * 0.2 ! 2 }.play;
)

// thirty-two, and the aliasing above Nyquist is audible
(
x.free;
DynGenDef(\built, ~partials.(32)).send;
x = { DynGen.ar(1, \built, params: [freq: 110]) * 0.2 ! 2 }.play;
)

x.free

CmdPeriod.run


///////////////////// One line each ////////////////////////////

/* Six scripts of one line each, for people named earlier in the
   class. None is a faithful implementation; each is the smallest thing
   that carries the idea. Read the line, predict the sound, then play it. */

// Xenakis: stochastic variation of the sound pressure directly, held by barriers
(
DynGenDef(\xe, "w += (rand() * 2 - 1) * _step; w = max(-1, min(1, w)); out0 = w;").send;
)

{ DynGen.ar(1, \xe, params: [step: MouseX.kr(0.002, 0.3)]) * 0.3 ! 2 }.play

// Brün: an element is an amplitude and a duration in samples
(
DynGenDef(\br, "c += 1; c >= _len ? (c = 0; v = rand() * 2 - 1); out0 = v;").send;
)

{ DynGen.ar(1, \br, params: [len: MouseX.kr(4, 800, \exponential)]) * 0.3 ! 2 }.play

// Koenig: the same, with the amplitudes quantised to a small set of values
(
DynGenDef(\ko, "c += 1; c >= _len ? (c = 0; v = floor(rand() * 5) / 2 - 1); out0 = v;").send;
)

{ DynGen.ar(1, \ko, params: [len: 90]) * 0.3 ! 2 }.play

// Berg: the waveform is the consequence of an instruction, not of a curve
(
DynGenDef(\be, "p += _step; p > 1 ? p = -1; out0 = p;").send;
)

{ DynGen.ar(1, \be, params: [step: MouseX.kr(0.0005, 0.2, \exponential)]) * 0.3 ! 2 }.play

// Di Scipio: the sine map applied n times inside one sample
(
DynGenDef(\ds, "x = in0; loop(_n, x = sin(_r * x)); out0 = x;").send;
)

(
{ DynGen.ar(1, \ds, LFSaw.ar(110).range(0.0, 1.0),
	params: [r: 3.6, n: MouseX.kr(1, 9).round]) * 0.3 ! 2 }.play
)

// Wishart: a new gain at every zero crossing of the input, which is a waveset
(
DynGenDef(\wi, "s = in0 >= 0; s != u ? g = rand(); u = s; out0 = in0 * g;").send;
)

(
{ DynGen.ar(1, \wi, SinOsc.ar(180) + (0.5 * SinOsc.ar(437))) * 0.4 ! 2 }.play
)

CmdPeriod.run
