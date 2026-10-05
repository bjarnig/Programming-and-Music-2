////////////////////////////////////////////////////////////////
//
//        Breakpoints: parameters written by patterns
//
////////////////////////////////////////////////////////////////

A breakpoint file is a text file of time and value pairs. CDP
reads it wherever a parameter may change over time, and SuperCollider
can write it. Every example waits for CDP to finish, so a chain
can be run from one block.


( //  Init: paths, a program runner that waits, a breakpoint writer  //

~path = PathName(thisProcess.nowExecutingPath).pathOnly;
~bin  = "~/cdpr8/_cdp/_cdprogs/".standardizePath;
~src  = ~path ++ "sounds/abstract/aa.wav";
~out  = ~path ++ "output/";
File.mkdir(~out);

// quote a path, since the class folders contain spaces
~q = { |p| "\"" ++ p ++ "\"" };

// run one CDP program and wait for it; returns the output file
// CDP refuses to overwrite, so an old output is removed first
~cdp = { |program, input, output, params = ""|
	var cmd = ~q.(~bin ++ program.split($ )[0]) + program.split($ )[1..].join(" ")
	         + ~q.(input) + ~q.(output) + params;
	var code;
	if(File.exists(output)) { File.delete(output) };
	code = cmd.systemCmd;
	if(code != 0) { "FAILED (%): %".format(code, cmd).postln };
	output
};

// write [time, value] pairs as a breakpoint file, return its quoted path
~brk = { |name, pairs|
	var path = ~out ++ name ++ ".brk";
	File.use(path, "w", { |f| pairs.do { |p| f.write("% %\n".format(p[0], p[1])) } });
	~q.(path)
};

// duration in seconds, to check what a process did to the length
~dur = { |path| SoundFile.use(path, { |f| f.duration }) };
)



( //  A chain in one block: shred, then the spectral domain and back  //

var shred = ~cdp.("modify radical 2", ~src, ~out ++ "shred.wav", "16 0.15");
var ana   = ~cdp.("pvoc anal 1", shred, ~out ++ "shred.ana");
var blur  = ~cdp.("blur blur", ana, ~out ++ "blur.ana", "32");
var str   = ~cdp.("stretch time 1", blur, ~out ++ "stretch.ana", "2.0");
var out   = ~cdp.("pvoc synth", str, ~out ++ "chain.wav");
"% s in, % s out".format(~dur.(~src).round(0.01), ~dur.(out).round(0.01)).postln;
)

( //  By hand: three breakpoints, the speed falls and then rises  //

var brk = ~brk.("hand", [[0, 1], [4, 0.5], [8, 2]]);
var out = ~cdp.("modify speed 1", ~src, ~out ++ "hand.wav", brk);
"% s in, % s out".format(~dur.(~src).round(0.01), ~dur.(out).round(0.01)).postln;
)



( //  By a pattern: a random walk written as breakpoints  //

var times  = (0..16) * 0.5;
var walk   = Pbrown(0.5, 2.0, 0.25, 17).asStream.nextN(17);
var pairs  = [times, walk].flop;
var brk    = ~brk.("walk", pairs);
var out    = ~cdp.("modify speed 1", ~src, ~out ++ "walk.wav", brk);
pairs.postln;
"% s out".format(~dur.(out).round(0.01)).postln;
)



( //  By an envelope: the shape is drawn once and sampled  //

var env   = Env([1, 4, 1.5, 3], [3, 2, 3], [4, -4, 0]);
var times = (0..16) * 0.5;
var pairs = times.collect { |t| [t, env.at(t).round(0.001)] };
var brk   = ~brk.("env", pairs);
var out   = ~cdp.("modify speed 1", ~src, ~out ++ "env.wav", brk);
"% s out".format(~dur.(out).round(0.01)).postln;
)



( //  By a chaotic function: the logistic map as the speed  //
// r rises from 3.2 to 3.99. Four iterations per breakpoint hide the cycles
// of period two and four, so the speed sits still until the map turns chaotic
// (r = 3.57, after about 3.7 seconds) and then wanders

var x = 0.5, pairs;
pairs = (0..40).collect { |i|
	var r = i.linlin(0, 40, 3.2, 3.99);
	4.do { x = r * x * (1 - x) };
	[i * 0.2, (2 ** (x * 2 - 1)).round(0.001)]
};
~cdp.("modify speed 1", ~src, ~out ++ "logistic.wav", ~brk.("logistic", pairs));
)



( //  Sequential and morphic: the same values, held and joined  //

var values = [1, 2, 0.7, 1.5, 0.5, 3, 1, 2];
var times  = (0..7);
var held   = values.collect { |v, i| [[i, v], [i + 0.99, v]] }.flatten(1);
var joined = [times, values].flop;
~cdp.("modify speed 1", ~src, ~out ++ "held.wav",   ~brk.("held",   held));
~cdp.("modify speed 1", ~src, ~out ++ "joined.wav", ~brk.("joined", joined));
)



( //  Three glides between the same two speeds  //
// Wishart's sound example 13.4: the same motion from A to B
// with a different shape, and each shape sounds different

[[\fast_then_slow, -4], [\linear, 0], [\slow_then_fast, 4]].do { |pair|
	var name = pair[0], curve = pair[1];
	var env   = Env([1, 2], [8], curve);
	var pairs = (0..16).collect { |i| [i * 0.5, env.at(i * 0.5).round(0.001)] };
	~cdp.("modify speed 1", ~src, ~out ++ name ++ ".wav", ~brk.(name, pairs));
};
)

( //  A spectral chain with a time-varying stretch  //

var stretch = ~brk.("stretch", [[0, 1], [3, 1], [4, 6], [8, 1]]);
var ana     = ~cdp.("pvoc anal 1", ~src, ~out ++ "aa.ana");
var stretched = ~cdp.("stretch time 1", ana, ~out ++ "aa-str.ana", stretch);
var out     = ~cdp.("pvoc synth", stretched, ~out ++ "aa-str.wav");
"% s in, % s out".format(~dur.(~src).round(0.01), ~dur.(out).round(0.01)).postln;
)



////////////////////////////////////////////////////////////////
//                    A family from one source
////////////////////////////////////////////////////////////////

Each member is a short chain, a shred and then a walk in the speed.
The seed is the only thing that differs. It fixes the parameters and
the breakpoints, and the log records them. CDP shreds differently on
every run, so a member can be described again but not remade exactly:
keep the files you like.


(
var dir = ~out ++ "family/";
var log, n = 8;
File.mkdir(dir);
log = File(dir ++ "log.txt", "w");

n.do { |i|
	var seed = 100 + i;
	var repeats, chunk, walk, shred, out;
	thisThread.randSeed = seed;
	repeats = rrand(4, 16);
	chunk   = rrand(0.1, 0.8).round(0.01);
	walk    = Pbrown(0.5, 2.0, 0.3, 17).asStream.nextN(17);

	shred = ~cdp.("modify radical 2", ~src, dir ++ "shred_%.wav".format(i), "% %".format(repeats, chunk));
	out   = ~cdp.("modify speed 1", shred, dir ++ "member_%.wav".format(i),
		~brk.("family/walk_%".format(i), [(0..16) * 0.5, walk].flop));

	log.write("member % seed % shred % % duration %\n".format(i, seed, repeats, chunk, ~dur.(out).round(0.01)));
};
log.close;
File.readAllString(dir ++ "log.txt").postln;
)
