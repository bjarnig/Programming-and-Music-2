////////////////////////////////////////////////////////////////
//
//                 Task 0: Basics
//
////////////////////////////////////////////////////////////////

Ndef.clear;

Ndef(\t).fadeTime_(2).play;
(
Ndef(\t, {
arg freq = 200, width = 0.5;
VarSaw.ar(freq + [0, 2], width: width, mul: 0.05); });
)
Ndef(\t).set(\freq, 300); // immediate change Ndef(\t).xset(\freq, 400); // crossfaded change
(
// after a source change, freq remains at 400, even though the de- fault is 200
Ndef(\t, {
arg freq = 200, width = 0.5;
var sig = SinOsc.ar(freq + [0, 2], mul: 0.1); sig = sig * LFPulse.kr(6, 0, 0.3).lag(0.03);
}); )

(
Ndef(\lfo, {LFTri.kr(0.25).exprange(300, 1500)}); Ndef(\t).xset(\freq, Ndef(\lfo));
)
Ndef.all.do({ |n| n.clear(2) });


////


Ndef(\pad).fadeTime_(3).play;
(
Ndef(\pad, { |notes = #[43, 50, 59, 66]|
	var sig;
	sig = notes.collect({ |n|
4.collect({ LFTri.ar(
freq: (n + LFNoise2.kr(0.2).bipolar(0.25)).midicps,
mul: 0.1 );
}).sum });
sig = Splay.ar(sig.scramble, 0.5);
sig = LPF.ar(sig, notes[3].midicps * 2); });
)

(
Tdef(\seq, {
var chords = Pseq([ [48, 55, 62, 64], [41, 48, 57, 64], [55, 59, 64, 69], [43, 50, 59, 66],
], inf).asStream; loop{
Ndef(\pad).xset(\notes, chords.next);
8.wait; }
}).play )
(
// clean up Tdef(\seq).stop; Ndef(\pad).clear(8); )
