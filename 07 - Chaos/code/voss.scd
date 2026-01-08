(

var array = Array.rand(3,1,10);

10.do {|i|

	array.do {|item, n|
		if(i % 2.pow(n) == 0, { array[n] = 10.rand });
	};

	array.postcs;
	array.sum.postln;
}

)