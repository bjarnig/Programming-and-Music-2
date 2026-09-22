////////////////////////////////////////////////////////////////
//
//                     Live Granulation
//
////////////////////////////////////////////////////////////////

/* Granulating a sound while it is still arriving. */


//////////////// A recorded source ////////////////

( // one reader ahead of the writer

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

	SynthDef(\reader, {|buf, in, rate=1, dur=0.1, delay=0.1|
		var sig, pos;
		pos = In.ar(in);
		pos = pos / BufFrames.kr(buf);
		pos = pos - delay;
		sig = GrainBuf.ar(1, Impulse.ar(20), dur ! 2, buf, rate, pos.wrap(0,1)) * 0.5;
		Out.ar(0, sig);
	}).add;

	s.sync;

	c = Buffer.read(s, (PathName(thisProcess.nowExecutingPath)).pathOnly ++ "samples/bikecat.wav");
	s.sync;

	// fixed two seconds
	b = Buffer.alloc(s, s.sampleRate * 2);

	~sourceBus = Bus.audio(s);
	~writerBus = Bus.audio(s);

	s.sync;

	Synth(\reader, [\buf, b, \in, ~writerBus, \dur, 0.1, \rate, 1]);
	Synth(\writer, [\buf, b, \in, ~sourceBus, \out, ~writerBus, \buf, b]);
	Synth(\source, [\in, 0, \out, ~sourceBus, \sample, c.bufnum]);

}.fork

)


//////////////// A synthetic source ////////////////

( // Gendy3 written in and granulated out, with eight readers at different rates

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
	sig = GrainBuf.ar(1, Impulse.ar(40), dur ! 2, buf, rate, pos) * 0.1;   // eight of these sum
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

CmdPeriod.run;
