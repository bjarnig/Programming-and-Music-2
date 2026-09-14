////////////////////////////////////////////////////////////////
//
//                 Microsound Examples
//
////////////////////////////////////////////////////////////////



//////////////// 01. Synthetic Granular sounds ////////////////

( // A

SynthDef(\sg, { arg freq=400, amp=0.3, dur=0.3, pan=0, index=10;
	var env, sig;
	env = EnvGen.ar(Env([0, amp, 0], [dur*0.5, dur*0.5], [8,-8]), doneAction: 2);
	sig = SinOsc.ar(freq,0,env);
	sig = Pan2.ar(sig, pan);
	OffsetOut.ar(0, sig);
}).add;

Routine{
	var next, fr, vol, pos, dur;
	var env = Env([1000,18000,1000],[500,500]);
    s.sync;

	inf.do{|i|
		dur = 0.02;
		next = dur * rrand(0.1, 0.4);
		vol = 0.2;
		pos = rrand(-1.0, 1.0);
		fr	= rrand(100.0, env[i % 1001]);
		Synth(\sg, [\dur, dur, \freq, fr, \pan, pos, \amp, vol, \index, rrand(10,20)]);
		next.wait
	}
}.play;

)

( // B

SynthDef(\sg, { arg freq=400, amp=0.3, dur=0.3, pan=0, index=10;
	var env, sig;
	env = EnvGen.ar(Env([0, amp, 0], [dur*0.5, dur*0.5], [2,-2]), doneAction: 2);
	sig = PMOsc.ar(freq,freq*2,10,mul:env);
	sig = Pan2.ar(sig, pan);
	OffsetOut.ar(0, sig);
}).add;

Routine{
	var next, freq, amp, pan, dur;
    s.sync;

	inf.do{|i|
		dur = 0.06;
		next = dur * rrand(0.1, 0.4);
		amp = 0.2;
		pan = rrand(-1.0, 1.0);
		freq = rrand(10, 500);
		Synth(\sg, [\dur, dur, \freq, freq, \pan, pan, \amp, amp, \index, rrand(10,20)]);
		next.wait
	}
}.play;

)


// GrainFM, trigger with dust, layers, line for mod amt and fold2 for waveshaping.

( // A

{
	var trig = Dust.kr(100);
	GrainFM.ar(2, trig, 0.01, 500, 1500, Line.ar(0.1, 10, 5)) * 0.5;

}.play

)

( // B

{
	var density=100, dur=0.01, freqFrom=100, freqTo=4000;
	var trig = Dust.kr(density);
	Mix.fill(5, {
		var freq=rrand(freqFrom, freqTo);
		var modfreq=rrand(freqFrom, freqTo);
		GrainFM.ar(2, trig, dur, freq, modfreq, Line.ar(0.1, 0.9, 5)).fold2(SinOsc.ar(20)) * 0.1;
	})

}.play

)


//////////////// 02. Waveshaping ////////////////


( // Plot the different fold2 settings

{ SinOsc.ar().fold2(0.1) }.plot;
{ SinOsc.ar().fold2(0.9) }.plot;
{ SinOsc.ar().fold2(Line.kr(0.0,0.5,0.1)) }.plot

)

( // Fold SinOscFB

{

Fold.ar(
	SinOscFB.ar([40,42], LFNoise1.ar(3).range(0.1,1.75)), // src
		LFNoise2.ar(4.3).range(0.1,0.5), // lo
		SinOsc.ar([0.03,0.1]).range(0.5,2.0) // hi
) * 0.3

}.play

)

( // fold2

{ Blip.ar([200,100], 150).fold2(SinOsc.ar( LFDNoise1.ar(25).range(10,60) ) ) * 0.5 }.play

)


//////////////// 03. Buffer Granulation ////////////////

