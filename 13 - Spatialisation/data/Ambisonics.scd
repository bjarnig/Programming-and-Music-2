
////////////////////////////////////////////////////////////////
//
//                     Ambisonics
//
////////////////////////////////////////////////////////////////

/*

Ambisonics is used to treat an audio scene as a full 360-degree sphere of
sound coming from different directions around a center point. The
center point is where the microphone is placed while recording, or
where the listener’s ‘sweet spot’ is located while playing back.

*/


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

// #1, Ambisonics SynthDef, azimuth through SinOsc (Azimuth describes the direction of an object or location relative to the observer's position)

SynthDef(\ambisonic, {
    var src, w, x, y, a, b, c, d;
    src = PlayBuf.ar(1, ~s1m);
    #w, x, y, z = PanB.ar(src, SinOsc.ar(0.2).range(-1.0,1.0));
    Out.ar(0, DecodeB2.ar(4, w, x, y, 0.5));
    }).play;

)

(

// #2, Ambisonics Ndef, azimuth through LFNoise1

    NF(\leafspread, {|sdm=1,repeats=2,from=1,to=20,mod=40,amp=0.5,mf=0.3|
      var w, x, y, z, a, b, c, d;
      var sd = SampleDur.ir * sdm;
      var src = DemandEnvGen.ar(
    		Dseq([Dseries(-1.0, 0.05, 30)], inf),
    		Dseq([
    			Dwhite(from, to, repeats),
    			Dwhite(from/1.5, to*3, repeats)
    		], inf) * sd
    	).clip(SinOsc.ar(mod)) * mf * amp;

	    Ambspat.ar(4, src, LFNoise1.ar(LFNoise1.ar(1).range(0.01,3.14)).range(-1.0,1.0));

    }).play;
)

// #3, using UGens from sc3-plugins

(

SynthDef(\btoster, {
        var src, w, x, y, z, a, b, c, d, lf, rf, rr, lr;
	    src = PlayBuf.ar(1, ~s1m);
        #w, x, y, z = BFEncode1.ar(src, MouseX.kr(0, -2pi));
        #a, b, c, d = B2A.ar(w, x, y, z);
        // Filter the signal - a, b, c, and d represent mic capsule, so the color will change as the sound pans around
        #a, b, c, d = Resonz.ar([a, b, c, d], 440 * [1, 2, 4, 8], 0.1, 5);
        // back to b format
        #w, x, y, z = A2B.ar(a, b, c, d);
        #lf, rf = B2Ster.ar(w, x, y);
        Out.ar(0, [lf, rf]);
        }).play;
)

a = Synth(\btoster);