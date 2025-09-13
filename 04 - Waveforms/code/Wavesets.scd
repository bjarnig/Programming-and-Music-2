////////////////////////////////////////////////////////////////
//
//                         Wavesets 
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)


// Install Wavesets quark
Quarks.install("Wavesets");

////////////////////////// Wavesets ///////////////////////////


/* The wavesets class and associated examples come from Alberto
   De Campo's chapter 'Microsound' in the SuperCollider book */

(
	~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
    w = Wavesets.from(~path ++ "/samples/vocalm.wav");
)


// The associated buffer
w.buffer

// The associated signal
w.signal

// Number of zero crossings
w.numXings

// All wavesets lengths
w.lengths

// Every peak amplitude
w.amps

// Plot the a waveset
w.plot(1000, 1)

// Plot 10 wavesets
w.plot(1000, 10)




// SynthDef to play wavesets
(
SynthDef(\waveset, {|out=0,buf=0,start=0,length=441,playRate=1,sustain=1,amp=0.2,pan|
	var phasor = Phasor.ar(0, BufRateScale.ir(buf) * playRate, 0, length) + start;
	var env = EnvGen.ar(Env([amp, amp, 0], [sustain, 0]), doneAction: 2);
	var snd = BufRd.ar(1, buf, phasor) * env;
	OffsetOut.ar(out, Pan2.ar(snd, pan));
}).add;
)




// Play the synth, reconstruct the source
(
Pbindef(\ws).clear;
Pbindef(\ws,
	\instrument, \waveset,
	\startWs, Pn(Pseries(0, 1, w.numXings), inf),
	\numWs, 1,
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


// Waveset transposition: every fourth waveset, half speed
Pbindef(\ws, \playRate, 0.5, \startWs, Pn(Pseries(0, 4, 1000), inf)).play;


// Reverse every 10 wavesets
Pbindef(\ws, \numWs, 2, \playRate, -1, \startWs, Pn(Pseries(0, 10, 1000), inf)).play;


// Restore
Pbindef(\ws, \numWs, 1, \playRate, 1, \startWs, Pn(Pseries(0, 1, 1000), 1)).play;


// Repeat cycles, causes timestretch
Pbindef(\ws, \playRate, 1, \repeats, 10).play;


// High values create (very audible, nice?) artifacts
Pbindef(\ws, \playRate, 4, \repeats, 100).play;


// Omit every waveset randomly
Pbindef(\ws, \numWs, 1, \freq, Pfunc({ if (0.25.coin, 1, \) }) ).play;


// Play random wavesets
Pbindef(\ws, \startWs, Pwhite(0, 10000) ).play;