
channelForThresholding = 2;
title = getTitle();

getDimensions(width, height, channels, slices, frames);
run("Hyperstack to Stack");

run("Restore Selection");
run("Straighten...", "title=Straightened line=150 process");

run("Stack to Hyperstack...", "order=xyczt(default) channels=channels slices=slices frames=frames display=Color");

Stack.setChannel(channelForThresholding);
run("Duplicate...", "duplicate channels=2 frames=1");
run("Gaussian Blur...", "sigma=10");
setAutoThreshold("Yen dark");
run("Convert to Mask");

run("Fill Holes");
run("Create Selection");


	// Check number of ROIs, if nROI > 1, send error message
	roiManager("reset");
	run("Analyze Particles...", "size=0-Infinity add");
	nROIs = roiManager("count");

	if (nROIs != 1) {
        Dialog.create("ERROR");
        Dialog.addMessage("Number of ROI is more than one!");
        Dialog.show();
	}

	//Fit ellipse and measure
	run("Set Measurements...", "centroid fit");
	run("Clear Results");
	run("Measure");


	selectWindow("Straightened");

xCoordinate = getResult("X", 0);
yCoordinate = getResult("Y", 0);
makePoint(xCoordinate, yCoordinate, "xxl yellow hybrid");



makeLine(xCoordinate+50, 1, xCoordinate+50, 149, 30);


makeLine(xCoordinate+300, 1, xCoordinate+300, 149, 30);

run("Plot Profile");

