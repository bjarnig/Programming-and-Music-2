////////////////////////////////////////////////////////////////
//
//                          Fractals
//
////////////////////////////////////////////////////////////////

(

SynthDef(\fractalTone, {
	|out=0, freq=440, amp=0.2, atk=0.01, rel=0.2, pan=0|
	var sig, env;
	env = EnvGen.ar(Env.perc(atk, rel), doneAction: 2);
	sig = SinOsc.ar(freq) + SinOsc.ar(freq * 2, mul: 0.3) + SinOsc.ar(freq * 3, mul: 0.1);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;

)

/////////////////////// Fractal Sequence ////////////////////////

(

~fractalMelody = {
	|baseNote, intervals, duration, amp, depth, synth = \fractalTone|

	Routine {
		intervals.do { |interval|
			var note = baseNote + interval;

			Synth(synth, [
				\freq, note.midicps,
				\amp, amp,
				\rel, duration * 0.8
			]);

			// Recursion: play smaller version within each note
			if(depth > 1) {
				~fractalMelody.(
					note + 12,
					intervals,
					duration / intervals.size,
					amp * 0.7,
					depth - 1,
					synth
				);
			};

			duration.wait;
		};
	}.play;
};

// Execute: depth 5 fractal
~fractalMelody.(40, [0, 2, 5], 1.5, 0.25, 5);

)


/////////////////////// Thue–Morse sequence ////////////////////////

/*

Start: 0, 0 → 01, 1 → 10
Output: 0, 01, 0110, 01101001, ...

*/

(

~thueMorse = { |iterations|
	var sequence = [0];

	iterations.do {
		sequence = sequence.collect { |bit|
			if(bit == 0) { [0, 1] } { [1, 0] }
		}.flat;
	};
	sequence
};

)

(

var tm = ~thueMorse.(5);
var pitchA = 60, pitchB = 72;

"Thue-Morse: ".post; tm.postln;

fork {
	tm.do { |bit|
		var pitch = if(bit == 0) { pitchA } { pitchB };

		Synth(\fractalTone, [
			\freq, pitch.midicps,
			\amp, 0.15,
			\rel, 0.15,
			\pan, if(bit == 0) { -0.4 } { 0.4 }
		]);

		0.1.wait;
	};
};

)

/////////////////////// Sierpinski triangle ////////////////////////

(

~sierpinskiPitches = { |basePitches, depth|
	var result = basePitches.copy;

	depth.do {
		var newPitches = [];
		(result.size - 1).do { |i|
			newPitches = newPitches.add(result[i]);
			newPitches = newPitches.add((result[i] + result[i + 1]) / 2);
		};
		newPitches = newPitches.add(result.last);
		result = newPitches;
	};

	result;
};

)

// Generate and play Sierpinski pitches

(

var basePitches = [40, 80, 50];
var sierpinski = ~sierpinskiPitches.(basePitches, 3);

"Sierpinski pitches: ".post; sierpinski.postln;

fork {
	sierpinski.do { |pitch|
		Synth(\fractalTone, [
			\freq, pitch.midicps,
			\amp, 0.15,
			\rel, 0.3
		]);
		0.05.wait;
	};
};

)
