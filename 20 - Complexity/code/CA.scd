////////////////////////////////////////////////////////////////
//
//                       Cellular Automata
//
////////////////////////////////////////////////////////////////


/* NatureToolkit / ModernLife examples.

     1. install SafetyNet + NatureToolkit
     2. eval the synths
     3. one-line rule examples (eval, watch, eval the next)
     4. pattern-based walker  (melodic sines from grid rows)
     5. auto-evolving CA with stuck-detection feedback

   In the auto-evolving block:  press 'n' to force a reset to a
   new rule whenever you want.
*/



( Quarks.fetchDirectory(true); Quarks.install("NatureToolkit"); thisProcess.recompile )


(

SynthDef(\sine, {|out=0, amp=0.5, midinote=60, sus=0.05, pan=0|
	var env = EnvGen.kr(Env.perc(0.01, sus, 0.6), doneAction: 2);
	var sig = SinOsc.ar(midinote.midicps, 0, env * amp);
	Out.ar(out, Pan2.ar(sig, pan));
}).add;

SynthDef(\click, {|amp=0.3, freq=2000, dur=0.05, pan=0|
	var env = EnvGen.kr(Env.perc(0.001, dur), doneAction: 2);
	var sig = (PinkNoise.ar * env * amp) + (SinOsc.ar(freq) * env * amp * 0.3);
	OffsetOut.ar(0, Pan2.ar(sig, pan));
}).add;

)


// ── one-line rule examples ────────────────────────────────

( if(a.notNil) { a.stop }; a = ModernLife.new.setRule("23/3").fps_(15).fadeAmount_(0.88).play )      // Conway
( if(a.notNil) { a.stop }; a = ModernLife.new.setRule("23/36").fps_(15).fadeAmount_(0.85).play )     // HighLife
( if(a.notNil) { a.stop }; a = ModernLife.new.setRule("34678/3678").fps_(10).fadeAmount_(0.9).play ) // Day & Night
( if(a.notNil) { a.stop }; a = ModernLife.new.setRule("1357/1357").fps_(8).fadeAmount_(0.95).play )  // Replicator
( if(a.notNil) { a.stop }; a = ModernLife.new.setRule("/2").fps_(8).fadeAmount_(0.6).play )          // Seeds
( if(a.notNil) { a.stop }; a = ModernLife.new.setRule("12345/3").fps_(10).fadeAmount_(1.0).play )    // Maze
( if(a.notNil) { a.stop }; a = ModernLife.new.setRule("45678/3").fps_(20).fadeAmount_(1.0).play )    // Coral
( if(a.notNil) { a.stop }; a = ModernLife.new.setRule("125/36").fps_(10).fadeAmount_(0.85).play )    // 2x2
( if(a.notNil) { a.stop }; a = ModernLife.new.setRule("34/34").fps_(10).fadeAmount_(0.88).play )     // 3-4 Life
( if(a.notNil) { a.stop }; a = ModernLife.new.setRule("5/345").fps_(8).fadeAmount_(0.9).play )       // Long Life
( if(a.notNil) { a.stop }; a = ModernLife.new.setRule("5678/35678").fps_(10).fadeAmount_(0.9).play ) // Diamoeba

if(a.notNil) { a.stop };


// Pattern-based walker

(

var n = 16;

~caLife = ModernLife.new(n, 320);
~caLife.setRule("23/3").fps_(1).fadeAmount_(0.92);

~caLife.userFunc = {|states, pop|
	var topRow = states[0].asArray;
	var midRow = states[(n / 2).asInteger].asArray;
	var botRow = states[n - 1].asArray;

	~caPat = Pbind(
		\instrument, \sine,
		\midinote,   Pseq(topRow.collect({|v, i| 48 + (i * 2) + (v * 5) }), 1),
		\dur,        Pseq(midRow.collect({|v|    if(v == 1, 0.18, 0.06) }), 1),
		\amp,        Pseq(botRow.collect({|v|    0.10 + (v * 0.22) }),     1),
		\sus,        0.25,
		\pan,        Pseq(topRow.collect({|v, i| ((i / n) * 2) - 1 * 0.6 }), 1)
	).play;
};

~caLife.play;

)


