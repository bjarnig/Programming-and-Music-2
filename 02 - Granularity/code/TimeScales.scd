////////////////////////////////////////////////////////////////
//
//            			Timescales & Synthesis
//
////////////////////////////////////////////////////////////////

Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)



////////////////////////// Timescales ///////////////////////////

/* From pulses to tones and back again */

// Up
{ Impulse.ar (Line.kr(1, 120, 15))}.play;


// Down
{ Impulse.ar (XLine.kr(1000, 1, 5))}.play;


// Up and Down
{ Impulse.ar (EnvGen.kr(Env.new([1, 1000, 1],[5, 5])))}.play;




////////////////////////// Grains ///////////////////////////

/* Simple sine grains with different envelopes, adepted from
   the SuperCollider book, chapter Microsound by Alberto De Campo.
*/

(
SynthDef(\gauss, { |amp=0.5, freq=440, sustain=0.1|
	var signal, shape, env;
	signal = SinOsc.ar(freq);
	shape = Env.sine(sustain, amp);
	env = EnvGen.ar(shape, doneAction: 2);
	OffsetOut.ar(0, signal * env ! 2);
}).add;

SynthDef(\perc, { |amp=0.5, freq=440, sustain=0.1|
	var signal, shape, env;
	signal = SinOsc.ar(freq);
	shape = Env.perc(0.1, 0.9, amp);
	env = EnvGen.ar(shape, timeScale:sustain, doneAction: 2);
	OffsetOut.ar(0, signal * env ! 2);
}).add;

SynthDef(\reversed, { |amp=0.5, freq=440, sustain=0.1|
	var signal, shape, env;
	signal = SinOsc.ar(freq);
	shape = Env.perc(0.9, 0.1, amp);
	env = EnvGen.ar(shape, timeScale:sustain, doneAction: 2);
	OffsetOut.ar(0, signal * env ! 2);
}).add;

SynthDef(\double, { |amp=0.5, freq=440, sustain=0.1|
	var signal, shape, env;
	signal = SinOsc.ar(freq) * amp;
	shape = Env([0, 1, 0, 1, 0], [0.1, 0.4, 0.4, 0.1], \sine);
	env = EnvGen.ar(shape, timeScale:sustain, doneAction: 2);
	OffsetOut.ar(0, signal * env ! 2);
}).add;
)



// Create a grain player and experiment with different settings

(
Pbindef(
	\grainPlayer,
	\instrument, \gauss,
	\dur, 0.1
).play;
)


// Envelope changes
Pbindef(\grainPlayer, \sustain, 0.01);
Pbindef(\grainPlayer, \sustain, 0.1);
Pbindef(\grainPlayer, \sustain, Pwhite(0.0001, 0.01));
Pbindef(\grainPlayer, \instrument, \perc);




// Frequency changes
Pbindef(\grainPlayer, \instrument, \perc, \sustain, 0.1);
Pbindef(\grainPlayer, \freq, 200);
Pbindef(\grainPlayer, \freq, Pwhite(100, 1000));




// Density changes
Pbindef(\grainPlayer, \dur, 0.05, \sustain, 0.01,  \freq, 400)
Pbindef(\grainPlayer, \dur, Pn(Penv([0.5, 0.01, 0.1], [4,4]), inf));
Pbindef(\grainPlayer, \dur, 0.1 * Pbrown(0.1, 1.5, 0.1))




// Relate parameters
(
Pbind(
	\instrument, \gauss,
	\freq, Pn(Penv([100, 1000, 100], [4,4])),
	\dur, Pkey(\freq) * 0.0001).play
)

(
Pbind(
	\instrument, \gauss,
	\dur, Pn(Penv([0.01, 0.5, 0.01], [4,4])),
	\sus, Pkey(\dur) * 0.01).play
)



////////////////////////// Synthesis ///////////////////////////

/* Simple synthDefs using filtered noise and sine glissandi */

(
SynthDef(\noise, { |amp=0.5, freqFrom=200, freqTo=1000, atk=0.2, sus=0.1, rel=0.8|
	var signal, shape, env;
	signal = BPF.ar(WhiteNoise.ar(amp), Line.ar(freqFrom, freqTo, sus), 2);
	shape = Env.perc(atk, rel);
	env = EnvGen.ar(shape, doneAction: 2, timeScale: sus);
	OffsetOut.ar(0, signal * env ! 2);
}).add;

SynthDef(\gliss, { |amp=0.5, freqFrom=200, freqTo=1000, sus=0.1|
	var signal, shape, env;
	signal = SinOsc.ar(Line.ar(freqFrom, freqTo, sus));
	shape = Env.sine(sus, amp);
	env = EnvGen.ar(shape, doneAction: 2);
	OffsetOut.ar(0, signal * env ! 2);
}).add;
)




(
Pbindef(
	\noises,
	\instrument, \noise,
	\freqFrom, Pn(Penv([100, 2000, 100], [4,4])),
	\freqTo, Pwhite(100, 1000, inf),
	\sus, Pkey(\freqFrom).linlin(100,2000,0.05,0.005),
	\dur, 0.01
).play;
)

Pbindef(\noises, \freqFrom, 100, \freqTo, 2000, \dur, 0.01, \sus, 0.05)




(
Pbindef(\glissandi,
    \instrument, \gliss,
	\freqFrom, Pn(Penv([100, 500, 100], [4,4])),
	\freqTo, Pn(Penv([200, 10000], [8])),
	\sus, Pkey(\freqTo).linlin(200,10000,0.05,0.005),
    \dur, 0.01
).play
)

Pbindef(\glissandi, \freqFrom, 100, \freqTo, 8000, \dur, 0.01, \sus, 0.01)
Pbindef(\glissandi, \freqFrom, 100, \freqTo, 400, \dur, 0.5, \sus, 0.5)
Pbindef(\glissandi, \freqFrom,Pwhite(100,200),\freqTo,Pwhite(1000,2000),\dur, 0.1)
