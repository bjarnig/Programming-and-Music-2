////////////////////////////////////////////////////////////////
//
//                    Task 2: Patterns .ar
//
////////////////////////////////////////////////////////////////

Ndef.clear

(

SynthDef(\jsnd, { arg freq=100, gate=1, out=0, lop=800, amp=0.1;
	var env = EnvGen.kr(Env.asr(0.1, amp, 1.5), gate, doneAction:2);
	var signal = RLPF.ar(Blip.ar(freq, 150).fold2(SinOsc.ar(freq/10)), lop, 0.5);
    Out.ar(out, Pan2.ar(signal * env));
}).add;

)

a = Ndef(\na);
a.source = Pbind(\instrument, \jsnd, \freq, 500, \lop, 2700, \amp, 0.2, \dur, 0.5, \legato, 0.1);
a.play
a.stop

b = Ndef(\nb)
b.source = { a.ar * SinOsc.ar(SinOsc.kr(10, 250, 500)) };
b.play

c = Ndef(\nc, { SinOsc.kr(10, 0, 500, 2000) });
c.fadeTime = 1;

d = Ndef(\nd)
d.source = Pbind(\instrument, \jsnd, \freq, 500, \lop, c, \amp, 0.4, \dur, 2);
d.play