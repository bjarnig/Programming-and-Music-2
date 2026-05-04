////////////////////////////////////////////////////////////////
//
//                  Mutable Instruments
//
////////////////////////////////////////////////////////////////

// SC ports of the famous MI EuroRack Modules. By Émilie Gillet.

// Ported by Volker Böhm https://vboehm.net/downloads/


( // MiVerb with freeze

Ndef(\system, {
	var input = RLPF.ar(Dust.ar([10,20]), LFNoise1.kr(2).range(100,4000), 0.1) * 2;
	var frz = TRand.kr(-1, 1, Dust.kr(0.7));
    MiVerb.ar(input, 0.8, 0.5, 0.75, 0.1, freeze:frz);
}).play

)


( // Plaits (a macro oscillator)

Ndef(\plaits, { Splay.ar(

	MiPlaits.ar(

	34, // pitch
	5,  // engine
	LFNoise2.ar([4,2]).range(0.1,0.5), // timbre
	LFNoise2.ar(0.4).range(0.1,0.95), // morph
	LFNoise2.ar([0.5,3]).range(0.1,0.9), // trigger

	mul: 0.5) )} * 0.5).play
)


( // Rings (resonator)

Ndef(\miRings, {
	MiRings.ar(
		Dust.ar(10),
		pit: [40,71],
		bright:0.4,
		damp:LFDNoise0.ar(0.2).range(0,1));
}).play

)

( // Clouds (Granular audio processor)

b = Buffer.read(s,"/Users/bjarni/Courses/Classes/PMB/17 - Examples/data/snd/up.wav");

Ndef(\miClouds, {

	var input = PlayBuf.ar(1, b, 1, loop: 1)!2;
    var dens = LFDNoise3.kr(0.3).range(0.08, 0.045);
	var pos = LFDNoise3.kr(0.8).range(0.0, 1.0);
	Splay.ar(MiClouds.ar(input, 0, pos, 0.1, dens, [0.5,0.8], drywet: 1, mode: 0, mul:0.5));

}).play

)

(   // MiBraids, Vosim

{
    var pit = LFNoise0.kr(4).range(33, 66).round;
    var timb = LFNoise1.kr(0.3,0.5,0.5);
    var color = LFNoise1.kr(0.3,0.5,0.5);
    MiBraids.ar(pit, timb, color, 21, mul: 0.2) ! 2;
}.play

)
