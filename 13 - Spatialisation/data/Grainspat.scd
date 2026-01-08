
////////////////////////////////////////////////////////////////
//
//                        Granular
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

    	// mono
    	~s1m = Buffer.readChannel(s, ~fp ++ "dolico.wav", channels:[0]);
    	~s2m = Buffer.readChannel(s, ~fp ++ "chanslim.wav", channels:[0]);
    	~s3m = Buffer.readChannel(s, ~fp ++ "charesoi.wav", channels:[0]);
    	~s4m = Buffer.readChannel(s, ~fp ++ "screpen.wav", channels:[0]);
    	~s5m = Buffer.readChannel(s, ~fp ++ "freeze.wav", channels:[0]);

    })
)

(

b = ~s3m; // Choose the sample to spatialize

SynthDef("grain",{ arg i_out=0, i_sampbufnum, dur = 0.05, pointer, offset = 0.005, amp = 1.0, loop = 1;
    var thisStart, thisDur, grain;
    thisStart = pointer + IRand(0, offset); // adds random time offset
    grain = EnvGen.ar(Env.sine, 1.0, amp, 0.0, dur, 2)
    * PlayBuf.ar(1,i_sampbufnum, BufRateScale.ir(i_sampbufnum), 1, thisStart,loop);
    OffsetOut.ar(i_out,grain); // use OffsetOut for precise sub-block timing
}).add;

SynthDef("syngrain",{ arg i_out=0, i_sampbufnum, dur = 0.05, pointer, offset = 0.005, loop = 1;
    var thisStart, thisDur, grain;
	var rate=12,ffreq=0.5,fmin=400,fmax=1000,amp=0.5,freq=30,bw=12,hpf=40;
    thisStart = pointer + IRand(0, offset); // adds random time offset
    grain = EnvGen.ar(Env.sine, 1.0, amp, 0.0, dur, 2)
    * HPF.ar(
        BBandStop.ar(
        LeastChange.ar(
            GravityGrid.ar(0,[freq/2,freq/4,freq,freq/16]),
            Saw.ar(freq)),
			LFNoise1.ar(ffreq).range(fmin,fmax), bw),
    hpf, amp);
    OffsetOut.ar(i_out,grain); // use OffsetOut for precise sub-block timing
}).add;

)

(
    x = {
        var numGrains = 10; // approximate number of simultaneous grains
        var numChannels = 4; // adjust for your setup
        var dur = 0.5, durRand = 0.1, thisDur;
        var start, now;
        var numGrainsRecip;
        var ampOffset = 4;

        numGrainsRecip = numGrains.reciprocal; // save some divides by converting to reciprocal
        start = Main.elapsedTime;

        loop {
            now = Main.elapsedTime - start;
            thisDur = dur + durRand.rand;
            s.bind({Synth("grain", [i_out: numChannels.rand, i_sampbufnum: b, dur: thisDur,
            pointer: now * b.sampleRate, amp: numGrainsRecip * ampOffset]);
            }); // send as a bundle for precise sub-block timing
            (thisDur * numGrainsRecip).wait;
        }
    }.fork;
)

x.stop; b.free;
