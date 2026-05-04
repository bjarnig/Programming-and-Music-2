////////////////////////////////////////////////////////////////
//
//                  Network Music - Advanced
//
////////////////////////////////////////////////////////////////


///////////////// Basic OSC Communication //////////////////////

// Get your IP address
// Mac: ifconfig | grep inet
// Linux: ip a
// Windows: ipconfig
// Or use: ipconfig getifaddr en0

// Check SC's listening port
NetAddr.langPort


( // Machine A: Send messages

var partner = NetAddr("192.168.1.100", 57120);
partner.sendMsg("/hello", "Hello from A");
partner.sendMsg("/data", 42, 3.14, "test");

)


( // Machine B: Receive messages

OSCdef(\receiver, {|msg, time, addr, recvPort|
	"Received: %".format(msg).postln;
	"From: % : %".format(addr.ip, recvPort).postln;
}, '/hello');

)


( // Bidirectional communication

var partner = NetAddr("192.168.1.100", 57120);
OSCdef(\chat, {|msg, time, addr|
	postln("Partner: " ++ msg[1]);
	partner.sendMsg("/reply", "Got your message!");
}, '/chat');
partner.sendMsg("/chat", "Hello!");

)


// Debug: trace all OSC
OSCFunc.trace(true);
OSCFunc.trace(false);


/////////////////// Remote Server //////////////////////////////

( // Connect to remote server

var remoteIP = "192.168.1.100";
var remotePort = 57110;
~remote = Server.remote(\remote, NetAddr(remoteIP, remotePort));
~remote.makeWindow;

)


( // Boot remote server

~remote.boot;

)


( // Send SynthDef to remote

SynthDef(\ping, {|freq=440, amp=0.1|
	var sig = SinOsc.ar(freq) * amp;
	var env = EnvGen.ar(Env.perc, doneAction: 2);
	Out.ar(0, sig * env ! 2);
}).add(~remote);

)


( // Play synth on remote

Synth(\ping, [\freq, 660], ~remote);

)


( // Remote with Ndef

Ndef(\sound, {
	SinOsc.ar([400, 401]) * 0.2
}, target: ~remote).play;

)


///////////////// Multiple Servers (Ensemble) //////////////////

( // Create array of remote servers

var ips = ["192.168.1.100", "192.168.1.101", "192.168.1.102"];
~ensemble = ips.collect {|ip, i|
	Server("player" ++ i, NetAddr(ip, 57110))
};

)


( // Make GUIs for all

~ensemble.do {|server| server.makeWindow };

)


( // Send SynthDef to all servers

var sendToAll = {|synthDef|
	~ensemble.do {|server| synthDef.send(server) }
};
sendToAll.value(
	SynthDef(\tone, {|freq=440, amp=0.1|
		var sig = Pulse.ar(freq) * amp;
		Out.ar(0, sig ! 2);
	})
);

)


( // Round-robin synth firing

fork {
	10.do {|i|
		Synth.grain(\tone, [\freq, 200 + (i * 100)], ~ensemble.wrapAt(i));
		0.2.wait;
	};
};

)


( // Pattern-based server selection

fork {
	var pattern = Pseq([0, 1, 2, 1, 2, 0], inf).asStream;
	20.do {|i|
		var serverIdx = pattern.next;
		Synth.grain(\tone, [\freq, rrand(300, 1200)], ~ensemble[serverIdx]);
		0.15.wait;
	};
};

)


( // Random server selection

fork {
	30.do {
		Synth.grain(\tone, [\freq, rrand(400, 2000)], ~ensemble.choose);
		rrand(0.05, 0.2).wait;
	};
};

)


/////////////// Audio Analysis over OSC ////////////////////////

( // Machine A: Analyze and send

Ndef(\source, {|amp=0.3|
	Pulse.ar([200, 201]) * amp
}).play;
Ndef(\analyzer, {
	var sig = Ndef(\source).ar;
	var rms = RMS.ar(sig);
	var pitch = Pitch.kr(sig);
	var centroid = SpecCentroid.kr(sig);
	SendReply.kr(Impulse.kr(10), '/analysis', [rms, pitch[0], centroid]);
	0;
});
var partner = NetAddr("192.168.1.100", 57120);
OSCdef(\sendAnalysis, {|msg|
	var rms = msg[3];
	var pitch = msg[4];
	var centroid = msg[5];
	partner.sendMsg("/audio", rms, pitch, centroid);
}, '/analysis');

)


