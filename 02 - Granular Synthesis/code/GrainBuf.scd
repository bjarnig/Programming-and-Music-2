////////////////////////////////////////////////////////////////
//
//                            GrainBuf
//
////////////////////////////////////////////////////////////////


s.boot


///////////////////////////// Setup ////////////////////////////

(

~path = (PathName(thisProcess.nowExecutingPath)).pathOnly ++ "samples/";
~voice = Buffer.read(s, ~path ++ "vocal.wav");
~bikecat = Buffer.read(s, ~path ++ "bikecat.wav");

)


// GrainBuf.ar(numChannels, trigger, dur, sndbuf, rate, pos,
//             interp, pan, envbufnum, maxGrains, mul, add)


/////////////////////// One grain at a time ////////////////////

// a single grain, fired by hand. Nothing else.
(
{ GrainBuf.ar(2, Impulse.kr(0.8), 0.08, ~voice.bufnum, 1, 0.3) * 0.6 }.play
)

// same grains, made longer and then shorter. 
(
	{ GrainBuf.ar(2, Impulse.kr(2), MouseX.kr(0.001, 0.2, \exponential),
	~voice.bufnum, 1, 0.3) * 0.6 }.play
)

CmdPeriod.run


////////////////// Polled once, at grain birth /////////////////

// pos sweeps continuously, but each grain reads it once. 

(
{ GrainBuf.ar(2, Impulse.kr(2), 0.4, ~voice.bufnum, 1, Line.kr(0, 1, 4)) * 0.6 }.play
)

// the same sweep with short grains and a high rate sounds continuous,

(
{ GrainBuf.ar(2, Impulse.kr(60), 0.05, ~voice.bufnum, 1, Line.kr(0, 1, 4)) * 0.3 }.play
)

CmdPeriod.run


/////////////////// Where the pointer goes /////////////////////

/* pos is a fraction of the buffer, 0 to 1. */

// forward, slower than real time: a time stretch
(
{ GrainBuf.ar(2, Impulse.kr(40), 0.08, ~voice.bufnum, 1, Line.kr(0, 1, 20)) * 0.4 }.play
)

// frozen: one point in the buffer, read over and over
(
{ GrainBuf.ar(2, Impulse.kr(40), 0.08, ~voice.bufnum, 1, MouseX.kr(0, 1)) * 0.4 }.play
)

// reversed: the pointer walks backwards while every grain still plays forwards
(
{ GrainBuf.ar(2, Impulse.kr(40), 0.08, ~voice.bufnum, 1, Line.kr(1, 0, 12)) * 0.4 }.play
)

// scattered: a new random point for every grain
(
{
	var trig = Impulse.kr(40);
	GrainBuf.ar(2, trig, 0.08, ~voice.bufnum, 1, TRand.kr(0, 1, trig)) * 0.4
}.play
)

// scattered, but within a window that drifts: Roads' statistical evolution
(
{
	var trig = Impulse.kr(40);
	var centre = Line.kr(0, 1, 20);
	GrainBuf.ar(2, trig, 0.08, ~voice.bufnum, 1,
		(centre + TRand.kr(-0.03, 0.03, trig)).clip(0, 1)) * 0.4
}.play
)

CmdPeriod.run


////////////////////////// Grain Rate /////////////////////////


// pitch up an octave, time unchanged
(
{ GrainBuf.ar(2, Impulse.kr(40), 0.08, ~voice.bufnum, 2, Line.kr(0, 1, 8)) * 0.4 }.play
)

// pitch down, time unchanged
(
{ GrainBuf.ar(2, Impulse.kr(40), 0.08, ~voice.bufnum, 0.5, Line.kr(0, 1, 8)) * 0.4 }.play
)

// a different transposition for every grain
(
{
	var trig = Impulse.kr(40);
	GrainBuf.ar(2, trig, 0.08, ~voice.bufnum,
		TChoose.kr(trig, [0.5, 1, 1.5, 2]), Line.kr(0, 1, 12)) * 0.4
}.play
)

CmdPeriod.run


////////////////////////// Fill factor /////////////////////////

// fill factor = density x grain duration.

// sparse: 10 grains a second, 20 ms each. FF = 0.2
{ GrainBuf.ar(2, Impulse.kr(10), 0.02, ~bikecat.bufnum, 1, LFNoise1.kr(0.3).range(0, 1)) * 0.5 }.play

// covered: 50 a second, 20 ms each. FF = 1.0
{ GrainBuf.ar(2, Impulse.kr(50), 0.02, ~bikecat.bufnum, 1, LFNoise1.kr(0.3).range(0, 1)) * 0.4 }.play

// packed: 100 a second, 20 ms each. FF = 2.0, and the holes are gone
{ GrainBuf.ar(2, Impulse.kr(100), 0.02, ~bikecat.bufnum, 1, LFNoise1.kr(0.3).range(0, 1)) * 0.3 }.play

// sweep the density through all three and listen for where it closes up
(
{ GrainBuf.ar(2, Impulse.kr(XLine.kr(4, 200, 15)), 0.02, ~bikecat.bufnum, 1,
	LFNoise1.kr(0.3).range(0, 1)) * 0.3 }.play
)

CmdPeriod.run


//////////////////////// The envelope //////////////////////////

(
~rect = Buffer.sendCollection(s, Signal.rectWindow(1024), 1);
~hann = Buffer.sendCollection(s, Signal.hanningWindow(1024), 1);
~perc = Buffer.sendCollection(s, Env([1, 0.001], [1], \exp).discretize(1024), 1);
)

// the default Hann
{ GrainBuf.ar(2, Impulse.kr(18), 0.06, ~voice.bufnum, 1, LFNoise1.kr(0.2).range(0, 1), 2, 0, -1) * 0.5 }.play

// rectangular: the same grains, now with a click at each edge
{ GrainBuf.ar(2, Impulse.kr(18), 0.06, ~voice.bufnum, 1, LFNoise1.kr(0.2).range(0, 1), 2, 0, ~rect.bufnum) * 0.4 }.play

// exponential decay: each grain now has a direction
{ GrainBuf.ar(2, Impulse.kr(18), 0.06, ~voice.bufnum, 1, LFNoise1.kr(0.2).range(0, 1), 2, 0, ~perc.bufnum) * 0.5 }.play

CmdPeriod.run


/////////////////////// Combined Arguments /////////////////////

(
{
	var trig = Dust.kr(LFNoise1.kr(0.1).range(15, 90));
	GrainBuf.ar(2, trig,
		TExpRand.kr(0.02, 0.14, trig),          // dur
		~bikecat.bufnum,
		TChoose.kr(trig, [0.5, 1, 1, 1.5, 2]),  // rate
		(LFNoise1.kr(0.15).range(0, 1) + TRand.kr(-0.05, 0.05, trig)).clip(0, 1),
		2,
		TRand.kr(-1, 1, trig),                  // pan
		-1
	) * 0.35
}.play
)

CmdPeriod.run
