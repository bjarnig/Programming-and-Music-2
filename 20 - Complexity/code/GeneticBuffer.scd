////////////////////////////////////////////////////////////////
//
//                       Genetic Algorithm
//
////////////////////////////////////////////////////////////////

/* Evolution over a permutation of audio-buffer segments.
   Each chromosome is a permutation of segment indices; the
   identity permutation reproduces the original sound.
   Fitness Speech evolves from cut-up scramble to
   intelligible in roughly five audible passes.

   Keys:  space pause   r reseed
*/


( Quarks.fetchDirectory(true); Quarks.install("SafetyNet"); thisProcess.recompile )


(

SynthDef(\seg, {|buf=0, segIndex=0, numSegs=16, amp=0.7, dur=0.3, pan=0|
	var startFrame = BufFrames.kr(buf) * (segIndex / numSegs);
	var env = EnvGen.kr(Env.linen(0.005, dur - 0.015, 0.01), doneAction: 2);
	var sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf), 1, startFrame, 0);
	OffsetOut.ar(0, Pan2.ar(sig * env * amp, pan));
}).add;

~path   = (PathName(thisProcess.nowExecutingPath)).pathOnly ++ "samples/";
~ca     = Buffer.read(s, ~path ++ "ca.wav");
~cb     = Buffer.read(s, ~path ++ "cb.wav");
~speech = Buffer.read(s, ~path ++ "speach.wav");

)


(

var numSegs      = 32;
var popSize      = 140;
var eliteCount   = 28;
var mutRate      = 0.6;
var tournament_k = 4;
var gensPerPass  = 14;
var winW = 820, winH = 380;
var srcBuf, bufDur, segDur;
var population, generation = 0, bestChrom, bestFit = 0, playStep = 0;
var running = true, clock;
var randPerm, fitness, ox, mutate, tournament, nextGen, reseed, segColor;

srcBuf = ~speech;
bufDur = (srcBuf.duration ? 11.35);
segDur = bufDur / numSegs;

randPerm = { Array.series(numSegs, 0, 1).scramble };
fitness  = {|c| c.collect({|v, i| (v == i).asInteger }).sum };

segColor = {|idx|
	var hue = (idx / max(numSegs - 1, 1)) * 0.9;
	Color.hsv(hue, 0.55, 0.95)
};

// Order Crossover — preserves permutation validity (no duplicates).
ox = {|pa, pb|
	var n = pa.size;
	var lo, hi, child, taken, idx, pidx, remaining;
	lo = n.rand; hi = n.rand;
	if(lo > hi, { var t = lo; lo = hi; hi = t });
	child = Array.fill(n, -1);
	(lo..hi).do {|k| child[k] = pa[k] };
	taken = Set.newFrom(child[lo..hi]);
	idx       = (hi + 1) % n;
	pidx      = (hi + 1) % n;
	remaining = n - (hi - lo + 1);
	remaining.do {
		while({ taken.includes(pb[pidx]) }, { pidx = (pidx + 1) % n });
		child[idx] = pb[pidx];
		taken.add(pb[pidx]);
		idx  = (idx + 1) % n;
		pidx = (pidx + 1) % n;
	};
	child
};

mutate = {|chrom|
	var c = chrom.copy;
	if(mutRate.coin, {
		var i = numSegs.rand, j = numSegs.rand, tmp = c[i];
		c[i] = c[j]; c[j] = tmp;
	});
	c
};

tournament = {
	var best, bestF = -1;
	tournament_k.do {
		var cand = population.choose;
		var f = fitness.value(cand);
		if(f > bestF, { best = cand; bestF = f });
	};
	best
};

nextGen = {
	var newPop = List.new;
	population.sort({|a, b| fitness.value(a) > fitness.value(b) });
	eliteCount.do {|i| newPop.add(population[i]) };
	(popSize - eliteCount).do {
		newPop.add(mutate.value(ox.value(tournament.value, tournament.value)));
	};
	population = newPop;
	generation = generation + 1;
	bestChrom  = population[0];
	bestFit    = fitness.value(bestChrom);
};

reseed = {
	population = List.new;
	popSize.do { population.add(randPerm.value) };
	generation = 0;
	playStep   = 0;
	bestChrom  = population[0];
	bestFit    = fitness.value(bestChrom);
};


reseed.value;

w = Window("GA / buffer segments", Rect(200, 100, winW, winH)).front;
v = UserView(w, Rect(0, 0, winW, winH));
v.background = Color.fromHexString("171b21");

v.drawFunc = {
	var pad = 20;
	var cellW = (winW - (pad * 2)) / numSegs;
	var topY = 70, midY = 175, botY = 285;
	var cellH = 80;
	var pct = (bestFit / numSegs * 100).round(1);

	Pen.stringAtPoint(
		"gen " ++ generation ++ "    fitness " ++ bestFit ++ " / " ++ numSegs ++ "    " ++ pct ++ "%",
		Point(pad, 24), Font("Monaco", 16), Color.white);
	Pen.stringAtPoint("target (identity permutation)",
		Point(pad, topY - 18), Font("Monaco", 10), Color.gray(0.6));
	Pen.stringAtPoint("best chromosome",
		Point(pad, midY - 18), Font("Monaco", 10), Color.gray(0.6));
	Pen.stringAtPoint("playhead",
		Point(pad, botY - 18), Font("Monaco", 10), Color.gray(0.6));

	numSegs.do {|i|
		Pen.fillColor = segColor.value(i);
		Pen.fillRect(Rect(pad + (i * cellW), topY, cellW - 2, cellH));
	};

	numSegs.do {|i|
		var segIndex = bestChrom[i];
		Pen.fillColor = segColor.value(segIndex);
		Pen.fillRect(Rect(pad + (i * cellW), midY, cellW - 2, cellH));
		if(segIndex == i, {
			Pen.strokeColor = Color.fromHexString("bce7fd");
			Pen.width = 2;
			Pen.strokeRect(Rect(pad + (i * cellW), midY, cellW - 2, cellH));
		});
	};

	numSegs.do {|i|
		Pen.fillColor = if(i == playStep,
			{ Color.fromHexString("bce7fd") },
			{ Color.fromHexString("2a3140") });
		Pen.fillRect(Rect(pad + (i * cellW), botY, cellW - 2, 22));
	};
};

v.keyDownAction = {|view, char|
	case
	{ char == $  } { running = running.not }
	{ char == $r } { reseed.value };
};

clock = Routine {
	inf.do {
		if(running, {
			Synth(\seg, [
				\buf,      srcBuf,
				\segIndex, bestChrom[playStep],
				\numSegs,  numSegs,
				\dur,      segDur,
				\amp,      0.7,
				\pan,      ((playStep / numSegs * 2) - 1) * 0.4
			]);
			playStep = playStep + 1;
			if(playStep >= numSegs, {
				playStep = 0;
				if(bestFit < numSegs, { gensPerPass.do { nextGen.value } });
			});
		});
		v.refresh;
		segDur.wait;
	}
}.play(AppClock);

w.onClose = { clock.stop };
)
