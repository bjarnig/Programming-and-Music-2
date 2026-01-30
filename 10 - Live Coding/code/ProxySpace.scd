////////////////////////////////////////////////////////////////
//
//                     JITLib - ProxySpace
//
////////////////////////////////////////////////////////////////



/* - 0. Setup - */

// Activate ProxySpace - all ~variables become NodeProxies
p = ProxySpace.push(s);

// Verify the current environment
currentEnvironment.postln;



/* - 1. Basics - */

// Now tilde variables are NodeProxies
~simple.play;
~simple = { SinOsc.ar(440, 0, 0.2) ! 2 };

// Redefine on the fly
~simple = { Saw.ar(200, 0.1) ! 2 };

~simple = { Pulse.ar(300, 0.3, 0.1) ! 2 };


// Stop and clear
~simple.stop;
~simple.clear;


// FadeTime for smooth transitions
(
~fader.play(fadeTime: 3);  // Fade in over 3 seconds
~fader.fadeTime = 2;        // Set crossfade time between definitions
~fader = { SinOsc.ar(400, 0, 0.2) ! 2 };
)

// Now changes crossfade over 2 seconds
~fader = { Saw.ar(300, 0.15) ! 2 };

~fader = { LFTri.ar(100, 0, 0.2) ! 2 };

~fader.stop(fadeTime: 4);  // Fade out over 4 seconds



/* - 2. Parameters and Control - */


// Define proxies with arguments for live tweaking
(

~synth = { |freq=400, detune=4, amp=0.2, pan=0|
	var sig = SinOsc.ar([freq, freq + detune], 0, amp);
	Pan2.ar(sig.sum, pan);
};
~synth.play;

)


// Tweak parameters live
~synth.set(\freq, 1000.rand);

// Open GUI for control
~synth.gui;


// Set parameter specs for better slider ranges
(

Spec.add(\detune, [0, 50, \lin]);
~synth.gui(8);

)

// Use xset for crossfaded parameter changes
(

~synth.fadeTime = 10;
~synth.xset(\freq, 600.rand);

)

~synth.stop;



/* - 3. Routing and Nesting - */


// Use ~name.ar or ~name.kr inside another proxy for modular routing

// Source signal
~source = { WhiteNoise.ar(0.3) };

// Filter using the source
(

~filtered = { LPF.ar(~source.ar, SinOsc.ar(7).range(100,3000)) };
~filtered.play; // Play the effect, will start the source

)

// Change the filter - source stays the same
(
~filtered.fadeTime = 2;
~filtered = { BPF.ar(~source.ar, SinOsc.ar(2).range(10,8000), 0.1) };
)

// Change the source - filter stays the same
~source = { PinkNoise.ar(0.3) };

~filtered.stop;


// Frequency Modulation with nested proxies
(
~modulator = { SinOsc.ar(5) };
~carrier = { SinOsc.ar(~modulator.ar * 200 + 400, 0, 0.2) ! 2 };
~carrier.play;
)

// Modify the modulator - carrier automatically updates
(
~modulator.fadeTime = 3;
~modulator = { SinOsc.ar(10) };
)

~modulator = { LFNoise2.ar(2) };

~carrier.stop;


// Decomposed sound
(
~padFreqs = { [404, 505, 606, 707] + LFNoise2.ar(0.1 ! 4, 30) };
~padAmps = { [0.4, 0.3, 0.2, 0.5] + LFNoise2.ar(0.1 ! 4, 0.1) };
~padCut = 2000;
~padQ = 0.8;

~pad = {
	Splay.ar(
		BLowPass4.ar(
			Saw.ar(~padFreqs.ar, ~padAmps.ar),
			~padCut.kr,
			~padQ.kr
		)
	)
};
~pad.play;
)

// Modify components independently
(
~padFreqs.fadeTime = 10;
~padFreqs = 500;
)

~padFreqs = { SinOsc.ar(1) * 10 + 500 };

~padFreqs = { SinOsc.ar([1, 1.1, 1.2]) * [10, 20, 30] + 500 };

~padCut = { SinOsc.kr(0.1).range(500, 4000) };

~pad.stop(4);



/* - 4. Mapping Control Signals - */

/*
.map connects a proxy's output to a parameter.
.unmap disconnects it.
.xmap crossfades to a new modulation source.
*/


// Main synth with parameters
(
~mapped = { |freq=400, amp=0.1| PMOsc.ar(freq, [freq*3, freq*5], 10, 0, amp)};
~mapped.play;
)

