////////////////////////////////////////////////////////////////
//
//                 Task 5: Preset Morphing
//
////////////////////////////////////////////////////////////////

Ndef.clear;
(

// define control spces to be used -
Ndef(\foo).addSpec(\carFreq, Spec.specs[\freq]);
Ndef(\foo).addSpec(\modFreq, Spec.specs[\freq]);
Ndef(\foo).addSpec(\pmindex, ControlSpec(-4.0, 4.0));
Ndef(\foo).addSpec(\modphase, ControlSpec(-4.0, 4.0));

Ndef(\foo, {
	var sig = PMOsc.ar(
		carfreq: \carFreq.kr(200.0),
		modfreq: \modFreq.kr(200.0),
		pmindex: \pmindex.kr(0.0) * [1.0, 1.01],
		modphase: \modphase.kr(0.0),
	) * SinOscFB.ar(0.7, feedback: 1.8);
	sig;
}).play(vol: 0.2).gui;

)

// setup preset morpher
p = NdefPreset(Ndef(\foo))

// tweak params in gui
// and store it as a preset yes
p.addSet(\yes);

// tweak params in gui and store another preset
p.addSet(\no);

// check if preset got picked up
p.settings;

// randomly jump between the the two presets
p.morph(0.2, \yes, \no);

// fade to preset yes
p.xfadeTo(target: \yes, dur: 3);

// fade from preset \yes to preset \no in an exponential manner
({
	var steps = 1000;
	var time = 10;

	steps.do({|i|
		p.morph(i.linexp(0, steps, 0.0001, 1), \yes, \no);
		(time/steps).wait;
	});
	"Finished".postln;
}.fork;
)

// or use gui
// NdefPresetGui(p, numItems: 6);

////////// end

(

NdefPreset.all.clear;

x = Ndef(\sparkling, {|freq=30,from=50,to=100|
	var mod = PMOsc.ar(freq, LFDClipNoise.ar().range(from,to),1);
	0.1 * HPF.ar(LPF.ar( LeastChange.ar(GravityGrid.ar(0, [12, 30, 60, 90]), mod),
	LFNoise1.ar(3).range(80,150)),30) }).play;

x.addSpec(\freq, [10, 60, \lin]);
x.addSpec(\from, [20, 60, \lin]);
x.addSpec(\to, [80, 120, \lin]);

)

y = NdefPreset(Ndef(\sparkling));

x.set(\freq, 10, \from, 20, \to, 80); y.addSet(\bga);

x.set(\freq, 60, \from, 50, \to, 100); y.addSet(\bgb);

y.settings;

y.morph(0.9, \bga, \bgb);

