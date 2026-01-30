////////////////////////////////////////////////////////////////
//
//                 Task 0: Basics
//
////////////////////////////////////////////////////////////////


//////// Ndef basics ////////


Ndef.clear;

Ndef(\t).fadeTime_(2).play;

(

Ndef(\t, {
	arg freq = 200, width = 0.5;
	VarSaw.ar(freq + [0, 2], width: width, mul: 0.05);
});

)

Ndef(\t).set(\freq, 400); // immediate change Ndef(\t).xset(\freq, 400); // crossfaded change


( // after a source change, freq remains at 400, even though the default is 200

Ndef(\t, {
	arg freq = 200, width = 0.5;
	var sig = SinOsc.ar(freq.poll + [0, 2], mul: 0.1); sig = sig * LFPulse.kr(6, 0, 0.3).lag(0.03);
});

)

( // create and activate an LFO

Ndef(\lfo, {LFTri.kr(0.25).exprange(300, 1500)});
Ndef(\t).xset(\freq, Ndef(\lfo));

)

// clear all
Ndef.all.do({ |n| n.clear(2) });


//////// Tdef and Ndef interaction ////////


Ndef(\pad).fadeTime_(3).play;

(

Ndef(\pad, { |notes = #[40, 41, 46, 54]|
	var sig;

	sig = notes.collect({ |n|
		4.collect({ Saw.ar(
			freq: (n + LFNoise2.kr(0.2).bipolar(0.25)).midicps,
			mul: 0.1 );
	}).sum });

	sig = Splay.ar(sig.scramble, 0.5);
	sig = (sig * 0.5) + RLPF.ar(sig, SinOsc.ar(20).range(notes[2].midicps, notes[3].midicps * 4), 0.5); });
)

(

Tdef(\seq, {

	var chords = Pseq([
		[36, 37, 42, 49],
		[33, 39, 44, 52],
		[38, 44, 49, 56],
		[40, 41, 46, 54],
	], inf).asStream;

	loop {

		Ndef(\pad).xset(\notes, chords.next.postln);
		8.wait;
	}

}).play

)

// clean up
Tdef(\seq).stop; Ndef(\pad).clear(8);
