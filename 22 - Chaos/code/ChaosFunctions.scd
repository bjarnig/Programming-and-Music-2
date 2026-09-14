////////////////////////////////////////////////////////////////
//
//                        Chaos Functions
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)


////////////////////// Plotter Helpers ////////////////////////

(

~plotPattern = {|pattern, count=500|
	var values = pattern.asStream.nextN(count).flatten;
    values.plot(minval: values.minItem.floor,
		maxval: values.maxItem.ceil)
};

~plotSignal = {|signal, duration=2|
	signal.plot(duration)
};

~plotStream = {|stream, count=500|
	var values = stream.nextN(count).flat;
    values.plot(minval: values.minItem.floor,
		maxval: values.maxItem.ceil)
};

~playStreamFreq = {|stream, delta=0.1, times=inf|

	Routine {
		times.do {
			var freq = stream.next();
			Synth(\perc, [\freq, freq]);
			delta.wait
		}
	}.play
}

)


//////////////////////// Iterative functions ///////////////////////

(

// Logistic Map

~logistic = {|r = 3.81699451, x = 0.5, average=1000|
	Routine {

		inf.do
		{
			x = r * x * (1 - x);
			(x * average).yield
		}
	}
};

// Sine Map

~sineMap = {|a = 3.14, b=0.125, r=1.1, x = 0.15, average=1000|
	Routine {

		inf.do
		{
			x = sin(x * a * b * 2.0 * r) * 0.5 + 0.5;
			x.yield;
			(x * average).yield
		}
	}
};

// Tent Map

~tent = {|r=0.92, x = 0.25, average=1000|
	Routine {

		inf.do
		{
			if(x <= 0.5, { x = 2.0 * r * x }, {x = 2 * r * (1.0 - x) });
			x.yield;
			(x * average).yield
		}
	}
};

//  Lehmer's Congruential

~lehmer = {|a = 3.14, b=0.25, m=1.0, x = 0.5, average=1000|
	Routine {

		inf.do
		{
			x = a * x + b % m;
			x.yield;
			(x * average).yield
		}
	}
};

//  Poppcorn attractor

~henon = {|a = 1.8, b = 0.3, average=1000|
	Routine {

		var x = 0.1, y = 0.1;

		inf.do
		{
			x = 1 + y - (a * x.pow(2));
			y = b * x;
			(x * average).yield
		}
	}
};

~plotStream.value(~henon.value, 200);
~playStreamFreq.value(~henon.value)

)


~plotStream.value(~logistic.value(3.8))

~plotStream.value(~sineMap.value(2.2))

~plotStream.value(~poppcorn.value)

~playStreamFreq.value(~logistic.value(3.9))

~playStreamFreq.value(~lehmer.value(10))

~playStreamFreq.value(~tent.value(0.55))
