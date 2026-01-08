////////////////////////////////////////////////////////////////
//
//                    L-Systems: Extended
//
////////////////////////////////////////////////////////////////


(

SynthDef(\lsysTone, {
	|out=0, freq=440, amp=0.2, atk=0.01, rel=0.3, pan=0|
	var sig, env;
	env = EnvGen.ar(Env.perc(atk, rel), doneAction: 2);
	sig = SinOsc.ar(freq) + SinOsc.ar(freq * 2.01, mul: 0.2);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;

SynthDef(\lsysPercussion, {
	|out=0, freq=500, amp=0.2, rel=0.1|
	var sig, env;
	env = EnvGen.ar(Env.perc(0.001, rel), doneAction: 2);
	sig = SinOsc.ar(freq) * SinOsc.ar(freq * 1.5);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

)

/////////////////////// L-system ////////////////////////

(

~lsystem = { |axiom, rules, iterations|
	var current = axiom;

	iterations.do {
		current = current.as(Array).collect { |char|
			rules[char] ?? char.asString
		}.join;
	};
	current
};

)

(

var axiom = "A";
var rules = ($A: "AB", $B: "A");

5.do { |i|
	var result = ~lsystem.(axiom, rules, i);
	("Iteration %: %").format(i, result).postln;
};

)


/////////////////////// Algea Growth ////////////////////////

(

var axiom = "A";
var rules = ($A: "AB", $B: "A");
var lstring = ~lsystem.(axiom, rules, 7);
var baseNote = 60;
var currentNote = baseNote;

"L-string: ".post; lstring.postln;

fork {
	lstring.do { |char|
		Synth(\lsysTone, [
			\freq, currentNote.midicps,
			\amp, 0.15,
			\rel, 0.2
		]);

		currentNote = switch(char,
			$A, { currentNote + 1 },
			$B, { currentNote - 1 },
			{ currentNote }
		);

		0.1.wait;
	};
};

)

/////////////////////// L-system for rhythms ////////////////////////

(

var axiom = "X";
var rules = ($X: "Y", $Y: "YX");
var lstring = ~lsystem.(axiom, rules, 8);
var baseDur = 0.1;
var pitches = [60, 62, 64, 65, 67];

"Rhythm L-string: ".post; lstring.postln;

fork {
	lstring.do { |char, i|
		var dur = switch(char,
			$X, { baseDur },
			$Y, { baseDur * 2 },
			{ baseDur }
		);

		Synth(\lsysPercussion, [
			\freq, pitches.wrapAt(i).midicps,
			\amp, 0.2,
			\rel, dur * 0.8
		]);

		dur.wait;
	};
};

)


/////////////////////// Turtle graphics ////////////////////////

/*

Turtle graphics commands:
  F = move forward (play note, advance pitch)
  + = turn right (transpose up)
  - = turn left (transpose down)
  [ = push state (save current pitch/parameters)
  ] = pop state (restore saved pitch/parameters)

*/

(

~turtleInterpret = { |lstring, baseNote = 60, stepSize = 2, angleStep = 5|
	var pitch = baseNote;
	var stack = [];
	var notes = [];

	lstring.do { |char|
		switch(char,
			$F, {
				notes = notes.add(pitch);
				pitch = pitch + stepSize;
			},
			$f, {
				notes = notes.add(\rest);
				pitch = pitch + stepSize;
			},
			$+, { pitch = pitch + angleStep },
			$-, { pitch = pitch - angleStep },
			$[, { stack = stack.add(pitch) },
			$], {
				if(stack.size > 0) {
					pitch = stack.last;
					stack = stack.drop(-1);
				};
			}
		);
	};

	notes
};

)

// Koch curve L-system

(

var axiom = "F";
var rules = ($F: "F+F--F+F");
var lstring = ~lsystem.(axiom, rules, 3);
var notes;

"Koch L-string: ".post; lstring.postln;

notes = ~turtleInterpret.(lstring, 55, 2, 7);
"Notes: ".post; notes.postln;

fork {
	notes.do { |note|
		if(note != \rest) {
			Synth(\lsysTone, [
				\freq, note.midicps,
				\amp, 0.15,
				\rel, 0.15
			]);
		};
		0.1.wait;
	};
};

)

// Dragon curve L-system

(

var axiom = "FX";
var rules = (
	$X: "X+YF+",
	$Y: "-FX-Y"
);
var lstring = ~lsystem.(axiom, rules, 8);
var notes;

"Dragon curve (first 50 chars): ".post; lstring[0..50].postln;

notes = ~turtleInterpret.(lstring, 60, 1, 3);

fork {
	notes[0..80].do { |note|
		if(note != \rest) {
			Synth(\lsysTone, [
				\freq, note.midicps,
				\amp, 0.12,
				\rel, 0.12
			]);
		};
		0.08.wait;
	};
};

)
