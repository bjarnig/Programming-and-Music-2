////////////////////////////////////////////////////////////////
//
//                 Pulsar Synthesis, Advanced
//
////////////////////////////////////////////////////////////////

/* Pulsars.scd builds the train: a pulsaret of duration d, a silence of
   duration s, and a period p = d + s. Formant is 1/d and fundamental is 1/p,
   and the two are independent.

   That is a texture generator. Three additions turn it into something a piece
   can be made of.

   Masking decides which pulses sound at all. Roads takes the term from
   Xenakis: a mask is a rule applied to the train after it has been generated,
   and it is what gives pulsar synthesis its rhythm. Three kinds are here:
   probability, burst and rest, and channel.

   Flux is bounded randomness. A pulsar train with fixed parameters is
   recognisably synthetic within a second. A slow bounded walk on top of a
   trajectory is not, and the walk has to be bounded or it leaves the range.

   Resonance treats the train as an excitation rather than as the sound. A
   pulsar has a wide spectrum and a sharp attack, which is what a resonator
   wants. The resonator carries the pitch and the train carries the rhythm.

   Amplitude: every layered example divides by the number of layers, because
   these do sum.
*/


//////////////// Buffers ////////////////

( // three pulsarets and one envelope

{
	// a single sine: the formant is one clean peak
	~pSine = Buffer.alloc(s, 2048, 1); s.sync;
	~pSine.sine1([1.0], asWavetable: false);

	// ten random partials: a formant with an internal colour
	~pRand = Buffer.sendCollection(s, Signal.sineFill(2048, { 1.0.rand }.dup(10)), 1);

	// odd harmonics falling as 1/n^2, plus five inharmonic partials on top
	~pOdd = Buffer.sendCollection(s, Signal.sineFill(2048,
		Array.fill(20, { |i| if (i.even) { 0 } { 1 / (i + 1).squared } })
			++ [0.2, 0.15, 0.1, 0.08, 0.05],
		Array.fill(25, { 2pi.rand })), 1);

	~envbuf = Buffer.sendCollection(s, Env.perc.discretize, 1);

	s.sync;
	"pulsarets ready".postln;
}.fork;

)


//////////////// The SynthDef ////////////////

( /* One definition for everything below. Every addition is off by default, so
     with no arguments beyond fund and form it is the plain train again. */

SynthDef(\pulsarM, { |wavebuf, envbuf, fund = 40, form = 400, amp = 0.3,
	fmRatio = 1, fmAmt = 0, fluxAmt = 0, fluxRate = 8,
	prob = 1, burst = 1, rest = 0, chanMask = 0, centerMask = 1, pan = 0|

	var flux, trig, grain, rate, mask, sig;

	// flux: a slow bounded walk around 1, multiplying both frequencies
	flux = LFDNoise3.ar(fluxRate, fluxAmt, 1).lag(0.2);
	grain = form * flux;
	trig = Impulse.ar(fund * LFDNoise3.kr(fluxRate, fluxAmt * 0.5, 1).lag(0.2));

	// masking, in the order Roads gives: first drop pulses, then group them
	trig = CoinGate.ar(prob, trig);
	trig = trig * Demand.ar(trig, 0, Dseq([Dser([1], burst), Dser([0], rest)], inf));

	// channel mask: n pulses left, n right, then centerMask in the middle
	mask = Demand.ar(trig, 0, Dseq([
		Dser([-1], chanMask), Dser([1], chanMask), Dser([0], centerMask)], inf)).lag(0.005);

	// the pulsaret is read once per pulse, so rate sets the formant
	rate = grain * BufDur.kr(wavebuf);
	rate = rate * (1 + (SinOsc.ar(grain * fmRatio) * fmAmt));

	sig = GrainBuf.ar(2, trig, grain.reciprocal, wavebuf, rate, 0, 4,
		(pan + mask).clip(-1, 1), envbuf, 512, amp);

	Out.ar(0, LeakDC.ar(sig));
}).add;

)


//////////////// The pulsaret ////////////////

( // the same train three times; only the waveform in the buffer changes
Pbind(\instrument, \pulsarM, \envbuf, ~envbuf, \fund, 40, \form, 500,
	\amp, 0.3, \dur, 2,
	\wavebuf, Pseq([~pSine, ~pRand, ~pOdd].collect(_.bufnum), 1)).play;
)


//////////////// Masking ////////////////

( // probability: each pulse survives with probability prob
Pmono(\pulsarM, \wavebuf, ~pRand.bufnum, \envbuf, ~envbuf,
	\fund, 60, \form, 600, \amp, 0.3,
	\prob, Pseq([1.0, 0.8, 0.5, 0.25, 0.1], inf), \dur, 1.5).play;
)

