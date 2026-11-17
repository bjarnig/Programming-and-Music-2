////////////////////////////////////////////////////////////////
//
//                   Non-Standard Examples
//
////////////////////////////////////////////////////////////////

s.boot

( // two sounds for the granular exercises and the recap
~path = PathName(thisProcess.nowExecutingPath).pathOnly ++ "samples/";
~voice = Buffer.read(s, ~path ++ "vocal.wav");
~bikecat = Buffer.read(s, ~path ++ "bikecat.wav");
)


/////////////////// Waveforms from streams /////////////////////

( // a saw: a rising series, five samples a step
{
	var levels = Dseq([Dseries(-1.0, 0.02, 100)], inf);
	DemandEnvGen.ar(levels, SampleDur.ir * 5) * 0.2 ! 2
}.play
)

( // a triangle: up, then down
{
	var levels = Dseq([Dseries(-1, 0.04, 50), Dseries(1, -0.04, 50)], inf);
	DemandEnvGen.ar(levels, SampleDur.ir * 5) * 0.2 ! 2
}.play
)

( // a square: each level repeated fifty times
{
	var levels = Ddup(50, Dseq([-1, 1], inf));
	DemandEnvGen.ar(levels, SampleDur.ir * 5) * 0.2 ! 2
}.play
)

( // a staircase: shape 0 jumps to each level and holds it
{
	var levels = Dseq((-4..4) / 4, inf);
	DemandEnvGen.ar(levels, SampleDur.ir * 40, 0) * 0.2 ! 2
}.play
)

( // an exponential ramp: Dgeom instead of Dseries, rescaled to -1 and 1
{
	var levels = Dseq([Dgeom(0.01, 1.05, 95)], inf);
	DemandEnvGen.ar(levels, SampleDur.ir * 5) * 2 - 1 * 0.2 ! 2
}.play
)


////////////////////// Two time scales /////////////////////////

( // durations in seconds: an envelope on the frequency of a sine
{
	var levels = Dseq([200, 800, 400, 1200], inf);
	SinOsc.ar(DemandEnvGen.kr(levels, Dseq([0.5, 0.25], inf))) * 0.2 ! 2
}.play
)

( // durations of 12 and 6 samples: the streams are now a waveform
{
	var levels = Dseq([-1, 1, -0.3, 0.6], inf);
	DemandEnvGen.ar(levels, Dseq([12, 6], inf) * SampleDur.ir) * 0.2 ! 2
}.play
)

( // the durations scaled by the mouse: pitch is the sum of the durations
{
	var levels = Dseq([-1, 1, -0.3, 0.6], inf);
	var scale = MouseX.kr(0.2, 20, \exponential);
	DemandEnvGen.ar(levels, Dseq([12, 6], inf) * SampleDur.ir * scale) * 0.2 ! 2
}.play
)


/////////////////////// Random streams /////////////////////////

// white levels at a fixed duration: a noise with a pitch
{ DemandEnvGen.ar(Dwhite(-1, 1), SampleDur.ir * 20) * 0.2 ! 2 }.play

// a brown walk: the waveform drifts rather than jumps
{ DemandEnvGen.ar(Dbrown(-0.8, 0.8, 0.1), SampleDur.ir * 20) * 0.2 ! 2 }.play

( // random durations as well: the pitch wanders with the shape
{
	var durations = Dwhite(5, 40) * SampleDur.ir;
	DemandEnvGen.ar(Dbrown(-0.8, 0.8, 0.1), durations) * 0.2 ! 2
}.play
)


/////////////////////// Curves and reset ///////////////////////

( // shape 5 bends every segment by the curve; the mouse sets the curve
{
	var sd = SampleDur.ir * 50;
	DemandEnvGen.ar(Dseq([-1, 1], inf), sd, 5, MouseX.kr(-8, 8)) * 0.2 ! 2
}.play
)

( // the curve as a stream: every segment bends differently
{
	var sd = SampleDur.ir * 50;
	DemandEnvGen.ar(Dseq([-1, 1], inf), sd, 5, Dwhite(-8, 8)) * 0.2 ! 2
}.play
)

( // a reset restarts the streams: a second period on top of the first
{
	var levels = Dseq([Dseries(-1, 0.01, 200)], inf);
	var reset = Impulse.ar(MouseX.kr(50, 400));
	DemandEnvGen.ar(levels, SampleDur.ir * 2, reset: reset) * 0.2 ! 2
}.play
)


////////////////////// Whole waveforms /////////////////////////

( // Dswitch plays a whole stream before it chooses again
{
	var saw = Dseries(-1, 0.04, 50);
	var tri = Dseq([Dseries(-1, 0.08, 25), Dseries(1, -0.08, 25)]);
	var sqr = Ddup(25, Dseq([-1, 1]));
	var levels = Dswitch([saw, tri, sqr], Drand([0, 1, 2], inf));
	DemandEnvGen.ar(levels, SampleDur.ir * 4) * 0.2 ! 2
}.play
)

