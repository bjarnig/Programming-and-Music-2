////////////////////////////////////////////////////////////////
//
//                  Sonification  (Data Files)
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)



///////// Use files to store the state of an object ////////////

(
~path = (PathName(thisProcess.nowExecutingPath)).pathOnly;
~arrayPath = ~path ++ "array.test";
)

a = [1,2,3];
a.writeArchive(~arrayPath);
a = 0;

a = Object.readArchive(~arrayPath);
a




/////// Use SC to read files (such as Sonology courses) ////////

(

~readSimpleFile = {|path, action, dur = 0.2|
var file, data;

file = File(path,"r");

// start a looping file reading process
fork {
	loop {

		// check for remaining data
		if (file.pos != file.length) {

			// process the data
			data = file.getLine;
			action.value(data);
	} {
		// stop the process and close the file
		file.close;
		thisThread.stop;
	};

	dur.wait;

    }
}};

)


~readSimpleFile.value(~path ++ "data/courses.txt", {|str| str.postln}, 1);


~readSimpleFile.value(~path ++ "data/courses.txt", {|str| str.scramble.postln});


~snd = {|freq| { Line.kr(1,0,1,doneAction:2) * Impulse.ar(freq) }.play };


(

~readSimpleFile.value(~path ++ "data/courses.txt", {|str|
	Routine.new({ str.postln;  str.do {|a| a.postln; ~snd.value(a.ascii); 0.1.wait; } }).play;
}, 2)

)



// It is also possible to read more complex dat such as US senator votes

x = CSVFileReader.read(~path ++ "data/votes.csv").postcs;

(

i = 1;

fork {
	x.size.do {
		var title, votes;
		title = x[i][1].postln;
		votes = x[i][21].asInt.min(10000).max(100);
		votes.postln;
		~snd.value(votes);
		i = i + 1;
		0.1.wait;
    }
}.play;

)



// Or earthquake logs

y = CSVFileReader.read(~path ++ "data/earthquakes.csv").postcs;

(

i = 1;

fork {
	y.size.do {
		var magnitude, title, longitude, latitude;
		magnitude = y[i][0].postln;
		title = y[i][1].postln;
		longitude = abs(y[i][3].asInt);
		latitude= abs(y[i][4].asInt);
		longitude.postln;
		latitude.postln;
		{ EnvGen.ar(Env([0,1,0], magnitude.asInt ! 2)) *
		  SinOsc.ar(longitude.midicps) ! 2 * 0.2}.play;
		i = i + 1;
		1.wait;
    }
}.play;

)