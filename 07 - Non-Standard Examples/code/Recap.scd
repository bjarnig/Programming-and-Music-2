////////////////////////////////////////////////////////////////
//
//                     Recap of Block 1
//
////////////////////////////////////////////////////////////////

/* Granular, glisson, trainlet, grainlet, pulsar, waveshaping, wavesets and CDP, each from scratch. Every block uses the sound that ships with SuperCollider. */

s.boot

~voice = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");


//////////////////////// The grain pointer ///////////////////////

// frozen: one point in the buffer, read over and over
{ GrainBuf.ar(2, Impulse.kr(40), 0.08, ~voice, 1, MouseX.kr(0, 1)) * 0.4 }.play

// scattered: a new random point for every grain
{ var trig = Impulse.kr(40); GrainBuf.ar(2, trig, 0.08, ~voice, 1, TRand.kr(0, 1, trig)) * 0.4 }.play

// scattered within a window that drifts
{ var trig = Impulse.kr(40); GrainBuf.ar(2, trig, 0.08, ~voice, 1, (Line.kr(0, 1, 20) + TRand.kr(-0.03, 0.03, trig)).clip(0, 1)) * 0.4 }.play

// density swept through the fill factor: listen for where it closes up
{ GrainBuf.ar(2, Impulse.kr(XLine.kr(4, 200, 15)), 0.02, ~voice, 1, LFNoise1.kr(0.3).range(0, 1)) * 0.3 }.play


////////////////////// One synth per grain ///////////////////////

(
SynthDef(\grain, { |buf = 0, rate = 1, start = 0, amp = 0.5, dur = 0.3, pan = 0|
	var env = EnvGen.ar(Env([0, amp, 0], [dur * 0.5, dur * 0.5], \sine), doneAction: 2);
	var sig = PlayBuf.ar(1, buf, rate * BufRateScale.ir(buf), 1, start * BufSamples.ir(buf));
	OffsetOut.ar(0, Pan2.ar(sig * env, pan));
}).add;
)

( // reconstruct the sound: grains in order, each starting where it sits in the file
var dur = 0.1, delta = dur / 2;
var n = (~voice.duration / delta).asInteger;
Pbind(\instrument, \grain, \buf, ~voice, \dur, dur, \delta, delta,
	\start, Pseries(0, 1/n, n), \amp, 1).play
)

( // the same grains, with the read position moving eight times slower: a time stretch
var dur = 0.1, delta = dur / 2, stretch = 8;
var n = (~voice.duration / delta * stretch).asInteger;
Pbind(\instrument, \grain, \buf, ~voice, \dur, dur, \delta, delta,
	\start, Pseries(0, 1/n, n), \amp, 1).play
)


/////////////////////////// Glisson //////////////////////////////

(
SynthDef(\gliss, { |buf = 0, start = 0, amp = 0.5, dur = 0.3, pan = 0, from = 0.5, to = 4.0|
	var env = EnvGen.ar(Env([0, amp, 0], [dur * 0.5, dur * 0.5], \sine), doneAction: 2);
	var sig = PlayBuf.ar(1, buf, Line.ar(from, to, dur) * BufRateScale.ir(buf), 1, start * BufFrames.ir(buf));
	OffsetOut.ar(0, Pan2.ar(sig * env, pan));
}).add;
)

( // glissons towards high: each grain sweeps its own pitch, and the sweep widens
var delta = 0.01, n = (~voice.duration / delta).asInteger;
Pbind(\instrument, \gliss, \buf, ~voice, \dur, 0.02, \delta, delta,
	\start, Pseries(0, 1/n, n),
	\from, Pseries(1.0, 1/n, n), \to, Pseries(2.0, 8/n, n)).play
)

( // converging to the centre: wide sweeps that narrow to none
var delta = 0.01, n = (~voice.duration / delta).asInteger, half = ~voice.duration / 2;
Pbind(\instrument, \gliss, \buf, ~voice, \dur, 0.05, \delta, delta,
	\start, Pseries(0, 1/n, n),
	\from, Pseg([0.1, 1, 1], [half, half]), \to, Pseg([100, 4, 1], [half, half]),
	\amp, 0.3).play
)

( // layers: five streams at once, each with its own range
5.do { |i|
	Pbind(\instrument, \gliss, \buf, ~voice, \dur, 0.1, \delta, 0.05,
		\start, Pwhite(0.0, 1.0), \from, 0.5 * (i + 1), \to, Pwhite(0.1, 4.0),
		\pan, i.linlin(0, 4, -0.8, 0.8), \amp, 0.15).play
};
)


/////////////////////////// Trainlet /////////////////////////////

(
SynthDef(\trainlet, { |amp = 0.3, dur = 0.3, pan = 0, density = 20, harmonics = 10|
	var env = EnvGen.ar(Env.perc(dur * 0.2, dur * 0.8), doneAction: 2);
	OffsetOut.ar(0, Pan2.ar(Blip.ar(density, harmonics) * env, pan, amp));
}).add;
)

