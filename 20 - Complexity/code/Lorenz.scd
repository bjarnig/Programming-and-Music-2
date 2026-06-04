////////////////////////////////////////////////////////////////
//
//                       Lorenz Attractor
//
////////////////////////////////////////////////////////////////

/*
     dx/dt = σ (y − x)
     dy/dt = x (ρ − z) − y
     dz/dt = x y − β z
*/


( Quarks.fetchDirectory(true); Quarks.install("SafetyNet"); thisProcess.recompile )


(

SynthDef(\lorenzVoice, {|freq=300, amp=0.0, pan=0, gate=1, lagTime=0.05|
	var f   = Lag.kr(freq, lagTime);
	var env = EnvGen.kr(Env.asr(0.05, 1, 0.2), gate, doneAction: 2);
	var sig = LPF.ar(Saw.ar(f), f * 8) * amp * env;
	OffsetOut.ar(0, Pan2.ar(sig * 0.25, pan));
}).add;

)

(

var winW = 700, winH = 700;
var sigma = 10.0, beta = 8 / 3, rho = 28.0;
var dt = 0.006, stepsPerFrame = 14;
var trailMax = 1600;
var x, y, z, trail, voices;
var running = true, clock;
var bg, palette, rhoSlider, rhoLabel;
var integrate, mapXZ, reset;

bg = Color.fromHexString("171b21");

palette = (
	trail: Color.fromHexString("A3CEF1"),
	head:  Color.fromHexString("bce7fd"),
	axis:  Color.gray(0.16),
	text:  Color.gray(0.7)
);

reset = {
	x = 0.1; y = 0.0; z = 0.0;
	trail = List.new;
};

mapXZ = {|xv, zv|
	Point(
		(winW * 0.5) + (xv * (winW / 50)),
		winH - 30 - (zv * (winH / 60))
	)
};

integrate = {
	stepsPerFrame.do {
		var dx = sigma * (y - x);
		var dy = (x * (rho - z)) - y;
		var dz = (x * y) - (beta * z);
		x = x + (dx * dt);
		y = y + (dy * dt);
		z = z + (dz * dt);
		trail.add([x, z]);
	};
	while({ trail.size > trailMax }, { trail.removeAt(0) });

	voices[0].set(\freq, ((x + 25) * 13) + 100);
	voices[1].set(\freq, ((y + 30) * 11) + 100);
	voices[2].set(\freq, (z * 7) + 60);
};


reset.value;

voices = [
	Synth(\lorenzVoice, [\freq, 200, \amp, 0.16, \pan, -0.7]),
	Synth(\lorenzVoice, [\freq, 200, \amp, 0.16, \pan,  0.7]),
	Synth(\lorenzVoice, [\freq, 100, \amp, 0.16, \pan,  0.0])
];

w = Window("Lorenz attractor", Rect(200, 100, winW, winH + 70)).front;
v = UserView(w, Rect(0, 0, winW, winH));
v.background = bg;

v.drawFunc = {
	var origin = mapXZ.value(0, 0);
	Pen.strokeColor = palette[\axis];
	Pen.width = 1;
	Pen.moveTo(Point(0, origin.y));  Pen.lineTo(Point(winW, origin.y));
	Pen.moveTo(Point(origin.x, 0));  Pen.lineTo(Point(origin.x, winH));
	Pen.stroke;

	if(trail.size > 1, {
		Pen.width = 1.2;
		(trail.size - 1).do {|i|
			var a = trail[i], b = trail[i + 1];
			if(a.isArray and: { b.isArray }, {
				var alpha = (i / trail.size).clip(0, 1);
				Pen.strokeColor = palette[\trail].alpha_(alpha * 0.85);
				Pen.moveTo(mapXZ.value(a[0], a[1]));
				Pen.lineTo(mapXZ.value(b[0], b[1]));
				Pen.stroke;
			});
		};
	});

	{
		var p = mapXZ.value(x, z);
		Pen.fillColor = palette[\head];
		Pen.fillOval(Rect(p.x - 3, p.y - 3, 6, 6));
	}.value;

	Pen.stringAtPoint(
		"Lorenz   σ = " ++ sigma ++ "   β = " ++ beta.round(0.001)
			++ "   ρ = " ++ rho.round(0.01),
		Point(12, 12), Font("Helvetica", 11), palette[\text]);
};

v.keyDownAction = {|view, char|
	case
	{ char == $  } { running = running.not }
	{ char == $r } { reset.value };
};

rhoLabel = StaticText(w, Rect(20, winH + 8, 180, 16));
rhoLabel.string      = "ρ  (0..50)";
rhoLabel.stringColor = palette[\text];

rhoSlider = Slider(w, Rect(20, winH + 26, winW - 40, 30));
rhoSlider.value      = (rho / 50).clip(0, 1);
rhoSlider.background = Color.fromHexString("2a3140");
rhoSlider.action     = {|s| rho = s.value * 50 };

clock = Routine {
	inf.do {
		if(running, { integrate.value });
		v.refresh;
		(1 / 60).wait;
	}
}.play(AppClock);

w.onClose = {
	clock.stop;
	voices.do({|s| s.set(\gate, 0) });
};

)
