////////////////////////////////////////////////////////////////
//
//                      Genetic Algorithm
//
////////////////////////////////////////////////////////////////

/*

   The population is a list of random strings; the target is one fixed
   string. Fitness counts characters that already match the target at
   their position. Generation by generation the population evolves
   toward the target.

   Five operations make a GA:
       makeChrom    a random candidate
       fitness      how good a candidate is
       tournament   pick a parent
       crossover    combine two parents into a child
       mutate       perturb the child a little

*/


( Quarks.fetchDirectory(true); Quarks.install("SafetyNet"); thisProcess.recompile )


(

SynthDef(\blip, {|freq=440, amp=0.25, dur=0.18, pan=0|
	var env = EnvGen.kr(Env.perc(0.005, dur, 1, -4), doneAction: 2);
	var sig = SinOsc.ar(freq) * env * amp;
	OffsetOut.ar(0, Pan2.ar(sig, pan));
}).add;

)


(

/* What we want the GA to discover. */
var target  = "Sonology and LHI";
var charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ";


/* Parameters  */
var popSize    = 80;     /* number of candidate strings */
var eliteCount = 4;      /* top N kept for each generation */
var mutRate    = 0.04;   /* per-character mutation probability */
var k          = 3;      /* tournament size */
var maxGens    = 500;    /* hard ceiling on generations */
var fps        = 6;      /* generations per second on screen / in audio */


/* States  */
var population, generation = 0, bestChrom, bestFit;
var makeChrom, fitness, tournament, crossover, mutate;


/* Random candidate string */
makeChrom = { String.fill(target.size, { charset[charset.size.rand] }) };


/* Fitness = count of characters matching target at the same position. */
fitness = {|chrom|
	var matches = 0;
	target.size.do {|i| if(chrom[i] == target[i]) { matches = matches + 1 } };
	matches
};

/* Pick k random candidates, return the best */
tournament = {
	var best  = population.choose;
	var bestF = fitness.value(best);
	(k - 1).do {
		var cand = population.choose;
		var f    = fitness.value(cand);
		if(f > bestF) { best = cand; bestF = f };
	};
	best
};

/* Prefix from one parent, suffix from the other */
crossover = {|pa, pb|
	var cut = target.size.rand;
	(pa.copyRange(0, cut - 1) ++ pb.copyRange(cut, target.size - 1))
};

/* Mutation, per character, with probability mutRate, replace with random */
mutate = {|chrom|
	String.fill(target.size, {|i|
		if(mutRate.coin, { charset[charset.size.rand] }, { chrom[i] })
	})
};

population = Array.fill(popSize, { makeChrom.value });
bestChrom  = population[0];
bestFit    = fitness.value(bestChrom);


/*
   At each generation:
     1. sort the population by fitness so elites sit at the front
     2. log the best to the post window and ring a blip
     3. stop if it matches the target exactly
     4. otherwise: copy elites + breed the rest via tournament / crossover / mutate
     5. wait one frame and repeat
*/

Routine {
	block {|break|
		maxGens.do {
			var newPop = List.new;

			population.sort({|a, b| fitness.value(a) > fitness.value(b) });
			bestChrom = population[0];
			bestFit   = fitness.value(bestChrom);

			("gen " ++ generation.asString.padLeft(3)
				++ "    fit " ++ bestFit.asString.padLeft(2) ++ " / " ++ target.size
				++ "    \"" ++ bestChrom ++ "\"").postln;

			Synth(\blip, [
				\freq, (48 + ((bestFit / target.size) * 36)).midicps,
				\amp,  0.25,
				\dur,  0.20
			]);

			if(bestFit == target.size) {
				"→ completed.".postln;
				break.value;
			};

			eliteCount.do {|i| newPop.add(population[i]) };
			(popSize - eliteCount).do {
				newPop.add(mutate.value(crossover.value(tournament.value, tournament.value)));
			};
			population = newPop.asArray;
			generation = generation + 1;
			(1 / fps).wait;
		};
	};
}.play(AppClock);

)
