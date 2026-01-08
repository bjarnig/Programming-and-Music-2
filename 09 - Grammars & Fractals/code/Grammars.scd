////////////////////////////////////////////////////////////////
//
//                          Grammars
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)


(

SynthDef(\sine, { arg out=0, freq=440, sus=0.05;
	var env = EnvGen.kr(Env.perc(0.01, sus, 0.2), doneAction:2);
    Out.ar(out, SinOsc.ar(freq, 0, env) ! 2)
}).add;

)


/////////////////////// Phrases //////////////////////////

S -> NS + VS // Full Sentance
NS -> A + N  // Noun Sentance
VS -> V + NS // Verb sentance

(

a = ["the", "a", "an"]; // Article
n = ["software", "computer", "music", "musician", "piece"]; // Noun
v = ["composes", "makes", "hears", "performs"]; // Verb

~ns = { a[a.size.rand] + n[n.size.rand] };
~vs = { v[v.size.rand] + ~ns.value };
~s = { ~ns.value + ~vs.value };

4.do { (~s.value ++ ".").postln }

)




/////////////////////// Notes /////////////////////////

Phrase -> LoMiddle + HiLow + MiddleHi

(

l = {|i| Pbrown(40,50,0.5).asStream.nextN(i) }; // Lo
m = {|i| Pbeta(60,70,1).asStream.nextN(i) }; // Middle
h = {|i| Pwhite(80,90).asStream.nextN(i) }; // Hi

~lm = { l.value(rrand(2,3)) ++ m.value(4) };
~hl = { h.value(4) ++ l.value(rrand(5,7)) };
~mh = { m.value(rrand(1,3)) ++ h.value(6) };
~p = { ~lm.value ++ ~hl.value ++ ~mh.value };

~p.value.postln;

Pbind(\instrument, \sine, \midinote, Pseq(~p.value, inf), \dur, 0.2).play

)