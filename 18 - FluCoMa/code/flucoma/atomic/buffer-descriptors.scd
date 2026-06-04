////////////////////////////////////////////////////////////////
//
//             Offline (buffer) descriptors
//
////////////////////////////////////////////////////////////////


~sounds = thisProcess.nowExecutingPath.dirname +/+ "../../sounds/";

(

~vocal = Buffer.read(s, ~sounds +/+ "vocal.wav");
~melodie = Buffer.read(s, ~sounds +/+ "melodie.wav");
~noise = Buffer.read(s, ~sounds +/+ "noise.wav");
~texture = Buffer.read(s, ~sounds +/+ "texture.wav");

)


// FluidBufLoudness, loudness + true peak per frame
// Output is 2 channels per analysis frame: [loudness LUFS, truePeak dBFS].

(

~loudness = Buffer.alloc(s, 1);
FluidBufLoudness.processBlocking(s, ~vocal, features: ~loudness);
FluidWaveform(~vocal, featuresBuffer: ~loudness, bounds: Rect(0, 0, 1200, 400), stackFeatures: true);

)


// FluidBufPitch, offline pitch tracking on a buffer (default algorithm: YinFFT).
// Output is 2 channels per analysis frame: [pitch in Hz, confidence 0..1].

(

~pitch = Buffer.alloc(s, 1);
FluidBufPitch.processBlocking(s, ~melodie, features: ~pitch);


FluidWaveform(~melodie, featuresBuffer: ~pitch, bounds: Rect(0, 0, 1200, 400), stackFeatures: true);

)

// Convert to an array of floats

(

~pitch.loadToFloatArray(action: { |fa|

	("Frames analysed:" + (fa.size / 2)).postln;
	fa.clump(2).keep(15).do { |pair, i|
		("frame % pitch=% Hz conf=%".format(i, pair[0].round(0.1), pair[1].round(0.01))).postln;
	};

});

)


// FluidBufMFCC, 13 mel-frequency cepstral coefficients per frame

(

~mfcc = Buffer.alloc(s, 1);
FluidBufMFCC.processBlocking(s, ~texture, features: ~mfcc, numCoeffs: 13);
FluidWaveform(~texture, featuresBuffer: ~mfcc, bounds: Rect(0, 0, 1200, 400), stackFeatures: true);

)


// Convert to an array of floats

(

~mfcc.loadToFloatArray(action: { |fa|

	("Total frames:" + (fa.size / 13)).postln;
	("First frame's 13 coefficients:" + fa.keep(13).collect(_.round(0.01))).postln;

});

)



// FluidBufSpectralShape, 7 spectral descriptors per frame
// Output channels: [centroid, spread, skewness, kurtosis, rolloff, flatness, crest]

(

~shape = Buffer.alloc(s, 1);
FluidBufSpectralShape.processBlocking(s, ~noise, features: ~shape);
FluidWaveform(~noise, featuresBuffer: ~shape, bounds: Rect(0, 0, 1200, 400), stackFeatures: true);

)


// Convert to an array of floats

(

~shape.loadToFloatArray(action: { |fa|

	("Total frames:" + (fa.size / 7)).postln;
	("First frame [cent, spread, skew, kurt, roll, flat, crest]:" + fa.keep(7).collect(_.round(0.01))).postln;

});

)

~noise.play;



// FluidBufStats, sper-frame analysis to summary statistics, 7 stats:
// [mean, std, skewness, kurtosis, low-percentile, mid-percentile, high-percentile].

(

~mfcc2 = Buffer.alloc(s, 1);
~stats = Buffer.alloc(s, 1);

FluidBufMFCC.processBlocking(s, ~texture, features: ~mfcc2, numCoeffs: 13);
FluidBufStats.processBlocking(s, ~mfcc2, stats: ~stats);
"FluidBufStats done.".postln;

)

(

~stats.loadToFloatArray(action: { |fa|

	("Stats matrix: % rows (one per MFCC coeff) x 7 stats".format(fa.size / 7)).postln;
	fa.clump(7).do { |row, i|
		("coeff %: %".format(i, row.collect(_.round(0.01)))).postln;
	};

});

)
