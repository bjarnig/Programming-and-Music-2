////////////////////////////////////////////////////////////////
//
//          06 - Wavesets: Zero-Crossings
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.


// Wavesets divide audio into segments at zero-crossings
// Each segment can be manipulated independently for microsound synthesis

(

{
	// Install Wavesets quark if needed
	if(Quarks.installed.collect(_.name).includes("Wavesets").not) {
		Quarks.install("Wavesets");
		thisProcess.recompile;
	};

	s.sync;

}

)

(

{
	// Set path to samples (adjust as needed)
	~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
	~path = ~path ++ "sounds/";

	// Load waveset from vocal file
	w = Wavesets.from(~path ++ "sequencem.wav");

	s.sync;

	// Define SynthDef for waveset playback
	SynthDef(\waveset, { |out=0, buf=0, start=0, length=441, playRate=1, sustain=1, amp=0.2, pan=0|
		var phasor = Phasor.ar(0, BufRateScale.ir(buf) * playRate, 0, length) + start;
		var env = EnvGen.ar(Env([amp, amp, 0], [sustain, 0]), doneAction: 2);
		var snd = BufRd.ar(1, buf, phasor) * env;
		OffsetOut.ar(out, Pan2.ar(snd, pan));
	}).add;

	s.sync;

	"Wavesets ready! Found % wavesets".format(w.numXings).postln;
}.fork;

)


// Example 1: Amplitude-Based Selection

(

var ampThreshold = 0.3;  // Adjust to taste
var loudWavesets = [];

// Find all wavesets above amplitude threshold
w.amps.do { |amp, i|
	if(amp > ampThreshold) {
		loudWavesets = loudWavesets.add(i);
	}
};

"Found % loud wavesets out of %".format(loudWavesets.size, w.numXings).postln;

Pbindef(\ws,
	\instrument, \waveset,
	\startWs, Pseq(loudWavesets, inf),  // Only loud ones!
	\numWs, 5,
	\playRate, 1,
	\buf, w.buffer.bufnum,
	\repeats, 1,
	\amp, 0.4,
	[\start, \length, \sustain], Pfunc({ |ev|
		var start, length, wsDur;
		#start, length, wsDur = w.frameFor(ev[\startWs], ev[\numWs]);
		[start, length, wsDur * ev[\repeats] / ev[\playRate].abs]
	}),
	\dur, Pkey(\sustain)
).play;

)


// Example 2: Length-Based Selection

(

var lengthThreshold = 50;  // Very short wavesets
var shortWavesets = [];

w.lengths.do { |length, i|
	if(length < lengthThreshold) {
		shortWavesets = shortWavesets.add(i);
	}
};

"Found % short wavesets".format(shortWavesets.size).postln;

Pbindef(\ws,
	\startWs, Pseq(shortWavesets, inf),
	\numWs, 1,
	\playRate, Pwhite(0.8, 1.5),  // Vary pitch slightly
	\repeats, Pwhite(1, 5)         // Random repetition
).play;

)


// Example 3: Waveset Scrubbing
(

Pbindef(\ws,
	\startWs, Prand([
		Pseries(0, 1, 100),    // Forward
		Pseries(100, -1, 100), // Backward
		Pseries(0, 2, 50),     // Forward by 2s
		Pseries(100, -2, 50)   // Backward by 2s
	], inf),
	\numWs, 10,
	\playRate, 1,
	\repeats, 1
).play;

)


// Example 4: Rhythmic Waveset Patterns

(

Pbindef(\ws,
	\startWs, Pwhite(0, w.numXings),
	\numWs, Prand([1, 2, 3], inf),
	\playRate, Prand([1, 2, 0.5], inf),
	\repeats, 1,
	\dur, Pseq([0.125, 0.125, 0.25, 0.125, 0.375], inf)
).play;

)


// Example 5: Waveset Granulation

(

Pbindef(\ws,
	\startWs, Pwhite(0, w.numXings),
	\numWs, 5,
	\playRate, Pwhite(0.5, 2.0),
	\repeats, 1,
	\amp, Pwhite(0.1, 1.4),
	\pan, Pwhite(-1.0, 1.0),
	\dur, Pwhite(0.01, 0.05)
).play;

)


// Example 6: Waveset + Binary Operations

