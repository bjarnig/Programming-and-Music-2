////////////////////////////////////////////////////////////////
//
//                		Buses and Groups
//
////////////////////////////////////////////////////////////////



// Add a generating synth and an effect
(

SynthDef("noise", { arg out=0, freq = 10, lpf = 2000, amp=1;
	var sig = RLPF.ar(Dust.ar(freq ! 2, amp), lpf);
	Out.ar(out, sig);
}).add;

SynthDef("reverb", { arg in=0, out=0;
	var sig = In.ar(in, 2);
	sig = FreeVerb.ar(sig, 0.8);
	Out.ar(out, sig);
}).add;

)

// By default, s is assigned to the server, we can boot it
s.boot

// We can also plot the tree and bus meters in new windows
s.plotTree
s.meter

// The server has option through the ServerOptions class, s.options
ServerOptions
s.options

// The options contain the number of buses, we can change them and reboot
s.options.numAudioBusChannels = 1024
s.options.numOutputBusChannels = 32
s.options.numInputBusChannels = 4
s.reboot


// We ask for a new audio bus (be careful that the number of channel matches!)
b = Bus.audio(s, 2)
b.index
b.numChannels

// The order of events is important, first added will be on the tail of the chain
x = Synth(\reverb, [\in, b]); y = Synth(\noise, [\out, b])

// Oppposite order gives silence since then the reverb is calculated before the synth
y = Synth(\noise, [\out, b]); x = Synth(\reverb, [\in, b]);

// The order can be specified using the addAction
y = Synth(\noise, [\out, b]); x = Synth(\reverb, [\in, b], nil, \addToTail);

// You could also use variants of Synth.new() (also available for groups)
Synth.before(); Synth.after(); Synth.head(); Synth.tail()


// It is possible to exchange values through control buses
c = Bus.control(s); y = Synth(\noise)

// Map the synth's second input (freq) to read from the bus
y.map(1, c); c.value = rrand(10, 150);


// Create a group, add 2 synths to it via the 'target' argument and then set the amplitude for both
g = Group(s)
y = Synth(\noise, [\freq, 100], g)
z = Synth(\noise, [\freq, 1000], g)
g.set(\amp, rrand(0.1, 1.0))
g.freeAll÷


// Use Pbind with set type to change the synths in the running group
Pbind(\type, \set, \id, g, \amp, Pwhite(0.1, 0.2), \dur, 0.1).play


// It is possible to use buses to communicate between server and language
(

~myBus = Bus.control;
{ Out.kr(~myBus, LFNoise2.kr(10).range(10, 5000)) }.play;

Routine {

	var synth = Synth(\noise, [\freq, 100]);
	0.5.wait;

	inf.do {
		synth.set(\lpf, ~myBus.getSynchronous.postln);
		0.1.wait;
	}

}.play

)

/* Buses and Groups */

(
	SynthDef("saw", { arg out=0, freq=100, amp=0.3;
		var sig;
		sig = Saw.ar(freq, amp);
		Out.ar(out, sig);
	}).add;

	SynthDef("noise", { arg out=0, amp=0.3;
		var sig;
		sig = Crackle.ar(1.99, mul: amp);
		Out.ar(out, sig);
	}).add;

	SynthDef("reson", { arg in=0, out=0;
		var sig;
		sig = In.ar(in);
		sig = Resonz.ar(sig, LFNoise2.kr(2.6).range(100, 1000), 0.2, 5);
		ReplaceOut.ar(out, sig);
	}).add;

	SynthDef("chop", { arg in=0, out=0;
		var sig;
		sig = In.ar(in);
		sig = LFPulse.ar(5, mul: sig);
		ReplaceOut.ar(out, sig);
	}).add;
)

~saw = Synth("saw");

// new nodes get placed before the others (by default):
~res = Synth("reson")

// but a node can be moved somewhere else:
~res.moveAfter(~saw)

// nodes can be un/muted:
~res.run(false)
~res.run(true)

~saw.free;  ~res.free;

// this node reads from bus 1 and (over)writes to bus 0:
~chop = Synth("chop", [\in, 1, \out, 0])

// this writes to bus 1:
~noise = Synth("noise", [\out, 1])

// create this node in the right position:
~res = Synth.after(~chop, "reson")

// and set its busses:
~res.set(\in, 1, \out, 1)

~res.free; ~noise.free; ~chop.free;


~src = Group(s);
~fx = Group.after(~src);

~saw = Synth("saw", [\out, 1], ~src);
~noise = Synth("noise", target: ~src);

~chop = Synth("chop", [\in, 1, \out, 1], ~fx)
~res = Synth("reson", target: ~fx)

~fx.run(false)
~fx.run(true)

~fx.moveBefore(~src)
~src.moveBefore(~fx)
