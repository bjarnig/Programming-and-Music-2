////////////////////////////////////////////////////////////////
//
//                       Bouncing Balls
//
////////////////////////////////////////////////////////////////

/*  Keys:  space pause   r respawn  */

( Quarks.fetchDirectory(true); Quarks.install("SafetyNet"); thisProcess.recompile )

(

SynthDef(\gr, {|buf=0, amp=0.0, speed=10, rate=1, grSize=1.2, pos=0.125, pan=0|
	var sig = TGrains.ar(2, Impulse.kr(speed), buf, rate, pos, grSize, pan, amp);
	OffsetOut.ar(0, sig);
}).add;

SynthDef(\hit, {|buf=0, amp=0.3, rate=1, pos=0.1, dur=0.15, pan=0|
	var env = EnvGen.kr(Env.perc(0.003, dur), doneAction: 2);
	var sig = PlayBuf.ar(1, buf, rate * BufRateScale.kr(buf), 1, pos * BufFrames.kr(buf));
	OffsetOut.ar(0, Pan2.ar(sig * env * amp, pan));
}).add;

~path = (PathName(thisProcess.nowExecutingPath)).pathOnly ++ "samples/";
~ca   = Buffer.read(s, ~path ++ "ca.wav");
~cb   = Buffer.read(s, ~path ++ "cb.wav");

)

