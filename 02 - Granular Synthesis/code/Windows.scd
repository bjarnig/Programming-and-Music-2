////////////////////////////////////////////////////////////////
//
//              Grain windows
//
////////////////////////////////////////////////////////////////

s.boot


///////////////////////// Ten shapes ///////////////////////

(
~n = 1024;

// Tukey: flat in the middle with cosine tapers at both ends. 
~tukey = { |n, a = 0.5|
	Signal.newFrom(n.collect { |i|
		var x = i / (n - 1);
		case
		{ x < (a / 2) }       { 0.5 * (1 + cos(pi * (((2 * x) / a) - 1))) }
		{ x > (1 - (a / 2)) } { 0.5 * (1 + cos(pi * (((2 * x) / a) - (2 / a) + 1))) }
		{ true }              { 1.0 };
	});
};

// Gaussian, truncated at the edges. Smaller sigma is a narrower bell.
~gauss = { |n, sigma = 0.3|
	Signal.newFrom(n.collect { |i|
		var x = (i / (n - 1) * 2) - 1;
		exp(-0.5 * (x / sigma).squared);
	});
};

~windows = (
	rect:     Signal.rectWindow(~n),
	hann:     Signal.hanningWindow(~n),
	hamming:  Signal.hammingWindow(~n),
	welch:    Signal.welchWindow(~n),
	triangle: Env.triangle(1, 1).discretize(~n),
	sine:     Env.sine(1, 1).discretize(~n),
	tukey:    ~tukey.(~n, 0.5),
	gauss:    ~gauss.(~n, 0.3),
	expodec:  Env([1, 0.001], [1], \exp).discretize(~n),
	rexpodec: Env([0.001, 1], [1], \exp).discretize(~n)
);

~order = [\rect, \hann, \hamming, \welch, \triangle, \sine, \tukey, \gauss, \expodec, \rexpodec];
)

// look at them
~order.do { |k| ~windows[k].plot(k.asString) }

// or all at once
Signal.newFrom(~order.collect { |k| ~windows[k] }.flatten).plot("all ten, end to end")


/////////////////////// Hearing the shape //////////////////////

// each window becomes a one-channel buffer that GrainBuf reads as its envelope
(
~envbufs = ();
~order.do { |k| ~envbufs[k] = Buffer.sendCollection(s, ~windows[k], 1) };
~wave = Buffer.alloc(s, 1024, 1);
~wave.sine1([1], true, true, true);
s.sync;
)

(
SynthDef(\winGrain, { |envbuf = 0, wavebuf = 0, freq = 400, dens = 12, grdur = 0.09, amp = 0.3|
	var trig = Impulse.kr(dens);
	Out.ar(0, GrainBuf.ar(2, trig, grdur, wavebuf, freq / 400, 0, 2, 0, envbuf, mul: amp));
}).add;
)

// one window at a time, four seconds each.
(
Routine({
	~order.do { |k|
		var x;
		("  " ++ k).postln;
		x = Synth(\winGrain, [\envbuf, ~envbufs[k].bufnum, \wavebuf, ~wave.bufnum]);
		4.wait;
		x.free;
		0.4.wait;
	};
}).play(AppClock);
)

CmdPeriod.run


/////////////////// Audible Shapes /////////////////

// short grains make the difference obvious: the envelope is the spectrum
(
Routine({
	[\rect, \hann, \gauss].do { |k|
		var x;
		("  short, " ++ k).postln;
		x = Synth(\winGrain, [\envbuf, ~envbufs[k].bufnum, \wavebuf, ~wave.bufnum,
			\grdur, 0.004, \dens, 40, \amp, 0.2]);
		4.wait;
		x.free;
		0.4.wait;
	};
}).play(AppClock);
)

CmdPeriod.run
