////////////////////////////////////////////////////////////////
//
//                Task 6: \in.ar + feedback
//
////////////////////////////////////////////////////////////////

Ndef.clear

Ndef(\filter, {|freq=15| BLowPass.ar(\in.ar, LFNoise1.ar(freq!2).range(100,4000), 0.2) });

Ndef(\osc1, { Saw.ar(20!2,0.1) });

Ndef(\filter).play;

Ndef(\filter).set(\in, Ndef(\osc1).asMap)

Ndef(\filter).map(\freq, Ndef(\osc2, {LFNoise1.ar(1!2).range(0.1,140)}));



// activate Ndef feedback
a = Ndef(\ep, { Ndef(\filter).ar }).play

a[1] = \filter-> {|in| in + (Ndef.ar(\ep_fb) * 0.98)}

Ndef(\ep_fb, { DelayC.ar(LPF.ar(Ndef.ar(\ep), LFNoise1.ar(10).range(100,8000)), 0.5, LFNoise1.ar(10).range(0.1,0.2)) })