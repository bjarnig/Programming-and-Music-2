////////////////////////////////////////////////////////////////
//
//                       Traer Physics
//
////////////////////////////////////////////////////////////////


( Quarks.install("TraerPhysics"); thisProcess.recompile )


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

var winW = 700, winH = 700;
var vortexStrength = 0.045;
var running = true;
var clock, spawner, win, view;
var bg, palette, maxAge, spawnPerSec;
var physics, meta, pools;
var spawn, applyVortex, purge, updateSound, drawScene, initAnchors;


bg = Color.fromHexString("171b21");

palette = (
	anchor:  Color.fromHexString("A3CEF1"),
	drifter: Color.fromHexString("72b6ec"),
	wisp:    Color.fromHexString("bce7fd"),
	spring:  Color.fromHexString("A3CEF1"),
	stress:  Color.fromHexString("a47e3c")
);

maxAge      = (anchor: 1000000, drifter: 420, wisp: 130);
spawnPerSec = (drifter: 0.7, wisp: 2.8);

physics = TraerParticleSystem(0, 0, 0, 0.05);
meta    = Dictionary.new;
pools   = (anchor: List.new, drifter: List.new, wisp: List.new);

spawn = {|type, x, y|
	var p, mass, bufRef, grSize, synth;
	mass = case
		{ type == \anchor }  { 60 }
		{ type == \drifter } { 7 }
		{ type == \wisp }    { 1.4 };
	p = physics.makeParticle(mass, x, y, 0);
	if(type == \anchor) { p.makeFixed };
	bufRef = case
		{ type == \anchor }  { ~cb }
		{ type == \drifter } { ~cb }
		{ type == \wisp }    { ~ca };
	grSize = case
		{ type == \anchor }  { 1.8 }
		{ type == \drifter } { 0.7 }
		{ type == \wisp }    { 0.18 };
	synth = Synth(\gr, [\buf, bufRef, \amp, 0.0, \grSize, grSize, \pos, 1.0.rand]);
	meta.put(p.identityHash, (kind: type, synth: synth, lifetime: maxAge[type], age: 0));
	pools[type].add(p);

	case
	{ type == \drifter } {
		if(pools[\anchor].size > 0, {
			physics.makeSpring(p, pools[\anchor].choose, 0.06, 0.15, rrand(100.0, 180.0));
			if((pools[\anchor].size > 1) and: { 0.5.coin }, {
				physics.makeSpring(p, pools[\anchor].choose, 0.04, 0.15, rrand(80.0, 160.0));
			});
		});
	}
	{ type == \wisp } {
		var candidates = pools[\drifter].copy.addAll(pools[\anchor]);
		if(candidates.size > 0, {
			physics.makeSpring(p, candidates.choose, 0.10, 0.05, rrand(20.0, 70.0));
		});
	};
	p
};

applyVortex = {
	var cx = winW * 0.5, cy = winH * 0.5;
	physics.particles.do {|p|
		var m = meta.at(p.identityHash);
		if(m.notNil and: { m[\kind] != \anchor }, {
			var dx = p.position.x - cx, dy = p.position.y - cy;
			var distSq = (dx * dx) + (dy * dy);
			if(distSq > 100, {
				var dist = distSq.sqrt;
				var tx = dy.neg / dist;
				var ty = dx / dist;
				p.force.x = p.force.x + (tx * vortexStrength * p.mass);
				p.force.y = p.force.y + (ty * vortexStrength * p.mass);
			});
		});
	};
};

purge = {
	var dead = List.new;
	physics.particles.do {|p|
		var m = meta.at(p.identityHash);
		if(m.notNil, {
			m[\age] = m[\age] + 1;
			if(m[\age] > m[\lifetime], { dead.add(p) });
		});
	};
	dead.do {|p|
		var m = meta.at(p.identityHash);
		physics.springs.copy.do {|s|
			if((s.a === p) or: { s.b === p }, { physics.removeSpring(s) });
		};
		physics.removeParticle(p);
		pools[m[\kind]].remove(p);
		m[\synth].free;
		meta.removeAt(p.identityHash);
	};
};

