////////////////////////////////////////////////////////////////
//
//          03 - Pulsar Synthesis
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.


/*

Pulsar synthesis: particles of sound with a pulsaret waveform + silent period
A pulsar = pulsaret waveform (duty cycle d) + silent time (s)
Pulsar period p = d + s
Repetitions create a pulsar train

*/


(

{
	// Create a pulsaret waveform (10 random sine partials)
	~pulsaret = Signal.sineFill(1024, { 1.0.rand }.dup(10));
	s.sync;
	~pulsarbuf = Buffer.sendCollection(s, ~pulsaret, 1);

	// Create an envelope buffer for the grain
	~env = Env.perc.discretize;
	s.sync;
	~envbuf = Buffer.sendCollection(s, ~env, 1);

	s.sync;

	// Define the pulsar synth
	SynthDef(\pulsar, { |fund=10, form=100, amp=1.0, wavebuf, envbuf|
		var trig = Impulse.ar(fund);        // Fundamental frequency
		var grdur = form.reciprocal;         // Grain duration from formant
		var rate = form * BufDur.kr(wavebuf); // Playback rate
		Out.ar(0, GrainBuf.ar(2, trig, grdur, wavebuf, rate, 0, 4, 0, envbuf, mul: amp));
	}).add;

	"Pulsar synthesis ready!".postln;
}.fork;

)


// Example 1: Basic Pulsar Train
// Simple pulsar with fixed fundamental and formant frequencies

(

Synth(\pulsar, [
	\wavebuf, ~pulsarbuf,
	\envbuf, ~envbuf,
	\fund, 20,    // Fundamental: 20 Hz
	\form, 100    // Formant: 100 Hz
]);

)

// Example 2: Envelope-Controlled Pulsar
// Use envelopes to create evolving timbres

(

Pmono(\pulsar,
	\wavebuf, ~pulsarbuf,
	\envbuf, ~envbuf,
	\fund, Env([100, 50, 10, 5], [2, 3, 1]),
	\form, Env([100, 1000, 10, 400], [2, 3, 1]),
	\dur, 0.001,
	\amp, 0.7
).play;

)


// Example 3: Pattern-Based Pulsar Control
// Use patterns for stochastic variation

(

Pmono(\pulsar,
	\wavebuf, ~pulsarbuf,
	\envbuf, ~envbuf,
	\fund, Pbeta(10,2000),    // Beta fundamental
	\form, Pbrown(100, 1000, 50),  // Brownian formant
	\dur, 0.001,
    \amp, 0.5
).play;

)


// Example 4: Multi-Layered Pulsar Synthesis
// Create rich textures with multiple pulsar trains

(

var numLayers = 10;
var fundFrom = 50;
var fundTo = 100;
var formFrom = 100;
var formTo = 1000;

numLayers.do { |i|
	Pmono(\pulsar,
		\wavebuf, ~pulsarbuf,
		\envbuf, ~envbuf,
		\fund, fundFrom + (i * (fundTo - fundFrom) / numLayers),
		\form, Env([formFrom, formTo, formFrom], [5, 5]),
		\amp, 1.0 / numLayers,
		\dur, 0.01
	).play;
};

)


// Example 5: Pulsar with Different Waveforms
// Create pulsars from inharmonic and complex source waveforms

(

{
	// Complex inharmonic pulsaret: odd harmonics with decaying amplitudes + some inharmonic partials
	var harmonics = 20;
	var amps = Array.fill(harmonics, { |i| if(i.even, { 0 }, { 1.0 / (i + 1).squared }) });
	var phases = Array.fill(harmonics + 5, { 2pi.rand });

	amps = amps ++ [0.2, 0.15, 0.1, 0.08, 0.05];

	~complexPulsaret = Signal.sineFill(1024, amps, phases);
	s.sync;
	~complexPulsarBuf = Buffer.sendCollection(s, ~complexPulsaret, 1);

	s.sync;

	Pmono(\pulsar,
		\wavebuf, ~complexPulsarBuf,
		\envbuf, ~envbuf,
		\fund, 20,
		\form, Pwhite(10,100),
		\dur, 0.05,
		\amp, 1.0
	).play;
}.fork;

)




// Example 6: Pulsar + Binary Operations
// Apply waveshaping to pulsar synthesis

