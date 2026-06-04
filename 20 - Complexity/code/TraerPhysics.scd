////////////////////////////////////////////////////////////////
//
// Particle Systems (adapted from examples by Fredrik Olofsson)
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)



( // Synth & Samples

SynthDef(\gr, {|buf=0, amp=0.5, speed=10, rate=1, atk=0.01, sus=0.5,
	rel=0.5, grSize=1.2, pos=0.125|
	var sig = TGrains.ar(2,Impulse.kr(speed), buf, rate, pos, grSize);
	OffsetOut.ar(0, sig * amp);
}).add;

~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
~path = ~path ++ "samples/";
~ca = Buffer.read(s, ~path ++ "ca.wav");
~ca = Buffer.read(s, ~path ++ "cb.wav");

)



// Needs the TraerPhysics Quark.
Quarks.fetchDirectory(true); Quarks.install("TraerPhysics");




( // Animation with particles

var width = 400, height= 400, maxAge= 200, maxBorneAge= 10;
var win = Window("Particles", Rect(100, 100, width, height), false, true);
var view = UserView(win, Rect(0, 0, width, height));
var physics, create, granulators = Dictionary.new;

view.frameRate = 20;
view.background = Color.white;
physics = TraerParticleSystem(0, 0, 0, 0.1);

view.drawFunc= {

	// Check for death
	var dead = List.new;
	physics.particles.do{|p, i|
		if(p.age > maxAge, {
			p.dead= true;
			dead.add(p);
		});
	};

	// Remove if dead
	dead.do{|p|
		var synth = granulators.at(p.basicHash);
        synth.free;

        physics.springs.select{|s| s.a==p or:{s.b==p}}.do{|s|
			physics.removeSpring(s)
        };

        physics.removeParticle(p);
	};

    // Next tick
	physics.tick;

    Pen.fillColor = Color.green(0.6, 0.3);

	physics.particles.do{|p|
		// Sound
		var synth = granulators.at(p.basicHash);
		synth.set(\pos,  (p.position.x).linlin(0,400,0.0,1.0));
		synth.set(\speed, (p.position.y).linlin(0,400,0.1,20));
		synth.set(\rate, (p.position.x).linlin(0,400,0.25,0.75));
		synth.set(\amp, 1 - (p.age/maxAge));

		// Image
        Pen.addOval(Rect.aboutPoint(Point(p.position.x, p.position.y),
			p.mass*(1-(p.age/maxAge)), p.mass*(1-(p.age/maxAge))));
        Pen.fill;
    };

};

view.animate = true;
win.front;


// Generate particles and corresponding grains
create = {|x, y|
	var p = physics.makeParticle(1.0.rrand(20), x, y, 0);
	var synth = Synth(\gr, [\buf, ~ca, \sus, 300, \pos, 1.0.rand]);

    granulators.put(p.basicHash, synth);
	p.age = maxBorneAge.rand;

	2.do{|i|
		var q = physics.particles.choose;

        if(p != q, {
			physics.makeSpring(p, q, 0.1.rand, 0.25.rand, 10.rand+10);
		});
	};
};

Routine {
	inf.do {
		create.value(400.rand, 400.rand);
		rrand(1,3).wait;
	}
}.play;

)