( // nested Dseqs: the waveform has a form above the sample
{
	var from = 10, to = 35, repeats = 100, sd = SampleDur.ir;
	DemandEnvGen.ar(
		Dseq([
			Dseq([0, 0.5], repeats),
			Dseq([-0.2, 0.8], repeats/2),
			Dseq([-1.0, 1.0], Dwhite(repeats/32, repeats)),
			Dseq([-0.8, 0.1], repeats/16)
		], inf),
		Dseq([
			Dwhite(from, to, repeats),
			Dbrown(from/10, to/10, from/20, repeats)
		], inf) * sd
	) * 0.1 ! 2
}.play
)

( // twenty layers of one stream, at durations of 1 to 20 samples
{
	Splay.ar(20.collect { |i|
		var levels = Dseq([Dseries(-0.5, 0.1, 15)], inf);
		DemandEnvGen.ar(levels, SampleDur.ir * Dseq([1, 2], inf) * (i + 1))
	}) * 0.2
}.play
)


/////////////////////// GENDY by hand //////////////////////////

( // after Sergio Luque: every breakpoint has its own walk
{
	var n = 12;
	var amps = { Dbrown(-0.8, 0.8, 0.05) } ! n;
	var durs = { Dbrown(4, 40, 2) } ! n;
	DemandEnvGen.ar(
		Dswitch1(amps, Dseq((0..n - 1), inf)),
		Dswitch1(durs, Dseq((0..n - 1), inf)) * SampleDur.ir
	) * 0.2 ! 2
}.play
)

( // the breakpoints visited in random order: the cycle is gone
{
	var n = 12;
	var amps = { Dbrown(-0.8, 0.8, 0.05) } ! n;
	var durs = { Dbrown(4, 40, 2) } ! n;
	DemandEnvGen.ar(
		Dswitch1(amps, Drand((0..n - 1), inf)),
		Dswitch1(durs, Drand((0..n - 1), inf)) * SampleDur.ir
	) * 0.2 ! 2
}.play
)


/////////////////////// Streams and fold2 //////////////////////

( // three levels, folded by a sine; the mouse sets the sine's frequency
{
	var sd = SampleDur.ir, min = 0.1, max = 0.3, from = 9, to = 12;
	HPF.ar(
		DemandEnvGen.ar(
			Dseq([min, min.neg, [max.neg, max]], inf),
			sd * Dseq([from, to, Dbrown(from, to, to, from.neg, from)], inf)
		).fold2(SinOsc.ar(MouseX.kr(0.1, 80, \exponential))),
	40) * 0.2
}.play
)


////////////////////// Buffers on demand ///////////////////////

~table = Buffer.loadCollection(s, Array.fill(64, { 1.0.rand2 }));

( // read in order, four samples a cell: one cycle is 256 samples
{
	var levels = Dbufrd(~table, Dseq((0..63), inf));
	DemandEnvGen.ar(levels, SampleDur.ir * 4) * 0.2 ! 2
}.play
)

( // read along a random walk through the cells
{
	var levels = Dbufrd(~table, Dibrown(0, 63, 3));
	DemandEnvGen.ar(levels, SampleDur.ir * 4) * 0.2 ! 2
}.play
)

( // write a walk into a random cell twenty times a second, while reading
{
	var levels = Dbufrd(~table, Dseq((0..63), inf));
	Demand.kr(Impulse.kr(20), 0, Dbufwr(Dbrown(-1, 1, 0.2), ~table, Diwhite(0, 63)));
	DemandEnvGen.ar(levels, SampleDur.ir * 4) * 0.2 ! 2
}.play
)


///////////////////// Binary operations ////////////////////////

// fold a sine by a slow sine
{ SinOsc.ar(200).fold2(SinOsc.ar(5)) * 0.1 ! 2 }.play

// wrap a sine by noise
{ SinOsc.ar(150).wrap2(LFNoise1.ar(3)) * 0.3 ! 2 }.play

// the fold level on the mouse: lower is brighter
{ SinOsc.ar(200).fold2(MouseX.kr(0.05, 1)) * 0.3 ! 2 }.play

// threshold a sine wave with respect to another
{ SinOsc.ar(100).thresh(SinOsc.ar()) * 0.3 ! 2 }.play

// white noise pulses
{ WhiteNoise.ar(0.4).amclip(SinOsc.ar(100)) ! 2 }.play

// ring modulation only where LFNoise2 is negative
{ LFNoise2.ar(400).scaleneg(LFSaw.ar(1000)) * 0.3 ! 2 }.play

