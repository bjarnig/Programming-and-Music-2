////////////////////////////////////////////////////////////////
//
//          01 - Waveform Synthesis
//
////////////////////////////////////////////////////////////////


// Be careful with volume. SafetyNet can prevent harmful signals.

(

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)


// Example 1: Sawtooth Wave
// Use Dseries to create a rising ramp that resets

(

{
	var levels = Dseq([Dseries(-1.0, 0.02, 100)],inf);
	var durations = SampleDur.ir * 5;
	DemandEnvGen.ar(levels, durations) ! 2 * 0.3;
}.play

)


// Example 2: Triangle Wave
// Use Dseq with ascending and descending Dseries

(

{

	// Up ramp, then down ramp = triangle wave
	var levels = Dseq([
		Dseries(-1, 0.04, 50),   // rise: -1 to 1
		Dseries(1, -0.04, 50)    // fall: 1 to -1
	], inf);
	var durations = SampleDur.ir * 5;

	DemandEnvGen.ar(levels, durations) ! 2 * 0.3;
}.play

)


// Example 3: Square Wave
// Use Dstutter to repeat each level

(

{
	// Repeat each level 50 times before switching (true square wave)
	var levels = Dstutter(50, Dseq([-1, 1], inf));
	var durations = SampleDur.ir * 5;

	DemandEnvGen.ar(levels, durations) ! 2 * 0.3;
}.play

)


// Example 4: Pulse Wave (Variable Duty Cycle)
// Create asymmetric pulse by repeating values unequally

(

{
	// 25% duty cycle: high for 25 samples, low for 75 samples
	var high = Array.fill(25, { 1 });    // 25 samples at +1
	var low = Array.fill(75, { -1 });    // 75 samples at -1
	var levels = Dseq(high ++ low, inf);
	var durations = SampleDur.ir * 5;

	DemandEnvGen.ar(levels, durations) ! 2 * 0.3;
}.play

)


// Example 5: Multi-layered Sawtooth Waves
// Layer multiple sawtooth waves at different frequencies

(

{
	var numLayers = 10;
	var signals = numLayers.collect { |i|
		var steps = 50 + (i * 20);  // different frequencies per layer
		var stepSize = 2.0 / steps;
		var levels = Dseq([Dseries(-1, stepSize, steps)], inf);
		var durations = SampleDur.ir;

		DemandEnvGen.ar(levels, durations) / numLayers;
	};

	Splay.ar(signals);
}.play

)


// Example 6: Stepped Waveform (Staircase)
// Create a stepped/quantized sawtooth wave with held values

(

{
	// 8 discrete levels, each held for 20 samples
	var levels = Dstutter(20, Dseq([-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75], inf));
	var durations = SampleDur.ir * 5;

	DemandEnvGen.ar(levels, durations) ! 2 * 0.4;
}.play

)


// Example 7: Exponential Sawtooth (using Dgeom)
// Create a logarithmic/exponential ramp instead of linear

(

{
	var levels = Dseq([Dgeom(0.01, 1.05, 95)], inf);  // geometric growth, repeating
	var durations = SampleDur.ir * 5;
	var sig = DemandEnvGen.ar(levels, durations);
	sig = sig * 2 - 1;  // rescale

	sig ! 2 * 0.3;

}.play

)


// Example 8: Complex Composite Waveform
// Combine different wave shapes in sequence

(

{
	var levels = Dseq([
		Dseries(-1, 0.04, 50),                     // sawtooth up
		Dseries(-1, 0.04, 50),                     // triangle up half
		Dseries(1, -0.04, 50),                     // triangle down half
		Dstutter(25, Dseq([1, -1], 6)),           // square wave (6 cycles, 25 samples each)
		Dgeom(0.01, 1.08, 50)                      // exponential ramp
	], inf);

	var durations = SampleDur.ir * 5;
	var sig = DemandEnvGen.ar(levels, durations);
	sig = sig.clip(-1, 1);  // safety clip

	sig ! 2 * 0.3;

}.play

)


// Example 9: Basic Gendy - Few Breakpoints (Adapted from Sergio Luque)

