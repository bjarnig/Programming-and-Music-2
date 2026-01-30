////////////////////////////////////////////////////////////////
//
//                   JITLib - Tdef/Pdef
//
////////////////////////////////////////////////////////////////


/* - 1. Tasks and Tdef - */

// Tdef keeps a ref to a task that can be replaced while playing.


// Start the task
Tdef(\x, { loop { 0.5.wait; "sono".postln } }).play;

// Update the task
Tdef(\x, { loop { 0.125.wait; "logy".postln } });

// Stop the task
Tdef(\x).stop;

// Start again
Tdef(\x).play;

// Clear it
Tdef(\x).clear;



// Add a SynthDef for the processes below
(
SynthDef(\perc, {|freq=440, amp=0.1|
	var env = EnvGen.ar(Env.perc(0.01, 0.2), 1, doneAction:2) * amp;
	OffsetOut.ar(0, SinOsc.ar(freq, 0, env) ! 2);
}).add;
)


// Play the synth with a task
(
Tdef(\x, {
    loop({
		Synth(\perc);
        0.1.wait;
    })
}).play(quant:2)
)

// Update the tempo clock
TempoClock.default.tempo = 0.5;

// Update the task
(
Tdef(\x, {
    loop({
		Synth(\perc, [\freq, rrand(100, 1000)]);
        0.1.wait;
    })
}).play()
)


// Using .embed and .fork one can control subtasks
(
Tdef(\a, { 10.do { Synth(\perc, [\freq, rrand(100, 200)]);  0.05.wait } });
Tdef(\b, { 10.do { Synth(\perc, [\freq, rrand(1000, 2000)]);  0.05.wait } });
Tdef(\c, { "C will wait".postln; 2.wait; });

Tdef(\d, {
	loop {
		Tdef(\a).embed; // In sequence
		1.wait;
		Tdef(\b).embed;
		2.wait;
		Tdef(\a).fork; // In parallel
		Tdef(\b).fork;
		Tdef(\c).embed;
	}
}).play
);


// With TaskProxy
(
a = TaskProxy.new;
b = TaskProxy.new;
a.source = { "sono".postln; 1.wait; "logy".postln };
b.source = { "live".postln; 1.wait; "coding".postln };

Task {
    a.embed;
    b.fork;
    "DONE!".postln;
}.play;
)


/* - 2. Patterns - */

// Basic Pdef
(

Pdef(\melody).play;
Pdef(\melody, Pbind(\instrument, \perc, \dur, 0.15, \midinote, Pseq([60, 61, 64, 68], inf)));

)

// Modify on the fly
Pdef(\melody, Pbind(\instrument, \perc, \dur, 0.125, \midinote, Prand([60, 64, 67, 72], inf)));


Pdef(\melody).stop;



// Pbindef - modify individual keys
(

Pbindef(\groove,
	\instrument, \perc,
	\dur, 0.25,
	\midinote, 60,
	\amp, 0.2
).play;

)

Pbindef(\groove, \midinote, Prand([60, 62, 64], inf));

Pbindef(\groove, \midinote, Prand([60, 62, 64, 67, 69], inf));

Pbindef(\groove, \dur, Prand([0.25, 0.125, 0.5], inf));

Pbindef(\groove, \amp, Pwhite(0.1, 0.3, inf));

Pbindef(\groove, \pan, Pwhite(-0.7, 0.7, inf));

(
Pbindef(\groove).stop;
Pbindef(\groove).clear;
)


// Pdefn - non event stream reference definition
(
Pdefn(\x, Pbrown(100, 500, 10, inf));
Pbind(\instrument, \perc, \freq, Pdefn(\x), \dur, 0.1).play;
Pdefn(\x, Pseq([1,2,4] * 100, inf));
)


// Using Pdefn in multiple places - change affects all streams
(
Pdefn(\x, Pbrown(0, 6, 0.1, inf));
Pbind(\note, Pdefn(\x), \dur, 0.3).play;
Pbind(\note, Pdefn(\x), \dur, 0.1, \ctranspose, 15).play;
)

Pdefn(\x, Pseq([0, 3, 5, 7, 9, 11], inf));
Pdefn(\x, Pseq([0, 3, 3, 7], inf) + Pseq([0, [0, 3], [0, 5, 7]], inf));


// Fdef - Placeholder for functions to calculate with
(
Fdef(\dur, 0.2);

Tdef(\x, {
    loop({
		Synth(\perc);
		Fdef(\dur).value.wait;
    })
}).play(quant:2);
)

Fdef(\dur, { rrand(0.4, 0.12) });
Fdef(\dur, { rrand(0.01, 0.12) });

// Graphical Controllers
(
ProxyMixer, TdefAllGui, PdefAllGui, NdefMixer,
TdefGui, PdefGui, MonitorGui, NdefGui, NdefParamGui
)