(

SynthDef(\wavesetFold, { |out=0, buf=0, start=0, length=441, playRate=1, sustain=1, amp=0.2, pan=0|
	var phasor = Phasor.ar(0, BufRateScale.ir(buf) * playRate, 0, length) + start;
	var env = EnvGen.ar(Env([amp, amp, 0], [sustain, 0]), doneAction: 2);
	var snd = BufRd.ar(1, buf, phasor);

	snd = snd.fold2(LFNoise2.ar(8).range(0.2, 0.6));

	snd = snd * env;
	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;

Pbindef(\ws,
	\instrument, \wavesetFold,  // Use the folding version
	\startWs, Pwhite(0, w.numXings),
	\numWs, Pwhite(1, 3),
	\playRate, Pwhite(0.8, 1.5),
	\amp, 0.3
).play;

)


// Example 7: Amplitude-Mapped Playback Rate

(

Pbindef(\ws,
	\instrument, \waveset,
	\startWs, Pwhite(0, w.numXings),
	\numWs, 10,
	\playRate, Pfunc({ |ev|
		// Get amplitude of current waveset
		var wsAmp = w.amps[ev[\startWs].asInteger.min(w.numXings - 1)];
		// Map to playback rate
		wsAmp.linlin(0.0, 1.0, 0.5, 3.0);
	}),
	\repeats, 1,
	\amp, 0.4
).play;

)


// Example 8: Waveset Clusters

(

Pbindef(\ws,
	\startWs, Pwhite(0, w.numXings - 10),
	\numWs, 5,  // Play 5 consecutive wavesets together
	\playRate, Prand([1, 1.5, 2, 0.5], inf),
	\repeats, Pwhite(1, 3),
	\dur, 0.5
).play;

)


// Example 10: Waveset Freezing

(

Pbindef(\ws,
	\instrument, \waveset,
	\startWs, Pstutter(Pwhite(10, 50), Pwhite(0, w.numXings)),
	\numWs, 15,
	\playRate, Pstutter(Pwhite(10, 50), Pwhite(0.5, 2.0)),
	\repeats, 1,
	\amp, 0.4,
	\dur, 0.05
).play;

)


// Example 11: Multi-Layered Waveset Chaos

(

// Layer 1: Sequential playback
Pdef(\ws1, Pbind(
	\instrument, \waveset,
	\startWs, Pseries(0, 1, w.numXings).repeat,
	\numWs, 1,
	\playRate, 1,
	\buf, w.buffer.bufnum,
	\repeats, 1,
	\amp, 0.15,
	\pan, -0.7,
	[\start, \length, \sustain], Pfunc({ |ev|
		var start, length, wsDur;
		#start, length, wsDur = w.frameFor(ev[\startWs], ev[\numWs]);
		[start, length, wsDur * ev[\repeats] / ev[\playRate].abs]
	}),
	\dur, Pkey(\sustain)
)).play;

// Layer 2: Random high-speed
Pdef(\ws2, Pbind(
	\instrument, \waveset,
	\startWs, Pwhite(0, w.numXings),
	\numWs, 1,
	\playRate, 3,
	\buf, w.buffer.bufnum,
	\repeats, 1,
	\amp, 0.1,
	\pan, 0.7,
	[\start, \length, \sustain], Pfunc({ |ev|
		var start, length, wsDur;
		#start, length, wsDur = w.frameFor(ev[\startWs], ev[\numWs]);
		[start, length, wsDur * ev[\repeats] / ev[\playRate].abs]
	}),
	\dur, Pkey(\sustain)
)).play;

// Layer 3: Stuttering reverse
Pdef(\ws3, Pbind(
	\instrument, \waveset,
	\startWs, Pstutter(5, Pwhite(0, w.numXings)),
	\numWs, 2,
	\playRate, -0.5,
	\buf, w.buffer.bufnum,
	\repeats, 1,
	\amp, 0.15,
	\pan, 0,
	[\start, \length, \sustain], Pfunc({ |ev|
		var start, length, wsDur;
		#start, length, wsDur = w.frameFor(ev[\startWs], ev[\numWs]);
		[start, length, wsDur * ev[\repeats] / ev[\playRate].abs]
	}),
	\dur, Pkey(\sustain)
)).play;

)


// Example 12: Waveset Probability Filter

(

Pbindef(\ws,
	\instrument, \waveset,
	\startWs, Pseries(0, 1, w.numXings).repeat,
	\numWs, 3,
	\playRate, 1,
	\repeats, 1,
	\amp, 0.8,
	// Probability based on waveset amplitude
	\freq, Pfunc({ |ev|
		var wsAmp = w.amps[ev[\startWs].asInteger.min(w.numXings - 1)];
		if(wsAmp > 0.5.rand, 1, \);  // Play if amp > random threshold
	})
).play;

)


// Stop all waveset patterns when done experimenting

(

Pbindef(\ws).stop;
Pdef(\ws1).stop;
Pdef(\ws2).stop;
Pdef(\ws3).stop;

)