// LFO for frequency
(
~lfo = { SinOsc.kr(2).range(100, 600) };
)

// Map LFO to frequency parameter
(
~mapped.map(\freq, ~lfo);
)

// Change the LFO, mapping stays
(
~lfo.fadeTime = 3;
~lfo = { LFNoise2.kr(2).range(200, 800) };
)

~lfo = { LFSaw.kr(0.5).range(100, 1000) };

// Unmap to return to static value
(
~mapped.unmap(\freq);
~mapped.set(\freq, 440);
)

~mapped.stop;




/* - 5. Multichannel Expansion - */

// Using arrays for multiple frequencies
(
~multi.play;
~multi = { Splay.ar(SinOsc.ar([400, 500, 600, 700], 0, 0.1)) };
)

// Detune with noise
(
~multi.fadeTime = 3;
~multi = { Splay.ar(Saw.ar([400, 500, 600, 700] + LFNoise2.ar(0.1 ! 4, 20), 0.1)) };
)

// Generate arrays with collect
(
~rich = {
	var freqs = Array.rand(10,100,2000);
	var sigs = freqs.collect { |f| SinOsc.ar(f + LFNoise2.kr(0.1, 10), 0, 0.08) };
	Splay.ar(sigs);
};
~rich.play;
)

// Using (1..n) range notation for harmonics
(
~harmonics = { Splay.ar(SinOsc.ar((1..8) * 150, 0, 0.05)) };
~harmonics.play;
)


p.clear;



/* - 6. Effects and Processing - */

/*
Use .filter(n, func) to add numbered effect slots.
Each slot can be modified independently.
Remove a slot by setting it to nil or using [n] = nil.
*/


( // Source

~chain.play;
~chain = { WhiteNoise.ar(0.2) ! 2 };

)

// Add effects in numbered slots
~chain.filter(1, { |in| in * LFPulse.ar(4).lag(0.01) });

~chain.filter(2, { |in| in + CombN.ar(in, 0.2, 0.08, 4) });

~chain.filter(3, { |in| LPF.ar(in, 2000) });

~chain.filter(4, { |in| in + (in * 0.3).fold2(SinOsc.ar(20)) });


// Modify individual slots
~chain.filter(1, { |in| in * SinOsc.ar(1).range(0.3, 1) });

// Remove a slot
~chain[3] = nil;

// Stop everything
~chain.stop;



// Different processing approaches on same source
(

~foral = { |ser=500, amp=1.0, sdm=0.5, mf=0.008|
	var sd = SampleDur.ir * sdm;
	Limiter.ar(DemandEnvGen.ar(
		Dseq([Dseries(-0.5, [0.1,-0.1], ser)], inf),
		sd * Dbrown(1, 7, 2.5)
	) * mf) * amp
};

)


// External Filtering
(
~foralFilter = {
	var snd = ~foral.ar;
	var brj = BBandStop.ar(
		snd,
		LFNoise1.ar(4).range(200, 8000),
		LFNoise1.ar(0.5).range(3, 12)
	);
	var lop = BLowPass4.ar(
		brj,
		LFNoise1.ar(20).range(20, 18000),
		LFNoise1.ar(0.5).range(0.2, 0.3)
	);
	lop;
};
~foralFilter.play;
)

~foralFilter.clear;

// Multi-Band Processing
(
~multiband = {
	var snd = ~foral.ar;
	var low, mid, high;

	// Split into bands
	low = LPF.ar(snd, 400);
	mid = BPF.ar(snd, 1200, 1);
	high = HPF.ar(snd, 3000);

	// Process each band differently
	low = low * 1.5;
	mid = (mid * 10).fold2(0.3);
	high = high * LFNoise1.kr(10);

	// Recombine
	(low + mid + high).dup;
};
~multiband.play;
)

(
~multiband.clear;
~foral.clear;
)




/* - 7. Textures - */

// Granular synthesis texture
(
~golum = {|rate=25, grAtk=0.88, grRel=0.2, rq=0.2, amp=0.5|
	var trigger = (Impulse.ar(rate) * 0.8) + (Dust.ar(rate) * 0.2);
	var env = EnvGen.ar(Env.perc(XLine.kr(grAtk, grAtk * 0.89, 12), grRel, 1, 4), trigger, 1, 0, (1/rate));
	Splay.ar(HPF.ar(SinOsc.ar([rate/3, rate], 0, env * 0.5) +
		BPF.ar(PinkNoise.ar(mul:env), rate * Array.series(8,4,4), 0.2), 40)) * amp;
};
~golum.play;
)