Pbind(\instrument, \trainlet, \dur, 0.05, \delta, 0.025, \density, Pexprand(20, 200), \harmonics, 1000, \pan, Pwhite(-1.0, 1.0)).play

// slower trains, fewer harmonics, longer grains
Pbind(\instrument, \trainlet, \dur, 0.4, \delta, 0.1, \density, Pexprand(5, 80), \harmonics, Pwhite(2, 40)).play


/////////////////////////// Grainlet /////////////////////////////

(
SynthDef(\grainlet, { |freq = 440, amp = 0.2, dur = 0.05, pan = 0|
	var env = EnvGen.ar(Env([0, amp, 0], [dur * 0.5, dur * 0.5], \sine), doneAction: 2);
	OffsetOut.ar(0, Pan2.ar(SinOsc.ar(freq) * env, pan));
}).add;
)

// no linkage: frequency and duration chosen independently
Pbind(\instrument, \grainlet, \freq, Pexprand(200, 4000), \dur, Pwhite(0.01, 0.12), \delta, 0.04, \pan, Pwhite(-1.0, 1.0)).play

// duration follows frequency: high grains short, low grains long
Pbind(\instrument, \grainlet, \freq, Pexprand(200, 4000), \dur, Pkey(\freq).explin(200, 4000, 0.12, 0.008), \delta, 0.04, \pan, Pwhite(-1.0, 1.0)).play

// the link reversed: high grains long
Pbind(\instrument, \grainlet, \freq, Pexprand(200, 4000), \dur, Pkey(\freq).explin(200, 4000, 0.008, 0.12), \delta, 0.04, \pan, Pwhite(-1.0, 1.0)).play

// pan follows frequency as well: low on the left, high on the right
Pbind(\instrument, \grainlet, \freq, Pexprand(200, 4000), \dur, Pkey(\freq).explin(200, 4000, 0.12, 0.008), \delta, 0.02, \pan, Pkey(\freq).explin(200, 4000, -1, 1)).play


/////////////////////// Live granulation /////////////////////////

( // Gendy3 written into a buffer and granulated out of it by eight readers
{
	var buf = LocalBuf(s.sampleRate * 3).clear;
	var pos = Phasor.ar(0, 1, 0, BufFrames.ir(buf));
	BufWr.ar(Gendy3.ar(freq: 200) * 0.3, buf, pos);
	Splay.ar(8.collect { |i|
		GrainBuf.ar(1, Impulse.ar(40), (i + 1) * 0.01, buf, rrand(0.25, 2.0),
			(pos / BufFrames.ir(buf) - 0.1).wrap(0, 1))
	}) * 0.3
}.play
)


//////////////////////////// Pulsars /////////////////////////////

( // a pulsaret of ten random partials and a percussive envelope
~pulsaret = Buffer.sendCollection(s, Signal.sineFill(1024, { 1.0.rand }.dup(10)), 1);
~envbuf = Buffer.sendCollection(s, Env.perc.discretize, 1);
)

(
SynthDef(\pulsar, { |fund = 10, form = 100, amp = 0.5, prob = 1, wavebuf, envbuf|
	var trig = CoinGate.ar(prob, Impulse.ar(fund));
	var rate = form * BufDur.kr(wavebuf);
	Out.ar(0, GrainBuf.ar(2, trig, form.reciprocal, wavebuf, rate, 0, 4, 0, envbuf, mul: amp));
}).add;
)

// a basic pulsar train
Synth(\pulsar, [\wavebuf, ~pulsaret, \envbuf, ~envbuf, \fund, 20, \form, 100])

// fundamental on mouse x, formant on mouse y
{ var form = MouseY.kr(50, 2000, \exponential); GrainBuf.ar(2, Impulse.ar(MouseX.kr(1, 200, \exponential)), form.reciprocal, ~pulsaret, form * BufDur.kr(~pulsaret), 0, 4, 0, ~envbuf) * 0.5 }.play

// the formant swept, the fundamental walking
Pmono(\pulsar, \wavebuf, ~pulsaret, \envbuf, ~envbuf, \fund, Pbrown(10, 300, 10), \form, Pbrown(100, 1000, 10), \dur, 0.01).play

// masking: fewer pulses get through as the probability falls
Pmono(\pulsar, \wavebuf, ~pulsaret, \envbuf, ~envbuf, \fund, 60, \form, 600, \prob, Pseq([1.0, 0.8, 0.5, 0.25, 0.1], inf), \dur, 1.5).play

( // the train as an excitation: a chord of resonators struck by sparse pulses
{
	var trig = CoinGate.ar(0.5, Impulse.ar(LFNoise0.kr(1).range(2, 9)));
	var train = GrainBuf.ar(1, trig, 1/400, ~pulsaret, 400 * BufDur.kr(~pulsaret), 0, 4, 0, ~envbuf);
	Splay.ar(Ringz.ar(train, [110, 164, 247, 371, 556, 833], 0.4)) * 0.05
}.play
)


