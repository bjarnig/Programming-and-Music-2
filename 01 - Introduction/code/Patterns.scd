////////////////////////////////////////////////////////////////
//
//                   		Patterns
//
////////////////////////////////////////////////////////////////


// - Pbind Pitch Model -

(

SynthDef(\sine, {
	|amp=0.1, freq=440, atk=0.001, rel=1|
	var env, sig;
	env = EnvGen.kr(Env.perc(atk, rel), doneAction:2);
	sig = SinOsc.ar(freq) * env;
	Out.ar(0, sig * amp);
}).add;

)

// detune (in hertz)
Pbind(\instrument, \sine,  \dur, 0.2, \freq, 200, \detune, Pn(Pseries(10,10,10,10))).play

// using midinotes directly
Pbind(\instrument, \sine, \dur, 0.2, \midinote, Pseq([60,62,65], inf)).play

// within an octave
Pbind(\instrument, \sine, \dur, 0.2, \note, Pseq([1,3,5], inf), \octave, Pseq([6,6,5,5,7], inf)).play

// within a scale
Pbind(\instrument, \sine, \dur, 0.2, \degree, Pseq([1,3,5, Pseq([6,7],2)], inf), \scale, Scale.ionian).play

// divide the octave differently than in 12 steps using \stepsPerOctave
Pbind(\instrument, \sine, \dur, 0.2, \stepsPerOctave, 31, \note, Pseq([1,3,5], inf)).play

// calling play returns an EventStreamPlayer with various ways to play the pattern
p = Pbind(\instrument, \sine, \dur, 0.2, \freq, Pwhite(400,600)).play

p.class
p.stop
p.start
p.mute
p.unmute
p.pause
p.resume
p.reset


// Use Pbindef to gradually build up a Pbind
Pbindef(\test, \instrument, \sine).play
Pbindef(\test, \dur, 0.3)


// Ppatlace, lace one from each patter
(
p = Pbind(
	\instrument, \sine,
    \midinote, Ppatlace([ Pexprand(70,80), Pwhite(50,58,inf)], inf),
    \dur, 0.1
).play;
)

( // Ptuple, combine patterns to arrays instead of values. Useful for chords or multichannel expansion.

Pbind(
	\instrument, \sine,
	\freq, Ptuple([ Pwhite(1000,2000), Pwhite(600,800), Pwhite(200,300) ], inf),
	\dur, 0.5
).play

)


( // Chords and Place

c = [[0, 3, 7], [2, 5, 8], [3, 7, 10]];

Pbind(\instrument, \sine, \note, Pseq(c,inf), \dur, 0.4).play;

Pbind(\instrument, \sine, \note, Place(c,inf), \dur, 0.2).trace.play;

)


( // Pslide, slide values from the list to output value

Pbind(
	\instrument, \sine,
	\note, Pslide([1, 2, 3, 4, 5], inf, 3, 1).trace,
	\dur, 0.15;
).play;

)


( // Audio rate LFO's to patterns

c = Bus.control(s,1);

SynthDef(\snd, {|amp=0.1, freq=100, atk=0.05, rel=0.25, gate=1, lpf=200, q=0.2|
	var signal = BMoog.ar(VarSaw.ar(freq ! 2), lpf, q) * amp;
	Out.ar(0, signal * EnvGen.ar(Env.asr(atk,1,rel),gate, doneAction:2));
}).add;

)

( // Map to Pbind

{ Out.kr(c, LFDNoise3.kr(3).range(10, 2000)) }.play;

p = Pbind(
	\instrument, \snd,
	\dur, 0.05,
	\amp, 0.1,
	\freq, Pfunc({ c.getSynchronous }),
	\lpf, Pkey(\freq) * 2
).trace.play;

)
