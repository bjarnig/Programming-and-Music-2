////////////////////////////////////////////////////////////////
//
//                       Kuramoto
//
////////////////////////////////////////////////////////////////

/*
   Coupled oscillators and synchronisation.
*/


( Quarks.fetchDirectory(true); Quarks.install("SafetyNet"); thisProcess.recompile )


(

SynthDef(\kuramoto, {|master=0.4, gate=1, lagTime=0.25|
	var freqs       = \freqs.kr(Array.fill(24, 220));
	var amps        = \amps.kr(Array.fill(24, 0));
	var laggedFreqs = Lag.kr(freqs, lagTime);
	var laggedAmps  = Lag.kr(amps,  lagTime);
	var sigs        = SinOsc.ar(laggedFreqs) * laggedAmps;
	var env         = EnvGen.kr(Env.asr(0.3, 1, 0.5), gate, doneAction: 2);
	var mix         = Mix.ar(sigs) * master * env * 0.2;
	Out.ar(0, Limiter.ar(mix ! 2, 0.7, 0.01));
}).add;

)

(

var winW = 720, winH = 760;
var nOsc = 24, omegaSpread = 0.5, dt = 1 / 60;
var baseFreq = 300, octaveSpan = 2.5, lagTime = 0.20;
var perOscAmp = 0.13;
var kCoupling = 0.0;
var orderHistoryMax = 240;
var thetas, omegas, orderHistory, synth;
var running = true, clock;
var bg, palette, kSlider, kLabel;
var step, reset, orderParameter;


bg = Color.fromHexString("171b21");

palette = (
	osc:    Color.fromHexString("A3CEF1"),
	circle: Color.gray(0.20),
	rline:  Color.fromHexString("a47e3c"),
	text:   Color.gray(0.7),
	dim:    Color.fromHexString("2a3140")
);

reset = {
	thetas       = Array.fill(nOsc, { 2pi.rand });
	omegas       = Array.fill(nOsc, { rrand(omegaSpread.neg, omegaSpread) });
	orderHistory = List.new;
};

orderParameter = {
	var sumCos = 0, sumSin = 0;
	thetas.do {|t| sumCos = sumCos + t.cos; sumSin = sumSin + t.sin };
	(((sumCos * sumCos) + (sumSin * sumSin)).sqrt) / nOsc
};

step = {
	var newThetas = Array.newClear(nOsc);
	var freqArr;

	nOsc.do {|i|
		var coupling = 0;
		nOsc.do {|j| coupling = coupling + (thetas[j] - thetas[i]).sin };
		coupling = coupling * kCoupling / nOsc;
		newThetas[i] = (thetas[i] + ((omegas[i] + coupling) * dt)) % 2pi;
	};
	thetas = newThetas;

	freqArr = Array.fill(nOsc, {|i|
		var coupling = 0;
		nOsc.do {|j| coupling = coupling + (thetas[j] - thetas[i]).sin };
		coupling = coupling * kCoupling / nOsc;
		baseFreq * (2 ** ((omegas[i] + coupling) * octaveSpan / omegaSpread))
	});
	synth.set(\freqs, freqArr);

	orderHistory.add(orderParameter.value);
	while({ orderHistory.size > orderHistoryMax }, { orderHistory.removeAt(0) });
};


reset.value;

synth = Synth(\kuramoto, [
	\master,  0.55,
	\lagTime, lagTime,
	\amps,    Array.fill(nOsc, perOscAmp)
]);

w = Window("Kuramoto — coupled oscillators", Rect(200, 100, winW, winH)).front;
v = UserView(w, Rect(0, 0, winW, winH - 90));
v.background = bg;

v.drawFunc = {
	var cx     = winW * 0.5;
	var cy     = ((winH - 90) * 0.5) + 30;
	var radius = (winH - 90 - 80) * 0.45;
	var r      = if(orderHistory.size > 0, orderHistory.last, 0);

	Pen.strokeColor = palette[\circle];
	Pen.width = 1;
	Pen.addArc(Point(cx, cy), radius, 0, 2pi);
	Pen.stroke;

	{
		var sumCos = 0, sumSin = 0, meanCos, meanSin;
		thetas.do {|t| sumCos = sumCos + t.cos; sumSin = sumSin + t.sin };
		meanCos = sumCos / nOsc;
		meanSin = sumSin / nOsc;
		Pen.strokeColor = palette[\rline].alpha_(0.85);
		Pen.width = 2;
		Pen.moveTo(Point(cx, cy));
		Pen.lineTo(Point(cx + (meanCos * radius), cy + (meanSin * radius)));
		Pen.stroke;
		Pen.fillColor = palette[\rline];
		Pen.fillOval(Rect(
			cx + (meanCos * radius) - 5,
			cy + (meanSin * radius) - 5,
			10, 10));
	}.value;

	nOsc.do {|i|
		var px   = cx + (thetas[i].cos * radius);
		var py   = cy + (thetas[i].sin * radius);
		var size = 4 + (omegas[i].abs / omegaSpread * 3);
		Pen.fillColor = palette[\osc];
		Pen.fillOval(Rect(px - (size * 0.5), py - (size * 0.5), size, size));
	};

	{
		var stripY = winH - 130;
		var stripH = 28;
		Pen.fillColor = palette[\dim];
		Pen.fillRect(Rect(20, stripY, winW - 40, stripH));
		Pen.strokeColor = palette[\rline];
		Pen.width = 1.5;
		if(orderHistory.size > 1, {
			orderHistory.do {|val, i|
				var px = 20 + ((i / (orderHistoryMax - 1)) * (winW - 40));
				var py = stripY + stripH - (val * stripH);
				if(i == 0, { Pen.moveTo(Point(px, py)) }, { Pen.lineTo(Point(px, py)) });
			};
			Pen.stroke;
		});
	}.value;

	Pen.stringAtPoint(
		"Kuramoto   N = " ++ nOsc ++ "   K = " ++ kCoupling.round(0.01)
			++ "   r = " ++ r.round(0.001),
		Point(12, 12), Font("Helvetica-Bold", 14), Color.white);
	Pen.stringAtPoint("order parameter r  (0 = scattered, 1 = synced)",
		Point(20, winH - 152), Font("Helvetica", 10), palette[\text]);
};

kLabel = StaticText(w, Rect(20, winH - 78, 200, 16));
kLabel.string      = "coupling strength K";
kLabel.stringColor = palette[\text];

kSlider = Slider(w, Rect(20, winH - 60, winW - 40, 38));
kSlider.value      = 0.0;
kSlider.background = palette[\dim];
kSlider.action     = {|s| kCoupling = s.value * 4 };

v.keyDownAction = {|view, char|
	case
	{ char == $  } { running = running.not }
	{ char == $r } { reset.value };
};

clock = Routine {
	inf.do {
		if(running, { step.value });
		v.refresh;
		dt.wait;
	}
}.play(AppClock);

w.onClose = { clock.stop; synth.set(\gate, 0) };

)
