////////////////////////////////////////////////////////////////
//
//                       Sonification
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)

~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;


/////////////////// Load File as Buffer ///////////////////

// Read a file, convert to Signal, filter and load as Buffer

(

var file = File.open(~path ++ "data/atoms.pdf", "rb");
var signal = file.readAllSignal;

    // Normalize and filter bad data from the signal
	signal.normalize;
	signal = signal.reject({arg item; item.isNaN });

    // Load the signal as buffer
    b = Buffer.alloc(s, signal.size);
	b.loadCollection(signal);
);


// Play the buffer
{ PlayBuf.ar(1, b, loop:1) ! 2}.play



/////////////////// Use a dataset as buffer ///////////////////


// Fill an array with random numbers, could be any list of numbers
a = Array.fill(1024 * 64, { rrand(1, 100) })

(

b = Buffer.loadCollection(s, a, 1);

SynthDef(\player, {|out=0, buf=0, rate=1, amp=0.005|
	var snd = PlayBuf.ar(1, buf, rate/SampleRate.ir, 1, 0, 1) * amp;
	Out.ar(out, snd ! 2);
}).add;

)

(

// start synth
x = Synth(\player, [\buf, b, \rate, 100000]);

// set rate in samples per second
x.set(\rate, 5000);

)




/////////////////// Analyse a buffer ///////////////////

(

b = Buffer.loadCollection(s, a, 1);

SynthDef(\analyse, {|out=0, buf=0, rate=1, t_trig=1, amp=0.5|
	var buffer = PlayBuf.ar(1, buf, rate/SampleRate.ir, 1, 0, 1);
	var synth = Saw.ar(Tartini.kr(buffer)[0].poll);
	Out.ar(out, synth);
}).add;

)


(

// start synth
x = Synth(\analyse, [\buf, b, \rate, 1000]);

// set rate in samples per second
x.set(\rate, 5000);

)




/////////////// Read Buffer for Control ///////////////

// DBufRd for reading buffers with demand rate

b = Buffer.alloc(s, 24, 1);
b.setn(0, { exprand(200, 500) } ! b.numFrames);
b.getn(0, b.numFrames, {|x| x.postln })

(

{ var indexPattern;
    indexPattern = Dseq([Dseq([0, 3, 5, 0, 3, 7, 0, 5, 9], 3), Dbrown(0, 23, 1, 5)], inf);
    SinOsc.ar(
        Demand.kr(Dust.kr(10), 0, Dbufrd(b, indexPattern))
    ) * 0.1
}.play;

)




