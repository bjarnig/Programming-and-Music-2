////////////////////////////////////////////////////////////////
//
//                        Fractal Tree
//
////////////////////////////////////////////////////////////////

// Drawing example only ...

(

var angles = [
	(-1pi) / 8,
	(1pi) / 8
		];

var drawTree = {|depth, size, angle|
	var y = ((size * -1) / 2);
	Pen.rotate(angle);
	Pen.moveTo(0@0);
	Pen.lineTo(0@y);
	Pen.strokeColor = Color.rand;
	Pen.stroke;
	Pen.translate(0, y);

	if(depth > 0, {
		drawTree.value(depth - 1, size / 2, angles[0]);
		Pen.translate(0, size / 4);
		Pen.rotate(angles[1]);

		drawTree.value(depth - 1, size / 2, angles[1]);
		Pen.translate(0, size / 4);
		Pen.rotate(angles[0]);
	});
};

w = Window.new("Fractal Tree", 800@600).front;
w.view.background_(Color.white);

w.drawFunc = {
	Pen.translate(350, 500);
	drawTree.value(10, 400, 0);
};

w.refresh;

)
