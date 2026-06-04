////////////////////////////////////////////////////////////////
//
//                       2D Life CA
//
////////////////////////////////////////////////////////////////

/*
   Native 2D Life-like cellular automaton.
   Keys:  [ ] cycle preset   r randomise   c clear   click toggle   space pause
*/


( Quarks.fetchDirectory(true); Quarks.install("SafetyNet"); thisProcess.recompile )


(

/* Short tonal blip — one per visible cell birth or death. */
SynthDef(\blip, {|freq=440, amp=0.3, dur=0.18, pan=0|
	var env = EnvGen.kr(Env.perc(0.005, dur, 1, -4), doneAction: 2);
	var sig = SinOsc.ar(freq) * env * amp;
	OffsetOut.ar(0, Pan2.ar(sig, pan));
}).add;

)


(

var n = 50, winSize = 600, fps = 12, fadeAmount = 0.82;
var presets = [
	["Conway",   "B3/S23"],
	["HighLife", "B36/S23"],
	["Seeds",    "B2/S"],
	["Maze",     "B3/S12345"],
	["Coral",    "B3/S45678"]
];
var presetIndex = 0;
var cur, nxt, prev, birth, survive, cellSize, clock;
var running = true;
var parseRule, randomize, clear, step, sonify;
var maxBirthsPerStep = 5;     /* cap events so dense generations don't flood the server */
var maxDeathsPerStep = 2;
var lowMidi = 40, highMidi = 76;   /* pitch range (E2 .. E5) keyed off row */


/* String:collect would return a String, so collect digits into an Array explicitly. */
parseRule = {|str|
	var parts = str.toUpper.split($/);
	birth   = parts[0].select({|ch| ch.isDecDigit }).collectAs({|ch| ch.digit }, Array);
	survive = parts[1].select({|ch| ch.isDecDigit }).collectAs({|ch| ch.digit }, Array);
};

randomize = { cur = Array.fill(n, { Int8Array.fill(n, { [0, 1].choose }) }) };
clear     = { cur = Array.fill(n, { Int8Array.fill(n, 0) }) };

step = {
	nxt = Array.fill(n, { Int8Array.fill(n, 0) });
	n.do {|y|
		n.do {|x|
			var count = 0;
			[-1, 0, 1].do {|dy|
				[-1, 0, 1].do {|dx|
					if((dx != 0) || (dy != 0), {
						count = count + cur[(y + dy) % n][(x + dx) % n];
					});
				};
			};
			nxt[y][x] = if(cur[y][x] == 1,
				{ survive.includes(count).if(1, 0) },
				{ birth.includes(count).if(1, 0) });
		};
	};
	cur = nxt;
};

/* Diff the previous grid against the current to find birth (0→1) and
   death (1→0) events. Each event fires a brief tonal blip whose pitch
   is read off the cell's row — top of the grid = high pitch, bottom = low.
   Pan is read off the column. So you hear the grid: every visible
   cell-state change is one audible note.                              */
sonify = {
	var births = List.new, deaths = List.new;
	n.do {|y|
		n.do {|x|
			if(cur[y][x] != prev[y][x], {
				if(cur[y][x] == 1, { births.add([y, x]) }, { deaths.add([y, x]) });
			});
		};
	};

	/* births → bright short notes */
	births.scramble.keep(maxBirthsPerStep).do {|p|
		var row = p[0], col = p[1];
		var midi = highMidi - ((row / (n - 1)) * (highMidi - lowMidi));
		var pan  = ((col / (n - 1)) * 2) - 1;
		Synth(\blip, [\freq, midi.midicps, \amp, 0.16, \dur, 0.15, \pan, pan * 0.7]);
	};

	/* deaths → softer / longer / one octave below */
	deaths.scramble.keep(maxDeathsPerStep).do {|p|
		var row = p[0], col = p[1];
		var midi = (highMidi - ((row / (n - 1)) * (highMidi - lowMidi))) - 12;
		var pan  = ((col / (n - 1)) * 2) - 1;
		Synth(\blip, [\freq, midi.midicps, \amp, 0.08, \dur, 0.35, \pan, pan * 0.5]);
	};

	/* snapshot for next step's diff */
	prev = cur.collect(_.copy);
};

parseRule.value(presets[presetIndex][1]);
randomize.value;
prev = cur.collect(_.copy);

w = Window("Life CA: " ++ presets[presetIndex][0], Rect(200, 100, winSize, winSize)).front;
v = UserView(w, Rect(0, 0, winSize, winSize));
v.background     = Color.fromHexString("171b21");
v.clearOnRefresh = false;
cellSize         = winSize / n;

v.drawFunc = {
	Pen.fillColor = Color.fromHexString("171b21").alpha_(1 - fadeAmount);
	Pen.fillRect(Rect(0, 0, winSize, winSize));
	Pen.fillColor = Color.fromHexString("A3CEF1");
	n.do {|y|
		n.do {|x|
			if(cur[y][x] == 1, {
				Pen.addRect(Rect(x * cellSize, y * cellSize, cellSize + 0.5, cellSize + 0.5));
			});
		};
	};
	Pen.fill;
};

v.mouseDownAction = {|view, x, y|
	var cx = (x / cellSize).floor.asInteger.clip(0, n - 1);
	var cy = (y / cellSize).floor.asInteger.clip(0, n - 1);
	cur[cy][cx] = 1 - cur[cy][cx];
	v.refresh;
};

v.keyDownAction = {|view, char|
	var changeRule = {|delta|
		presetIndex = (presetIndex + delta) % presets.size;
		parseRule.value(presets[presetIndex][1]);
		w.name = "Life CA — " ++ presets[presetIndex][0];
	};
	case
	{ char == $  } { running = running.not }
	{ char == $r } { randomize.value }
	{ char == $c } { clear.value }
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
