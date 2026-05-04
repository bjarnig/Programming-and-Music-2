////////////////////////////////////////////////////////////////
//
//                       Network
//
////////////////////////////////////////////////////////////////


///////////////// Messages  /////////////////

// Obtain IP addresses

// ifconfig   # or use `ip a` on Linux to get the IP Address
// ipconfig getifaddr en0


// MACHINE B

(

OSCdef(\recvMsg, { |msg, time, addr, recvPort|
    "Received message: % from %".format(msg, addr).postln;
}, '/test'); // Listening to messages with address `/test`

)

NetAddr.langPort; // To check what port SC is listening on (usually 57120)



// MACHINE A

// Replace with Machine B's IP and chosen port
n = NetAddr("192.168.1.42", 57120); // or 9000 if B is listening on that

// Send a test message
n.sendMsg("/test", "Hello from A!");

NetAddr.langPort




///////////////// Server Control  /////////////////



///// On Client Machine /////

(

var serverIP = "10.9.76.23"; // CHANGE THIS to your server's actual IP
var serverPort = 57110;

// Test if we can reach the server first
n = NetAddr(serverIP, serverPort);
n.sendMsg("/status"); // try to send a status request

// Create remote server connection
o = ServerOptions.new;
o.maxLogins = 4;
t = Server.remote(\remote, NetAddr(serverIP, serverPort), o);

fork {
    "Attempting to connect to remote server...".postln;
    1.wait;

    // Try to get server status
    t.serverRunning.postln;
    t.notify; // register for notifications
    1.wait;

    "Connection successful!".postln;
};

)

x = { Saw.ar(60,0.1) }.play(target:t)


///// On SERVER Machine /////

(

s.quit;

s.options.bindAddress = "0.0.0.0"; // allow connections from any address
s.options.maxLogins = 4; // allow multiple clients (increase if needed)

s.waitForBoot({
    "Server is ready and listening on port 57110".postln;
    s.addr.postln; // print the address
});

)