updateSound = {
	physics.particles.do {|p|
		var m = meta.at(p.identityHash);
		if(m.notNil, {
			var px = p.position.x, py = p.position.y;
			var spd  = p.velocity.x.hypot(p.velocity.y);
			var fade = (1 - (m[\age] / m[\lifetime])).clip(0, 1);
			var pan  = (((px / winW) * 2) - 1) * 0.7;
			case
			{ m[\kind] == \anchor } {
				var conns = physics.springs.count({|s| (s.a === p) or: { s.b === p } });
				var act   = conns.linlin(0, 6, 0.0, 1.0);
				m[\synth].set(
					\pos,   (px / winW).clip(0, 1),
					\rate,  (py / winH).linexp(0, 1, 0.45, 0.85),
					\speed, 3 + (act * 6),
					\amp,   0.08 + (act * 0.10),
					\pan,   pan
				);
			}
			{ m[\kind] == \drifter } {
				m[\synth].set(
					\pos,   (px / winW).clip(0, 1),
					\rate,  (py / winH).linexp(0, 1, 0.7, 1.4),
					\speed, 8 + spd.linlin(0, 8, 0, 14),
					\amp,   0.13 * fade,
					\pan,   pan
				);
			}
			{ m[\kind] == \wisp } {
				m[\synth].set(
					\pos,   (px / winW).clip(0, 1),
					\rate,  (px / winW).linexp(0, 1, 1.0, 2.4),
					\speed, 18 + spd.linlin(0, 10, 0, 22),
					\amp,   0.09 * fade,
					\pan,   pan
				);
			};
		});
	};
};

drawScene = {
	var lx = 12;

	physics.springs.do {|s|
		var ax = s.a.position.x, ay = s.a.position.y;
		var bx = s.b.position.x, by = s.b.position.y;
		var current = (ax - bx).hypot(ay - by);
		var stretch = (current / s.restLength) - 1;
		var tension = stretch.abs.clip(0, 0.6);
		var col     = palette[\spring].blend(palette[\stress], tension / 0.6);
		Pen.strokeColor = col.alpha_(tension.linlin(0, 0.3, 0.15, 0.7));
		Pen.width = 1.2;
		Pen.moveTo(Point(ax, ay));
		Pen.lineTo(Point(bx, by));
		Pen.stroke;
	};

	physics.particles.do {|p|
		var m = meta.at(p.identityHash);
		if(m.notNil, {
			var radius = case
				{ m[\kind] == \anchor }  { 16 }
				{ m[\kind] == \drifter } { 7 }
				{ m[\kind] == \wisp }    { 3.5 };
			var alpha = (1 - (m[\age] / m[\lifetime])).clip(0.08, 1);
			Pen.fillColor = palette[m[\kind]].alpha_(alpha);
			Pen.fillOval(Rect(
				p.position.x - radius, p.position.y - radius,
				radius * 2, radius * 2));
		});
	};
};

initAnchors = {
	3.do {|i|
		var ang = ((i / 3) * 2pi) + (pi / 4);
		spawn.value(\anchor,
			(winW * 0.5) + (ang.cos * 220),
			(winH * 0.5) + (ang.sin * 220));
	};
};


initAnchors.value;

win  = Window("Traer Particles", Rect(200, 100, winW, winH)).front;
view = UserView(win, Rect(0, 0, winW, winH));
view.background = bg;
view.drawFunc   = { drawScene.value };

view.keyDownAction = {|view, char|
	case
	{ char == $  } { running = running.not }
	{ char == $r } {
		meta.do {|m| m[\synth].free };
		meta.clear;
		[\anchor, \drifter, \wisp].do {|t| pools[t].clear };
		physics.springs.copy.do {|s| physics.removeSpring(s) };
		physics.particles.copy.do {|p| physics.removeParticle(p) };
		initAnchors.value;
	}
	{ char == $v } { vortexStrength = vortexStrength.neg };
};

clock = Routine {
	inf.do {
		if(running, {
			applyVortex.value;
			physics.tick;
			purge.value;
			updateSound.value;
		});
		view.refresh;
		(1 / 30).wait;
	}
}.play(AppClock);

spawner = Routine {
	inf.do {
		if(running, {
			if((spawnPerSec[\drifter] / 30).coin, {
				spawn.value(\drifter, rrand(80, winW - 80), rrand(80, winH - 80));
			});
			if((spawnPerSec[\wisp] / 30).coin, {
				spawn.value(\wisp, rrand(20, winW - 20), rrand(20, winH - 20));
			});
		});
		(1 / 30).wait;
	}
}.play(AppClock);

~traerMeta = Routine {
	var t = 0;
	inf.do {
		t = t + 1;
		vortexStrength       = (t * 0.035).sin * 0.06;
		spawnPerSec[\drifter] = 0.4 + (((t * 0.022).sin + 1) * 0.6);
		spawnPerSec[\wisp]    = 1.5 + (((t * 0.018).cos + 1) * 1.5);
		1.0.wait;
	}
}.play(AppClock);

win.onClose = {
	clock.stop; spawner.stop; ~traerMeta.stop;
	meta.do {|m| m[\synth].free };
	meta.clear;
};

)