(

var size = 600, restitution = 0.92, ballRest = 0.96, numBalls = 15;
var balls = List.new;
var running = true;
var clock, spawn, impact, applyBehaviour, physics;
var behaviours, palette, glyph, soundCfg;

behaviours = [\drift, \orbit, \jitter, \float, \repel];

palette = (
	drift:  Color.fromHexString("A3CEF1"),
	orbit:  Color.fromHexString("72b6ec"),
	jitter: Color.fromHexString("bce7fd"),
	float:  Color.fromHexString("dbc59e"),
	repel: Color.fromHexString("a47e3c")
);

glyph = (drift: "D", orbit: "O", jitter: "J", float: "F", repel: "R");

soundCfg = (
	drift: (
		buf: ~cb, grSize: 0.9,
		speedFn:   {|b, spd| spd.linlin(0, 20, 6, 18) },
		rateFn:    {|b, spd| (b[\x] / size).linexp(0, 1, 0.7, 1.4) },
		ampFn:     {|b, spd| spd.linlin(0, 20, 0.02, 0.16) },
		hitBuf:    ~cb,
		hitRateFn: {|b, str| (b[\x] / size).linexp(0, 1, 0.6, 1.6) },
		hitDurFn:  {|b, str| str.linlin(0, 25, 0.08, 0.30) }
	),
	orbit: (
		buf: ~cb, grSize: 1.5,
		speedFn:   {|b, spd| spd.linlin(0, 20, 8, 26) },
		rateFn:    {|b, spd|
			var d = (b[\x] - (size * 0.5)).hypot(b[\y] - (size * 0.5));
			d.linexp(1, size * 0.5, 1.8, 0.5)
		},
		ampFn:     {|b, spd| spd.linlin(0, 20, 0.04, 0.18) },
		hitBuf:    ~cb,
		hitRateFn: {|b, str| 1.4 + 0.5.rand2 },
		hitDurFn:  {|b, str| str.linlin(0, 25, 0.15, 0.40) }
	),
	jitter: (
		buf: ~ca, grSize: 0.12,
		speedFn:   {|b, spd| spd.linlin(0, 20, 28, 60) },
		rateFn:    {|b, spd| 1.0 + spd.linlin(0, 10, 0.0, 0.8) + 0.4.rand2 },
		ampFn:     {|b, spd| spd.linlin(0, 20, 0.03, 0.14) },
		hitBuf:    ~ca,
		hitRateFn: {|b, str| 1.0 + 1.0.rand2 },
		hitDurFn:  {|b, str| str.linlin(0, 25, 0.03, 0.10) }
	),
	float: (
		buf: ~cb, grSize: 2.5,
		speedFn:   {|b, spd| spd.linlin(0, 10, 2, 6) },
		rateFn:    {|b, spd| (b[\y] / size).linexp(0, 1, 0.35, 0.8) },
		ampFn:     {|b, spd| spd.linlin(0, 10, 0.06, 0.18) },
		hitBuf:    ~cb,
		hitRateFn: {|b, str| 0.4 + 0.2.rand2 },
		hitDurFn:  {|b, str| str.linlin(0, 25, 0.30, 0.60) }
	),
	repel: (
		buf: ~ca, grSize: 0.25,
		speedFn:   {|b, spd| spd.linlin(0, 20, 15, 35) },
		rateFn:    {|b, spd| (b[\x] / size).linexp(0, 1, 1.0, 2.4) },
		ampFn:     {|b, spd| spd.linlin(0, 20, 0.03, 0.16) },
		hitBuf:    ~ca,
		hitRateFn: {|b, str| 1.5 + str.linlin(0, 25, 0.0, 1.0) + 0.3.rand2 },
		hitDurFn:  {|b, str| str.linlin(0, 25, 0.05, 0.15) }
	)
);


spawn = {
	balls.do {|b| b[\granulator].free };
	balls = List.new;
	numBalls.do {|i|
		var bhv = behaviours.wrapAt(i);
		var r = case
			{ bhv == \float  } { rrand(22.0, 30.0) }
			{ bhv == \jitter } { rrand( 8.0, 12.0) }
			{ rrand(14.0, 20.0) };
		var b = ();
		b[\behaviour] = bhv;
		b[\radius]    = r;
		b[\mass]      = r * r;
		b[\x]         = rrand(r, size - r);
		b[\y]         = rrand(r, size - r);
		b[\vx]        = rrand(-4.0, 4.0);
		b[\vy]        = rrand(-4.0, 4.0);
		b[\color]     = palette[bhv];
		b[\timer]     = 120.rand;
		b[\granulator] = Synth(\gr, [
			\buf, soundCfg[bhv][\buf], \amp, 0.0,
			\grSize, soundCfg[bhv][\grSize], \pos, 1.0.rand
		]);
		balls.add(b);
	};
};

impact = {|b, strength|
	if(strength > 1.2, {
		var cfg = soundCfg[b[\behaviour]];
		Synth(\hit, [
			\buf,  cfg[\hitBuf],
			\amp,  strength.linlin(0, 25, 0.05, 0.50).clip(0, 0.55),
			\rate, cfg[\hitRateFn].value(b, strength),
			\pos,  (b[\y] / size).clip(0, 0.95),
			\dur,  cfg[\hitDurFn].value(b, strength),
			\pan,  ((b[\x] / size) * 2 - 1) * 0.8
		]);
	});
};

applyBehaviour = {|b|
	b[\timer] = b[\timer] + 1;
	case
	{ b[\behaviour] == \drift } {
		b[\vy] = b[\vy] + 0.08;
		b[\vx] = b[\vx] * 0.998;
		b[\vy] = b[\vy] * 0.998;
		if((b[\timer] % 90) == 0, {
			var ang = 2pi.rand;
			b[\vx] = b[\vx] + (ang.cos * 3.5);
			b[\vy] = b[\vy] + (ang.sin * 3.5);
		});
	}
	{ b[\behaviour] == \orbit } {
		var cx = size * 0.5, cy = size * 0.5;
		var dx = cx - b[\x], dy = cy - b[\y];
		var k = 0.0015;
		b[\vx] = b[\vx] + (dx * k);
		b[\vy] = b[\vy] + (dy * k);
	}
	{ b[\behaviour] == \jitter } {
		b[\vx] = (b[\vx] + 0.6.rand2) * 0.99;
		b[\vy] = (b[\vy] + 0.6.rand2) * 0.99;
	}
	{ b[\behaviour] == \float } {
		var spd = b[\vx].hypot(b[\vy]);
		if(spd < 0.6, {
			var ang = 2pi.rand;
			b[\vx] = ang.cos * 1.8;
			b[\vy] = ang.sin * 1.8;
		});
	}
	{ b[\behaviour] == \repel } {
		var nearest, nearDist = 1000000;
		balls.do {|other|
			if(other !== b, {
				var dx = other[\x] - b[\x], dy = other[\y] - b[\y];
				var d = dx.hypot(dy);
				if(d < nearDist, { nearDist = d; nearest = other });
			});
		};
		if(nearest.notNil and: { (nearDist < 200) and: { nearDist > 0 } }, {
			var dx = b[\x] - nearest[\x], dy = b[\y] - nearest[\y];
			var strength = ((200 - nearDist) / 200) * 0.5;
			b[\vx] = (b[\vx] + (dx / nearDist * strength)) * 0.995;
			b[\vy] = (b[\vy] + (dy / nearDist * strength)) * 0.995;
		});
	};
};

physics = {
	balls.do {|b|
		applyBehaviour.value(b);
		b[\x] = b[\x] + b[\vx];
		b[\y] = b[\y] + b[\vy];
		if(b[\x] < b[\radius],          { b[\x] = b[\radius];        b[\vx] = b[\vx].neg * restitution; impact.value(b, b[\vx].abs) });
		if(b[\x] > (size - b[\radius]), { b[\x] = size - b[\radius]; b[\vx] = b[\vx].neg * restitution; impact.value(b, b[\vx].abs) });
		if(b[\y] < b[\radius],          { b[\y] = b[\radius];        b[\vy] = b[\vy].neg * restitution; impact.value(b, b[\vy].abs) });
		if(b[\y] > (size - b[\radius]), { b[\y] = size - b[\radius]; b[\vy] = b[\vy].neg * restitution; impact.value(b, b[\vy].abs) });
	};

	balls.size.do {|i|
		balls.size.do {|j|
			var a = balls[i], c = balls[j];
			var dx = c[\x] - a[\x], dy = c[\y] - a[\y];
			var dist = dx.hypot(dy);
			var minDist = a[\radius] + c[\radius];
			if((j > i) && (dist < minDist) && (dist > 0), {
				var nx = dx / dist, ny = dy / dist;
				var overlap = minDist - dist;
				var invA = 1 / a[\mass], invC = 1 / c[\mass];
				var totalInv = invA + invC;
				var rvx = a[\vx] - c[\vx], rvy = a[\vy] - c[\vy];
				var velN = (rvx * nx) + (rvy * ny);
				a[\x] = a[\x] - (nx * overlap * (invA / totalInv));
				a[\y] = a[\y] - (ny * overlap * (invA / totalInv));
				c[\x] = c[\x] + (nx * overlap * (invC / totalInv));
				c[\y] = c[\y] + (ny * overlap * (invC / totalInv));
				if(velN > 0, {
					var jImp = (1 + ballRest) * velN / totalInv;
					a[\vx] = a[\vx] - (jImp * invA * nx);
					a[\vy] = a[\vy] - (jImp * invA * ny);
					c[\vx] = c[\vx] + (jImp * invC * nx);
					c[\vy] = c[\vy] + (jImp * invC * ny);
					impact.value(a, velN);
				});
			});
		};
	};

	balls.do {|b|
		var spd = b[\vx].hypot(b[\vy]);
		var cfg = soundCfg[b[\behaviour]];
		b[\granulator].set(
			\pos,   (b[\x] / size).clip(0, 1),
			\rate,  cfg[\rateFn].value(b, spd),
			\speed, cfg[\speedFn].value(b, spd),
			\amp,   cfg[\ampFn].value(b, spd),
			\pan,   ((b[\x] / size) * 2 - 1) * 0.8
		);
	};
};

spawn.value;

w = Window("Bouncing Balls", Rect(200, 100, size, size)).front;
v = UserView(w, Rect(0, 0, size, size));
v.background = Color.fromHexString("171b21");

v.drawFunc = {
	var labelX = 10;
	behaviours.do {|bhv|
		Pen.stringAtPoint(glyph[bhv] ++ "  " ++ bhv.asString,
			Point(labelX, 10), Font("Helvetica", 11), palette[bhv]);
		labelX = labelX + 115;
	};
	balls.do {|b|
		Pen.fillColor = b[\color];
		Pen.fillOval(Rect(b[\x] - b[\radius], b[\y] - b[\radius], b[\radius] * 2, b[\radius] * 2));
		Pen.stringAtPoint(glyph[b[\behaviour]],
			Point(b[\x] - 4, b[\y] - 8),
			Font("Helvetica-Bold", 13),
			Color.fromHexString("171b21"));
	};
};

v.keyDownAction = {|view, char|
	case
	{ char == $  } { running = running.not }
	{ char == $r } { spawn.value };
};

clock = Routine {
	inf.do {
		if(running, { physics.value });
		v.refresh;
		(1 / 60).wait;
	}
}.play(AppClock);

w.onClose = { balls.do {|b| b[\granulator].free }; clock.stop };

)
