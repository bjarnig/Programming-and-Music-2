////////////////////////////////////////////////////////////////
//
//                     A set of wavetables
//
////////////////////////////////////////////////////////////////

/* Wavetables.scd works with one table at a time. This file loads a whole
   set into consecutive buffers, which is what VOsc needs: it reads a range
   of buffer numbers and interpolates between them, so the waveform itself
   becomes a signal you can modulate. The thirteen tables in tables/ are
   single cycles of 4096 samples each. */

s.boot


//////////////////// Loading the set ///////////////////////////

/* VOsc requires the buffers to be consecutive, of equal power-of-two size,
   and in wavetable format. asWavetable does the conversion; it returns twice
   as many samples, which is why a 4096-frame file becomes an 8192 buffer. */

(
~tablePath = (PathName(thisProcess.nowExecutingPath)).pathOnly ++ "tables/";

~loadTables = { |path|
	var files = SoundFile.collect(path ++ "*.wav").sort { |a, b|
		a.path.split($/).last < b.path.split($/).last
	};
	Routine({
		~tables = files.collect { |sf|
			var file = SoundFile.new, signal;
			file.openRead(sf.path);
			signal = Signal.newClear(file.numFrames);
			file.readData(signal);
			file.close;
			Buffer.loadCollection(s, signal.asWavetable);
		};
		s.sync;
		("loaded " ++ ~tables.size ++ " tables, buffers "
			++ ~tables.first.bufnum ++ " to " ++ ~tables.last.bufnum).postln;
		// VOsc will be silent if these are not consecutive
		(~tables.collect(_.bufnum).differentiate.drop(1).every(_ == 1)).if(
			{ "buffers are consecutive".postln },
			{ "WARNING: buffers are NOT consecutive, free them and reload".postln }
		);
	}).play;
};

~loadTables.(~tablePath);
)

// look at one before hearing it
~tables[0].plot

// and the whole set, end to end
(
Buffer.loadCollection(s, ~tables.collect { |b| b.numFrames }.sum.collect { 0 });
~tables.do { |b, i| b.plot("table " ++ i) };
)


/////////////////// One table at a time ////////////////////////

// Osc reads a single wavetable buffer
{ Osc.ar(~tables[0].bufnum, 110, 0, 0.2) ! 2 }.play

// step through the set by hand and listen to what each one is
(
Routine({
	~tables.do { |b, i|
		var x;
		("table " ++ i).postln;
		x = { Osc.ar(b.bufnum, 110, 0, 0.2) ! 2 }.play;
		1.5.wait;
		x.free;
		0.2.wait;
	};
}).play(AppClock);
)

CmdPeriod.run


////////////////// Interpolating across the set ////////////////

/* VOsc takes a fractional buffer index. At 3.5 it is halfway between the
   fourth and fifth table. Because the index is a signal, the waveform can be
   swept, modulated or driven by anything else in the graph. */

// swept by hand
{ VOsc.ar(~tables[0].bufnum + MouseX.kr(0, ~tables.size - 1), 110, 0, 0.2) ! 2 }.play

// swept slowly across the whole set, so the morph is the piece
(
{ VOsc.ar(~tables[0].bufnum + Line.kr(0, ~tables.size - 1, 30), 110, 0, 0.2) ! 2 }.play
)

// the index modulated at audio rate, which is a kind of waveform FM
(
{ VOsc.ar(
	~tables[0].bufnum + SinOsc.ar(MouseY.kr(0.2, 200, \exponential))
		.range(0, ~tables.size - 1),
	110, 0, 0.2) ! 2 }.play
)

CmdPeriod.run


//////////////////////// Layers ////////////////////////////////

/* Four oscillators over the same set, each drifting through the tables at its
   own rate and detuned slightly. After the voscDrift SynthDef in the
   Topics/Wavetable material. */

(
SynthDef(\voscDrift, { |freq = 220, amp = 0.15, first = 0, span = 6,
	rates = #[0.04, 0.02, 0.08, 0.01], mults = #[1.0, 1.003, 0.997, 1.006],
	atk = 4, rel = 6|
	var env = EnvGen.ar(Env([0, 1, 1, 0], [atk, 4, rel], \sine), doneAction: 2);
	var sig = Mix.fill(4, { |i|
		VOsc.ar(first + LFNoise2.ar(rates[i]).range(0, span), freq * mults[i])
	});
	Out.ar(0, Splay.ar(sig * env * amp));
}).add;
)

Synth(\voscDrift, [\first, ~tables[0].bufnum, \span, ~tables.size - 1])

// several at once, an octave apart
(
Routine({
	[110, 220, 55].do { |f|
		Synth(\voscDrift, [\freq, f, \first, ~tables[0].bufnum,
			\span, ~tables.size - 1, \amp, 0.1]);
		2.wait;
	};
}).play(AppClock);
)

CmdPeriod.run


/////////////////// Writing your own table /////////////////////

/* A table is an array of samples, so it can be written rather than loaded.
   Signal has the harmonic fills; anything else can be built by hand. */

(
// a harmonic series with chosen amplitudes
~mine = Buffer.loadCollection(s,
	Signal.sineFill(4096, [1, 0, 0.5, 0, 0.3, 0, 0.2]).asWavetable);
)

{ Osc.ar(~mine.bufnum, 110, 0, 0.2) ! 2 }.play

(
// written by hand: a shape that is not a sum of sines
~drawn = Buffer.loadCollection(s, Signal.newFrom(4096.collect { |i|
	var x = i / 4095;
	((x * 2 - 1).cubed * 0.8) + (0.2 * (x * 8).sin)
}).asWavetable);
)

{ Osc.ar(~drawn.bufnum, 110, 0, 0.2) ! 2 }.play

CmdPeriod.run
