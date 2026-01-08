////////////////////////////////////////////////////////////////
//
//                      Chaos Patterns
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)


/////////////////////////// SynthDefs //////////////////////////


(

SynthDef(\perc, {|freq=440, amp=0.1|
	var env = EnvGen.ar(Env.perc(0.01, 0.2), 1, doneAction:2) * amp;
	OffsetOut.ar(0, SinOsc.ar(freq, 0, env) ! 2);
}).add;

SynthDef(\percNote, {|note=60, amp=0.1|
	var env = EnvGen.ar(Env.perc(0.01, 0.2), 1, doneAction:2) * amp;
	OffsetOut.ar(0, SinOsc.ar(note.midicps, 0, env) ! 2);
}).add;

)


////////////////////// Plotter Helpers ////////////////////////

(

~plotPattern = {|pattern, count=500|
	var values = pattern.asStream.nextN(count).flatten;
    values.plot(minval: values.minItem.floor,
		maxval: values.maxItem.ceil)
};

)


////////////////////////// Chaos Patterns ///////////////////////////

/* See BhobUGens in SC3 plugins for some chaos patterns, often they
output arrays and normalize to 0-1 by default (turned off by setting
n false) */

~plotPattern.value(Pstandard.new)

~plotPattern.value(Pfhn.new)

~plotPattern.value(Pgbman.new)

~plotPattern.value(Pquad.new(-2.8, 3.8, 0.1, 0.2))

~plotPattern.value(PlinCong.new(1.8,0.1))

~plotPattern.value(Plorenz.new(20, 22))

~plotPattern.value(Platoo.new(7,2, 0.2))

~plotPattern.value(Phenon.new(1.4, 0.2, 0.2, 0.3))


(
Pbind(
	\note, Pstandard(1.5, 4.9, 5.9),
	\dur, 0.1
).play
)







