////////////////////////////////////////////////////////////////
//
//                    JITLib - Node Proxies
//
////////////////////////////////////////////////////////////////


/* - 0. NodeProxy Basics - */

// Create an audio rate node proxy with 2 channels
a = NodeProxy.audio(s, 2);

// Set the source of the proxy
a.source = { Gendy3.ar(freq:[50,25]) };

// Start playing the node proxy
a.play;

// Stop playing the node proxy but keep it alive
a.stop;

// Play again
a.play;

// Stop playing and free the synth
a.end;

// Clear the source
a.clear;


/* - 1. Ndef Basics - */

/*

Ndef provides a global dictionary of NodeProxies accessed by name.
More convenient than creating individual NodeProxy variables.

*/

// Basic Ndef - define and play
Ndef(\a).play;
Ndef(\a, { SinOsc.ar(440, 0, 0.2) ! 2 });

// Redefine on the fly
Ndef(\a, { Saw.ar(220, 0.2) ! 2 });

Ndef(\a, { Pulse.ar([350, 351.3] / 4, 0.4) * 0.2 });

// Stop and clear
Ndef(\a).stop;
Ndef(\a).clear;


// You can define and play in one line
Ndef(\simple, { WhiteNoise.ar(0.1) ! 2 }).play;

Ndef(\simple, { PinkNoise.ar(0.1) ! 2 });

Ndef(\simple).stop;


// Ndef can also contain patterns (uses default synth here)
(
Ndef(\a).play;
Ndef(\a, Pbind(
	\dur, 0.03,
	\freq, Pbrown(0, 1, 0.1, inf).linexp(0, 1, 200, 350)
));
)

Ndef(\a).stop;
Ndef(\a).clear;



/* - 2. Parameters and Control - */

// Define Ndef with arguments
(
Ndef(\synth, { |freq=400, amp=0.2|
	SinOsc.ar(freq, 0, amp) ! 2
}).play;
)

// Set parameters
Ndef(\synth).set(\freq, 600);
Ndef(\synth).set(\freq, 200, \amp, 0.1);

// Use xset for crossfaded parameter changes
(
Ndef(\synth).fadeTime = 2;
Ndef(\synth).xset(\freq, 300);
)

Ndef(\synth).xset(\freq, 1000);


// Open GUI for parameter control
Ndef(\synth).gui;


// Define parameter specs for better GUI ranges
(
Spec.add(\detune, [0, 50, \lin]);
Spec.add(\cutoff, [100, 10000, \exp]);
)

(
Ndef(\filtered, { |freq=400, cutoff=2000, res=0.3, amp=0.2|
	var sig = Saw.ar(freq, amp);
	RLPF.ar(sig, cutoff, res) ! 2
}).play;

Ndef(\filtered).gui;
)

Ndef(\filtered).stop;



/* - 3. Routing and Nesting - */

/*
Use Ndef.ar(\name) or Ndef.kr(\name) to reference other Ndefs.
Changes to either Ndef automatically update the signal chain.
*/

// Create a source
Ndef(\source, { WhiteNoise.ar(0.5) });

// Filter the source
Ndef(\filtered, { LPF.ar(Ndef.ar(\source), 800) }).play;

// Change the filter
Ndef(\filtered, { BPF.ar(Ndef.ar(\source), 1200, 0.2) });

Ndef(\filtered, { HPF.ar(Ndef.ar(\source), 2000) });

// Change the source (filter automatically uses new source)
Ndef(\source, { PinkNoise.ar(0.5) });

Ndef(\source, { Saw.ar(100, 0.5) });

Ndef(\source, { Pulse.ar([100, 101], 0.5, 0.5) });

Ndef(\filtered).stop;


// Frequency modulation example
(

Ndef(\modulator, { SinOsc.ar(5) });
Ndef(\carrier, {
	SinOsc.ar(Ndef.ar(\modulator) * 200 + 400, 0, 0.2) ! 2
}).play;

)

