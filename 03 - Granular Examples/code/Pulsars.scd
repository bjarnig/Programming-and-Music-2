////////////////////////////////////////////////////////////////
//
//                    Pulsar Synthesis
//
////////////////////////////////////////////////////////////////


// Based on Microsound chapter my Alberto de Campo in SuperCollider book


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)

/*

A single pulsar is a particle of sound. It consists of an arbitrary pulsaret
waveform w with a period d followed by a silent time interval s.

The total duration of a pulsar is p = d + s, where
p is the pulsar period,
d is the duty cycle,
and s is silent.

Repetitions of the pulsar signal form a pulsar train.

*/


( // Buffers

{

~pulsaret = Signal.sineFill(1024, { 1.0.rand }.dup(10)); s.sync;
~pulsarbuf = Buffer.sendCollection(s, ~pulsaret, 1);

~env = Env.perc.discretize; s.sync;
~envbuf = Buffer.sendCollection(s, ~env, 1);

}.fork;

)

( // SynthDef

SynthDef(\pulsar, { |fund=10, form=100, amp=1.0, wavebuf, envbuf|
	var trig = Impulse.ar(fund);
	var grdur = form.reciprocal;
	var rate = form * BufDur.kr(wavebuf);
	Out.ar(0, GrainBuf.ar(2, trig, grdur, wavebuf, rate, 0, 4, 0, envbuf, mul:amp));
}).add;

)

( // Basic Pulsar Train

Synth(\pulsar, [\wavebuf, ~pulsarbuf, \envbuf, ~envbuf, \fund, 20, \form, 100])

)

( // Variate with envelopes

Pmono(\pulsar,
	\wavebuf, ~pulsarbuf,
	\envbuf, ~envbuf,
	\fund, 30,
	\form, Env([100,1000,10,400],[2,3,1]),
	\dur, 0.1
).trace.play

)

( // Variate with patterns

Pmono(\pulsar,
	\wavebuf, ~pulsarbuf,
	\envbuf, ~envbuf,
	\fund, Pbrown(10,300,10),
	\form, Pbrown(100,1000,10),
	\dur, 0.01
).play

)

( // Layers

var amt = 10;
var from = 10;
var to = 2000;

amt.do {|i|

Pmono(\pulsar,
	\wavebuf, ~pulsarbuf,
	\envbuf, ~envbuf,
	\fund, 10 + (10 * i),
	\form, Env([from, to, from],[5,5]),
	\amp, 1.0/amt,
	\dur, 0.01
).play

}

)
