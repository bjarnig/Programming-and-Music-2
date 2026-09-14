////////////////////////////////////////////////////////////////
//
//                     Live Granulation
//
////////////////////////////////////////////////////////////////

/* Granulating a sound while it is still arriving.

   The architecture is three nodes and one buffer. A source writes into a
   circular buffer with BufWr driven by a Phasor, and hands the write position
   on as an audio signal. A reader takes that position, subtracts a delay, and
   granulates behind the write head. Nothing is loaded in advance: the buffer
   holds only the last few seconds, and the grains are taken out of it as it is
   being filled.

   The delay is the whole control. Too small and the reader catches up with the
   writer and reads what has not been written yet; large enough and the grains
   trail the input by a fixed, audible distance.

   The order of the three nodes matters, which is the same rule as anywhere on
   the server: the reader has to run after the writer, or it reads the previous
   block. They are started in reverse here for that reason.

   Adapted from a longer file of microsound examples; the synthetic granular,
   waveshaping and demand-rate sections of that file live in classes 02 and 07.
*/


//////////////// A recorded source ////////////////

( // one reader, trailing the write head by a tenth of the buffer

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
		sig = GrainBuf.ar(1, Impulse.ar(20), dur ! 2, buf, rate, pos.wrap(0,1)) * 0.5;
		Out.ar(0, sig);
	}).add;

	s.sync;

	c = Buffer.read(s, (PathName(thisProcess.nowExecutingPath)).pathOnly ++ "samples/vocal.wav");
	s.sync;

	// a fixed two seconds, not a fraction of c.duration: the buffer's frame count
	// has not come back from the server yet at this point
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