(

{
	var points = 10;
	var durFrom = 1, durTo = 50, durStep = 0.2;
	var ampFrom = -0.5, ampTo = 0.5, ampStep = 0.01;

	// Array of independent random walks for amplitudes
	var amps = { Dbrown(ampFrom, ampTo, ampStep, inf) } ! points;
	// Array of independent random walks for durations
	var durations = { Dbrown(durFrom, durTo, durStep, inf) } ! points;
	// Cycle through all breakpoints sequentially
	var series = Array.series(points, 0, 1);

	DemandEnvGen.ar(
		Dswitch1(amps, Dseq(series, inf)),
		Dswitch1(durations, Dseq(series, inf)) * SampleDur.ir
	) ! 2 * 0.3;
}.play

)


// Example 10: High-Point Gendy (Many Breakpoints)

(

{
	var points = 30;
	var durFrom = 3, durTo = 10, durStep = 0.1;
	var ampFrom = -0.7, ampTo = 0.7, ampStep = 0.05;  // smaller steps

	var amps = { Dbrown(ampFrom, ampTo, ampStep, inf) } ! points;
	var durations = { Dbrown(durFrom, durTo, durStep, inf) } ! points;
	var series = Array.series(points, 0, 1);

	DemandEnvGen.ar(
		Dswitch1(amps, Dseq(series, inf)),
		Dswitch1(durations, Dseq(series, inf)) * SampleDur.ir
	) ! 2 * 0.3;
}.play

)




// Example 11: Random Order Gendy - Non-Sequential Breakpoint Access

(

{
	var points = 10;
	var durFrom = 5, durTo = 15, durStep = 0.1;
	var ampFrom = -0.5, ampTo = 0.5, ampStep = 0.01;

	var amps = { Dbrown(ampFrom, ampTo, ampStep, inf) } ! points;
	var durations = { Dbrown(durFrom, durTo, durStep, inf) } ! points;
	var series = Array.series(points, 0, 1);

	DemandEnvGen.ar(
		Dswitch1(amps, Drand(series, inf)),  // random access!
		Dswitch1(durations, Drand(series, inf)) * SampleDur.ir
	) ! 2 * 0.3;
}.play

)


// Example 12: Shuffled Gendy - Random Without Repeats

(

{
	var points = 4;
	var durFrom = 1, durTo = 30, durStep = 0.2;
	var ampFrom = -0.6, ampTo = 0.6, ampStep = 0.015;

	var amps = { Dbrown(ampFrom, ampTo, ampStep, inf) } ! points;
	var durations = { Dbrown(durFrom, durTo, durStep, inf) } ! points;
	var series = Array.series(points, 0, 1);

	DemandEnvGen.ar(
		Dswitch1(amps, Dshuf(series, inf)),
		Dswitch1(durations, Dshuf(series, inf)) * SampleDur.ir * 2
	) ! 2 * 0.3;
}.play

)


// Example 13: Multi-Voice Gendy - Layered Breakpoint Clouds

(

{
	var numVoices = 10;

	var sig = Mix.fill(numVoices, { |i|
		var points = 6 + (i * 3);  // increasing complexity per voice
		var durFrom = 5 + (i * 2), durTo = 15 + (i * 3);
		var ampRange = 0.5 / (i + 1);  // decreasing amplitude per voice

		var amps = { Dbrown(ampRange.neg, ampRange, 0.01, inf) } ! points;
		var durations = { Dbrown(durFrom, durTo, 0.1, inf) } ! points;
		var series = Array.series(points, 0, 1);

		DemandEnvGen.ar(
			Dswitch1(amps, Dseq(series, inf)),
			Dswitch1(durations, Dseq(series, inf)) * SampleDur.ir
		) / numVoices;
	});

	sig ! 2;
}.play

)


// Example 14: Rapid Gendy - Very Fast Evolution with Drand for amps

(

{
	var points = 15;
	var durFrom = 3, durTo = 12, durStep = 1.0;  // large duration steps!
	var ampFrom = -0.8, ampTo = 0.8, ampStep = 0.1;  // large amp steps!

	var amps = { Dbrown(ampFrom, ampTo, ampStep, inf) } ! points;
	var durations = { Dbrown(durFrom, durTo, durStep, inf) } ! points;
	var series = Array.series(points, 0, 1);

	DemandEnvGen.ar(
		Dswitch1(amps, Dseq(series, inf)),
		Dswitch1(durations, Drand(series, inf)) * SampleDur.ir
	) ! 2 * 0.2;
}.play

)