// Auto-evolving CA with stuck-detection

(

var n              = 36;
var stuckThreshold = 25;
var historyLen     = 14;
var ruleList = [
	["Conway",     "23/3"],
	["HighLife",   "23/36"],
	["DayNight",   "34678/3678"],
	["Replicator", "1357/1357"],
	["Seeds",      "/2"],
	["Maze",       "12345/3"],
	["Coral",      "45678/3"],
	["2x2",        "125/36"],
	["34Life",     "34/34"],
	["LongLife",   "5/345"],
	["Diamoeba",   "5678/35678"]
];
var stateHist   = List.new;
var stuckFrames = 0, resetCount = 0;
var prevPop = 0;
var pingPitches = [60, 62, 64, 67, 69, 72, 74, 76, 79];
var pingRate = 1.5;
var currentName = "Conway", currentRule = "23/3";
var life;
var pickNewRule, perturbAndReset, fireForceReset;


pickNewRule = {
	var pick = ruleList.reject({|r| r[0] == currentName }).choose;
	currentName = pick[0];
	currentRule = pick[1];
};

perturbAndReset = {|states|
	pickNewRule.value;
	n.do {|i| n.do {|j| states[i][j] = (0.42.coin).asInteger } };
	life.setRule(currentRule);
	stateHist.clear;
	stuckFrames = 0;
	resetCount  = resetCount + 1;
	Synth(\click, [\freq, rrand(800, 4000), \amp, 0.35, \dur, 0.10]);
	("[reset #" ++ resetCount ++ "]  " ++ currentName ++ "  (" ++ currentRule ++ ")").postln;
};


if(~evolveLife.notNil) { ~evolveLife.stop };

life = ModernLife.new(n, 480);
life.setRule(currentRule);
life.fps        = 12;
life.fadeAmount = 0.86;
~evolveLife = life;

life.userFunc = {|states, pop|
	var area     = n * n;
	var q        = (n / 2).asInteger;
	var leftSum  = states.collect({|r| r.copyRange(0, q - 1).sum }).sum;
	var rightSum = states.collect({|r| r.copyRange(q, n - 1).sum }).sum;
	var sig1     = pop;
	var sig2     = states.collect({|r, i| r.sum * (i + 1) }).sum;
	var stuck    = false;
	var safeArea = max(area, 1);
	var popDelta = (pop - prevPop).abs;

	if(pop == 0) { stuck = true };
	stateHist.do {|h|
		if((h.s1 == sig1) and: { h.s2 == sig2 }) { stuck = true };
	};
	if(stuck) { stuckFrames = stuckFrames + 1 } { stuckFrames = 0 };

	/* melodic pings fire when population jumps */
	if((popDelta > 4) and: { pingRate.reciprocal.coin }) {
		Synth(\sine, [
			\midinote, pingPitches.wrapAt(pop),
			\amp,      popDelta.linlin(0, 30, 0.08, 0.30),
			\sus,      popDelta.linlin(0, 30, 0.15, 0.6),
			\pan,      ((leftSum - rightSum) / safeArea).clip(-0.7, 0.7)
		]);
	};

	prevPop = pop;
	stateHist.add((s1: sig1, s2: sig2));
	if(stateHist.size > historyLen) { stateHist.removeAt(0) };

	if(stuckFrames > stuckThreshold) { perturbAndReset.value(states) };
	if(~caForceReset == true) {
		~caForceReset = false;
		perturbAndReset.value(states);
	};
};

fireForceReset = { ~caForceReset = true };

{
	var view    = life.instVarAt(\view);
	var oldKey  = view.keyDownAction;
	view.keyDownAction = {|v, char, mods, unicode, keycode, key|
		if(char == $n) { fireForceReset.value }
		            { oldKey.value(v, char, mods, unicode, keycode, key) };
	};
}.value;

life.play;

)
