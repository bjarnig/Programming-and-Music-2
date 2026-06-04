////////////////////////////////////////////////////////////////
//
//                       Additive CA
//
////////////////////////////////////////////////////////////////


/* 16×16 Life CA to 16-oscillator additive voice. Each column drives one partial. */

( Quarks.fetchDirectory(true); Quarks.install("NatureToolkit"); thisProcess.recompile )


(

SynthDef(\additive16, {|master=0.45, gate=1, lagTime=0.25, modRatio=1.5, modIndex=2|
	var freqs       = \freqs.kr(Array.fill(16, 220));
	var amps        = \amps.kr(Array.fill(16, 0));
	var laggedFreqs = Lag.kr(freqs, lagTime);
	var laggedAmps  = Lag.kr(amps,  lagTime);
	var sigs = PMOsc.ar(laggedFreqs, laggedFreqs * modRatio, modIndex) * laggedAmps;
	var env  = EnvGen.kr(Env.asr(0.3, 1, 0.4), gate, doneAction: 2);
	var mix  = Mix.ar(sigs) * master * env;
	Out.ar(0, mix ! 2);
}).add;

)

(

var n = 16, stepFps = 5, lagTime = 0.25;
var stuckThreshold = 22, historyLen = 14, maxOscAmp = 0.07;
var fLow = 50, fHigh = 8000;
var baseFreqs;
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
	["LongLife",   "5/345"]
];
var stateHist   = List.new;
var stuckFrames = 0, resetCount = 0;
var currentName = "Conway", currentRule = "23/3";
var life, additive, pickNewRule, perturbAndReset, isStuck;

baseFreqs = Array.fill(n, {|i| fLow * ((fHigh / fLow) ** (i / (n - 1))) });

pickNewRule = {
	var pick = ruleList.reject({|r| r[0] == currentName }).choose;
	currentName = pick[0];
	currentRule = pick[1];
};

perturbAndReset = {|states|
	pickNewRule.value;
	n.do {|i| n.do {|j| states[i][j] = (0.4.coin).asInteger } };
	life.setRule(currentRule);
	stateHist.clear;
	stuckFrames = 0;
	resetCount  = resetCount + 1;
	("[reset #" ++ resetCount ++ "]  " ++ currentName ++ "  (" ++ currentRule ++ ")").postln;
};

isStuck = {|sig1, sig2, pop|
	var stuck = false;
	if(pop == 0) { stuck = true };
	stateHist.do {|h|
		if((h.s1 == sig1) and: { h.s2 == sig2 }) { stuck = true };
	};
	stuck
};


~addLife  !? _.stop;
~addSynth !? { |s| s.set(\gate, 0) };

life = ModernLife.new(n, 480);
life.setRule(currentRule);
life.fps        = stepFps;
life.fadeAmount = 0.95;
~addLife = life;

additive  = Synth(\additive16, [\master, 0.45, \lagTime, lagTime]);
~addSynth = additive;

life.userFunc = {|states, pop|
	var freqArr = Array.fill(n, {|col|
		var colCells = Array.fill(n, {|row| states[row][col] });
		var live     = colCells.sum;
		var centroid = if(live > 0,
			{ colCells.collect({|v, i| v * i }).sum / live },
			{ (n - 1) * 0.5 });
		baseFreqs[col] * centroid.linlin(0, n - 1, 1.06, 0.94)
	});
	var ampArr = Array.fill(n, {|col|
		var live = Array.fill(n, {|row| states[row][col] }).sum;
		(live / n) * maxOscAmp
	});
	var sig1 = pop;
	var sig2 = states.collect({|r, i| r.sum * (i + 1) }).sum;
	var stuck = isStuck.value(sig1, sig2, pop);

	additive.set(\freqs, freqArr, \amps, ampArr);

	if(stuck) { stuckFrames = stuckFrames + 1 } { stuckFrames = 0 };
	stateHist.add((s1: sig1, s2: sig2));
	if(stateHist.size > historyLen) { stateHist.removeAt(0) };

	if(stuckFrames > stuckThreshold) { perturbAndReset.value(states) };
	if((pop == 0) and: { stuckFrames > 5 }) { perturbAndReset.value(states) };
};

life.play;

)