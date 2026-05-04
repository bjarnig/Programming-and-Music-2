////////////////////////////////////////////////////////////////
//
//                          NRT
//
////////////////////////////////////////////////////////////////

(

~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;

)


// Render a 5-second sine to disk

(

var server, x;

server = Server(\nrt, options: ServerOptions.new.numOutputBusChannels_(2));

x = Score([
	[0.0, ['/d_recv',
		SynthDef(\sine, {
			Out.ar(0, SinOsc.ar(200, 0, 0.2) ! 2)
		}).asBytes
	]],
	[0.0, Synth(\sine, server).newMsg],
	[5.0, [\c_set, 0, 0]]
]);

x.recordNRT(
	outputFilePath: ~path ++ "output/sine.wav",
	sampleRate: 44100,
	headerFormat: "wav",
	sampleFormat: "int16",
	options: server.options,
	duration: 5,
	action: { "render done".postln }
);

server.remove;

)


// FFT freeze (offline). Reads an input file, writes a frozen-spectrum file

(

var server, x, inputFile;
inputFile = SoundFile.openRead(~path ++ "sounds/abstract/aa.wav");
inputFile.close;

server = Server(\nrt,
	options: ServerOptions.new
		.numOutputBusChannels_(2)
		.numInputBusChannels_(inputFile.numChannels)
);

x = Score([
	[0.0, ['/d_recv',
		SynthDef(\fftFreeze, {
			var in = SoundIn.ar([0]);
			var fft = FFT(LocalBuf(1024, 1), in);
			fft = PV_MagFreeze(fft, ToggleFF.kr(Dust.kr(12)));
			Out.ar(0, IFFT(fft).dup)
		}).asBytes
	]],
	[0.01, Synth(\fftFreeze, server).newMsg]
]);

x.recordNRT(
	outputFilePath: ~path ++ "output/aa-freeze.wav",
	inputFilePath: inputFile.path,
	sampleRate: 44100,
	headerFormat: "wav",
	sampleFormat: "int16",
	options: server.options,
	duration: inputFile.duration,
	action: { "freeze rendered".postln }
);

server.remove;

)


// A reusable render helper. Pass a SynthDef function and a name

(

~render = { |defFunc, name, dur = 8|
	var server, x, def;
	server = Server(\nrt, options: ServerOptions.new.numOutputBusChannels_(2));
	def = defFunc.value;

	x = Score([
		[0.0, ['/d_recv', def.asBytes]],
		[0.0, Synth.basicNew(def.name, server, 1000).newMsg(args: [dur: dur])],
		[dur * 1.05, [\n_free, 1000]]
	]);

	x.recordNRT(
		outputFilePath: ~path ++ "output/" ++ name ++ ".wav",
		sampleRate: 44100,
		headerFormat: "wav",
		sampleFormat: "int24",
		options: server.options,
		duration: dur * 1.1,
		action: { (name ++ " done").postln }
	);

	server.remove;
};

)


// Render a sound using the helper

(

~render.value({
	SynthDef(\nrtGrain, { |out, dur = 8|
		var trig, env, son;
		trig = Impulse.ar(LFNoise1.kr(0.5).range(20, 80));
		env = EnvGen.ar(Env([0, 1, 1, 0], [0.05, 0.7, 0.25] * dur));
		son = GrainFM.ar(2, trig, 0.04,
			LFNoise1.kr(0.3).range(100, 200),
			LFNoise2.kr(0.7).range(400, 600),10);
		Out.ar(out, HPF.ar(son * env * 0.2, 20))
	})
}, "grain", 6);

)


// Batch render SynthDef variants over both source files

(

~variants = (
	freezeNoise: { SynthDef(\freezeNoise, { |out, dur = 8|
		var sig = WhiteNoise.ar(0.3) * EnvGen.ar(Env([0, 1, 1, 0], [0.05, 0.8, 0.15] * dur));
		var fft = FFT(LocalBuf(1024), sig);
		fft = PV_MagFreeze(fft, ToggleFF.kr(Dust.kr(8)));
		Out.ar(out, IFFT(fft) ! 2)
	}) },
	chord: { SynthDef(\chord, { |out, dur = 8|
		var rates = [1, 1.25, 1.5, 1.875];
		var sig = Mix.ar(rates.collect { |r| SinOsc.ar(220 * r, 0, 0.1) });
		Out.ar(out, sig * EnvGen.ar(Env([0, 1, 1, 0], [0.2, 0.6, 0.2] * dur)) ! 2)
	}) }
);

Routine {
	~variants.keysValuesDo { |name, defFunc|
		~render.value(defFunc, name.asString, 6);
		0.2.wait;
	}
}.play;

)
