
////////////////////////////////////////////////////////////////
//
//                         Specdiff
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

(   // FFT buffers

    n = 512; // number of bins

    b = Buffer.alloc(s, n, 1);
    c = Buffer.alloc(s, n, 1);

    // create arrays of magnitude scalars and load them to buffers
    d = Array.fill(n, {1.0.linrand});
    e = 1.0 - d;

    d = Buffer.loadCollection(s, d);
    e = Buffer.loadCollection(s, e);

    g = Array.fill(n, {1.0.linrand});
    h = 1.0 - g;

    g = Buffer.loadCollection(s, g);
    h = Buffer.loadCollection(s, h);

    // sample to spatialize
    f = ~s2m;

)

(
    x = SynthDef("spectral-diffusion", { arg out=0, analBuf, analBufCopy, scalBuf1, scalBuf2, soundBuf;
        var chain1, chain2, chain3, chain4;

        chain1 = FFT(analBuf, PlayBuf.ar(1, soundBuf, BufRateScale.kr(soundBuf), loop: 1));
        chain2 = PV_Copy(chain1, analBufCopy);

        chain1 = PV_MagMul(chain1, scalBuf1);
        chain2 = PV_MagMul(chain2, scalBuf2);

        Out.ar(out,  0.5 * IFFT([chain1, chain2]));

    }).add;
)

(

    // 1-2
    Synth("spectral-diffusion", [out: 0, analBuf: b, analBufCopy: c, scalBuf1: d, scalBuf2: e, soundBuf: f]);

    // 3-4
    Synth("spectral-diffusion", [out: 2, analBuf: b, analBufCopy: c, scalBuf1: g, scalBuf2: h, soundBuf: f]);

    // 5-6
    Synth("spectral-diffusion", [out: 0, analBuf: b, analBufCopy: c, scalBuf1: d, scalBuf2: e, soundBuf: f]);

    // 7-8
    Synth("spectral-diffusion", [out: 2, analBuf: b, analBufCopy: c, scalBuf1: g, scalBuf2: h, soundBuf: f]);

    s.scope;

)

s.meter


// execute this multiple times to change the distribution

(

    ~d = Array.fill(n, {1.0.linrand});
    ~e = 1 - ~d;
    d.loadCollection(~d);
    e.loadCollection(~e);

    ~g = Array.fill(n, {1.0.linrand});
    ~h = 1 - ~g;
    g.loadCollection(~g);
    h.loadCollection(~h);

)



// or try different ways to split the spectrum

(

    ~d = Array.fill(n, rrand(0.0, 0.25));
    ~e = Array.fill(n, rrand(0.25, 0.5));
    d.loadCollection(~d);
    e.loadCollection(~e);

    ~g = Array.fill(n, rrand(0.5, 0.75));
    ~h = Array.fill(n, rrand(0.75, 1.0));
    g.loadCollection(~g);
    h.loadCollection(~h);

)


// free resources

Buffer.freeAll;