// Change the modulator
Ndef(\modulator, { SinOsc.ar(0.5) });

Ndef(\modulator, { LFNoise2.ar(12) });

Ndef(\carrier).stop;


// Complex modular setup
(
// Define frequencies as a separate Ndef
Ndef(\padFreqs, { [404, 505, 606, 707] + LFNoise2.ar(0.1 ! 4, 30) });

// Define amplitudes as a separate Ndef
Ndef(\padAmps, { [0.4, 0.3, 0.2, 0.5] + LFNoise2.ar(0.1 ! 4, 0.1) });

// Main pad sound uses both
Ndef(\pad, {
	Splay.ar(
		BLowPass4.ar(
			Saw.ar(Ndef.ar(\padFreqs), Ndef.ar(\padAmps)),
			2000,
			0.8
		)
	)
}).play;
)

// Modify frequencies independently
(
Ndef(\padFreqs).fadeTime = 10;
Ndef(\padFreqs, 500);
)

Ndef(\padFreqs, { SinOsc.ar(1) * 10 + 500 });

Ndef(\padFreqs, { SinOsc.ar([1, 1.1, 1.2]) * [10, 20, 30] + 500 });

Ndef(\pad).stop(4);



/* - 4. Mapping Control Signals - */

/*
.map(\param, Ndef(\lfo)) connects an Ndef's output to a parameter
.unmap(\param) disconnects the mapping
.xmap(\param, Ndef(\lfo)) crossfades to a new modulation source
*/


// Create a sound with parameters
(
Ndef(\sound, { arg freq=200, filt=5000;
	RLPF.ar(Impulse.ar(freq), filt) ! 2
}).play;
)

// Create an LFO
Ndef(\lfo, { LFNoise1.kr(2, 100, 200) });

// Map the LFO to frequency
Ndef(\sound).map(\freq, Ndef(\lfo));

// Change the LFO (mapping stays active)
(
Ndef(\lfo).fadeTime = 2;
Ndef(\lfo, { LFNoise1.kr(5, 200, 400) });
)

Ndef(\lfo, { SinOsc.kr(1, 0, 100, 300) });


// Add another LFO for the filter
(
Ndef(\filtLFO, { SinOsc.kr(0.5).range(500, 8000) });
Ndef(\sound).map(\filt, Ndef(\filtLFO));
)

// Unmap to return to static value
(
Ndef(\sound).unmap(\freq);
Ndef(\sound).set(\freq, 10);
)

Ndef(\sound).stop;


// Use xmap for crossfaded mapping changes
(
Ndef(\synth, { |freq=400, amp=0.2|
	SinOsc.ar(freq, 0, amp) ! 2
}).play;

Ndef(\lfo1, { LFNoise2.kr(0.5).range(200, 600) });
Ndef(\lfo2, { SinOsc.kr(0.2).range(300, 900) });
)

// Map with crossfade
Ndef(\synth).xmap(\freq, Ndef(\lfo1));

// Switch to different LFO with crossfade
(
Ndef(\synth).fadeTime = 3;
Ndef(\synth).xmap(\freq, Ndef(\lfo2));
)

Ndef(\synth).stop;



/* - 5. Effect Chains - */

/*
Use .filter(index, function) to add effects in numbered slots.
Each slot processes the previous output.
Set a slot to nil to remove it.
*/

// Create a source
Ndef(\chain, { WhiteNoise.ar(0.2) ! 2 }).play;

// Add a tremolo effect in slot 1
Ndef(\chain).filter(1, { |in| in * LFPulse.ar(4).lag(0.01) });

// Add a delay in slot 2
Ndef(\chain).filter(2, { |in| in + CombN.ar(in, 0.2, 0.15, 2) });

// Add a low-pass filter in slot 3
Ndef(\chain).filter(3, { |in| LPF.ar(in, 2000) });

// Add distortion in slot 4
Ndef(\chain).filter(4, { |in| in + (in * 0.3).distort.tanh });

