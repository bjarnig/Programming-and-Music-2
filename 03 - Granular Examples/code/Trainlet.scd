////////////////////////////////////////////////////////////////
//
//                          Trainlet
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)

/*

A trainlet cloud contains one or more trainlets. The main variables in the synthesis of a trainlet cloud are:
* Density per second of trainlets I Trainlet pulse period
* Trainlet harmonic structure
* Trainlet spectral energy profile

*/

////////////////////// SynthDef ///////////////////////////////

(

SynthDef(\trainlet, { |amp=1.0, dur=0.3, pan=0, density=20, harmonics=10|
	var sig, shape, env, pos;
	shape = Env.perc(dur*0.2, dur*0.8);
	env = EnvGen.ar(shape, doneAction: 2);
	sig = Blip.ar(density, harmonics);
	OffsetOut.ar(0, Pan2.ar(sig * env, pan, amp));
}).add;

)

( // Trainlet

var dur=0.05, overlap=2.0, times=1000;

Routine {

	times.do{|i|
		var next = dur / overlap;

		s.makeBundle(0.1,
		{ Synth(\trainlet, [\dur, dur, \density, 10.rand, \harmonics, 1000]) });
		(dur/overlap).wait;
	};

}.play;

)
