////////////////////////////////////////////////////////////////
//
//                Real-time audio descriptors
//
////////////////////////////////////////////////////////////////


~sounds = thisProcess.nowExecutingPath.dirname +/+ "../../sounds/";


// Load a single sound

(

~vocal = Buffer.read(s, ~sounds +/+ "vocal.wav", action: { |b|

	("Loaded vocal:" + b.numFrames + "frames," + b.numChannels + "ch," + b.sampleRate + "Hz").postln;

});

)

{ PlayBuf.ar(1, ~vocal, BufRateScale.kr(~vocal), doneAction: 2).dup }.play;


// Load a whole folder

(

~loader = FluidLoadFolder(~sounds);

~loader.play(s, action: { |dict|

	("Concatenated buffer:" + ~loader.buffer).postln;
	"Files included:".postln;
	dict.keys.do(_.postln);

});

)

{ PlayBuf.ar(1, ~loader.buffer, BufRateScale.kr(~loader.buffer), doneAction: 2).dup }.play;


// Load material

(

~vocal   = Buffer.read(s, ~sounds +/+ "vocal.wav");
~melodie = Buffer.read(s, ~sounds +/+ "melodie.wav");
~texture = Buffer.read(s, ~sounds +/+ "texture.wav");
~noise   = Buffer.read(s, ~sounds +/+ "noise.wav");
~branches = Buffer.read(s, ~sounds +/+ "branches.wav");

)


//  FluidLoudness, returns [loudness in LUFS, true peak in dBFS]

(

{
	var sig = PlayBuf.ar(1, ~vocal, BufRateScale.kr(~vocal), loop: 1);
	var loud = FluidLoudness.kr(sig);  // [loudness, truePeak]

	Poll.kr(Impulse.kr(10), loud[0], \loudness_LUFS);
	Poll.kr(Impulse.kr(10), loud[1], \truePeak_dB);

	sig.dup * 0.5;

}.play;

)


// FluidPitch 2. Pitch — FluidPitch vs Tartini / Pitch / ZeroCrossing
// 4 algorithm: 0 = Cepstrum, 1 = HPS, 2 = YinFFT (default), 3 = Yin

(

{

	var sig = PlayBuf.ar(1, ~melodie, BufRateScale.kr(~melodie), loop: 1);
	var pitch = FluidPitch.kr(sig, algorithm: 2);  // YinFFT

	Poll.kr(Impulse.kr(10), pitch[0], \pitchHz);
	Poll.kr(Impulse.kr(10), pitch[1], \confidence);

	sig.dup * 0.5;

}.play;

)


// FluidMFCC handles the windowing internally, gives direct control over numCoeffs / startCoeff

(

~mfccBuf = Buffer.alloc(s, 13);

OSCdef(\mfccs, { |msg|

	("MFCCs:" + msg.copyRange(3, 15).collect(_.round(0.1))).postln;

}, "/mfccs");

~mfccSynth = {

	var sig = PlayBuf.ar(1, ~texture, BufRateScale.kr(~texture), loop: 1);
	var mfccs = FluidMFCC.kr(sig, numCoeffs: 13, startCoeff: 1, maxNumCoeffs: 13);

	FluidKrToBuf.kr(mfccs, ~mfccBuf);

	// Send the 13-channel kr stream to the language
	SendReply.kr(Impulse.kr(5), "/mfccs", mfccs);

	sig.dup * 0.5;

}.play;

)


// FluidSpectralShape has 7 spectral descriptors at once from one FFT pass:
// [centroid, spread, skewness, kurtosis, rolloff, flatness, crest]

(

{

	var sig = PlayBuf.ar(1, ~noise, BufRateScale.kr(~noise), loop: 1);
	var shape = FluidSpectralShape.kr(sig);

	Poll.kr(Impulse.kr(10), shape[0], \centroidHz);
	Poll.kr(Impulse.kr(10), shape[5], \flatness_dB);

	sig.dup * 0.5;

}.play;

)


// FluidOnsetSlice returns a sample-accurate trigger and exposes an onset-slicer parameter set
// (metric, threshold, frameDelta, etc.)
(

{

	var sig = PlayBuf.ar(1, ~branches, BufRateScale.kr(~branches), loop: 1);
	var trig = FluidOnsetSlice.ar(sig, threshold: 0.5);
	var click = EnvGen.ar(Env.perc(0.001, 0.05), trig) * SinOsc.ar(800,0.5);

	(sig * 0.4 + click).dup;

}.play;

)


// FluidAmpFeature, the difference between a fast and a slow envelope follower (in dB).

(

{

	var sig = PlayBuf.ar(1, ~vocal, BufRateScale.kr(~vocal), loop: 1);
	var feat = FluidAmpFeature.ar(sig,
		fastRampUp: 100, fastRampDown: 100,
		slowRampUp: 44100, slowRampDown: 44100,
		floor: -40);

	feat.poll(label: \ampDiff_dB);

	sig.dup * 0.5;

}.play;

)


// Sidechain: the differential gates (boosts) a separate sound.

(

{

	var voc = PlayBuf.ar(1, ~vocal,    BufRateScale.kr(~vocal),    loop: 1);
	var br  = PlayBuf.ar(1, ~branches, BufRateScale.kr(~branches), loop: 1);

	// The differential (in dB) goes positive on transients in `voc`.
	var feat = FluidAmpFeature.ar(voc,
		fastRampUp: 100, fastRampDown: 100,
		slowRampUp: 44100, slowRampDown: 44100,
		floor: -40);

	// Map the differential to a 0..1 control, smoothed.
	//   feat.clip(0, 30)        — clamp dB differential to 0..30 dB (ignore negatives).
	//   / 30                    — rescale into 0..1.
	//   LagUD.ar(_, 0.005, 0.1) — asymmetric lag: 5 ms attack (snap up on transients),
	//                             100 ms release (smooth tail). A fast-attack, slow-release
	//                             envelope follower on the transient signal.
	var ctl = LagUD.ar(feat.clip(0, 30) / 30, 0.005, 0.1);

	// Branches gets its level from vocal's transients.
	((voc * 0.5) + (br * ctl * 0.8)) ! 2;

}.play;

)


// Sidechain: control the cutoff of a low-pass over a synth pad.

(

{

	var voc = PlayBuf.ar(1, ~vocal, BufRateScale.kr(~vocal), loop: 1);
	var feat = FluidAmpFeature.ar(voc, 100, 100, 44100, 44100, -40);
	// Vocal transients drive a low-pass cutoff:
	//   feat.clip(0, 30)           — clamp dB differential to 0..30 dB.
	//   .linexp(0, 30, 200, 8000)  — exponential map (ear hears pitch on a log scale):
	//                                0 dB → 200 Hz (closed filter), 30 dB → 8 kHz (open).
	//   LagUD.ar(_, 0.005, 0.2)    — 5 ms attack snaps the filter open on a transient,
	//                                200 ms release lets it close gradually.
	var cutoff = LagUD.ar(feat.clip(0, 30).linexp(0, 30, 200, 8000), 0.005, 0.2);
	var pad = MoogFF.ar(Saw.ar([55, 110, 220]).sum * 0.2, cutoff, 2);
	((voc * 0.4) + pad) ! 2;

}.play;

)
