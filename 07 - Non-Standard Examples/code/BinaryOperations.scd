////////////////////////////////////////////////////////////////
//
//          05 - Binary Operations and Waveshaping
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.


// Example 1: .fold2 - Wave Folding
// Fold creates wave-folding synthesis - rich harmonics
(
{
	var carrier = SinOsc.ar(200);
	var modulator = SinOsc.ar(5);

	carrier.fold2(modulator) ! 2 * 0.3;
}.play
)


// Example 2: .wrap2 - Wave Wrapping
// Similar to fold but wraps around differently
(
{
	var carrier = SinOsc.ar(150);
	var modulator = LFNoise1.ar(3);

	carrier.wrap2(modulator) ! 2 * 0.3;
}.play
)


// Example 3: .thresh - Thresholding
// Creates square wave-like results
(
{
	var carrier = SinOsc.ar(300);
	var threshold = SinOsc.ar(2) * 0.5;

	carrier.thresh(threshold) ! 2 * 0.2;
}.play
)


// Example 4: .amclip - Amplitude Clipping
// Interesting rhythmic modulation
(
{
	var carrier = WhiteNoise.ar(0.5);
	var modulator = SinOsc.ar(200);

	carrier.amclip(modulator) ! 2 * 0.3;
}.play
)


// Example 5: .scaleneg - Scale Negative Values
// Ring modulation on negative part only
(
{
	var carrier = LFSaw.ar(400);
	var modulator = LFNoise2.ar(300);

	modulator.scaleneg(carrier) ! 2 * 0.3;
}.play
)


// Example 6: Comparison Operators - Generate Gates
// Use < > == to create complex rhythmic patterns
(
{
	var carrier = SinOsc.ar(600);
	var modulator = LFNoise0.ar(10);

	// Creates rhythmic gating
	LeakDC.ar(carrier * (modulator > 0)) ! 2 * 0.3;
}.play
)


// Example 7: .mod - Modulo Operation
// Creates complex harmonic structures
(
{
	var carrier = Saw.ar([100, 101]);
	var modulator = LFNoise1.ar(800);

	carrier.mod(modulator) * 0.2;
}.play
)


// Example 8: .distort - Soft Distortion
// Smooth saturation
(
{
	var signal = SinOsc.ar(200) * MouseX.kr(0, 10);

	signal.distort ! 2 * 0.3;
}.play
)


// Example 9: .softclip - Softer Clipping
// Gentler than distort
(
{
	var signal = SinOsc.ar(150) * Line.kr(0, 8, 5);

	signal.softclip ! 2 * 0.3;
}.play
)


// Example 10: Combining Multiple Binary Ops
// Chain operations for complex timbres
(
{
	var carrier = SinOsc.ar(100);
	var mod1 = SinOsc.ar(3);
	var mod2 = LFNoise1.ar(10);

	carrier
		.fold2(mod1)
		.wrap2(mod2)
		.softclip
	! 2 * 0.3;
}.play
)


// Example 11: DemandEnvGen + Binary Operations
// Combine stochastic synthesis with binary ops
(
{
	var levels = Dbrown(-0.8, 0.8, 0.1, inf);
	var durations = SampleDur.ir * 20;
	var stochastic = DemandEnvGen.ar(levels, durations);

	var modulator = SinOsc.ar(10);

	stochastic.fold2(modulator) ! 2 * 0.3;
}.play
)


// Example 12: GrainBuf + Binary Operations
// Granular synthesis with waveshaping
// (Requires buffers from 02_GranularSynthesis.scd)
(
{
	var trig = Dust.kr(50);
	var dur = 0.1;
	var pos = LFNoise1.kr(2).range(0, 1);
	var grains = GrainBuf.ar(1, trig, dur, ~vocal, 1, pos);

	var modulator = SinOsc.ar(5);

	grains.fold2(modulator) ! 2 * 0.4;
}.play
)


// Example 13: Multi-layer Binary Operations
// Create complex textures by layering
(
{
	var numLayers = 5;
	var signals = numLayers.collect { |i|
		var freq = 100 * (i + 1);
		var carrier = SinOsc.ar(freq);
		var mod = LFNoise1.ar(rrand(1, 5));

		carrier.fold2(mod) / numLayers;
	};

	Splay.ar(signals) * 0.4;
}.play
)


// Example 14: LeastChange - Interesting Hybrid
// Outputs whichever signal changed less
(
{
	var sig1 = SinOsc.ar(400);
	var sig2 = Pulse.ar(50);

	LeastChange.ar(sig1, sig2) ! 2 * 0.3;
}.play
)


// Example 15: MostChange - The Opposite
// Outputs whichever signal changed more
(
{
	var sig1 = SinOsc.ar(300);
	var sig2 = LFNoise0.ar(20);

	MostChange.ar(sig1, sig2) ! 2 * 0.3;
}.play
)


// Example 16: .ring1 - Advanced Ring Modulation
// (a * b) + a - creates metallic tones
(
{
	var carrier = SinOsc.ar(200);
	var modulator = SinOsc.ar(37);

	carrier.ring1(modulator) ! 2 * 0.3;
}.play
)


// Example 17: .excess - Residual from Clipping
// Returns a - clip2(a, b)
(
{
	var signal = SinOsc.ar(100) * Line.kr(0, 4, 5);
	var threshold = 0.5;

	signal.excess(threshold) ! 2 * 0.3;
}.play
)


// Example 18: SinOscFB with Fold - Complex Waveshaping
// Feedback sine oscillator through folder
(
{
	var carrier = SinOscFB.ar([40, 42], LFNoise1.ar(3).range(0.1, 1.75));
	var lo = LFNoise2.ar(4.3).range(0.1, 0.5);
	var hi = SinOsc.ar([0.03, 0.1]).range(0.5, 2.0);

	Fold.ar(carrier, lo, hi) * 0.3;
}.play
)


// Example 19: .squared and .cubed - Polynomial Waveshaping
// Simple but effective harmonic generation
(
{
	var sig = SinOsc.ar(150);

	// Try .squared, .cubed, or both
	sig.squared ! 2 * 0.3;
}.play
)


// Example 20: Complex Fold with Blip
// High harmonic content through folding
(
{
	var carrier = Blip.ar([200, 100], 150);
	var modulator = SinOsc.ar(LFDNoise1.ar(25).range(10, 60));

	carrier.fold2(modulator) * 0.5;
}.play
)
