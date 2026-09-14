////////////////////////////////////////////////////////////////
//
//                 Waveform Examples  (Demand Rate)
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)


( // DemandEnvGen with fold2

{
	var sdm=1, mod=0.005, from=9, to=12, min=0.1, max=0.3, amp=1;
	var sd = SampleDur.ir * sdm, hpf=40, mf=1.0;

	HPF.ar(
		DemandEnvGen.ar(
			Dseq([min, min.neg, [max.neg, max]], inf),
			sd * Dseq([from, to, Dbrown2(from,to,to,from.neg,from)], inf)
		).fold2(SinOsc.ar(mod)) * mf * amp,
	hpf)

}.play

)

( // Nested Dseqs

{
    var	from=10, to=35, sdm=1, repeats=100, sd = SampleDur.ir * sdm;

	DemandEnvGen.ar(
		Dseq([
			Dseq([0, 0.5], repeats),
			Dseq([-0.2, 0.8], repeats/2),
			Dseq([-1.0, 1.0], Dwhite(repeats/32, repeats)),
			Dseq([-0.8, 0.1], repeats/16)
		], inf),
		Dseq([
			Dwhite(from, to, repeats),
			Dwhite(from/1.5, to/1.5, repeats),
			Dbrown(from/10, to/10, from/20, repeats)
		], inf) * sd
	);

}.play

)


( // Layers

{
	var dur = SampleDur.ir, times = 20, amp = 1.0;

	Splay.ar(
		times.collect {|i|
			DemandEnvGen.ar(Dseq([Dseries(-0.5, 0.1, 15)], inf) * amp/times, dur * Dseq([1,2],inf) * (i + 1))
		}
	)

}.play

)
