////////////////////////////////////////////////////////////////
//
//                       Boids
//
////////////////////////////////////////////////////////////////

/* Reynolds flocking with 60 agents and a predator on a path. */

(

SynthDef(\gr, {|buf=0, amp=0.0, speed=10, rate=1, grSize=1.2, pos=0.125, pan=0|
	var sig = TGrains.ar(2, Impulse.kr(speed), buf, rate, pos, grSize, pan);
	OffsetOut.ar(0, sig * amp);
}).add;

~path = (PathName(thisProcess.nowExecutingPath)).pathOnly ++ "samples/";
~ca   = Buffer.read(s, ~path ++ "ca.wav");
~cb   = Buffer.read(s, ~path ++ "cb.wav");

)

(

var width = 700, height = 700;
var nBoids = 60;
var sepDist = 18.0, neighDist = 50.0;
var wSep = 0.05, wAli = 0.04, wCoh = 0.0008;
var maxSpeed = 3.5, minSpeed = 0.7;
var predatorRadius = 180.0, predatorWeight = 2.5, predatorEnabled = true;
var boids, predator;
var running = true, clock;
var bg, palette, spawn, step;


bg = Color.fromHexString("171b21");

palette = (
	boid:     Color.fromHexString("A3CEF1"),
	predator: Color.fromHexString("a47e3c"),
	halo:     Color.fromHexString("a47e3c"),
	text:     Color.gray(0.7)
);

spawn = {
	boids !? { boids.do {|b| b[\voice].free } };
	boids = Array.fill(nBoids, {|i|
		var ang = 2pi.rand;
		var b = (
			x:  rrand(0, width.asFloat),
			y:  rrand(0, height.asFloat),
			vx: ang.cos * rrand(1.0, maxSpeed),
			vy: ang.sin * rrand(1.0, maxSpeed)
		);
		b[\voice] = Synth(\gr, [\buf, ~cb, \amp, 0.0, \grSize, 0.6]);
		b
	});
	predator = (x: width * 0.5, y: height * 0.5, phase: 0.0);
};

step = {
	/* predator on a 1:2 Lissajous figure */
	predator[\phase] = predator[\phase] + 0.012;
	predator[\x]     = (width  * 0.5) + ((width  * 0.32) * (predator[\phase] * 1.0).sin);
	predator[\y]     = (height * 0.5) + ((height * 0.32) * (predator[\phase] * 2.0).sin);

	nBoids.do {|i|
		var b = boids[i];
		var sepX = 0, sepY = 0;
		var aliX = 0, aliY = 0;
		var cohX = 0, cohY = 0, neighCount = 0;
		var spd;

		/* gather contributions from all other boids in one pass */
		nBoids.do {|j|
			if(j != i, {
				var other = boids[j];
				var dx = other[\x] - b[\x], dy = other[\y] - b[\y];
				var dist = dx.hypot(dy);
				/* separation: steer away from close neighbours */
				if(dist < sepDist, {
					sepX = sepX - (dx / max(dist, 0.01));
					sepY = sepY - (dy / max(dist, 0.01));
				});
				/* alignment + cohesion: match velocity / position of nearby neighbours */
				if(dist < neighDist, {
					aliX = aliX + other[\vx]; aliY = aliY + other[\vy];
					cohX = cohX + other[\x];  cohY = cohY + other[\y];
					neighCount = neighCount + 1;
				});
			});
		};

		/* average the alignment/cohesion vectors, make cohesion a steer-toward-com */
		if(neighCount > 0, {
			aliX = aliX / neighCount;          aliY = aliY / neighCount;
			cohX = (cohX / neighCount) - b[\x]; cohY = (cohY / neighCount) - b[\y];
		});

		/* mix the three Reynolds rules with their weights */
		b[\vx] = b[\vx] + (sepX * wSep) + (aliX * wAli) + (cohX * wCoh);
		b[\vy] = b[\vy] + (sepY * wSep) + (aliY * wAli) + (cohY * wCoh);

		/* predator flee — strong push away within predatorRadius */
		if(predatorEnabled, {
			var dx = b[\x] - predator[\x], dy = b[\y] - predator[\y];
			var dist = dx.hypot(dy);
			if((dist < predatorRadius) and: { dist > 0 }, {
				var weight = (1 - (dist / predatorRadius)) * predatorWeight;
				b[\vx] = b[\vx] + (dx / dist * weight);
				b[\vy] = b[\vy] + (dy / dist * weight);
			});
		});

		/* clamp speed to [minSpeed, maxSpeed] so flocks never stall or runaway */
		spd = b[\vx].hypot(b[\vy]);
		if(spd > maxSpeed) { b[\vx] = b[\vx] / spd * maxSpeed; b[\vy] = b[\vy] / spd * maxSpeed };
		if((spd < minSpeed) and: { spd > 0 }) {
			b[\vx] = b[\vx] / spd * minSpeed;
			b[\vy] = b[\vy] / spd * minSpeed;
		};

		/* integrate position, toroidal wrap */
		b[\x] = (b[\x] + b[\vx]) % width;
		b[\y] = (b[\y] + b[\vy]) % height;

		/* per-boid voice: speed → density + amp, y → pitch, x → pos + pan */
		b[\voice].set(
			\amp,    spd.linlin(0, maxSpeed, 0.04, 0.20),
			\speed,  spd.linlin(0, maxSpeed, 6, 30),
			\pos,    (b[\x] / width).clip(0, 1),
			\rate,   (b[\y] / height).linexp(0, 1, 0.5, 2.0),
			\grSize, 0.3 + ((spd / maxSpeed) * 1.0),
			\pan,    ((b[\x] / width) * 2 - 1) * 0.85
		);
	};
};


spawn.value;

w = Window("Boids", Rect(200, 100, width, height)).front;
v = UserView(w, Rect(0, 0, width, height));
v.background = bg;

v.drawFunc = {

	if(predatorEnabled, {
		Pen.fillColor = palette[\halo].alpha_(0.10);
		Pen.fillOval(Rect(
			predator[\x] - predatorRadius, predator[\y] - predatorRadius,
			predatorRadius * 2, predatorRadius * 2));
		Pen.fillColor = palette[\predator];
		Pen.fillOval(Rect(predator[\x] - 9, predator[\y] - 9, 18, 18));
	});

	boids.do {|b|
		var ang  = b[\vy].atan2(b[\vx]);
		var size = 5.5;
		var fx = b[\x] + (ang.cos * size * 1.4);
		var fy = b[\y] + (ang.sin * size * 1.4);
		var bx = b[\x] - (ang.cos * size * 0.7);
		var by = b[\y] - (ang.sin * size * 0.7);
		var lx = bx + ((ang + 2.4).cos * size * 0.9);
		var ly = by + ((ang + 2.4).sin * size * 0.9);
		var rx = bx + ((ang - 2.4).cos * size * 0.9);
		var ry = by + ((ang - 2.4).sin * size * 0.9);
		Pen.fillColor = palette[\boid];
		Pen.moveTo(Point(fx, fy));
		Pen.lineTo(Point(lx, ly));
		Pen.lineTo(Point(rx, ry));
		Pen.fill;
	};

};

v.keyDownAction = {|view, char|
	case
	{ char == $  } { running = running.not }
	{ char == $r } { spawn.value }
	{ char == $p } { predatorEnabled = predatorEnabled.not };
};

clock = Routine {
	inf.do {
		if(running, { step.value });
		v.refresh;
		(1 / 60).wait;
	}
}.play(AppClock);

w.onClose = { clock.stop; boids.do {|b| b[\voice].free } };

)
