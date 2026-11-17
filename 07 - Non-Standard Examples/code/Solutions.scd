////////////////////////////////////////////////////////////////
//
//              Non-Standard Examples: Solutions
//
////////////////////////////////////////////////////////////////

s.boot

~voice = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");


// 1. the saw falls: start at 1 and step down
(
{
	var levels = Dseq([Dseries(1.0, -0.02, 100)], inf);
	DemandEnvGen.ar(levels, SampleDur.ir * 5) * 0.2 ! 2
}.play
)


// 2. at 220 Hz one cycle is 44100 / 220 = 200.45 samples, so 100 steps of
//    2 samples each give 200 samples, which is 220.5 Hz
(
{
	var levels = Dseq([Dseries(-1.0, 0.02, 100)], inf);
	DemandEnvGen.ar(levels, SampleDur.ir * 2) * 0.2 ! 2
}.play
)


// 3. five levels of my own instead of a series
(
{
	var levels = Dseq([-1, 0.5, -0.2, 0.8, 0.1], inf);
	DemandEnvGen.ar(levels, SampleDur.ir * 20) * 0.2 ! 2
}.play
)


// 4. the triangle with random durations
(
{
	var levels = Dseq([Dseries(-1, 0.04, 50), Dseries(1, -0.04, 50)], inf);
	DemandEnvGen.ar(levels, Dwhite(2, 8) * SampleDur.ir) * 0.2 ! 2
}.play
)


// 5. Dswitch between two waveforms: a staircase and a random cycle
(
{
	var steps = Ddup(10, Dseq([-1, -0.5, 0, 0.5, 1]));
	var noise = Dwhite(-1, 1, 40);
	var levels = Dswitch([steps, noise], Dseq([0, 0, 1], inf));
	DemandEnvGen.ar(levels, SampleDur.ir * 4) * 0.2 ! 2
}.play
)


// 6. the random-duration triangle folded by a slow sine
(
{
	var levels = Dseq([Dseries(-1, 0.04, 50), Dseries(1, -0.04, 50)], inf);
	var sig = DemandEnvGen.ar(levels, Dwhite(2, 8) * SampleDur.ir);
	sig.fold2(SinOsc.ar(0.3).range(0.1, 1)) * 0.3 ! 2
}.play
)


// 7. eight tables of random partials, morphed with the mouse
(
~wt = Buffer.allocConsecutive(8, s, 2048);
~wt.do { |b| b.sine1(Array.rand(12, 0.0, 1.0)) };
)

{ VOsc.ar(~wt[0].bufnum + MouseX.kr(0, 6.99), 110) * 0.2 ! 2 }.play


// 8. the index as a Dbrown stream, interpolated over a tenth of a second
(
{
	var index = DemandEnvGen.kr(Dbrown(0, 6.99, 0.5), 0.1);
	VOsc.ar(~wt[0].bufnum + index, 110) * 0.2 ! 2
}.play
)


// 9. a major triad: root, major third and fifth
(
{
	var index = LFNoise1.kr(0.2).range(0, 6.99);
	VOsc3.ar(~wt[0].bufnum + index, 220, 220 * 5/4, 220 * 3/2) * 0.1 ! 2
}.play
)


// 10. a demand-rate waveform in a SynthDef, played as notes
(
SynthDef(\dwave, { |freq = 220, amp = 0.2, dur = 0.5, pan = 0|
	var levels = Dseq([Dseries(-1, 0.04, 50), Dseries(1, -0.04, 50)], inf);
	var sig = DemandEnvGen.ar(levels, 1 / (freq * 100));
	var env = EnvGen.ar(Env.perc(0.01, dur), doneAction: 2);
	OffsetOut.ar(0, Pan2.ar(sig * env * amp, pan));
}).add;
)

Pbind(\instrument, \dwave, \freq, Pseq([220, 330, 275, 440], inf), \dur, 0.25, \pan, Pwhite(-0.5, 0.5)).play


// 11. one set of levels used twice: in samples as the waveform,
//     in seconds as an envelope on its frequency
(
{
	var shape = [-1, 1, -0.3, 0.6];
	var freq = DemandEnvGen.kr(Dseq(shape, inf), 0.5).linexp(-1, 1, 100, 800);
	DemandEnvGen.ar(Dseq(shape, inf), 1 / (freq * 4)) * 0.2 ! 2
}.play
)


// 12. two layers, each with its points from Dbrown and Dbrown2
(
{
	var a = DemandEnvGen.ar(Dbrown(-0.8, 0.8, 0.1), Dbrown(5, 30, 2) * SampleDur.ir);
	var b = DemandEnvGen.ar(Dbrown2(-0.8, 0.8, 0.05, 0, inf), Dbrown2(10, 60, 4, 0, inf) * SampleDur.ir);
	[a, b] * 0.2
}.play
)


// 13. a varying triangle: linear segments between -1 and 1,
//     with a new length and height on every segment
(
{
	var levels = Dseq([-1, 1], inf) * Dwhite(0.5, 1);
	var durations = Dbrown(20, 120, 10) * SampleDur.ir;
	DemandEnvGen.ar(levels, durations) * 0.2 ! 2
}.play
)


// 14. the sound split in two: folded below 400 Hz, thresholded and clipped above
(
{
	var src = PlayBuf.ar(1, ~voice, BufRateScale.kr(~voice), loop: 1);
	var low = LPF.ar(src, 400).fold2(SinOsc.ar(3).range(0.05, 0.3));
	var high = HPF.ar(src, 400).thresh(0.05).amclip(LFSaw.ar(80));
	(low + high) * 0.5 ! 2
}.play
)

CmdPeriod.run
