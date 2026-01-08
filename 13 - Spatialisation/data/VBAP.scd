
////////////////////////////////////////////////////////////////
//
//                     VBAP
//
////////////////////////////////////////////////////////////////

/*

Vector Base Amplitude Panner (VBAP) is  used for panning sounds in a three-dimensional space.
It is based on the principle of amplitude panning, where a sound source is reproduced by multiple
loudspeakers, each of which has a different amplitude level. By adjusting the amplitudes of the
loudspeakers, the sound source can be moved in any direction in the 3D space.VBAP can use any
number of loudspeakers to reproduce the sound source

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
    a = VBAPSpeakerArray(3, [
    	[-22.5, 10],
    	[22.5, 10],
    	[-67.5, 10],
    	[67.5, 10],
    	[-112.5, 10],
    	[112.5, 10],
    	[-157.5, 10],
    	[157.5, 10],
    	[-45, 0],
    	[45, 0],
    	[-90, 0],
    	[90, 0],
    	[-135, 0],
    	[135, 0],
    	[0, 0],
    	[180, 0]
    ]); // zig zag partial dome

    //a = VBAPSpeakerArray(2, [ -30, 30, 0, -110, 110 ]); // zig zag partial dome

    b = a.loadToBuffer;

)

(
    // pan around the circle up and down
    x = { |azi = 0, ele = 0, spr = 10|
        var source = PlayBuf.ar(1, ~s4m, loop:1, rate:1);
        var channels = 4; // How many channels
        var azimuth =  SinOsc.kr(0.1).range(-20, 20); // LFSaw.kr(0.5, 0).range(-180, 180) * -1;
        var elevation = 10; //SinOsc.kr(3, 0).range(0, 14.97);
        VBAP.ar(channels, source, b, azimuth, elevation, spr);
    }.play;
)
