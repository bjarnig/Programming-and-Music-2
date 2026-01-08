////////////////////////////////////////////////////////////////
//
//          04 - Real-Time Buffer Granulation
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

// Architecture: Source → Writer (to buffer) → Reader (granulate buffer)


(

~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
~path = ~path ++ "sounds/";

)

(

{
	// Source: plays a buffer into the system
	SynthDef(\source, { arg out=0, buf=0;
		var sig = PlayBuf.ar(1, buf, loop: 1);
		Out.ar(out, sig);
	}).add;

	// Writer: continuously writes to circular buffer and outputs write position
	SynthDef(\writer, { |in=0, out=0, buf=0|
		var pos = Phasor.ar(0, 1, 0, BufFrames.kr(buf));
		var sig = In.ar(in, 1);
		BufWr.ar(sig, buf, pos);
		Out.ar(out, pos);
	}).add;

	// Source (Gendy): synthetic source for variety
	SynthDef(\sourceGendy, { arg out=0;
		var sig = Gendy3.ar * 0.1;
		Out.ar(out, sig);
	}).add;

	s.sync;
	"Common SynthDefs loaded!".postln;
}.fork;

)


// Example 1: Basic Buffer-Based Real-Time Granulation

(

{
	SynthDef(\reader1, { |buf, in, rate=1, dur=0.4, delay=0.1|
		var sig, pos;
		pos = In.ar(in);
		pos = pos / BufFrames.kr(buf);
		pos = pos - delay;
		sig = GrainBuf.ar(2, Impulse.ar(20), dur, buf, rate, pos.wrap(0, 1));
		Out.ar(0, sig * 0.5);
	}).add;

	s.sync;

	// Allocate buffers
	~sourceFile = Buffer.read(s, ~path ++ "sequencem.wav");
	~recBuf = Buffer.alloc(s, s.sampleRate * 0.5);  // 0.5 second circular buffer

	// Create buses
	~sourceBus = Bus.audio(s);
	~writerBus = Bus.audio(s);

	s.sync;

	// Start the chain: reader ← writer ← source
	Synth(\reader1, [\buf, ~recBuf, \in, ~writerBus, \dur, 0.1, \rate, 0.5, \delay, 0.1]);
	Synth(\writer, [\buf, ~recBuf, \in, ~sourceBus, \out, ~writerBus]);
	Synth(\source, [\out, ~sourceBus, \buf, ~sourceFile]);

}.fork

)


// Example 2: Real-time Granulation with Variable Parameters

(

{
	SynthDef(\reader2, { |buf, in, rate=1, dur=0.4, delay=0.1|
		var sig, pos;
		pos = In.ar(in);
		pos = pos / BufFrames.kr(buf);
		pos = (pos - delay).wrap(0, 1);

		// Vary position slightly for texture
		pos = pos * LFNoise1.ar(10).range(0.9, 1.1);

		// Vary rate for pitch variation
		rate = LFDNoise3.ar(5).range(rate * 0.2, rate * 2.2);

		sig = GrainBuf.ar(2, Impulse.ar(40), dur, buf, rate, pos);
		Out.ar(0, sig * 0.4);
	}).add;

	s.sync;

	~sourceFile = Buffer.read(s, ~path ++ "bikecatm.wav");
	~recBuf = Buffer.alloc(s, s.sampleRate * 1);

	~sourceBus = Bus.audio(s);
	~writerBus = Bus.audio(s);

	s.sync;

	Synth(\reader2, [\buf, ~recBuf, \in, ~writerBus, \dur, 0.15, \rate, 1, \delay, 0.2]);
	Synth(\writer, [\buf, ~recBuf, \in, ~sourceBus, \out, ~writerBus]);
	Synth(\source, [\out, ~sourceBus, \buf, ~sourceFile]);

}.fork

)


// Example 3: Multi-layered Real-time Granulation

