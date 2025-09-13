////////////////////////////////////////////////////////////////
//
//            				Granular UGens
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)


////////////////////////// Buffers ///////////////////////////

(
    ~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
    ~path = ~path ++ "samples/";
	~voice = Buffer.read(s, ~path ++ "vocal.wav");
	~bikecat = Buffer.read(s, ~path ++ "bikecat.wav");
)




//////////////////////// Granular Ugens /////////////////////////


( // TGrains, normal playback
{
	var rate = 10, grSize=0.2, buf = ~voice.bufnum;
	TGrains.ar(2,Impulse.kr(10), buf, 1,
	Line.kr(0, BufDur.kr(buf), BufDur.kr(buf), doneAction: 2), grSize);
}.play
)




( // TGrains, envelope for position and grain size
{
	var rate = 10, buf = ~voice.bufnum, env;
	env = EnvGen.ar(Env([0, 1, 0.2, 0.8],[1, 2, 8]));
	TGrains.ar(2,Impulse.kr(10), buf, 1, env, env);
}.play
)




( // TGrains, randomize values and use layers
{
	var rate = 50, buf = ~voice.bufnum, trig;
	trig = Impulse.kr(rate);
	Mix.fill(5,{
	TGrains.ar(2, trig, buf, TRand.kr(0.5,1.5,trig),
	TRand.kr(0.01,0.5,trig), TRand.kr(0.01,0.99,trig),
	TRand.kr(-1.0,1.0,trig), TRand.kr(0.01,0.05,trig))});
}.play
)




( // TGrains, trigger with dust, slowly modulating grain size
{
	var rate = 100, grSize=0.2, buf = ~voice.bufnum, trig;
	trig = Dust.kr(rate);
	TGrains.ar(2, trig, buf, 1,TRand.kr(0.0,1.0,trig),
	LFPar.ar(0.05, mul: 0.09, add: 0.1));
}.play
)




( // GrainFM, trigger with dust, layers and line for mod amt
{
	var density=50, dur=0.01, freqFrom=100, freqTo=400, trig;
	trig = Dust.kr(density);
	Mix.fill(5, {
		var freq=rrand(freqFrom, freqTo);
		var modfreq=rrand(freqFrom, freqTo);
		GrainFM.ar(2, trig, dur, freq, modfreq, Line.ar(0.1, 0.9, 5)) * 0.1;
	})
}.play
)




( // GrainFM, harmonic layers
{
	var density=10, fund=100, trig, dur;
	trig = Impulse.kr(EnvGen.ar(Env([1,100,1],[4,4])));
	dur = EnvGen.ar(Env([0.1,0.01,0.2],[4,4]));
	Mix.fill(10, {|i|
		var freq=fund * (i + 1);
		var modfreq= freq * 4;
		GrainFM.ar(2, trig, dur, freq, modfreq, LFNoise0.ar(2, mul:0.2, add:0.7)) * 0.02;
	})
}.play
)




// Load Samples for buffer variations
(
    ~clickPath = ~path ++ "clicks/*";
    ~files = SoundFile.collect(~clickPath);
    ~clicks = ~files.collect { |sf| var b;
    b = Buffer.read(Server.local, sf.path)}
)




( // GrainBuf, sine wave used to modulate buffer index
{   var buf = ~voice.bufnum, trig, index, first, last;
	trig = Impulse.kr(40);
	first = ~clicks[0].bufnum;
	last = ~clicks[~clicks.size - 1].bufnum;
	index = SinOsc.kr(0.2).range(first,last);
	GrainBuf.ar(2, trig, 0.5, index,
	1, 0, 2, WhiteNoise.kr) * 0.5
}.play
)




( // GrainBuf, lfnoise used to modulate buffer index
{   var buf = ~voice.bufnum, trig, index, first, last;
	trig = Dust.kr(10);
	first = ~clicks[0].bufnum;
	last = ~clicks[~clicks.size - 1].bufnum;
	Mix.fill(5, {|i|
	index = LFNoise0.kr(i).range(first,last);
	GrainBuf.ar(2, trig, 0.5, index,
	i, 0, 2, WhiteNoise.kr) * 0.5
	});
}.play
)




( // Warp1, read a buffer using an envelope
{   var buf = ~bikecat.bufnum, pointer, freqScale;
	pointer = EnvGen.ar(Env([0.1, 0.8, 0.3, 0.2, 0.9], [4,2,1,0.5]).circle);
	freqScale = EnvGen.ar(Env([0.5, 4, 2, 0.8, 1.5], [0.5,1,2,4]).circle);
	Warp1.ar(1, buf, pointer:pointer, freqScale:freqScale.poll,windowSize:0.1) ! 2
}.play
)




( // Warp1, read a buffer using modulators
{   var buf = ~voice.bufnum, pointer, freqScale, windowSize;
	pointer = QuadN.ar(SinOsc.kr(2, mul:10, add:400), mul:0.4, add:0.5);
	freqScale = GrayNoise.kr(0.2, 1.0);
	windowSize = XLine.kr(0.001, 0.1, 10);
	Warp1.ar(1,buf,pointer:pointer,freqScale:freqScale,windowSize:windowSize) ! 2
}.play
)




// See the help file for the Ugens below for more examples.

GrainSin
GrainFM
GrainBuf
TGrains
Warp1
GrainIn
PitchShift
TGrains2
MonoGrain
