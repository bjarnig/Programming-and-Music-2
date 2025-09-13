
// waitForBoot waits until the server has been booted.
s.waitForBoot({

	var win, color, alpha, stringColor, defaultFont, synth, totalDuration, offset;
	var createKnob, createNumber, createLabel;
	var freqKnob, freqSpec, freqNumber, freqLabel;
	var ampKnob, ampSpec, ampNumber, ampLabel;
	var posKnob, posSpec, posNumber, posLabel;
	var grSizeKnob, grSizeSpec, grSizeNumber, grSizeLabel;
	var trigKnob, trigSpec, trigNumber, trigLabel;

	// Common values
	color = Color.fromHexString("#581845");
	stringColor = Color.white;
	defaultFont =  Font("Monaco", 14);
	alpha = 0.9;
	totalDuration=100;
	offset=250;

	// Add the window
	win = Window.new("Granulator", Rect(20, 400, 1250, 300));
	win.front;
	win.background = color;
	win.alpha = alpha;

	// Factory for knobs
	createKnob = {|spec, numberControl, synthKey, left|
		var knob, value;
		left.postln;
		knob =  Knob.new(win, Rect(left, 20, 200, 200));
	    knob.action = {arg v;
		value = spec.map(v.value);
		synth.set(synthKey, value);
			numberControl.string = value.round(0.1)};
		knob
	};

	// Factory for display numbers
	createNumber = {|spec, left|
		var number;
		number = StaticText.new(win, Rect(left, 210, 80, 25));
		number.background = color;
		number.alpha = alpha;
		number.align = \center;
		number.string = spec.default;
		number.font = defaultFont;
		number.stringColor = stringColor;
	};

	// Factory for labels
	createLabel = {|text, left|
		var label = StaticText.new(win, Rect(left, 240, 200, 25));
		label.string = text;
		label.align = \center;
		label.font = defaultFont;
		label.stringColor = stringColor;
	};

	// Create the specs
	freqSpec = ControlSpec(0.0, 2.0, 'lin', 0.01, 1.0);
	ampSpec = ControlSpec(0.0, 1.0, 'lin', 0.01, 0.1);
	posSpec = ControlSpec(0.0, 1.0, 'lin', 0.01, 0.0);
	grSizeSpec = ControlSpec(0.0, 4.0, 'lin', 0.01, 0.1);
	trigSpec = ControlSpec(1.0, 50.0, 'lin', 1, 0.1);

	// Frequency controls
	freqNumber = createNumber.value(freqSpec, 80);
	freqKnob = createKnob.value(freqSpec, freqNumber, \rate, 20);
	freqLabel = createLabel.value("Frequency", 20);

	// Amp controls
	ampNumber = createNumber.value(ampSpec, 80 + offset);
	ampKnob = createKnob.value(ampSpec, ampNumber, \amp, 20 + offset);
	ampLabel = createLabel.value("Amplitude", 20 + offset);

	// Pos controls
	posNumber = createNumber.value(posSpec, 80 + (offset * 2));
	posKnob = createKnob.value(posSpec, posNumber, \pos, 20 + (offset * 2));
	posLabel = createLabel.value("Position", 20 + (offset * 2));

	// grSize controls
	grSizeNumber = createNumber.value(grSizeSpec, 80 + (offset * 3));
	grSizeKnob = createKnob.value(grSizeSpec, grSizeNumber, \grSize, 20 + (offset * 3));
	grSizeLabel = createLabel.value("grSize", 20 + (offset * 3));

	// trigger controls
	trigNumber = createNumber.value(trigSpec, 80 + (offset * 4));
	trigKnob = createKnob.value(trigSpec, trigNumber, \trig, 20 + (offset * 4));
	trigLabel = createLabel.value("trig", 20 + (offset * 4));

	// Add the synthDef and play it
	{
		SynthDef(\grains, {|amp=0.8, pos=0.1, rate=1, trig=10, grSize=0.2, buf|
			var sig = TGrains.ar(2,Impulse.kr(trig), buf, rate,
			pos, grSize);
			Out.ar(0, sig * amp);
		}).add;

		~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
		~path = ~path ++ "samples/";
		~voice = Buffer.read(s, ~path ++ "vocal.wav");

		// Wait until the synth has been created
		s.sync;

		// Play the synth
		synth = Synth(\grains, [\buf, ~voice]);

	}.fork
});