(

{
	SynthDef(\reader3, { |buf, in, rate=1, dur=0.4, delay=0.1|
		var sig, pos;
		pos = In.ar(in);
		pos = pos / BufFrames.kr(buf);
		pos = (pos - delay).wrap(0, 1);
		pos = pos * LFNoise1.ar(10).range(0.9, 1.1);
		rate = LFDNoise3.ar(10).range(rate * 0.5, rate * 2);
		sig = GrainBuf.ar(2, Impulse.ar(40), dur, buf, rate, pos);
		Out.ar(0, sig);
	}).add;

	s.sync;

	~recBuf = Buffer.alloc(s, s.sampleRate * 3);

	~sourceBus = Bus.audio(s);
	~writerBus = Bus.audio(s);

	s.sync;

	// Create 8 layers with different characteristics
	8.do { |i|
		Synth(\reader3, [
			\buf, ~recBuf,
			\in, ~writerBus,
			\rate, rrand(0.5, 4.0),
			\dur, (i + 1) * 0.003,
			\delay, rrand(0.05, 0.3)
		]);
	};

	Synth(\writer, [\buf, ~recBuf, \in, ~sourceBus, \out, ~writerBus]);
	Synth(\sourceGendy, [\out, ~sourceBus]);

}.fork

)


// Example 4: Multiple Readers - Different Delay Times

(

{
	SynthDef(\reader4, { |buf, in, rate=1, dur=0.4, delay=0.1, amp=0.3|
		var sig, pos;
		pos = In.ar(in);
		pos = pos / BufFrames.kr(buf);
		pos = (pos - delay).wrap(0, 1);
		pos = pos * LFNoise1.ar(5).range(0.98, 1.02);
		sig = GrainBuf.ar(2, Impulse.ar(40), dur, buf, rate, pos);
		Out.ar(0, sig * amp);
	}).add;

	s.sync;

	~sourceFile = Buffer.read(s, ~path ++ "sequencem.wav");
	~recBuf = Buffer.alloc(s, s.sampleRate * 2);

	~sourceBus = Bus.audio(s);
	~writerBus = Bus.audio(s);

	s.sync;

	// 4 readers with different delay times
	~readers = [
		[0.1, 1.0, 0.08],   // [delay, rate, duration]
		[0.4, 0.75, 0.12],
		[0.8, 1.5, 0.15],
		[1.5, 0.5, 0.2]
	].collect { |params|
		Synth(\reader4, [
			\buf, ~recBuf,
			\in, ~writerBus,
			\delay, params[0],
			\rate, params[1],
			\dur, params[2],
			\amp, 0.15
		]);
	};

	Synth(\writer, [\buf, ~recBuf, \in, ~sourceBus, \out, ~writerBus]);
	Synth(\source, [\out, ~sourceBus, \buf, ~sourceFile]);

}.fork

)

// Stop
([~writer] ++ ~readers ++ [~source]).do(_.free);


// Example 5: Granular Cloud from Many Readers

(

{
	SynthDef(\reader5, { |buf, in, rate=1, dur=0.4, delay=0.1, amp=0.3, pan=0|
		var sig, pos;
		pos = In.ar(in);
		pos = pos / BufFrames.kr(buf);
		pos = (pos - delay).wrap(0, 1);
		pos = pos * LFNoise1.ar(8).range(0.95, 1.05);
		rate = rate * LFNoise2.ar(3).range(0.9, 1.1);
		sig = GrainBuf.ar(1, Impulse.ar(35), dur, buf, rate, pos);
		Out.ar(0, Pan2.ar(sig, pan) * amp);
	}).add;

	s.sync;

	~sourceFile = Buffer.read(s, ~path ++ "bikecatm.wav");
	~recBuf = Buffer.alloc(s, s.sampleRate * 3);

	~sourceBus = Bus.audio(s);
	~writerBus = Bus.audio(s);

	s.sync;

	// 8 readers with varied parameters and spatial spread
	~readers = 8.collect { |i|
		Synth(\reader5, [
			\buf, ~recBuf,
			\in, ~writerBus,
			\delay, exprand(0.05, 2.0),
			\rate, exprand(0.5, 2.5),
			\dur, rrand(0.06, 0.25),
			\pan, i.linlin(0, 7, -1, 1),
			\amp, 0.15
		]);
	};

	Synth(\writer, [\buf, ~recBuf, \in, ~sourceBus, \out, ~writerBus]);
	Synth(\source, [\out, ~sourceBus, \buf, ~sourceFile]);

}.fork

)

// Stop
([~writer] ++ ~readers ++ [~source]).do(_.free);
