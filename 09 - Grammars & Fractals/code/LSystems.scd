////////////////////////////////////////////////////////////////
//
//                          L-Systems
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("NatureToolkit"); Quarks.install("MathLib");
thisProcess.recompile;

)


// Add Synths

(

SynthDef(\pulse, {
	|out=0,pan=0,note=60,amp=1.0,res=0.5,atk=0.1,sus=0.1,rel=0.1|
	var sig, env;
	env = EnvGen.ar(Env.linen(atk, sus, rel), doneAction:2);
	sig = Impulse.ar(note.midicps * 0.25);
	Out.ar(out, Pan2.ar(sig, pan, amp) * env);
}).add;

SynthDef(\sine, {|note=40, amp=0.2|
	var sig, env;
	env = EnvGen.ar(Env.perc(0.01, 0.2), doneAction:2);
	sig = SinOsc.ar(note.midicps) * amp;
	Out.ar(0, sig * env ! 2);
}).add

)



/////////////////////// Rewriting rules ////////////////////////


( // Simple rewrite rules with patterns

t = Prewrite(1.00, (
	1.00: [0.25,0.50],
	0.25: [0.15],
	0.50: [1.25,0.125]
), 2).asStream;

t.nextN(8)

)


( // Or using Plsys

t = Plsys(Pseq("aabba"),
	["aa" -> "ab", "a" -> "b", "bb" -> "ab", "b" -> "ba"], 1)
    .asStream.all.postln;

Plsys(Pseq("aab"),
	["aa" -> "ab", "a" -> "b", "bb" -> "ab", "b" -> "ba"], 10)
    .asStream.all;

)


( // Use with patterns

var base = "aab";
var rule = ["aa" -> "ab", "a" -> "b", "bb" -> "ab", "b" ->"ba"];
var note = 60;

Pbind(
	\instrument, \pulse,
	\lsys, Plsys(Pseq(base), rule, 64),
    \note, Pfunc({|ev| if(ev.lsys.asString == "a", { note = note + 3}, { note = note - 1}); note }),
	\dur, Pfunc({|ev| if(ev.lsys.asString == "a", {0.1}, {0.2}) }),
	\print, Pfunc({|ev| ev.postln})
).play

)


// Turtle Graphics

// F => Draw line
// f => Draw empty line
// + => Rotate left
// - => Rotate right

LSPlant(360@350, 0, argAngle: 90).drawSize_(12).draw("F");
LSPlant(360@350, 0, argAngle: 90).drawSize_(12).draw("F+F");
LSPlant(360@350, 0, argAngle: 90).drawSize_(12).draw("F+F+F");
LSPlant(360@350, 0, argAngle: 90).drawSize_(12).draw("F+F+F-F");


( // From Nature Toolkit (Islands and Lakes)

a = LSys("F+F+F+F", ["F" -> "F+f-FF+F+FF+Ff+FF-f+FF-F-FF-Ff-FFF", "f" -> "ffffff"]);
k = a.applyRules(2);
k.postln;
LSPlant(360@350, 0, argAngle: 90).drawSize_(12).draw(k);
k.class

)


// Quadratic Snowflake from A.B.O.P. fig. 1.7b
(

a = LSys("F", ["F" -> "F+F-F-F+F"]);
k = a.applyRules(5);
LSPlant(20@350, 90, 90, Rect(300, 300, 530, 500), { Color.rand; }).drawSize_(2).draw(k);

)




( // Iterate evolution

a = LSys("baaaaaaaaaaaaaaaa", ["b<a" -> "b", "b" -> "a"]);
16.do
({
	a.applyRules(1).postln;
});

)



( // Use with patterns

var base = "F+F+F+F";
var rule = ["F" -> "F+f-FF+F+FF+Ff+FF-f+FF-F-FF-Ff-FFF", "f" -> "ffffff"];
var mapping, lsys, str;
var note = 100;
str.postln;

mapping = {|ev|
	ev.postln;
	if(ev.lsys.asString == "f", {note = note + 1});
	if(ev.lsys.asString == "F", {note = note - 1});
	if(ev.lsys.asString == "+", {note = note + 12});
	if(ev.lsys.asString == "-", {note = note - 12});
	note
};

lsys = LSys(base, rule);
str = lsys.applyRules(2);
str.postln;

LSPlant(300@300, 90, 90, Rect(300, 300, 530, 500), { Color.rand; }).drawSize_(5).draw(str);

Pbind(
	\instrument, \pulse,
	\lsys, Pseq(str, inf),
	\note, Pfunc(mapping),
	\dur, 0.2,
	\print, Pfunc({|ev| ev.postln})
).play

)