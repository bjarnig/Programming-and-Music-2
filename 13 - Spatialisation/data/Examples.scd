

////////////////////////////////////////////////////////////////
//
//                     Examples
//
////////////////////////////////////////////////////////////////


(    // - Sound Inputs -

    s.options.numOutputBusChannels = 16;

    s.waitForBoot({

    	~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
    	~fp = ~path ++ "sounds/";

    	// stereo
    	~s1 = Buffer.read(s, ~fp ++ "dolico.wav");
    	~s2 = Buffer.read(s, ~fp ++ "chanslim.wav");
    	~s3 = Buffer.read(s, ~fp ++ "charesoi.wav");
    	~s4 = Buffer.read(s, ~fp ++ "screpen.wav");
    	~s5 = Buffer.read(s, ~fp ++ "freeze.wav");
	    ~s6 = Buffer.read(s, ~fp ++ "ghm.wav");

    	// mono
    	~s1m = Buffer.readChannel(s, ~fp ++ "dolico.wav", channels:[0]);
    	~s2m = Buffer.readChannel(s, ~fp ++ "chanslim.wav", channels:[0]);
    	~s3m = Buffer.readChannel(s, ~fp ++ "charesoi.wav", channels:[0]);
    	~s4m = Buffer.readChannel(s, ~fp ++ "screpen.wav", channels:[0]);
    	~s5m = Buffer.readChannel(s, ~fp ++ "freeze.wav", channels:[0]);
	    ~s6m = Buffer.readChannel(s, ~fp ++ "ghm.wav", channels:[0]);

    })
)

(
	~winenv = Env([0, 1, 0], [0.05, 0.01], [8, -4]); ~winenvbuf = Buffer.sendCollection(s, ~winenv.discretize, 1);

	NF(\txtn, {
		var buf = ~s6m, trig, index, first, last, envbuf=~winenvbuf.bufnum, pan;
		trig = Impulse.ar( EnvGen.ar( Env([10,40,10],[5,10], [2-8]).circle ) );
	    pan = Demand.ar(trig, 0, Dseq(Array.rand(16,-1.0,1.0), inf));
		GrainBuf.ar(4, trig, 0.3, buf, 0.1, 0, 2, pan, envbuf, 512, 10)
	}).play;
)

(

SynthDef(\graingliss, { |buf=0, rate=1, start=0, amp=0.5, dur=0.3, pan=0, glissfrom=1, glissto=8|
	var sig, shape, env, pos;
	shape = Env([0, amp, 0], [dur*0.5, dur*0.5], \sine);
	env = EnvGen.ar(shape, doneAction: 2);
	pos = start * BufSamples.ir(buf);
	sig = PlayBuf.ar(1, buf, EnvGen.ar(Env([glissfrom, glissto], [dur]))  * BufRateScale.ir(buf), 1, pos, 0);
	OffsetOut.ar(0, Pan4.ar(sig * env, pan));
}).add;

)

(

~granular = {|dur=0.1, overlap=2, durend=10|

Routine({
	var next, rate, start, times, total;
	total = ~s4m.numFrames / ~s4m.sampleRate;
	times = ((total / dur) * overlap).asInteger.postln;
	times.do{|i|
		next = dur / overlap;
		start = (i * next) / total;
		s.makeBundle(0.1,
			{ Synth(\graingliss, [\buf, ~s4m.bufnum, \dur, dur, \start, start, \glissto, i.linlin(0,times, 1,10), \pan, i.linlin(0,times, -1.0,1.0),]) }
		);
		i.linlin(0,times, next, next*durend).wait
	};
}).play;

};

~granular.value(0.08,1.1,8);
~granular.value(0.2,3.1,0)

)
