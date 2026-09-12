////////////////////////////////////////////////////////////////
//
//          07 - Wavetable Oscillators (VOsc / VOsc3)
//
////////////////////////////////////////////////////////////////


// Be careful with volume. SafetyNet can prevent harmful signals.


// Load wavetables first

(

~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
~tablepath = ~path ++ "/sounds/tables/*";

// Convert wavetable to buffer
~addWt = { |path, dict, name|
	Buffer.read(s, path, action: { |buffer|
		buffer.loadToFloatArray(action: { |array|
			var signal, wavetable;
			try {
				signal = Signal.newFrom(array);
				wavetable = signal.asWavetable;
				{
					dict[name.replace(".wav", "")] = Buffer.loadCollection(s, wavetable);
					s.sync;
				}.fork;
				("Wavetable loaded:" + name).postln;
			} { |error|
				("Error loading wavetable:" + name).postln;
			}
		});
	});
};

// Dictionary to store wavetables
~wtb = Dictionary();

// Load wavetables from a directory
SoundFile.collect(~tablepath).do { |sf|
	~addWt.(sf.path, ~wtb, sf.path.split($/).last)
};

)



// Example 1: Basic VOsc - Single Oscillator

(

{
	var wtName = "tbl07";
	var freq = 100;
	var bufindex = LFNoise1.kr(0.5).range(0, 5) + ~wtb[wtName].bufnum;
	var sig = VOsc.ar(bufindex, freq);

	sig ! 2 * 0.3;
}.play

)


// Example 2: VOsc with Frequency Modulation

(

{
	var wtName = "tbl02";
	var modRate = 10;
	var freq = SinOsc.kr(modRate).range(200, 400);
	var bufindex = LFNoise2.kr([1.3,1.1]).range(1, 3) + ~wtb[wtName].bufnum;
	var sig = VOsc.ar(bufindex, freq);

	sig * 0.3;
}.play

)


// Example 3: Multiple VOsc Layers

(

{
	var wtName = "tbl07";
	var numLayers = 4;

	var sig = Mix.fill(numLayers, { |i|
		var freq = [100,300] * (1 + (i * 0.025));
		var bufindex = LFNoise2.kr(0.5 + (i * 0.1)).range(2, 4) + ~wtb[wtName].bufnum;
		VOsc.ar(bufindex, freq) / numLayers;
	});

	sig * 0.4;
}.play

)


// Example 4: VOsc3 - Mixes three adjacent wavetables for smoother transitions

(

{
	var wtName = "tbl03";
	var freq = 50;
	var bufindex = LFNoise1.kr(0.1).range(0, 6) + ~wtb[wtName].bufnum;
	var sig = VOsc3.ar(bufindex, freq);

	sig ! 2 * 0.3;
}.play

)


// Example 5: VOsc3 with Detuned Frequencies

(

{
	var wtName = "tbl05";
	var baseFreq = 100;
	var bufindex = LFNoise2.kr(0.8).range(1, 3) + ~wtb[wtName].bufnum;

	var sig = Mix([
		VOsc3.ar(bufindex, baseFreq * 1.0),
		VOsc3.ar(bufindex, baseFreq * 1.01),
		VOsc3.ar(bufindex, baseFreq * 0.995)
	]) / 3;

	sig ! 2 * 0.3;
}.play

)


// Example 6: Stereo VOsc with Independent Buffer Indices

(

{
	var wtName = "tbl01";
	var freq = 75;
	var bufindexL = LFNoise2.kr(0.5).range(3, 8) + ~wtb[wtName].bufnum;
	var bufindexR = LFNoise2.kr(0.7).range(5, 9) + ~wtb[wtName].bufnum;

	var sigL = VOsc.ar(bufindexL, freq);
	var sigR = VOsc.ar(bufindexR, freq * 1.005);

	[sigL, sigR] * 0.3;
}.play

)


// Example 7: Chaotic Buffer Index Modulation

(

{
	var wtName = "tbl07";
	var chaos = StandardN.ar(7).range(0, 3);
	var freq = 100;
	var bufindex = ~wtb[wtName].bufnum;
	var sig = VOsc.ar((bufindex + chaos).poll, freq);

	sig ! 2 * 0.3;
}.play

)


// Example 8: Rhythmic Buffer Switching

(

{
	var wtName = "tbl02";
	var freq = 40;
	var trig = Impulse.kr(5);
	var indexPattern = Dseq([0, 3, 5, 1, 2, 5], inf);
	var bufoffset = Demand.kr(trig, 0, indexPattern);
	var bufindex = Latch.kr(bufoffset, trig) + ~wtb[wtName].bufnum;
	var sig = VOsc.ar(bufindex, freq);

	sig ! 2 * 0.4;
}.play

)


// Example 9: Multi-Voice VOsc

(

{
	var wtName = "tbl06";
	var numVoices = 3;
	var freqs = [75, 50, 125];

	var sig = Mix.fill(numVoices, { |i|
		var freq = freqs[i];
		var bufindex = LFNoise2.kr(0.3 + (i * 0.05)).range(2, 3) + ~wtb[wtName].bufnum;
		var pan = (i / (numVoices - 1) * 2 - 1) * 0.7;
		Pan2.ar(VOsc3.ar(bufindex, freq), pan) / numVoices;
	});

	sig * 0.5;
}.play

)


// Example 10: Smooth Drifting

(

{
	var wtName = "tbl02";
	var mod = SinOsc.ar(0.075).range(10, 20);
	var freq = SinOsc.ar(mod).range(10, 110);
	var bufindex = LFNoise2.ar(0.04).range(1, 4) + ~wtb[wtName].bufnum;
	var sig = VOsc.ar(bufindex, freq);

	sig = sig.tanh;
	sig = FreeVerb.ar(sig, [0.7,0.2], 0.9, 0.5);

	sig * 0.25;
}.play

)



// Example 11: Evolving

(

{
	var wtName = "tbl02";
	var attack = 6, decay = 10, sustain = 8, release = 15;
	var curve = 8;
	var amp = 0.25;

	var mod = SinOsc.ar(0.075).range(20, 10);
	var freqf = rrand(600, 620);
	var freq = SinOsc.ar(mod).range(freqf, freqf * 1.001);

	var sig = Mix.fill(4, { |i|
		var bufindex = LFNoise2.ar(0.04 + (i * 0.02)).range(1, 5) + ~wtb[wtName].bufnum;
		var oscFreqMult = [1.0, 1.025, 1.0, 1.05][i];
		VOsc.ar(bufindex, freq * oscFreqMult) / 4;
	});

	var envLevels = [0.0, 1.0, 0.5, 0.8, 0.0] * amp;
	var envTimes = [attack, decay, sustain, release];
	var envCurves = [curve, curve / 3.0, curve / 1.5, curve.neg];
	var env = EnvGen.ar(Env(envLevels, envTimes, envCurves), doneAction: 2);

	sig = sig.tanh * env;
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.5);
	sig = HPF.ar(sig, EnvGen.ar(Env([800, 2400, 600, 4000, 10000], envTimes)));

	sig ! 2;
}.play

)
