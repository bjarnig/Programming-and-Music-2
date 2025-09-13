////////////////////////////////////////////////////////////////
//
//                    Microsound 2 (Shapes)
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)


////////////////////////// Waveforms ///////////////////////////


( // Envelopes for waveforms

{   var freq = 5, points = 10256, env, values, durations;
	values = Array.fill(points, { rrand(-1.0, 1.0)});
	durations = Array.fill(points, { rrand(0.0, 1.0)}).normalizeSum;
	env = Env(values, durations).circle;
	EnvGen.ar(env, timeScale:freq.reciprocal) * 0.2;
}.play;

)




( // Envelopes again, frequency varies

{   var freq, points = 512, env, values, durations;
	values = Array.fill(points, { rrand(-1.0, 1.0)});
	durations = Array.fill(points, { rrand(0.0, 1.0)}).normalizeSum;
	env = Env(values, durations).circle;
	freq = 100 * SinOsc.kr(0.1, mul: 0.4, add: 0.5);
	EnvGen.ar(env, timeScale:freq.reciprocal) * 0.2;
}.play;

)




( // Generate a buffer and read with Osc

    var wavetable, buffer, conditions;
    conditions = {arg i; if(i % 8 == 0, {0.1.rand},{0.8.rand})};
    wavetable = Signal.fill(8192,conditions).asWavetable;
    buffer = Buffer.loadCollection(Server.default, wavetable, 1, {
    { Osc.ar(buffer,1,mul:0.5) ! 2 }.play });
)




( // Different buffer and varying frequency

    var wavetable, buffer, conditions, mod;
    conditions = { arg i;
	if(i % 8 == 0, {rrand(0.1, 0.2)});
	if(i % 4 == 0, {rrand(0.3, 0.4)});
	if(i % 2 == 0, {rrand(0.6, 0.8)}, {rrand(0.7, 0.9)})};
    wavetable = Signal.fill(4096,conditions).asWavetable;
    buffer = Buffer.loadCollection(Server.default, wavetable, 1, {
	{   var mod = mod = SinOsc.kr(0.01, 0, 1, 2);
		Osc.ar(buffer, 10 * LFNoise0.kr(mod, 0.5, 0.4), mul:0.5) ! 2 }.play });
)