( // Machine B: Receive and visualize

OSCdef(\receiveAnalysis, {|msg|
	var rms = msg[1];
	var pitch = msg[2];
	var centroid = msg[3];
	postln("RMS: % Pitch: % Hz Centroid: % Hz".format(
		rms.round(0.001),
		pitch.round(1),
		centroid.round(1)
	));
}, '/audio');

)


//////////// Conditional Triggers from Analysis ////////////////

( // Receive audio data and trigger events

var partner = NetAddr("192.168.1.100", 57120);
OSCdef(\triggers, {|msg|
	var rms = msg[1];
	if(rms.inRange(0.1, 0.2), {
		postln("→ Low intensity");
		{
			SinOsc.ar(200) * EnvGen.ar(Env.perc, doneAction: 2) * 0.2 ! 2
		}.play;
	});
	if(rms.inRange(0.4, 0.6), {
		postln("→ Mid intensity");
		{
			Saw.ar(400) * EnvGen.ar(Env.perc, doneAction: 2) * 0.2 ! 2
		}.play;
	});
	if(rms > 0.8, {
		postln("→ High intensity");
		{
			WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.1), doneAction: 2) * 0.3 ! 2
		}.play;
	});
}, '/audio');

)


/////////////// Control Partner's Parameters ///////////////////

( // Machine A: Control Ndef

Ndef(\synth, {|freq=440, ffreq=1000|
	var sig = Saw.ar(freq);
	sig = RLPF.ar(sig, ffreq, 0.3);
	sig * 0.2 ! 2;
}).play;
OSCdef(\control, {|msg|
	Ndef(\synth).set(\freq, msg[1], \ffreq, msg[2]);
	postln("Set freq: % ffreq: %".format(msg[1], msg[2]));
}, '/control');

)


( // Machine B: Send control data

var partner = NetAddr("192.168.1.100", 57120);
fork {
	inf.do {
		var freq = rrand(200, 800);
		var ffreq = rrand(500, 5000);
		partner.sendMsg("/control", freq, ffreq);
		rrand(0.5, 2.0).wait;
	};
};

)


///////////////// Clock Synchronization ////////////////////////

( // Shared TempoClock over network

var partner = NetAddr("192.168.1.100", 57120);
var tempo = 120/60;
var clock = TempoClock(tempo);
OSCdef(\tempoSync, {|msg|
	var newTempo = msg[1];
	clock.tempo = newTempo;
	postln("Tempo synced to: " ++ (newTempo * 60) ++ " BPM");
}, '/tempo');
Pbind(
	\degree, Pseq([0, 2, 4, 5], inf),
	\dur, 0.5
).play(clock);
partner.sendMsg("/tempo", tempo);

)


( // Broadcast tempo changes

var partner = NetAddr("192.168.1.100", 57120);
var clock = TempoClock(120/60);
~changeTempo = {|bpm|
	var tempo = bpm / 60;
	clock.tempo = tempo;
	partner.sendMsg("/tempo", tempo);
	postln("Broadcast tempo: " ++ bpm ++ " BPM");
};

)

// Change tempo
~changeTempo.(90);
~changeTempo.(140);


( // ProxySpace tempo sync

p = ProxySpace.push(s.boot);
p.makeTempoClock(120/60);
var partner = NetAddr("192.168.1.100", 57120);
OSCdef(\proxyTempo, {|msg|
	p.clock.tempo = msg[1];
	postln("ProxySpace tempo: " ++ (msg[1] * 60) ++ " BPM");
}, '/tempo');
~sound = {
	Ringz.ar(Impulse.ar(~tempo.kr), 600, 0.1) ! 2
};
~sound.play;

)


/////////////// Distributed Patterns ///////////////////////////

( // Send pattern events over OSC

var partner = NetAddr("192.168.1.100", 57120);
Pbind(
	\type, \osc,
	\addr, partner,
	\path, '/note',
	\freq, Pseq([400, 500, 600], inf),
	\dur, 0.25
).play;

)


