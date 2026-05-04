////////////////////////////////////////////////////////////////
//
//                      Synthesis
//
////////////////////////////////////////////////////////////////


( // Selecting different FMs

Ndef(\selectx, {
	var fmArray = { PMOsc.ar(rrand(100,1000), LFDNoise3.ar(rrand(1,10)).range(100,3000), 10.rand) } ! 10;

	Splay.ar(

		// Use select X to sweep through the FM array
		SelectX.ar(SinOsc.ar(0.1).range(0,1), fmArray)) * 0.1
}).play

)

( // Fold SinOscFB

Ndef(\fold, {

Fold.ar(
	SinOscFB.ar([40,42], LFNoise1.ar(3).range(0.1,1.75)), // src
	LFNoise2.ar(4.3).range(0.1,0.5), // lo
	SinOsc.ar([0.03,0.1]).range(0.5,2.0) // hi
) * 0.5

}).play

)

( // DemandEnvGen with parameters and .atan

Ndef(\stdn, {
	var sd = SampleDur.ir * 0.15;
	var size = 5, from = 1, to = 25;
	var modFreq = 10, modFrom = 5, modTo = 25;

	DemandEnvGen.ar(
		Dseq([1, [-1, 0.5]], inf),
		Dseq(Array.rand(size,from,to), inf) * sd
	).atan(SinOsc.ar(LFNoise0.ar(modFreq).range(modFrom, modTo))) * 0.5;
}).play;

Ndef(\stdn).fadeTime = 2;

)