( // burst and rest: the train is grouped into a rhythm
Pmono(\pulsarM, \wavebuf, ~pRand.bufnum, \envbuf, ~envbuf,
	\fund, 80, \form, 700, \amp, 0.3,
	\burst, Pseq([5, 3, 7, 2], inf), \rest, Pseq([3, 1, 2, 6], inf), \dur, 1).play;
)

( // channel mask: consecutive pulses land in different places
Pmono(\pulsarM, \wavebuf, ~pOdd.bufnum, \envbuf, ~envbuf,
	\fund, 50, \form, 400, \amp, 0.3,
	\chanMask, Pseq([1, 2, 4], inf), \centerMask, Pseq([1, 0, 2], inf), \dur, 2).play;
)

( // all three at once, which is where the rhythm stops being regular
Pmono(\pulsarM, \wavebuf, ~pOdd.bufnum, \envbuf, ~envbuf,
	\fund, 90, \form, Pbrown(300, 1400, 120), \amp, 0.3,
	\prob, 0.75, \burst, Prand([3, 5, 8], inf), \rest, Prand([1, 2, 4], inf),
	\chanMask, 2, \centerMask, 1, \dur, 0.4).play;
)


//////////////// Flux ////////////////

( // the same train with and without flux; listen for how quickly it settles
Pmono(\pulsarM, \wavebuf, ~pRand.bufnum, \envbuf, ~envbuf,
	\fund, 45, \form, 550, \amp, 0.3,
	\fluxAmt, Pseq([0, 0.05, 0.15, 0.35], inf), \fluxRate, 8, \dur, 3).play;
)

( /* Flux written on the pattern side instead: a trajectory times a bounded
     random walk. The walk is a value that remembers, so it is a Pfunc over a
     variable, and the two are combined with Pkey. */

var formDrift = 1.0, fundDrift = 1.0;

Pmono(\pulsarM, \wavebuf, ~pOdd.bufnum, \envbuf, ~envbuf, \amp, 0.3, \dur, 0.1,
	\formBase, Pseg(Pseq([200, 1600, 400], inf), Pseq([8, 6, 10], inf), \exp),
	\fundBase, Pseg(Pseq([20, 70, 12], inf), Pseq([9, 7, 11], inf), \lin),
	\formDrift, Pfunc { formDrift = (formDrift * rrand(0.985, 1.015)).clip(0.75, 1.35) },
	\fundDrift, Pfunc { fundDrift = (fundDrift * rrand(0.99, 1.01)).clip(0.8, 1.25) },
	\form, Pkey(\formBase) * Pkey(\formDrift),
	\fund, Pkey(\fundBase) * Pkey(\fundDrift)).play;
)


//////////////// Formant FM ////////////////

( /* Modulating the read rate modulates the formant, so the sidebands appear
     around the formant peak and the fundamental is untouched. */

Pmono(\pulsarM, \wavebuf, ~pSine.bufnum, \envbuf, ~envbuf,
	\fund, 35, \form, 500, \amp, 0.3, \dur, 2,
	\fmRatio, Pseq([1, 1.5, 2, 3.7], inf), \fmAmt, Pseq([0.05, 0.2, 0.5], inf)).play;
)


//////////////// The train as an excitation ////////////////