( // Receive and play pattern events

OSCdef(\playNote, {|msg|
	var freq = msg[1];
	{
		SinOsc.ar(freq) * EnvGen.ar(Env.perc, doneAction: 2) * 0.2 ! 2
	}.play;
}, '/note');

)


( // Coordinate pattern start

var partner = NetAddr("192.168.1.100", 57120);
OSCdef(\startPattern, {|msg|
	Pbind(
		\degree, Pseq([0, 2, 4, 7], inf),
		\dur, 0.5
	).play;
	postln("Pattern started!");
}, '/start');
partner.sendMsg("/start");

)


///////////////// Shared State Management //////////////////////

( // Broadcast state changes

var partners = [
	NetAddr("192.168.1.100", 57120),
	NetAddr("192.168.1.101", 57120)
];
~broadcast = {|path, val|
	partners.do {|partner|
		partner.sendMsg(path, val);
	};
	postln("Broadcast: % = %".format(path, val));
};

)

// Broadcast changes
~broadcast.("/section", 2);
~broadcast.("/intensity", 0.7);


( // Receive state updates

var state = (section: 1, intensity: 0.5);
OSCdef(\stateSection, {|msg|
	state.section = msg[1];
	postln("Section changed to: " ++ state.section);
}, '/section');
OSCdef(\stateIntensity, {|msg|
	state.intensity = msg[1];
	postln("Intensity changed to: " ++ state.intensity);
}, '/intensity');

)


/////////////// Machine Listening Network //////////////////////

( // Complete system: analyze + send + receive + respond

var partner = NetAddr("192.168.1.100", 57120);
SynthDef(\analyzer, {
	var in = SoundIn.ar(0);
	var onset = Onsets.kr(FFT(LocalBuf(512), in));
	var rms = RMS.ar(in);
	var pitch = Pitch.kr(in);
	SendReply.kr(Impulse.kr(10), '/local', [rms, pitch[0]]);
	SendReply.kr(onset, '/onset', [1]);
}).add;
s.sync;
~analyzer = Synth(\analyzer);
OSCdef(\sendLocal, {|msg|
	partner.sendMsg("/remote", msg[3], msg[4]);
}, '/local');
OSCdef(\receiveRemote, {|msg|
	var rms = msg[1];
	var pitch = msg[2];
	Ndef(\response).set(\freq, pitch, \amp, rms);
}, '/remote');
Ndef(\response, {|freq=440, amp=0.1|
	Resonz.ar(WhiteNoise.ar, freq, 0.01) * amp ! 2;
}).play;

)


//////////// Synchronized Performance Sections /////////////////

( // Coordinator sends section cues

var ensemble = [
	NetAddr("192.168.1.100", 57120),
	NetAddr("192.168.1.101", 57120),
	NetAddr("192.168.1.102", 57120)
];
~cueSection = {|sectionNum, duration=nil|
	ensemble.do {|addr|
		addr.sendMsg("/section", sectionNum, duration ? 0);
	};
	postln("→ Section % (dur: %)".format(sectionNum, duration));
};

)


( // Performers respond to section cues

OSCdef(\sectionCue, {|msg|
	var section = msg[1];
	var duration = msg[2];
	postln("Received section cue: %".format(section));
	switch(section,
		1, {
			Ndef(\part).fadeTime = 2;
			Ndef(\part, {
				SinOsc.ar([200, 201]) * 0.2
			}).play;
		},
		2, {
			Ndef(\part).fadeTime = 2;
			Ndef(\part, {
				Pulse.ar([400, 403]) * 0.2
			});
		},
		3, {
			Ndef(\part).fadeTime = 4;
			Ndef(\part, {
				WhiteNoise.ar * 0.1
			});
		},
		4, {
			Ndef(\part).stop(4);
		}
	);
	if(duration > 0, {
		SystemClock.sched(duration, {
			~cueSection.(section + 1);
		});
	});
}, '/section');

)

// Trigger sections
~cueSection.(1, 10);
~cueSection.(2, 8);
~cueSection.(3, 12);
~cueSection.(4);
