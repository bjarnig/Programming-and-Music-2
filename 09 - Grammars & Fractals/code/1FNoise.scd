////////////////////////////////////////////////////////////////
//
//                         1/F Noise
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("ddwPatterns");
thisProcess.recompile;

)

Quarks.gui


/* Pvoss and Pmcvoss, from ddw patterns quarks */

"http://quark.sccode.org/ddwPatterns/Help/Pvoss.html"
"http://quark.sccode.org/ddwPatterns/Help/Pmcvoss.html"


(

a = Pvoss.new.asStream.nextN(350);
a.plot();

)


(

SynthDef(\onef, {|amp=0.2, note=60, atk=0.1, sus=0.5, rel=0.3|
	var sig, env, pan, offset, brown, freq, trig, base;
	base = note * 21;
	env = EnvGen.ar(Env([0, 1, 1, 0], [atk, sus, rel]), levelScale:amp, doneAction:2);
    brown = Dbrown(base, base * 2, 10, inf);
	trig = Impulse.kr(500);
    freq = Demand.kr(trig, 0, brown);
	sig = (Blip.ar(freq, 10) ! 2 * 0.1);
	OffsetOut.ar(0, sig ! 2);
}).add;

SynthDef(\simpleFm, {|amp=0.5, note=60, atk=0.01, rel=0.2, mod=0.25|
	var sig, env, pan;
	env = EnvGen.ar(Env.perc(atk, rel), doneAction:2) * amp;
	sig = PMOsc.ar(note.midicps, note.midicps * 2, mod * 10) * env;
	OffsetOut.ar(0, sig ! 2);
}).add;

)


(

p = Pbind(
	\instrument, \simpleFm,
	\note, Pmcvoss(20, 60, 1),
	\dur, 0.1
).play;

)


(

q = Pbind(
	\instrument, \onef,
	\note, Pvoss(12, 120, 2),
	\dur, 0.1
).play;

)
