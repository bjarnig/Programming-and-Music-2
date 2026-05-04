////////////////////////////////////////////////////////////////
//
//                      VST Plugin
//
////////////////////////////////////////////////////////////////

(

// Ndef in, VST plugin and callback
~plugin = {|ndef=\system, name, callback|
	var synth, vst, def="vst" ++ ndef, breath=0.2;

	{

	// Dynamically create a SynthDef for the incoming Ndef
	SynthDef(def, { arg out, mix=1.0.neg, hpf=60;
		var snd = Ndef(ndef).ar;
		var sig = VSTPlugin.ar(snd, 2);
		sig = XFade2.ar(snd, sig, mix);
		ReplaceOut.ar(out, HPF.ar(sig, hpf));
	}).add;

	s.sync;

	// Start the synth and plugin controller
	synth = Synth(def, [\out, 0]);
	vst = VSTPluginController( synth ).open(name, true);
	breath.wait;
	callback.(vst, synth)

	}.fork

};

	// :: Look for plugins :
	// VSTPlugin.search; // search all
	// VSTPlugin.pluginKeys(s).do{|d|d.postln}

	n = "GRM Shuffling Stereo.vst";

	Ndef(\fold, {

		Fold.ar(
			SinOscFB.ar([40,42], LFNoise1.ar(3).range(0.1,1.75)), // src
			LFNoise2.ar(4.3).range(0.1,0.5), // lo
			SinOsc.ar([0.03,0.1]).range(0.5,2.0) // hi
		) * 0.5

	});

	~plugin.(\fold, n, {|vst, synth|

		Tdef(\d, {
			inf.do {
				10.do {|i|
					vst.set("Feedback", i.linlin(0,9,0.3,0.99));
					0.4.wait;
				}
			}
		}).play;

		~fx = vst;
		1.wait;
		~fx.editor;
	})

)


(

VSTPlugin.plugins['myPlugin.vst3'].parameters.do { |i|
	i[\name].postln
}

)


// Find the parameter value
~fx.get("Random Pitch".asSymbol, {arg f; f.postln;});

( // Change the plugin throug a pattern.

Pdef(\seteff,
Pbind(
    \type, \vst_set,
    \vst, ~fx,
	"Random Pitch".asSymbol, Pbrown(0.2,0.8,0.1).trace,
    \dur, 0.2
)).play

)

// Gui and Editor
~fx.gui;
~fx.editor;

// Programs and Presets
~fx.info.printPrograms;
~fx.info.printPresets;