( // three resonated versions of the same train

SynthDef(\pulsarRingz, { |wavebuf, envbuf, fund = 8, form = 300, amp = 0.2,
	ringFreq = 220, ringDecay = 0.2, ringMix = 0.5, pan = 0|
	var trig = Impulse.ar(fund);
	var sig = GrainBuf.ar(2, trig, form.reciprocal, wavebuf,
		form * BufDur.kr(wavebuf), 0, 4, pan, envbuf, 512, amp);
	sig = XFade2.ar(sig, Ringz.ar(sig, ringFreq, ringDecay) * 0.2, ringMix * 2 - 1);
	Out.ar(0, LeakDC.ar(sig));
}).add;

SynthDef(\pulsarComb, { |wavebuf, envbuf, fund = 8, form = 300, amp = 0.2,
	combFreq = 220, combDecay = 0.3, combMix = 0.5, pan = 0|
	var trig = Impulse.ar(fund);
	var sig = GrainBuf.ar(2, trig, form.reciprocal, wavebuf,
		form * BufDur.kr(wavebuf), 0, 4, pan, envbuf, 512, amp);
	sig = XFade2.ar(sig, CombL.ar(sig, 0.2, combFreq.reciprocal, combDecay),
		combMix * 2 - 1);
	Out.ar(0, LeakDC.ar(sig));
}).add;

/* A bank rather than one filter. A narrow BPF is the wrong tool here: at an RQ
   of 0.08 the passband at 110 Hz is about 9 Hz wide, so it throws away almost
   all of a pulsaret's energy and the result is 40 dB below the others. A
   resonator rings instead of passing, so it keeps what it is given. */

SynthDef(\pulsarKlank, { |wavebuf, envbuf, fund = 30, form = 2000, amp = 0.3,
	decay = 1, mix = 0.85, pan = 0|
	var trig = Impulse.ar(fund);
	var sig = GrainBuf.ar(2, trig, form.reciprocal, wavebuf,
		form * BufDur.kr(wavebuf), 0, 4, pan, envbuf, 512, amp);
	var res = DynKlank.ar(`[\freqs.kr(#[110, 164, 247, 371, 556, 833]), nil,
		\decays.kr(#[1, 1, 1, 1, 1, 1]) * decay], sig);
	Out.ar(0, LeakDC.ar(XFade2.ar(sig, res * 0.1, mix * 2 - 1)));
}).add;

// any set of frequencies will do; this one is a stack of fifths, detuned
~freqs = [110, 164, 247, 371, 556, 833];

)

( // one Ringz layer per frequency: the set is heard as a chord, struck by the train
~freqs.do { |f, i|
	Pmono(\pulsarRingz, \wavebuf, ~pRand.bufnum, \envbuf, ~envbuf,
		\form, 400, \ringFreq, f, \ringMix, 0.7,
		\ringDecay, Env([0.15, 0.5, 0.1], [10, 12], \sin),
		\fund, Pbrown(1, 9, 2), \pan, i.linlin(0, ~freqs.size - 1, -0.9, 0.9),
		\amp, 0.5 / ~freqs.size, \dur, 0.25).play;
};
)

( // comb delays tuned to the same set: the resonance is a pitch and an echo at once
~freqs.do { |f, i|
	Pmono(\pulsarComb, \wavebuf, ~pRand.bufnum, \envbuf, ~envbuf,
		\form, Pseg(Pseq([f, f * 6, f * 0.5], inf), Pseq([7, 5, 9], inf), \exp),
		\fund, Pseg(Pseq([20, 8, 34], inf), Pseq([6, 11, 8], inf), \lin),
		\combFreq, f, \combDecay, 0.4, \combMix, 0.55,
		\pan, i.linlin(0, ~freqs.size - 1, -0.9, 0.9),
		\amp, 0.5 / ~freqs.size, \dur, 0.1).play;
};
)

( /* The whole set in one bank, struck by one train. The pulsaret is short, so
     each pulse is close to a click and excites all six at once. */

Pmono(\pulsarKlank, \wavebuf, ~pOdd.bufnum, \envbuf, ~envbuf,
	\freqs, ~freqs, \decays, ~freqs.collect { 1.0 },
	\form, 2000, \mix, 0.85, \amp, 0.15,
	\fund, Pseg(Pseq([18, 45, 24], inf), Pseq([8, 6, 10], inf), \exp),
	\decay, Pseg(Pseq([0.6, 2.5, 1.0], inf), Pseq([9, 7, 11], inf), \lin),
	\dur, 0.1).play;
)

( // the same bank with the decays uneven, so the set is heard as a chord voiced
Pmono(\pulsarKlank, \wavebuf, ~pRand.bufnum, \envbuf, ~envbuf,
	\freqs, ~freqs, \decays, [3.0, 0.4, 1.6, 0.3, 2.2, 0.5],
	\form, 2500, \mix, 0.9, \amp, 0.2, \fund, 30, \dur, 0.2).play;
)


//////////////// Walking the set ////////////////

( /* One synth per frequency, all held, each stepping to the next frequency in
     the set. The set does not change; what moves is which layer holds which
     member of it. */

{
	var synths = ~freqs.collect { |f, i|
		Synth(\pulsarComb, [\wavebuf, ~pRand.bufnum, \envbuf, ~envbuf,
			\fund, 5, \form, f * 2, \combFreq, f, \combDecay, 0.4, \combMix, 0.5,
			\pan, i.linlin(0, ~freqs.size - 1, -0.9, 0.9),
			\amp, 0.4 / ~freqs.size]);
	};

	24.do { |step|
		synths.do { |syn, i|
			var f = ~freqs[(i + step + 1).mod(~freqs.size)];
			syn.set(\form, f * 2, \combFreq, f);
		};
		0.4.wait;
	};

	synths.do(_.free);
}.fork;

)


CmdPeriod.run;