////////////////////////// Waveshaping //////////////////////////

( // a curve written into a buffer, which Shaper indexes with the input
~curve = Buffer.sendCollection(s, Signal.newFrom(1024.collect { |i|
	var x = i.linlin(0, 1023, -1.0, 1.0); ((3 * x) - x.cubed) / 2 }).asWavetableNoWrap, 1);
)

{ Shaper.ar(~curve, SinOsc.ar(180) * Line.kr(0.2, 1.0, 10)) * 0.2 ! 2 }.play

// Chebyshev polynomials: a sine of amplitude 1 mapped onto chosen harmonics
~cheb = Buffer.alloc(s, 1024, 1, { |b| b.chebyMsg([1, 0, 0.4, 0, 0.2]) });

{ Shaper.ar(~cheb, SinOsc.ar(180) * Line.kr(0.05, 1.0, 12)) * 0.2 ! 2 }.play


/////////////////////////// Wavesets ////////////////////////////

// needs the Wavesets quark: Quarks.install("Wavesets"), then recompile
w = Wavesets.from(Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
SynthDef(\waveset, { |out = 0, buf = 0, start = 0, length = 441, playRate = 1, sustain = 1, amp = 0.2, pan|
	var phasor = Phasor.ar(0, BufRateScale.ir(buf) * playRate, 0, length) + start;
	var env = EnvGen.ar(Env([amp, amp, 0], [sustain, 0]), doneAction: 2);
	OffsetOut.ar(out, Pan2.ar(BufRd.ar(1, buf, phasor) * env, pan));
}).add;
)

( // reconstruct the source, one waveset at a time
Pbindef(\ws, \instrument, \waveset, \buf, w.buffer, \amp, 0.4,
	\startWs, Pn(Pseries(0, 1, w.numXings), inf), \numWs, 1, \playRate, 1, \repeats, 1,
	[\start, \length, \sustain], Pfunc { |ev|
		var start, length, wsDur;
		#start, length, wsDur = w.frameFor(ev[\startWs], ev[\numWs]);
		[start, length, wsDur * ev[\repeats] / ev[\playRate].abs]
	},
	\dur, Pkey(\sustain)).play;
)

Pbindef(\ws, \playRate, 0.5, \startWs, Pn(Pseries(0, 4, 1000), inf));             // every fourth, half speed
Pbindef(\ws, \numWs, 2, \playRate, -1, \startWs, Pn(Pseries(0, 10, 1000), inf));  // reversed
Pbindef(\ws, \numWs, 1, \playRate, 1, \repeats, 10, \startWs, Pn(Pseries(0, 1, 1000), inf)); // repeated
Pbindef(\ws, \repeats, 1, \freq, Pfunc { if(0.25.coin, 1, \) });                   // omitted
Pbindef(\ws, \freq, 1, \startWs, Pwhite(0, w.numXings - 1));                       // random
Pbindef(\ws).stop;


////////////////////////////// CDP //////////////////////////////

( // a runner that waits for CDP and returns the output file
~bin = "~/cdpr8/_cdp/_cdprogs/".standardizePath;
~src = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
~out = Platform.defaultTempDir;
~cdp = { |program, input, output, params = ""|
	var words = program.split($ );
	var cmd = (~bin ++ words[0]).quote + words[1..].join(" ") + input.quote + output.quote + params;
	if(File.exists(output)) { File.delete(output) };
	cmd.postln.systemCmd;
	output
};
)

// repeat every group of wavecycles eight times: a time stretch
~stretched = ~cdp.("distort repeat", ~src, ~out +/+ "repeat.wav", "8 -c20");

// divide the wavecycle frequency by four
~divided = ~cdp.("distort divide", ~src, ~out +/+ "divide.wav", "4");

( // a breakpoint file from a pattern: a random walk in the speed
var times = (0..16) * 0.25;
var walk = Pbrown(0.5, 2.0, 0.25, 17).asStream.nextN(17);
var brk = ~out +/+ "walk.brk";
File.use(brk, "w", { |f| [times, walk].flop.do { |p| f.write("% %\n".format(*p)) } });
~walked = ~cdp.("modify speed 1", ~src, ~out +/+ "walk.wav", brk.quote);
)


////////////////////////// Round trip ////////////////////////////

// read what CDP made, and granulate it with the first example of this file
~cdpBuf = Buffer.read(s, ~stretched);

{ var trig = Impulse.kr(40); GrainBuf.ar(2, trig, 0.08, ~cdpBuf, TChoose.kr(trig, [0.5, 1, 2]), (Line.kr(0, 1, 30) + TRand.kr(-0.03, 0.03, trig)).clip(0, 1)) * 0.4 }.play

CmdPeriod.run