( // A

{

	SynthDef(\source, {
		arg in=0,out=0,sample=0;
		var sig = PlayBuf.ar(1,sample, loop:1);
		Out.ar(out,sig);
	}).add;

	SynthDef(\writer, {|in=0, out=0, buf=0|
		var pos = Phasor.ar(0, 1, 0, BufFrames.kr(buf));
		var sig = In.ar(in, 1);
		BufWr.ar(sig, buf, pos);
		Out.ar(out, pos);
	}).add;

	SynthDef(\reader, {|buf, in, rate=1, dur=0.4, delay=0.1|
		var sig, pos;
		pos = In.ar(in);
		pos = pos / BufFrames.kr(buf);
		pos = pos - delay;
		sig = GrainBuf.ar(1, Impulse.ar(20), dur ! 2, buf, rate, pos.wrap(0,1).poll) * 0.5;
		Out.ar(0, sig);
	}).add;

	s.sync;

    c = Buffer.read(s, (PathName(thisProcess.nowExecutingPath)).pathOnly ++ "vocal.wav"); s.sync;
	b = Buffer.alloc(s, s.sampleRate * (c.duration * 0.1));

	~sourceBus = Bus.audio(s);
	~writerBus = Bus.audio(s);

	s.sync;

	Synth(\reader, [\buf, b, \in, ~writerBus, \dur, 0.1, \rate, 1]);
	Synth(\writer, [\buf, b, \in, ~sourceBus, \out, ~writerBus, \buf, b]);
	Synth(\source, [\in, 0, \out, ~sourceBus, \sample, c.bufnum]);

}.fork

)


( // B

{

SynthDef(\source, {
	arg in=0,out=0;
	var sig = Gendy3.ar * 0.1;
	Out.ar(out,sig);
}).add;

SynthDef(\writer, {|in=0, out=0, buf=0|
	var pos = Phasor.ar(0, 1, 0, BufFrames.kr(buf));
	var sig = In.ar(in, 1);
	BufWr.ar(sig, buf, pos);
	Out.ar(out, pos);
}).add;

SynthDef(\reader, {|buf, in, rate=1, dur=0.4, delay=0.1|
	var sig, pos;
	pos = In.ar(in);
	pos = pos / BufFrames.kr(buf);
    pos = pos - delay;
	pos = pos.wrap(0,1);
	pos = pos * LFNoise1.ar(10).range(0.9,1.1);
	rate = LFDNoise3.ar(10).range(rate*0.5, rate*2);
	sig = GrainBuf.ar(1, Impulse.ar(40), dur ! 2, buf, rate, pos) * 0.4;
	Out.ar(0, sig);
}).add;

s.sync;

b = Buffer.alloc(s, s.sampleRate * 3);

~sourceBus = Bus.audio(s);
~writerBus = Bus.audio(s);

s.sync;

8.do {|i|
		Synth(\reader, [
			\buf, b,
			\in, ~writerBus,
			\rate, rrand(0.01,4.0),
			\dur, (i+1) * 0.01
		])
};

Synth(\writer, [\buf, b, \in, ~sourceBus, \out, ~writerBus, \buf, b]);
Synth(\source, [\in, 0, \out, ~sourceBus]);

}.fork

)


//////////////// 04. Demand Rate ////////////////

Pseq([Pseries(-1.0, 0.1, 20), Pseries(1.0, -0.1, 20)], inf).asStream.nextN(200).plot(discrete:true)


( // Use Demand and server side patterns for waveforms

{
	var trig, shape;
	trig = Impulse.ar(60 ! 2);
	shape = Dseq([Dseries(-1.0, 0.1, 20), Dseries(1.0,-0.1, 20)],inf);
	Demand.ar(trig, 0, shape) * 0.5;
}.play

)


( // Use Demand and server side patterns for waveforms (2)

{
	var trig, shape;
	trig = Impulse.ar(1000 ! 2);
	shape = Dseq([Dseries(-1.0, 0.1, Dwhite(1,50)), Dseries(1.0,-0.1, Dwhite(1,100))],inf);
	Demand.ar(trig, 0, shape) * 0.5;
}.play

)


( //  Waveform with break point envelope contours that interpolate between values

{
	DemandEnvGen.ar(
	Dseq([Dseries(-1.0, 0.1, 20), Dseries(1.0,-0.1, 20)],inf),
	SampleDur.ir) ! 2 * 0.2;
}.play;

)


( // Waveform where the sample duration is changing continously

{
		DemandEnvGen.ar(
			Dseq([Dseries(-1.0, 0.1, 20 ! 2)], inf),
			Dseq([
				Dwhite(1, 10, 4),
				Dwhite(0.1, 100, 4)
			], inf) * SampleDur.ir
		) * 0.3;
}.play;

)

( // Noisy texture

{
    var min=1.0.neg, max=0.5, mod=0.01, sd = SampleDur.ir;

    DemandEnvGen.ar(
        Dseq([min, min.neg, [max.neg, max ! 2]], inf),
        Dwhite(sd, sd * 100),
    ).wrap2(SinOsc.ar(mod)) * 0.3;

}.play

)
