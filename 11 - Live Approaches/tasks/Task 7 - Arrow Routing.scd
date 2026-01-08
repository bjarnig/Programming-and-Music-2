////////////////////////////////////////////////////////////////
//
//                 Task 7: Arrow Routing
//
////////////////////////////////////////////////////////////////

Ndef.clear;

// 10 Use <<> for routing

(
Ndef(\dst, {
	var son = \in.ar([0,0]);
	var inFreq = Tartini.kr(son)[0];
	var freq = inFreq[0] / 4;
	var thres = Lag.kr(Amplitude.kr(son), 0.1);
	var osc = Splay.ar(Pulse.ar(Array.series(10, freq, 5))) * thres;
	var verb = Mix.ar(Array.fill(10,{ CombL.ar(osc, 0.05, rrand(0.02, 0.04), 10.rand) }));
	XFade2.ar(son, verb, 0.75)
}).play;

)

Ndef(\src, { Blip.ar(LFNoise2.ar(7).range(40,100)) }) <>> Ndef(\dst);

Ndef(\src).play

