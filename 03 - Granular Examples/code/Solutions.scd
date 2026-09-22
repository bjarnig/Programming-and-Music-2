////////////////////////////////////////////////////////////////
//
//               Exercises, worked solutions
//
////////////////////////////////////////////////////////////////

One answer each, not the only answer. Run the setup block first.
Cmd+period stops everything.

s.boot;


//////////////////////////// Setup /////////////////////////////

(
~path = (PathName(thisProcess.nowExecutingPath)).pathOnly ++ "samples/";
~voice   = Buffer.read(s, ~path ++ "vocal.wav");
~bikecat = Buffer.read(s, ~path ++ "bikecat.wav");
~hydro   = Buffer.read(s, ~path ++ "hydro.wav");

{
	~pSine = Buffer.alloc(s, 2048, 1); s.sync;
	~pSine.sine1([1.0], asWavetable: false);
	~pRand = Buffer.sendCollection(s, Signal.sineFill(2048, { 1.0.rand }.dup(10)), 1);
	~pOdd  = Buffer.sendCollection(s, Signal.sineFill(2048,
		Array.fill(20, { |i| if (i.even) { 0 } { 1 / (i + 1).squared } })), 1);

	~envPerc = Buffer.sendCollection(s, Env.perc.discretize, 1);
	~envSine = Buffer.sendCollection(s, Env([0, 1, 0], [0.5, 0.5], \sine).discretize, 1);
	~envRect = Buffer.sendCollection(s, Env([1, 1], [1]).discretize, 1);
	s.sync;
	"buffers ready".postln;
}.fork;

SynthDef(\gliss, { |buf = 0, start = 0, amp = 0.5, dur = 0.3, pan = 0, from = 0.5, to = 4.0|
	var env = EnvGen.ar(Env([0, amp, 0], [dur*0.5, dur*0.5], \sine), doneAction: 2);
	var pos = start * BufFrames.ir(buf);
	var sig = PlayBuf.ar(1, buf, Line.ar(from, to, dur) * BufRateScale.ir(buf), 1, pos, 0);
	OffsetOut.ar(0, Pan2.ar(sig * env, pan));
}).add;

SynthDef(\trainlet, { |amp = 1.0, dur = 0.3, pan = 0, density = 20, harmonics = 10|
	var env = EnvGen.ar(Env.perc(dur*0.2, dur*0.8), doneAction: 2);
	OffsetOut.ar(0, Pan2.ar(Blip.ar(density, harmonics) * env, pan, amp));
}).add;

// 3: the trainlet with a sampled grain mixed into it
SynthDef(\trainletBuf, { |buf = 0, amp = 1.0, dur = 0.3, pan = 0, density = 20,
	harmonics = 10, start = 0, rate = 1, mix = 0.5|
	var env = EnvGen.ar(Env.perc(dur*0.2, dur*0.8), doneAction: 2);
	var pulse = Blip.ar(density, harmonics);
	var samp = PlayBuf.ar(1, buf, rate * BufRateScale.ir(buf), 1,
		start * BufFrames.ir(buf), 0);
	OffsetOut.ar(0, Pan2.ar(XFade2.ar(pulse, samp, mix * 2 - 1) * env, pan, amp));
}).add;

SynthDef(\pulsar, { |fund = 10, form = 100, amp = 1.0, wavebuf, envbuf, pan = 0|
	var trig = Impulse.ar(fund);
	Out.ar(0, GrainBuf.ar(2, trig, form.reciprocal, wavebuf,
		form * BufDur.kr(wavebuf), 0, 4, pan, envbuf, mul: amp));
}).add;

// 8: one grain, and every property of it is an argument
SynthDef(\grainbp, { |buf = 0, start = 0, dur = 0.08, rate = 1, amp = 0.2,
	pan = 0, cutoff = 1000, rq = 0.4, curve = 0|
	var env = EnvGen.ar(Env([0, amp, 0], [dur*0.5, dur*0.5], curve), doneAction: 2);
	var sig = PlayBuf.ar(1, buf, rate * BufRateScale.ir(buf), 1,
		start * BufFrames.ir(buf), 0);
	sig = BPF.ar(sig, cutoff, rq) * 2;
	OffsetOut.ar(0, Pan2.ar(sig * env, pan));
}).add;

// 12: the mask is an argument, so any rule can drive it
SynthDef(\pulsarMask, { |wavebuf, envbuf, fund = 20, form = 400, amp = 0.3,
	pan = 0, gate = 1|
	var trig = Impulse.ar(fund) * gate;
	Out.ar(0, LeakDC.ar(GrainBuf.ar(2, trig, form.reciprocal, wavebuf,
		form * BufDur.kr(wavebuf), 0, 4, pan, envbuf, 512, amp)));
}).add;

// 13: the resonator set and the exciting train are separate arguments
SynthDef(\pulsarKlank, { |wavebuf, envbuf, fund = 30, form = 2000, amp = 0.3,
	decay = 1, mix = 0.85, pan = 0|
	var trig = Impulse.ar(fund);
	var sig = GrainBuf.ar(2, trig, form.reciprocal, wavebuf,
		form * BufDur.kr(wavebuf), 0, 4, pan, envbuf, 512, amp);
	var res = DynKlank.ar(`[\freqs.kr(#[110, 164, 247, 371, 556, 833]), nil,
		\decays.kr(#[1, 1, 1, 1, 1, 1]) * decay], sig);
	Out.ar(0, LeakDC.ar(XFade2.ar(sig, res * 0.1, mix * 2 - 1)));
}).add;

SynthDef(\source, { |out = 0, buf = 0| Out.ar(out, PlayBuf.ar(1, buf, loop: 1)) }).add;

SynthDef(\writer, { |in = 0, out = 0, buf = 0|
	var pos = Phasor.ar(0, 1, 0, BufFrames.kr(buf));
	BufWr.ar(In.ar(in, 1), buf, pos);
	Out.ar(out, pos);
}).add;

// 10: delay is a bus, not a number, so it can be moved while it runs
SynthDef(\readerMoving, { |buf, in, rate = 1, dur = 0.4, delay = 0.1,
	sweep = 0.08, sweepRate = 0.07, amp = 0.5|
	var pos = In.ar(in) / BufFrames.kr(buf);
	var moving = delay + LFDNoise3.ar(sweepRate, sweep);
	var sig = GrainBuf.ar(2, Impulse.ar(20), dur, buf, rate,
		(pos - moving).wrap(0, 1)) * amp;
	Out.ar(0, sig);
}).add;
)


///////////////////////////// 1 ////////////////////////////////
// glissandi that fall further as the cloud goes on

(
var dur = 0.02, overlap = 2.0, sample = ~voice;
Routine {
	var total = sample.numFrames / sample.sampleRate;
	var times = ((total / dur) * overlap).asInteger;
	times.do { |i|
		var start = (i * (dur / overlap)) / total;
		s.makeBundle(0.1, {
			Synth(\gliss, [\buf, sample.bufnum, \dur, dur, \start, start, \amp, 0.4,
				\from, 1.0,
				\to, i.linlin(0, times, 0.9, 0.1)]);
		});
		(dur / overlap).wait;
	};
}.play;
)


///////////////////////////// 2 ////////////////////////////////
// three layers, each with its own pulsaret, envelope and fundamental

(
var layers = [
	[~pSine, ~envPerc, 13, 300, -0.7],
	[~pRand, ~envSine, 21, 700, 0.0],
	[~pOdd,  ~envRect, 34, 1300, 0.7]
];
layers.do { |spec|
	Synth(\pulsar, [\wavebuf, spec[0], \envbuf, spec[1], \fund, spec[2],
		\form, spec[3], \pan, spec[4], \amp, 0.3 / layers.size]);
};
)

s.freeAll;


///////////////////////////// 3 ////////////////////////////////
// the trainlet cloud, with each trainlet crossfaded towards a sampled grain

(
var dur = 0.05, overlap = 2.0, times = 400, sample = ~bikecat;
Routine {
	times.do { |i|
		s.makeBundle(0.1, {
			Synth(\trainletBuf, [\buf, sample.bufnum, \dur, dur, \amp, 0.5,
				\density, rrand(4, 40), \harmonics, 400,
				\start, 1.0.rand, \rate, rrand(0.5, 2.0),
				\mix, i.linlin(0, times, 0.0, 1.0),
				\pan, 1.0.rand2]);
		});
		(dur / overlap).wait;
	};
}.play;
)


///////////////////////////// 4 ////////////////////////////////
// the same cloud as a function: ask for a duration, get a cloud of that length

(
~cloud = { |length = 4, dur = 0.03, overlap = 3.0, sample, from = 1.0, to = 0.4|
	Routine {
		var n = ((length / dur) * overlap).asInteger;
		n.do { |i|
			s.makeBundle(0.1, {
				Synth(\gliss, [\buf, sample.bufnum, \dur, dur, \amp, 0.3,
					\start, 1.0.rand,
					\from, from, \to, i.linlin(0, n, from, to),
					\pan, 1.0.rand2]);
			});
			(dur / overlap).wait;
		};
	}.play;
};
)

~cloud.(2, sample: ~voice);
~cloud.(8, dur: 0.08, sample: ~bikecat, to: 2.0);


///////////////////////////// 5 ////////////////////////////////
// dense to sparse, two voices, two channels each from multichannel expansion

(
{
	var dens = XLine.kr(200, 4, 12);
	var a = GrainBuf.ar(2, Impulse.ar(dens), 0.04, ~voice.bufnum,
		LFNoise1.kr(0.3).range(0.8, 1.3), LFNoise1.kr(0.1).range(0, 1),
		2, [-0.6, 0.6]);
	var b = GrainBuf.ar(2, Impulse.ar(dens * 0.6), 0.12, ~bikecat.bufnum,
		LFNoise1.kr(0.2).range(0.4, 0.9), LFNoise1.kr(0.07).range(0, 1),
		2, [0.8, -0.8]);
	Mix(a + b) * 0.25 / 2;
}.play;
)


///////////////////////////// 6 ////////////////////////////////
// position and rate driven at audio rate, reading from two buffers

(
{
	var move = SinOsc.ar(0.07).range(0, 1);
	var jitter = LFDNoise3.ar(30, 0.01);
	var rate = SinOsc.ar(0.11).range(0.7, 1.6);
	var a = GrainBuf.ar(2, Impulse.ar(60), 0.06, ~voice.bufnum,   rate, move + jitter, 2, -0.4);
	var b = GrainBuf.ar(2, Impulse.ar(45), 0.09, ~hydro.bufnum, 2 - rate, 1 - move + jitter, 2, 0.4);
	(a + b) * 0.3;
}.play;
)


///////////////////////////// 7 ////////////////////////////////
// two knobs only

(
~coupled = { |density = 0.5, brightness = 0.5|
	{
		var dens = density.linexp(0, 1, 6, 200);
		var dur  = density.linexp(0, 1, 0.25, 0.02);
		var rate = brightness.linexp(0, 1, 0.4, 2.5);
		var spread = density.linlin(0, 1, 0.1, 0.9);
		var amp = 0.4 / sqrt(dens * dur);
		GrainBuf.ar(2, Impulse.ar(dens), dur, ~voice.bufnum, rate,
			LFNoise1.kr(0.2).range(0, 1), 2,
			LFNoise1.kr(3).range(spread.neg, spread)) * amp;
	}.play;
};
)

~coupled.(0.2, 0.2);

s.freeAll;

~coupled.(0.9, 0.8);

s.freeAll;


///////////////////////////// 8 ////////////////////////////////
// every grain gets its own filter, envelope curve, speed and position

(
var dur = 0.09, overlap = 4.0, times = 500, sample = ~bikecat;
Routine {
	times.do { |i|
		s.makeBundle(0.1, {
			Synth(\grainbp, [\buf, sample.bufnum, \dur, dur,
				\start, 1.0.rand,
				\rate, [0.5, 1, 1.5, 2].choose,
				\cutoff, exprand(200, 4000),
				\rq, rrand(0.1, 0.8),
				\curve, rrand(-4.0, 4.0),
				\pan, 1.0.rand2,
				\amp, 0.35 / sqrt(overlap)]);
		});
		(dur / overlap).wait;
	};
}.play;
)


///////////////////////////// 9 ////////////////////////////////
// exercise 8 as a Pbind: the cutoff follows the rate, so fast grains are bright

(
Pbind(
	\instrument, \grainbp,
	\buf, ~bikecat.bufnum,
	\dur, 0.09,
	\delta, 0.09 / 4,
	\start, Pwhite(0.0, 1.0),
	\rate, Pexprand(0.5, 2.5),
	\cutoff, Pkey(\rate) * 1200,
	\rq, Pwhite(0.1, 0.8),
	\pan, Pwhite(-1.0, 1.0),
	\amp, 0.35 / sqrt(4)
).play;
)


//////////////////////////// 10 ////////////////////////////////
// the read head drifts behind the write head instead of trailing it by a fixed gap

(

Routine {
	~rec = Buffer.alloc(s, s.sampleRate * 2, 1); s.sync;
	~posbus = Bus.audio(s, 1);
	~src = Synth(\source, [\buf, ~voice.bufnum, \out, 20]);
	~wr  = Synth.after(~src, \writer, [\in, 20, \out, ~posbus.index, \buf, ~rec.bufnum]);
	~rd  = Synth.after(~wr, \readerMoving, [\buf, ~rec.bufnum, \in, ~posbus.index,
		\dur, 0.35, \delay, 0.12, \sweep, 0.09, \sweepRate, 0.06, \amp, 0.5]);
}.play;

)

(

[~rd, ~wr, ~src].do(_.free);
~posbus.free; ~rec.free;

)


//////////////////////////// 11 ////////////////////////////////
// one cloud replaced by another while it sounds

(
Pdef(\cloud, Pbind(
	\instrument, \grainbp, \buf, ~voice.bufnum,
	\dur, 0.1, \delta, 0.035,
	\start, Pwhite(0.0, 0.4), \rate, 1, \cutoff, 800, \rq, 0.6, \amp, 0.15
)).quant_(4).play;
)

// evaluate while the first one is still sounding
(
Pdef(\cloud, Pbind(
	\instrument, \grainbp, \buf, ~bikecat.bufnum,
	\dur, 0.04, \delta, 0.012,
	\start, Pwhite(0.4, 1.0), \rate, 2, \cutoff, 2600, \rq, 0.3, \amp, 0.1
));
)

Pdef(\cloud).stop;


//////////////////////////// 12 ////////////////////////////////
// a sieve: keep a pulse when its index divides by 3 or by 5

(
~sieve = (0 .. 119).collect { |i| ((i % 3 == 0) or: { i % 5 == 0 }).binaryValue };
Pdef(\sieved, Pbind(
	\instrument, \pulsarMask,
	\wavebuf, ~pRand, \envbuf, ~envPerc,
	\fund, 20, \form, Pseq([400, 500, 650], inf),
	\gate, Pseq(~sieve, inf),
	\amp, 0.3, \pan, Pwhite(-0.6, 0.6),
	\dur, 0.08
)).play;
)

Pdef(\sieved).stop;

// the other kind: the mask is the amplitude of another signal

(
{
	var driver = PlayBuf.ar(1, ~voice.bufnum, loop: 1);
	var gate = (Amplitude.ar(driver, 0.01, 0.1) > 0.02);
	var trig = Impulse.ar(30) * gate;
	LeakDC.ar(GrainBuf.ar(2, trig, 1/400, ~pOdd, 400 * BufDur.kr(~pOdd),
		0, 4, 0, ~envPerc, 512, 0.3));
}.play;
)

s.freeAll;


//////////////////////////// 13 ////////////////////////////////
// the set of resonators and the rhythm that strikes them

(
~set = [
	[110, 164, 247, 371, 556, 833],          // fifths
	[100, 200, 300, 400, 500, 600],          // harmonic
	[110, 155, 233, 311, 466, 622]           // tritones
];

// the rhythm, written apart from the set. amp travels with the rate, because
// the faster the train strikes the more the resonators accumulate.
~fundSeq = Pseq([Pn(3, 2), Pn(11, 4), Pn(28, 8)], inf);
~durSeq  = Pseq([Pn(1, 2), Pn(0.5, 4), Pn(0.25, 8)], inf);
~ampSeq  = Pseq([Pn(0.015, 2), Pn(0.005, 4), Pn(0.002, 8)], inf);
)

(
Pdef(\struck, Pbind(
	\instrument, \pulsarKlank,
	\wavebuf, ~pRand, \envbuf, ~envPerc,
	\form, 1800, \mix, 0.85,
	\freqs, Pseq(~set, inf),
	\decays, Pfunc { { rrand(0.2, 0.7) } ! 6 },
	\fund, ~fundSeq,
	\dur,  ~durSeq,
	\amp,  ~ampSeq,
	\pan, Pwhite(-0.5, 0.5)
)).play;
)

// change either one on its own: a different set over the same rhythm,
// or the same set over a different rhythm
Pdef(\struck).stop;
