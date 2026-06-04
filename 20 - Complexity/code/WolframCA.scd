////////////////////////////////////////////////////////////////
//
//                       Elementary CA
//
////////////////////////////////////////////////////////////////

/*

One-dimensional cellular automata — Stephen Wolfram's 256 "elementary" rules.
   Keys:  [ ] cycle rule preset   r random row   s single seed   space pause
*/


( Quarks.fetchDirectory(true); Quarks.install("SafetyNet"); thisProcess.recompile )


(

/* Short tonal blip — one per audible cell per generation. */
SynthDef(\blip, {|freq=440, amp=0.3, dur=0.18, pan=0|
	var env = EnvGen.kr(Env.perc(0.005, dur, 1, -4), doneAction: 2);
	var sig = SinOsc.ar(freq) * env * amp;
	OffsetOut.ar(0, Pan2.ar(sig, pan));
}).add;

)


(

var width = 128, rows = 128, winSize = 640, fps = 12;
var presets = [30, 90, 110, 150, 184, 54, 60];
var presetIndex = 1;
var rule, ruleTable, current, history, cellW, cellH, clock;
var running = true, seedMode = \single;
var buildTable, seed, step, sonify;
var notesPerStep = 6;                  /* cap so dense rows don't flood the server */
var lowMidi = 40, highMidi = 80;       /* pitch span keyed off column position    */


buildTable = {|r| Array.fill(8, {|i| (r >> i) & 1 }) };

seed = {
	current = Array.fill(width, 0);
	if(seedMode == \single,
		{ current[width div: 2] = 1 },
		{ current = Array.fill(width, { [0, 1].choose }) });
	history = List.new;
	history.add(current.copy);
};

step = {
	var next = Array.fill(width, 0);
	width.do {|i|
		var l = current[(i - 1) % width];
		var c = current[i];
		var r = current[(i + 1) % width];
		next[i] = ruleTable[(l << 2) | (c << 1) | r];
	};
	current = next;
	history.add(current.copy);
	if(history.size > rows, { history.removeAt(0) });
};

/* Each new row is read as a short arpeggio. Find the alive cells,
   sample up to notesPerStep of them, and fire a \blip per cell —
   pitch maps from column position, pan also from column position.
   The rule's behaviour is now directly audible: Rule 30 stays
   dense and noisy, Rule 90 leaves regular gaps, Rule 110 alternates
   busy and sparse phrases.                                        */
sonify = {
	var aliveCols = current.collect({|v, i| if(v == 1, i, nil) }).reject(_.isNil);
	if(aliveCols.size > 0, {
		var picks = aliveCols.scramble.keep(notesPerStep.min(aliveCols.size));
		picks.do {|col, k|
			var midi = lowMidi + ((col / (width - 1)) * (highMidi - lowMidi));
			var pan  = ((col / (width - 1)) * 2) - 1;
			/* tiny intra-frame stagger so the row reads as an arpeggio */
			SystemClock.sched(k * 0.025, {
				Synth(\blip, [\freq, midi.midicps, \amp, 0.12, \dur, 0.18, \pan, pan * 0.7]);
				nil
			});
		};
	});
};


rule      = presets[presetIndex];
ruleTable = buildTable.value(rule);
seed.value;

w = Window("Elementary CA — Rule " ++ rule, Rect(200, 100, winSize, winSize)).front;
v = UserView(w, Rect(0, 0, winSize, winSize));
v.background = Color.fromHexString("171b21");

cellW = winSize / width;
cellH = winSize / rows;

v.drawFunc = {
	Pen.fillColor = Color.fromHexString("A3CEF1");
	history.do {|row, y|
		row.do {|cell, x|
			if(cell == 1, {
				Pen.addRect(Rect(x * cellW, y * cellH, cellW + 0.5, cellH + 0.5));
			});
		};
	};
	Pen.fill;
};

v.keyDownAction = {|view, char|
	var changeRule = {|delta|
		presetIndex = (presetIndex + delta) % presets.size;
		rule        = presets[presetIndex];
		ruleTable   = buildTable.value(rule);
		w.name      = "Elementary CA — Rule " ++ rule;
		seed.value;
	};
	case
	{ char == $  } { running = running.not }
	{ char == $r } { seedMode = \random; seed.value }
	{ char == $s } { seedMode = \single; seed.value }
	{ char == $] } { changeRule.value(1) }
	{ char == $[ } { changeRule.value(-1) };
};

clock = Routine {
	inf.do {
		if(running, { step.value; sonify.value });
		v.refresh;
		(1 / fps).wait;
	}
}.play(AppClock);

w.onClose = { clock.stop };

)