(

{

SynthDef(\pulsarFold, { |fund=10, form=100, amp=1.0, wavebuf, envbuf|
	var trig = Impulse.ar(fund);
	var grdur = form.reciprocal;
	var rate = form * BufDur.kr(wavebuf);
	var sig = GrainBuf.ar(2, trig, grdur, wavebuf, rate, 0, 4, 0, envbuf, mul: amp);

	sig = sig.fold2(SinOsc.ar(fund*0.25) * 0.5);
	Out.ar(0, HPF.ar(sig,40));
}).add;

s.sync;

Pmono(\pulsarFold,
	\wavebuf, ~pulsarbuf,
	\envbuf, ~envbuf,
	\fund, Pwhite(10,100),
	\form, 400,
	\dur, 0.1,
	\amp, 0.7
).play;

Pmono(\pulsarFold,
	\wavebuf, ~pulsarbuf,
	\envbuf, ~envbuf,
	\fund, Pwhite(100,300),
	\form, 2000,
	\dur, 0.02,
	\amp, 0.1
).play;

}.fork

)


// Example 7: Stochastic Pulsar Control
// Use DemandEnvGen to control pulsar parameters

(

{

SynthDef(\pulsarDemand, { |wavebuf, envbuf, amp=0.5|
	var fundLevels = Dbrown(20, 200, 10, inf);
	var fundDurs = Dwhite(10, 100, inf) * SampleDur.ir;
	var fund = DemandEnvGen.kr(fundLevels, fundDurs);

	var formLevels = Dbrown(100, 2000, 100, inf);
	var formDurs = Dwhite(20, 200, inf) * SampleDur.ir;
	var form = DemandEnvGen.kr(formLevels, formDurs);

	var trig = Impulse.ar(fund);
	var grdur = form.reciprocal;
	var rate = form * BufDur.kr(wavebuf);

	Out.ar(0, GrainBuf.ar(2, trig, grdur, wavebuf, rate, 0, 4, 0, envbuf, mul: amp));
}).add;

s.sync;

Synth(\pulsarDemand, [
	\wavebuf, ~pulsarbuf,
	\envbuf, ~envbuf,
	\amp, 0.5
]);

}.fork

)



////////////////////////////////////////////////////////////////
//
//   ADVANCED PULSAR SYNTHESIS - Nu_PG System
//
//   Extended pulsar synthesis with:
//   - FM modulation
//   - Flux/randomization (noise, Gendy)
//   - Masking (probability, burst/rest, sieve patterns, spatial)
//
////////////////////////////////////////////////////////////////


// Setup: Advanced Pulsar Buffers and SynthDef

(

{
	// Allocate buffers
	~advPulsaretBuf = Buffer.alloc(s, 2048, 1);
	~advEnvelopeBuf = Buffer.alloc(s, 2048, 1);

	s.sync;

	// Default waveforms
	~advPulsaretBuf.sine1([1.0], asWavetable: false);
	~advEnvelopeBuf.sine1([1.0], asWavetable: false);

	s.sync;

	// Advanced Pulsar SynthDef
	SynthDef(\pulsarAdv, {
		arg
		// Buffers
		pulBuf, envBuf,

		// Frequencies
		trigFreq = 50.0,      // Fundamental (train rate)
		grainFreq = 1.0,      // Formant ratio

		// FM modulation
		fmRatio = 1.0,
		fmAmt = 0.0,

		// Flux/randomization
		fluxAmt = 0.0,        // Amount of randomness
		fluxRate = 40.0,      // Speed of random changes

		// Masking
		probability = 1.0,    // Probability of each pulse
		burst = 5,            // Pulses in burst
		rest = 0,             // Pulses to rest

		// Spatial
		pan = 0,
		chanMask = 0,         // Alternate channels
		centerMask = 1,

		// Amplitude
		amp = 0.5;

		var trig, grain, rate, grainDur, sig;
		var channelMask;

		// Calculate formant frequency
		grain = trigFreq * grainFreq;

		// Add flux (randomization) to formant
		grain = grain * LFDNoise3.ar(fluxRate, fluxAmt, 1).lag(0.5);

		// Calculate grain duration
		grainDur = grain.reciprocal;

		// Generate trigger with flux
		trig = Impulse.ar(
			trigFreq * LFDNoise3.kr(fluxRate, fluxAmt * 0.5, 1).lag(0.5)
		);

		// Probability masking
		trig = trig * CoinGate.ar(probability, trig);

		// Burst/rest masking
		trig = trig * Demand.ar(trig, 1, Dseq([Dser([1], burst), Dser([0], rest)], inf));

		// Calculate playback rate with FM
		rate = grain * (2048 / SampleRate.ir);
		rate = rate * (1 + (SinOsc.ar(grain * fmRatio) * fmAmt * 0.1));

		// Channel masking for spatial movement
		channelMask = Demand.ar(trig, 0, Dseq([
			Dser([-1], chanMask),
			Dser([1], chanMask),
			Dser([0], centerMask)
		], inf)).lag(0.01);

		pan = (pan + channelMask).clip(-1, 1);

		// Generate pulsar
		sig = GrainBuf.ar(
			numChannels: 2,
			trigger: trig,
			dur: grainDur,
			sndbuf: pulBuf,
			rate: rate,
			pos: 0,
			interp: 4,
			pan: pan,
			envbufnum: envBuf,
			maxGrains: 512,
			mul: amp
		);

		Out.ar(0, LeakDC.ar(sig));
	}).add;

	"Advanced pulsar synthesis ready!".postln;
}.fork;

)


