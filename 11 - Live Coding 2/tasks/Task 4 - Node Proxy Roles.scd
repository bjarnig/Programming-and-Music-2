////////////////////////////////////////////////////////////////
//
//                    Task 4: Node Proxy roles
//
////////////////////////////////////////////////////////////////

Ndef.clear

(
// -> \set
Ndef(\a);
Ndef(\a)[0] = {|freq=80| Saw.ar(freq!2,0.1) };
Ndef(\a)[1] = {|freq=80| SinOsc.ar(freq!2 * 0.5,0,0.1) };
Ndef(\a)[2] = \set -> Pbind(\dur, 0.1, \freq, Pwhite(40,400));
Ndef(\a)[3] = {|freq=80| SinOsc.ar(freq*3!2 * 0.5,0,0.1) };
Ndef(\a).play
)

(
// -> \filter
Ndef(\c).play;
Ndef(\c).fadeTime = 2;
Ndef(\c)[0] = {|freq=90| Saw.ar(freq!2,0.1) };
Ndef(\c)[2] = \filter -> {|in| LPF.ar(in, LFNoise1.ar(8).range(100,800)) };
Ndef(\c)[3] = {|freq=900| Saw.ar(freq!2,0.1) };
)

// or .filter
Ndef(\saw, { Saw.ar(100!2) }).play
Ndef(\saw).filter(1, {arg in; LPF.ar(in, 900)})
Ndef(\saw).filter(2, {arg in; GVerb.ar(in)})
Ndef(\saw).filter(3, {arg in; CombC.ar(in, 2, LFNoise1.ar(3).range(0.1,0.2), 4) })