// compare a sine with white noise to get a rectangular wave
{ LeakDC.ar(SinOsc.ar(1000) < WhiteNoise.ar()) * 0.2 ! 2 }.play


/////////////////////////// Gendy //////////////////////////////

{ Gendy1.ar(ampdist: 10, ddparam: 0.001, minfreq: 200) * 0.2 ! 2 }.play

{ Gendy3.ar(freq: 60, durscale: 0.1) * 0.2 ! 2 }.play

( // Gendy2 as the excitation of a bank of resonators
{
	var specs = `[[142, 182, 1224, 1448, 2400], [1, 0.5, 0.2, 0.4, 0.2] * 0.01];
	Klank.ar(specs, Gendy2.ar) * 0.3 ! 2
}.play
)


/////////////////////////// Shapes /////////////////////////////

( // a random envelope, looped at audio rate; timeScale sets the pitch
{
	var points = 512, freq = 100 * SinOsc.kr(0.1, mul: 0.4, add: 0.5);
	var levels = Array.fill(points, { rrand(-1.0, 1.0) });
	var times = Array.fill(points, { 1.0.rand }).normalizeSum;
	EnvGen.ar(Env(levels, times).circle, timeScale: freq.reciprocal) * 0.2 ! 2
}.play
)

( // a buffer filled by a rule and read with Osc
var rule = { |i| if(i % 8 == 0, { 0.1.rand }, { 0.8.rand }) };
var wavetable = Signal.fill(8192, rule).asWavetable;
var buffer = Buffer.loadCollection(s, wavetable, 1, {
	{ Osc.ar(buffer, 1, mul: 0.3) ! 2 }.play
});
)


///////////////////// Morphing wavetables //////////////////////

( // eight tables in consecutive buffers, each with one more harmonic
~wt = Buffer.allocConsecutive(8, s, 2048);
~wt.do { |b, i| b.sine1(Array.fill(i + 1, { |h| 1 / (h + 1) })) };
)

// one table, read by Osc
{ Osc.ar(~wt[7], 110) * 0.2 ! 2 }.play

// VOsc reads between tables: the mouse moves from a sine to a saw
{ VOsc.ar(~wt[0].bufnum + MouseX.kr(0, 6.99), 110) * 0.2 ! 2 }.play

// swept slowly, so the morph is the sound
{ VOsc.ar(~wt[0].bufnum + SinOsc.kr(0.1).range(0, 6.99), 110) * 0.2 ! 2 }.play

( // the index at audio rate: the waveform moves as fast as it repeats
{
	var index = SinOsc.ar(MouseY.kr(1, 200, \exponential)).range(0, 6.99);
	VOsc.ar(~wt[0].bufnum + index, 110) * 0.2 ! 2
}.play
)

( // VOsc3: three detuned oscillators over the same morph
{
	var index = LFNoise1.kr(0.3).range(0, 6.99);
	VOsc3.ar(~wt[0].bufnum + index, 110, 110.5, 109.6) * 0.1 ! 2
}.play
)

( // four layers, each drifting through the tables at its own rate
{
	Splay.ar(4.collect { |i|
		var index = LFNoise1.kr(0.1 * (i + 1)).range(0, 6.99);
		VOsc.ar(~wt[0].bufnum + index, 55 * (i + 1))
	}) * 0.15
}.play
)

( // the index as a stream: one step through the tables every quarter second
{
	var index = DemandEnvGen.kr(Dbrown(0, 6.99, 1), 0.25);
	VOsc.ar(~wt[0].bufnum + index, 110) * 0.2 ! 2
}.play
)

// rewrite the tables while something plays: random partials this time
~wt.do { |b| b.sine1(Array.rand(12, 0.0, 1.0)) };

( // or write each table by hand: a cubic bent by a sine that grows per table
~wt.do { |b, i|
	b.loadCollection(Signal.newFrom(1024.collect { |j|
		var x = j / 1023 * 2 - 1;
		(x.cubed * 0.7) + (0.3 * (x * (i + 1) * pi).sin)
	}).asWavetable)
};
)


///////////////////////// DynGen ///////////////////////////////

/* Needs SuperCollider 3.14 and the DynGen extension. The code in quotes
   is EEL2, run once per sample. */

( // a value walks and turns around at a barrier: a triangle, never named
DynGenDef(\instr, "
@init
dir = 1;
@sample
val += dir * _step;
val >= _barrier ? (val = _barrier; dir = -1);
val <= -_barrier ? (val = -_barrier; dir = 1);
out0 = val;
").send;
)

( // a smaller barrier is a higher pitch, because the walk turns sooner
{
	var barrier = MouseX.kr(0.02, 1.0);
	DynGen.ar(1, \instr, params: [step: 0.01, barrier: barrier]) * 0.2 ! 2
}.play
)

CmdPeriod.run