// Example 8: Basic Advanced Pulsar
// Start simple with the new synth

(

~advPulsar = Synth(\pulsarAdv, [
	\pulBuf, ~advPulsaretBuf,
	\envBuf, ~advEnvelopeBuf,
	\trigFreq, 100,
	\grainFreq, 2.0,
	\amp, 0.3
]);

)

// Stop it
~advPulsar.free;


// Example 9: FM Modulation
// Add frequency modulation to the formant

(

~advPulsar = Synth(\pulsarAdv, [
	\pulBuf, ~advPulsaretBuf,
	\envBuf, ~advEnvelopeBuf,
	\trigFreq, 80,
	\grainFreq, 2.0,
	\fmRatio, 2.0,     // FM at 2x the formant frequency
	\fmAmt, 0.5,       // FM depth
	\amp, 0.3
]);

)

~advPulsar.free;


// Example 10: Flux/Randomization
// Add controlled randomness to make it less static

(

~advPulsar = Synth(\pulsarAdv, [
	\pulBuf, ~advPulsaretBuf,
	\envBuf, ~advEnvelopeBuf,
	\trigFreq, 60,
	\grainFreq, 2.5,
	\fluxAmt, 0.2,     // 20% randomization
	\fluxRate, 20,     // Rate of random changes
	\amp, 0.3
]);

)

~advPulsar.free;


// Example 11: Probability Masking
// Randomly drop some pulses

(

~advPulsar = Synth(\pulsarAdv, [
	\pulBuf, ~advPulsaretBuf,
	\envBuf, ~advEnvelopeBuf,
	\trigFreq, 100,
	\grainFreq, 3.0,
	\probability, 0.7,  // Only 70% of pulses sound
	\amp, 0.3
]);

)

~advPulsar.free;


// Example 12: Burst and Rest Patterns
// Create rhythmic patterns with burst/rest

(

~advPulsar = Synth(\pulsarAdv, [
	\pulBuf, ~advPulsaretBuf,
	\envBuf, ~advEnvelopeBuf,
	\trigFreq, 100,
	\grainFreq, 2.0,
	\burst, 5,         // 5 pulses on
	\rest, 3,          // 3 pulses off
	\amp, 0.3
]);

)

~advPulsar.free;


// Example 13: Spatial Movement
// Alternate pulses between left and right

(

~advPulsar = Synth(\pulsarAdv, [
	\pulBuf, ~advPulsaretBuf,
	\envBuf, ~advEnvelopeBuf,
	\trigFreq, 80,
	\grainFreq, 2.0,
	\chanMask, 2,      // 2 pulses left, 2 right
	\centerMask, 1,    // 1 pulse center
	\amp, 0.3
]);

)

~advPulsar.free;


// Example 14: Combining All Parameters
// Complex evolving pulsar texture

(

~advPulsar = Synth(\pulsarAdv, [
	\pulBuf, ~advPulsaretBuf,
	\envBuf, ~advEnvelopeBuf,
	\trigFreq, 120,
	\grainFreq, 3.0,
	\fmRatio, 1.5,
	\fmAmt, 0.3,
	\fluxAmt, 0.15,
	\fluxRate, 30,
	\probability, 0.8,
	\burst, 7,
	\rest, 2,
	\chanMask, 1,
	\centerMask, 2,
	\amp, 0.3
]);

)

~advPulsar.free;


// Example 15: Dynamic Parameter Control
// Change parameters over time

(

~advPulsar = Synth(\pulsarAdv, [
	\pulBuf, ~advPulsaretBuf,
	\envBuf, ~advEnvelopeBuf,
	\trigFreq, 50,
	\grainFreq, 1.0,
	\amp, 0.3
]);

// Gradually increase formant ratio
Routine({
	30.do { |i|
		~advPulsar.set(\grainFreq, 1.0 + (i * 0.2));
		0.2.wait;
	};
}).play;

)

~advPulsar.free;