// Dseries-based envelope with sine clipping
(
~leaf = {|sdm=1, repeats=2, from=1, to=20, mod=40, amp=0.8, mf=0.3|
	var sd = SampleDur.ir * sdm;
	var modArray = [mod, mod*0.9, mod*0.95, mod*0.85];
	Splay.ar(HPF.ar(DemandEnvGen.ar(
		Dseq([Dseries(-1.0, Array.rand(4,0.01,0.1), 30)], inf),
		Dseq([
			Dwhite(from, to, repeats),
			Dwhite(from/1.5, to*3, repeats)
		], inf) * sd
	).clip(SinOsc.ar(modArray)) * mf * amp, 50));
};
~leaf.play;
)


/* - 8. More - */

// Select-based switching - switch abruptly with Duty
(
~sel.play;
~sel.fadeTime = 12;
)

(
~sel = {
	Splay.ar(
		Select.ar(
			Duty.kr(0.1, 0, Dseq([0, 1], inf)),
			[SinOsc.ar(2000), Saw.ar(300)]
		)
	) * 0.5
};
)


(
~sel = {
	Splay.ar(
		Select.ar(
			Duty.kr(0.05, 0, Dseq([0, 1, 1, 1, 2, 0, 1], inf)),
			[SinOsc.ar(2000), Saw.ar(3000), WhiteNoise.ar(0.4)]
		)
	) * 0.5
};
)

(
~sel = {
	Splay.ar(
		SelectX.ar(
			Duty.kr(0.05, 0, Dseq([0, 1, 1, 1, 2, 0, 1], inf)).lag(0.1),
			[SinOsc.ar(2000), Saw.ar(3000), WhiteNoise.ar(0.4)]
		)
	) * 0.5
};
)

~sel.stop;


// Understanding .play(), .stop(), and .end()

/*
  .play()  → Routes to hardware output (monitoring)
  .stop()  → Stops routing (still running internally)
  .end()   → Actually stops the synthesis
*/

(
~a = { SinOsc.ar(400, 0, 0.1) };
~b = { |freq = 500| Saw.ar(freq, 0.1) };
)

(
~a.play;  // Start monitoring
)

(
~a.stop;  // Stop monitoring (still running if used elsewhere)
)

(
~a.end;   // Actually stop
)

// NdefMixer for overview (works with ProxySpace too!)
(
NdefMixer(s);
)

// Graphical Controllers
(
ProxyMixer, TdefAllGui, PdefAllGui, NdefMixer,
TdefGui, PdefGui, MonitorGui, NdefGui, NdefParamGui
)


// ═══════════════════════════════════════════════════════════════════════════════
// CLEANUP & UTILITIES
// ═══════════════════════════════════════════════════════════════════════════════

// Clear all proxies
p.clear;

// Clear specific proxy
~name.clear;

// Stop all (but keep running)
p.do(_.stop);

// End all (actually stop)
p.do(_.end);

// Clear everything
(

p.clear;
Pdef.all.do(_.stop);
Pbindef.all.do(_.clear);
Tdef.all.do(_.stop);

)

// Pop ProxySpace (return to normal environment)
p.pop;



// History class - record a live coding performance

History.start;

1 + 2
2 - 1

History.end;

History.saveStory("~/Desktop/TestHist.scd".standardizePath);

h = History.new.loadStory("~/Desktop/TestHist.scd".standardizePath);
h.lines.printcsAll; "";

History.play;



// ═══════════════════════════════════════════════════════════════════════════════
// REFERENCE
// ═══════════════════════════════════════════════════════════════════════════════

/*
See also:
  Pdef, Pdefn, Tdef, Pbindef, Psym, Pnsym, Fdef
  History, ProxySpace, NodeProxy
  ProxyMixer, TdefAllGui, PdefAllGui, NdefMixer,
  TdefGui, PdefGui, MonitorGui, NdefGui, NdefParamGui

Main:
  - p = ProxySpace.push(s) to activate
  - ~name = { ... } to define
  - ~name.play to monitor
  - ~other.ar to nest
  - .map() for control
  - .filter(n, func) for effects
  - p.clear to reset

Benefits:
  - Concise syntax: ~name instead of Ndef(\name)
  - Crossfading with fadeTime
  - Parameter mapping (.map, .xmap)
  - Effect chains (.filter)
  - Nested routing (~name.ar)
  - GUI integration (.gui)
  - Works with all JITLib patterns (Pdef, Tdef, etc.)
*/
