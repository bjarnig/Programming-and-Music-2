////////////////////////////////////////////////////////////////
//
//          02 - Granular Synthesis
////
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.


// Load buffers first

(

~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
~path = ~path ++ "sounds/";

~sequence = Buffer.read(s, ~path ++ "sequencem.wav");
~bikecat = Buffer.read(s, ~path ++ "bikecatm.wav");

~clickPath = ~path ++ "clicks/*";

~files = SoundFile.collect(~clickPath);
~clicks = ~files.collect { |sf|
	Buffer.read(Server.local, sf.path)
}

)

// Example 1: Basic GrainBuf - Simple File Playback

(

{
	var trig = Impulse.kr(20);  // 20 grains per second
	var dur = 0.1;              // 100ms grain duration
	var buf = ~sequence.bufnum;
	var pos = Line.kr(0.0, 1.0, ~sequence.duration, doneAction: 2);  // play through buffer

	GrainBuf.ar(
		numChannels: 2,
		trigger: trig,
		dur: dur,
		sndbuf: buf,
		rate: 1,
		pos: pos
	) * 0.5;
}.play

)


// Example 2: Variable Grain Size

(

{
	var trig = Impulse.kr(30);
	var dur = LFNoise1.kr(2).range(0.05, 0.3);  // varying grain size
	var buf = ~sequence.bufnum;
	var pos = Phasor.kr(0, 1 / (BufDur.kr(buf) * ControlRate.ir), 0, 1);

	GrainBuf.ar(2, trig, dur, buf, 1, pos) * 0.5;
}.play

)


// Example 3: Multi-Band Granular Processing

(

{
	var buf = ~bikecat.bufnum;

	// Low frequency layer: long grains, slow movement
	var low = {
		var trig = Impulse.kr(15);
		var dur = LFNoise1.kr(0.5).range(0.2, 0.5);
		var pos = LFNoise1.kr(0.1).range(0, 1);
		var rate = LFNoise1.kr(0.2).range(0.25, 0.5);  // down-pitched
		var sig = GrainBuf.ar(1, trig, dur, buf, rate, pos);
		BPF.ar(sig, 200, 0.5);  // filter to low
	};

	// Mid frequency layer: medium grains, moderate movement
	var mid = {
		var trig = Impulse.kr(40);
		var dur = LFNoise1.kr(1).range(0.08, 0.2);
		var pos = LFNoise1.kr(0.5).range(0, 1);
		var rate = LFNoise1.kr(0.5).range(0.8, 1.2);
		var sig = GrainBuf.ar(1, trig, dur, buf, rate, pos);
		BPF.ar(sig, 1200, 0.3);  // filter to mid
	};

	// High frequency layer: short grains, fast chaotic movement
	var high = {
		var trig = Dust.kr(100);
		var dur = TRand.kr(0.01, 0.05, trig);
		var pos = TRand.kr(0, 1, trig);
		var rate = TExpRand.kr(1.5, 4.0, trig);  // up-pitched
		var sig = GrainBuf.ar(1, trig, dur, buf, rate, pos);
		HPF.ar(sig, 3000);  // filter to high
	};

	var sig = Mix([low, mid, high]);
	Splay.ar(sig ! 5, 0.8) * 0.4;
}.play

)


// Example 4: Granular Scrubbing with Inertia

(
{
	var buf = ~sequence.bufnum;
	var trig = Impulse.kr(60);
	var dur = 0.1;

	// Target position jumps around but pos position smoothly follows
	var target = LFNoise0.kr(8).range(0, 1);
	var pos = Lag.kr(target, 0.3);

	// Rate follows position speed (faster scrub = higher pitch)
	var velocity = Slope.kr(pos) * 50;
	var velocityAbs = velocity.abs.clip(0.01, 2.0);
	var rate = velocityAbs.linlin(0.01, 2.0, 0.5, 3.0);

	// Grain density increases with speed
	var density = velocityAbs.linexp(0.01, 2.0, 10s, 100);
	var trigDynamic = Impulse.kr(density);

	GrainBuf.ar(2, trigDynamic, dur, buf, rate, pos) * 0.3;
}.play
)



// Example 5: Rhythmic Granular Patterns

(

{
	var buf = ~bikecat.bufnum;

	// Create a rhythmic trigger pattern
	var pattern = Dseq([1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0], inf);
	var tempo = 25;
	var clock = Impulse.kr(tempo);
	var trig = Demand.kr(clock, 0, pattern) * clock;

	// Each triggered grain has random properties
	var dur = TRand.kr(0.05, 0.15, trig);
	var pos = TRand.kr(0.1, 1.0, trig);
	var rate = TChoose.kr(trig, [0.5, 0.75, 1.0, 1.5, 2.0]);  // quantized pitches

	// Panning follows pattern
	var pan = TIRand.kr(-1, 1, trig) * 0.7;
	var sig = GrainBuf.ar(1, trig, dur, buf, rate, pos);
	Pan2.ar(sig, pan) * 0.4;
}.play

)


// Example 6: Feedback Granulation