// Modify an existing slot
Ndef(\chain).filter(1, { |in| in * SinOsc.ar(2).range(0.3, 1) });

// Remove a slot
Ndef(\chain)[3] = nil;

Ndef(\chain).stop;


// Effect chains with complex source
(
Ndef(\texture, {
	var rate = 25;
	var trigger = (Impulse.ar(rate) * 0.8) + (Dust.ar(rate) * 0.2);
	var env = EnvGen.ar(Env.perc(0.88, 0.2, 1, 4), trigger, 1, 0, (1/rate));
	Splay.ar(HPF.ar(
		SinOsc.ar([rate/3, rate], 0, env * 0.5) +
		BPF.ar(PinkNoise.ar(mul:env), rate * Array.series(8,4,4), 0.2),
	40)) * 0.75;
}).play;
)

// Add reverb
Ndef(\texture).filter(1, { |in| in + FreeVerb.ar(in, 0.5, 0.8, 0.5) });

// Add filtering
Ndef(\texture).filter(2, { |in| RLPF.ar(in, LFNoise1.kr(0.5).range(400, 4000), 0.3) });

Ndef(\texture).stop;



/* - 6. Multichannel Expansion - */

/*
Arrays create multiple channels.
! n creates n copies.
Splay.ar() distributes to stereo.
*/

// Multiple frequencies
(
Ndef(\multi, {
	Splay.ar(SinOsc.ar([400, 500, 600, 700], 0, 0.1))
}).play;
)

// Add detuning with unique LFOs
(
Ndef(\multi, {
	Splay.ar(
		Saw.ar(
			[400, 500, 600, 700] + LFNoise2.ar(0.1 ! 4, 20),
			0.1
		)
	)
});
)

// Using collect for complex arrays
(
Ndef(\rich, {
	var freqs = [400, 500, 600, 700, 800];
	var sigs = freqs.collect { |f|
		SinOsc.ar(f + LFNoise2.kr(0.1, 10), 0, 0.08)
	};
	Splay.ar(sigs);
}).play;
)

// Harmonics with range notation
(
Ndef(\harmonics, {
	Splay.ar(SinOsc.ar((1..8) * 100, 0, 0.05))
}).play;
)

Ndef(\harmonics).stop;
Ndef(\multi).stop;
Ndef(\rich).stop;



/* - 7. FadeTime and Crossfading - */

/*
fadeTime controls how long it takes to crossfade between definitions
or to fade in/out when playing/stopping.
*/

// Set fade time before playing
(
Ndef(\fader).fadeTime = 3;
Ndef(\fader, { SinOsc.ar(400, 0, 0.2) ! 2 }).play;
)

// Changes will now crossfade over 3 seconds
Ndef(\fader, { Saw.ar(300, 0.15) ! 2 });

Ndef(\fader, { Pulse.ar(500, 0.3, 0.2) ! 2 });

Ndef(\fader, { LFTri.ar(200, 0, 0.2) ! 2 });

// Stop with custom fade time
Ndef(\fader).stop(5);  // 5 second fade out


// Different fade times for different operations
(
Ndef(\example).fadeTime = 2;  // Default crossfade time
Ndef(\example, { WhiteNoise.ar(0.1) ! 2 }).play(fadeTime: 4);  // 4 second fade in
)

Ndef(\example, { PinkNoise.ar(0.1) ! 2 });  // Uses default 2 second crossfade

Ndef(\example).stop(6);  // 6 second fade out



/* - 8. Textures - */


// Saw excess with bandstop
(
Ndef(\swsc, {|freq=80, mfreqa=19, mfreqb=12, filtmod=10,
	filtfrom=100, filtto=900, bwmod=20, bwfrom=7, bwto=20, hpf=80, amp=1.4|
	HPF.ar(
		BBandStop.ar(
			Saw.ar(
				LFNoise1.ar([mfreqa, mfreqb]).range(freq, freq * 2),
				0.2
			).excess(
				SinOsc.ar([freq + 6, freq + 4, freq + 2, freq + 8])
			),
			LFNoise1.ar([filtmod * 1.2, filtmod * 1.4, filtmod]).range(filtfrom, filtto),
			SinOsc.ar(bwmod).range(bwfrom, bwto)
		),
		hpf
	) * amp
}).play;
)


