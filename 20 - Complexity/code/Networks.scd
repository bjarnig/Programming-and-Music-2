////////////////////////////////////////////////////////////////
//
//                       Granular Networks
//
////////////////////////////////////////////////////////////////

/*
   Several tokens walk a graph of 100 nodes in parallel.
   Each walker has its own granular voice, panned across the
   stereo field. Lagged controls smooth the transitions.

     • random graph         — each node connects to 2..8 random others
     • hub-and-spoke graph  — 5 hubs that re-emerge as recurring motifs

   The two graphs use separate globals (~ranRoutines / ~hubRoutines)
   so you can evaluate one while the other is still playing.
*/


( Quarks.fetchDirectory(true); Quarks.install("SafetyNet"); thisProcess.recompile )


(

SynthDef(\gr, {|buf=0, amp=0.0, speed=10, rate=1, grSize=1.2, pos=0.125, pan=0, lagTime=0.5|
	var sig = TGrains.ar(2,
		Impulse.kr(Lag.kr(speed, lagTime)),
		buf,
		Lag.kr(rate,   lagTime),
		Lag.kr(pos,    lagTime),
		Lag.kr(grSize, lagTime),
		Lag.kr(pan,    0.3),
		Lag.kr(amp,    0.3));
	OffsetOut.ar(0, sig);
}).add;

~path = (PathName(thisProcess.nowExecutingPath)).pathOnly ++ "samples/";
~ca   = Buffer.read(s, ~path ++ "ca.wav");
~cb   = Buffer.read(s, ~path ++ "cb.wav");

)


/* Random network — each node connects to 2..8 random others.
   nWalkers tokens roam the graph in parallel.                    */

(

var nNodes = 100, nWalkers = 3;
var nodes, totalEdges = 0;

nodes = Array.fill(nNodes, {|i|
	(
		id:         i,
		duration:   rrand(4, 8),
		pos:        1.0.rand,
		grDur:      rrand(0.1, 0.8),
		rate:       rrand(0.1, 0.8),
		speed:      rrand(2, 20),
		buf:        [~ca, ~cb].choose,
		neighbours: List.new
	)
});

nodes.do {|n|
	var k = rrand(2, 8);
	k.do { n[\neighbours].add(nodes.choose) };
	totalEdges = totalEdges + k;
};


if(~ranRoutines.notNil) { ~ranRoutines.do {|r| if(r.notNil) { r.stop } } };

if(~ranVoices.notNil) {
	~ranVoices.do {|v| if(v.notNil and: { v.isPlaying }) { v.free } };
};


~ranVoices = nWalkers.collect {|i|
	var pan = if(nWalkers > 1) { ((i / (nWalkers - 1)) * 2 - 1) * 0.7 } { 0 };
	Synth(\gr, [\amp, 0.0, \pan, pan]).register;
};

~ranRoutines = nWalkers.collect {|i|
	var myVoice = ~ranVoices[i];
	Routine {
		var node = nodes.choose;
		inf.do {
			("→ node " ++ node[\id].asString.padLeft(3)
				++ "   rate "  ++ node[\rate].round(0.01)
				++ "   speed " ++ node[\speed]).postln;
			myVoice.set(
				\buf,    node[\buf],
				\pos,    node[\pos],
				\grSize, node[\grDur],
				\rate,   node[\rate],
				\speed,  node[\speed],
				\amp,    0.18
			);
			node[\duration].wait;
			node = node[\neighbours].choose;
		};
	}.play
};

("── random network ── "
	++ nNodes ++ " nodes · " ++ totalEdges ++ " edges · "
	++ nWalkers ++ " walkers").postln;

)


/* Hub-and-spoke — 5 hubs that walkers keep returning to.
   nWalkers tokens start on different hubs and roam in parallel. */

(

var nNodes = 100, nHubs = 5, nWalkers = 3;
var nodes, hubs, outer, hubIds;

nodes = Array.fill(nNodes, {|i|
	(
		id:         i,
		duration:   rrand(2, 4),
		pos:        1.0.rand,
		grDur:      rrand(0.1, 0.8),
		rate:       rrand(0.1, 0.8),
		speed:      rrand(2, 20),
		buf:        [~ca, ~cb].choose,
		neighbours: List.new
	)
});
hubs   = nodes.copy.scramble.keep(nHubs);
outer  = nodes.reject({|n| hubs.includes(n) });
hubIds = hubs.collect({|h| h[\id] });

/* hubs connect to many outer nodes; outer nodes connect back only to hubs */
hubs.do {|h|  rrand(15, 25).do { h[\neighbours].add(outer.choose) } };
outer.do {|n| rrand(1,   2).do { n[\neighbours].add(hubs.choose)  } };

if(~hubRoutines.notNil) { ~hubRoutines.do {|r| if(r.notNil) { r.stop } } };
if(~hubVoices.notNil) {
	~hubVoices.do {|v| if(v.notNil and: { v.isPlaying }) { v.free } };
};

~hubVoices = nWalkers.collect {|i|
	var pan = if(nWalkers > 1) { ((i / (nWalkers - 1)) * 2 - 1) * 0.7 } { 0 };
	Synth(\gr, [\amp, 0.0, \pan, pan]).register;
};

~hubRoutines = nWalkers.collect {|i|
	var myVoice = ~hubVoices[i];
	Routine {
		var node = hubs.wrapAt(i);   /* each walker starts on a different hub */
		inf.do {
			var isHub = hubs.includes(node);
			var tag   = if(isHub) { "★ HUB  " } { "  outer" };
			(tag ++ " " ++ node[\id].asString.padLeft(3)
				++ "   rate "  ++ node[\rate].round(0.01)
				++ "   speed " ++ node[\speed]).postln;
			myVoice.set(
				\buf,    node[\buf],
				\pos,    node[\pos],
				\grSize, node[\grDur],
				\rate,   node[\rate],
				\speed,  node[\speed],
				\amp,    0.18
			);
			node[\duration].wait;
			node = node[\neighbours].choose;
		};
	}.play
};

("── hub-and-spoke ── "
	++ nHubs ++ " hubs " ++ hubIds ++ " · "
	++ (nNodes - nHubs) ++ " outer nodes · "
	++ nWalkers ++ " walkers").postln;

)
