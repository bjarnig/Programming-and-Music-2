////////////////////////////////////////////////////////////////
//
//                        Chaos UGens
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)


/////////////////////////// Buffers //////////////////////////


(
    ~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
    ~path = ~path ++ "samples/";

	~caa = Buffer.read(s, ~path ++ "caa.wav");
	~cab = Buffer.read(s, ~path ++ "cab.wav");
	~cac = Buffer.read(s, ~path ++ "cac.wav");
)


////////////////////////// Chaos Ugens ///////////////////////////


/* See all subclasses of ChaosGen */

ChaosGen.allSubclasses.do(_.postln)


( // Play all

{
	Limiter.ar(Splay.ar(ChaosGen.allSubclasses.collect{|c| c.ar(10000.rand) } * 0.5))

}.play

)



/* Plot some */

~plotSignal.value( {QuadN.ar(SampleRate.ir/4)} )

~plotSignal.value( {CuspN.ar(50)} )

~plotSignal.value( {HenonN.ar(EnvGen.kr(Env([10,1000],[10])))} )

~plotSignal.value( {FBSineN.ar(100, 0.8, 1.2)} )

~plotSignal.value( {LorenzL.ar(4000)} )

~plotSignal.value( {LinCongC.ar(500, 1.2, 0.8, 0.6).clip(-1,1)} )




/* Listen to others */

{ HenonN.ar(1000) * 0.2 ! 2 }.play

{ GbmanL.ar(2000) * 0.2 ! 2 }.play

{ StandardL.ar(3000) * 0.2 ! 2 }.play

{ CuspL.ar(4000) * 0.2 ! 2 }.play

{ Logistic.ar(LFNoise1.kr(0.1,0.5,3.5), LFNoise1.kr(0.2,500,1000), 0.25, 0.5) }.play

{ Crackle.ar(LinCongL.ar(2).range(1.0,2.0), 0.5, 0.5) }.play;



( // Modulate frequency

10.do { { Pulse.ar(CuspN.ar(rrand(20, 60)).range(100, 2000), 0.5, 0.05) ! 2 }.play }

)



( // Freq and harmonics with envelope

15.do { { Blip.ar(
	GbmanN.ar(rrand(10, 100)).range(100, 500),
	LinCongN.ar(rrand(40, 80)).range(10, 200), 0.1)
	* EnvGen.ar(Env([0,1,0],[20.rand, 5.rand]))
	! 2 }.play }
)



( // TGrains, modulate start position and rate
{
	var rate = 10, grSize=0.8, buf = ~caa.bufnum;
	TGrains.ar(2,Impulse.kr(LatoocarfianL.ar(150).range(5,150)), buf, 1,
	LorenzL.ar(100).range(0, BufDur.kr(buf)), grSize);
}.play
)



( // TGrains, modulate start position and rate
{
	var rate = 10, buf = ~caa.bufnum;
	TGrains.ar(2,Impulse.kr(QuadC.ar(1).range(10,150)), buf,
	CuspN.ar(10000).range(0.5, 1.5),
	LinCongL.ar(1000).range(0, BufDur.kr(buf)),
	HenonN.ar(8000).range(0.1, 1.5) * 1.5);
}.play
)



( // Resonant frequency and speed
{
	DynKlank.ar(
	`[[CuspN.ar(1).range(100,800).lag(1), HenonL.ar(2).range(200,900).lag(3)],nil,[2, 4]],
	Impulse.ar(GbmanN.ar(10).range(1,10).lag(2), 0, 0.05) ! 2)
}.play;
)



// DFM1 filtering
(
	{
	DFM1.ar(
		Dust.ar(400),
		LatoocarfianN.ar(10).range(20, 8000),
		QuadC.ar(20).range(0.05, 1.3))
	* 0.2 ! 2
	}.play
)



( // Through reverb
{
	var signal = LatoocarfianC.ar(
    SampleRate.ir/2,
    LFNoise2.kr(2,1.5,1.5),
    LFNoise2.kr(2,1.5,1.5),
    LFNoise2.kr(2,0.5,1.5),
    LFNoise2.kr(2,0.5,1.5)) * 0.1;

	Mix.fill(10,{ signal = AllpassN.ar(signal, 0.01, 0.01.rand, 2)});

}.play;
)



( // Through resonators
{
	Klank.ar(`[[142,182,1224,1448,2400],[1,0.5,0.2,0.4,0.2] * 0.01],
	Henon2DC.ar(100, 10000, LFNoise1.kr(0.8, 0.1, 1.3), 0.3)) ! 2 * 0.2
}.play
)



( // There also exist chaos triggers
{
	Ringz.ar(StandardTrig.ar(10, 20), 2205, 0.02).fold2(0.5).dup
}.play
)



( // Reset playback using a trigger
	{
		var offset = 1/2;
		PlayBuf.ar(1, ~caa,
		trigger: HenonTrig.ar(5,10),
		startPos: BufFrames.kr(~caa) * offset, loop: 0)
	}.play
)




////////////////// Multidimensional UGens (Dan Stowell) ////////////////////


( // Rossler attractor, in three dimensions

{
	# x,y,z = RosslerL.ar(LFNoise1.ar(10, 100, 5000));
	Impulse.ar(x.range(50,500), y.range(0.0,1.0)).distort(z.range(0.0,1.0)) * 0.6 ! 2;
}.play

)


( // An "system L" chaotic generator

{
	# x,y,z = FincoSprottL.ar(TRand.kr(10,500, Dust.kr(10)));
	RLPF.ar(Saw.ar(x.range(100,200)) * 0.1, y.range(100,1000), z.range(0.2, 1.2)) ! 2;
}.play

)