(

{
	var buf = ~sequence.bufnum;
	var trig = Impulse.kr(50);
	var dur = 0.1;

	// Initial grain stream
	var pos = LFNoise1.kr(0.5).range(0, 1);
	var rate = LFNoise1.kr(0.3).range(0.7, 1.4);
	var grains = GrainBuf.ar(1, trig, dur, buf, rate, pos);

	// Use feedback to modulate rate
	var feedback = LocalIn.ar(1) * 0.3;
	var modRate = rate + (feedback * 0.5);
	var sig = GrainBuf.ar(1, trig, dur, buf, modRate, pos);

	// Filter and compress
	sig = LPF.ar(sig + feedback, 8000);
	sig = Compander.ar(sig, sig, 0.5, 1, 0.3, 0.01, 0.1);

	LocalOut.ar(DelayC.ar(sig,1,0.01));

	sig ! 2 * 0.3;
}.play

)

// Example 7: Time-Stretching with Grain Overlap

(

{
	var buf = ~sequence.bufnum;

	// Very high density for smooth time-stretch
	var trig = Impulse.kr(100);
	var dur = 0.3;

	// Move very slowly through a small region
	var regionStart = LFNoise0.kr(0.1).range(0, 0.7);
	var regionSize = 0.05;  // only 5% of buffer
	var pos = LFNoise2.kr(1).range(regionStart, regionStart + regionSize);
	var rate = LFNoise2.kr(2).range(0.95, 1.05);

	// Multiple layers with slight detuning
	var sig = Mix.fill(4, { |i|
		var detune = 1 + (i * 0.01);
		GrainBuf.ar(1, trig, dur, buf, rate * detune, pos) / 4;
	});

	Pan2.ar(sig, 0) * 0.3;
}.play

)


// Example 8: Buffer Switching - Smooth Morphing

(

{
	var trig = Impulse.kr(40);
	var dur = 0.12;
	var first = ~clicks[0].bufnum;
	var last = ~clicks[~clicks.size - 1].bufnum;

	// Sweep through buffer range
	var bufIndex = LFNoise1.kr(4.3).range(first, last + 0.999);
	var pos = LFNoise1.kr(2).range(0, 0.1);
	var rate = LFNoise1.kr(0.5).range(0.8, 1.3);

	GrainBuf.ar(2, trig, dur, bufIndex, rate, pos) * 0.5;
}.play

)


// Example 9: Buffer Switching - Rhythmic Selection

(

{
	var trig = Impulse.kr(40);
	var dur = 0.2;
	var first = ~clicks[0].bufnum;
	var last = ~clicks[~clicks.size - 1].bufnum;

	// Create a rhythmic sequence of buffer indices
	var bufferPattern = Drand([
		Dser([first], 4),
		Dser([first + 2], 2),
		Dser([first + 4], 3),
		Dser([last], 1)
	], inf);

	var bufIndex = Demand.kr(trig, 0, bufferPattern);
	var ratePattern = Dseq([1.0, 0.75, 1.5, 2.0], inf);
	var rate = Demand.kr(trig, 0, ratePattern);

	var pos = TRand.kr(0, 1, trig);

	GrainBuf.ar(2, trig, dur, bufIndex, rate, pos) * 0.5;
}.play

)


// Example 10: Multi-Voice Buffer Switching

(

{
	var numVoices = 6;
	var first = ~clicks[0].bufnum;
	var last = ~clicks[~clicks.size - 1].bufnum;

	var sig = Mix.fill(numVoices, { |i|
		var trig = Impulse.kr(15 + (i * 5));
		var dur = 0.08 + (i * 0.02);

		// Each voice focuses on different subset of buffers
		var centerBuf = first + ((last - first) * (i / numVoices));
		var range = ((last - first) / numVoices) * 0.5;
		var bufIndex = LFNoise0.kr(1 + (i * 0.3)).range(
			(centerBuf - range).max(first),
			(centerBuf + range).min(last)
		);

		var pos = LFNoise2.kr(2 + i).range(0, 1);
		var rate = LFNoise1.kr(0.5 + (i * 0.1)).range(0.7, 1.5);
		var pan = (i / (numVoices - 1) * 2 - 1) * 0.8;

		Pan2.ar(
			GrainBuf.ar(1, trig, dur, bufIndex, rate, pos),
			pan
		) / numVoices;
	});

	sig * 0.5;
}.play

)


// Example 11: Triggered Buffer Jumps

(

{
	var trig = Impulse.kr(35);
	var dur = 0.2;
	var first = ~clicks[0].bufnum;
	var last = ~clicks[~clicks.size - 1].bufnum;

	// Randomly choose buffer for each grain
	var bufIndex = TIRand.kr(first, last, trig);

	// Probabilistic triggering creates rhythm
	var maskedTrig = trig * CoinGate.kr(0.7, trig);

	var pos = TRand.kr(0, 1, trig);
	var rate = TExpRand.kr(0.5, 2.0, trig);

	// Random spatial placement
	var pan = TRand.kr(-1.0, 1.0, trig);

	var sig = GrainBuf.ar(1, maskedTrig, dur, bufIndex, rate, pos);
	sig =  sig + GrainBuf.ar(1, maskedTrig, dur* 0.5, bufIndex, rate * 2, pos);
	Pan2.ar(sig, pan) * 0.4;
}.play

)
