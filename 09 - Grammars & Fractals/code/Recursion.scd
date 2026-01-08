////////////////////////////////////////////////////////////////
//
//                       Recursion
//
////////////////////////////////////////////////////////////////


Functions that call themselves, try/catch, advanced language
topics plus routines and tasks.


/////////////////////////// Recursion //////////////////////////


// Prints to 100, calls iteself and increments
r = {|n| if(n > 100, { "done" }, { n.postln; r.value(n + 1) })}
r.(1)


// Sum numbers in a list
~sum = {|list|

	if(list.size == 1, {
		list[0];
	}, {
		list[0] + ~sum.value(list.copyToEnd(1) )
	})
}

// TRACE:
// 2 + recursive call
//     4 + recursive call
//           return 8 (base case)
//     4 + 8
// 2 + 12
// 14



// Factorial (the product of all integers less than or equal to n)
f = { |x| if(x <= 1) { 1 } { x * f.value(x - 1) } };

f.value(4)


// TRACE:
// 4 * recursive call (3)
//     3 * recursive call (2)
//         2 * recursive call (1)
//             return 1
//         2 * 1
//     3 * 2
// 4 * 6




// Reverse a string
r = {|str| if(str.size < 1, { str }, { r.(str.copyToEnd(1)) ++ str[0]}) }
r.value("ram")

"ram".copyToEnd(1)

// TRACE:
// recursive call ("am") + "r"
//     recursive call ("m") + "a"
//         recursive call ("") + "m"
//             ""
//         "" + "m"
//      "m" + "a"
//  "ma" + r




// The fibonacci sequence, 0, 1, 1, 2, 3, 5, 8, 13, 21 ..
b = { |x| if(x < 2) { x } { b.(x-1) + b.(x-2) }};
b.value(8)

// TRACE:
// recursive call (7) + recursive call (6)
//        recursive call (5) + recursive call (4)
//            recursive call (3) + recursive call (2)
//                recursive call (1) + recursive call (0)
//                    1 + 0
//                1 + 2
//            3 + 5
//        8 + 13
//  21