// High-frequency sparkling texture
(
Ndef(\stics, {|amp=0.8|
	var freq = 4200, freqx = freq - 5;
	var snd = RLPF.ar(
		Saw.ar(
			LFNoise2.ar([0.1, 0.15], 2).range(
				freqx,
				freqx * Array.rand(8, 0.5, 2.0)
			)
		),
		1200
	) * EnvGen.ar(
		Env.perc(0.004, 0.08, 3.0),
		Impulse.ar(Array.rand(8, 0.5, 1.2))
	) * amp;
	Splay.ar(snd)
}).play;
)


/* - 9. GUI Tools - */

// Individual Ndef GUI
(
Ndef(\test, { |freq=400, amp=0.2|
	SinOsc.ar(freq, 0, amp) ! 2
}).play;

Ndef(\test).gui;  // or .edit
)


// NdefMixer - shows all Ndefs
NdefMixer(s);


// Create several Ndefs and use NdefMixer
(
Ndef(\sound1, { SinOsc.ar(200) * 0.1 ! 2 }).play;
Ndef(\sound2, { Saw.ar(300) * 0.1 ! 2 }).play;
Ndef(\sound3, { Pulse.ar(150) * 0.1 ! 2 }).play;

NdefMixer(s);
)


// Other graphical controllers
(
ProxyMixer;
NdefGui;
MonitorGui;
)

/*
Key Ndef methods:

  .play(out, numChannels, group, fadeTime)  - Start monitoring
  .stop(fadeTime)                           - Stop monitoring
  .end(fadeTime)                            - Stop and free
  .clear(fadeTime)                          - Clear source

  .set(\param, value)                       - Set parameter instantly
  .xset(\param, value)                      - Set with crossfade

  .map(\param, Ndef(\source))               - Map parameter to Ndef
  .xmap(\param, Ndef(\source))              - Map with crossfade
  .unmap(\param)                            - Remove mapping

  .filter(index, func)                      - Add effect in slot
  [index] = nil                             - Remove effect slot

  .fadeTime = seconds                       - Set crossfade time
  .gui or .edit                             - Open GUI

  .ar or .kr                                - Use as audio/control source
*/

// Difference between .stop, .end, and .clear
Ndef(\example, { SinOsc.ar(400) * 0.2 ! 2 }).play;

// .stop - stops monitoring but synth keeps running (useful if used elsewhere)
Ndef(\example).stop;

// .end - stops the synth completely
Ndef(\example).end;

// .clear - removes the source definition
Ndef(\example).clear;


// Check what Ndefs exist
Ndef.all.postln;

// Clear all Ndefs
Ndef.all.do(_.clear);

// Clears a specific Ndef after a delay
Ndef(\sound).clear(2);  // Clear after 2 seconds



/*
See also:
  NodeProxy, ProxySpace (covered in PatternProxies.scd)
  Pdef, Tdef, Pbindef (for pattern-based sequencing)

GUI Tools:
  ProxyMixer, NdefMixer, NdefGui, NdefParamGui,
  MonitorGui, TdefGui, PdefGui

Related:
  JITLib, JITLib tutorials

Ndef Advantages:
  - Global access by name (no variable needed)
  - Automatic crossfading between definitions
  - Live parameter control and mapping
  - Modular signal routing
  - Effect chains with numbered slots
  - Works with patterns (Pbind)
  - GUI integration

Benefits:
  - Live coding and improvisation
  - Complex modular synthesis
  - When you need to reference synths by name
  - Shared projects (symbols are explicit)

*/
