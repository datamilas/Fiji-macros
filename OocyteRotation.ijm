
/*
Rotating oocytes

Ana Milas
10/09/20


Notes:

For ZYLA videos

Macro was developed to work on Jupiter signal, but should work for all reporters that have signal in both nurse cells and oocyte
(Does not work well with Baz-mcherry signal)

Macro fits ellipse on thresholded image and rotates by angle between ellipse and x-axis.
For everything to work properly, the vertexes of the fitted ellipse should be outside of image
If this is not the case, the image will still be rotated, but anterior-posterior axis could be flipped
 */

gausBlurSigma=50;

channelForThresholding = 1;

frameForThresholding = 1;

//Duplicate the specified channel and frame of the image and convert to 16 bit	
title = getTitle();
getDimensions(width, height, channels, slices, frames);

run("Duplicate...", "title=test duplicate channels=channelForThresholding frames=frameForThresholding")
run("Duplicate...", "duplicate");
rename("Thresholded");
run("16-bit");

//Threshold
run("Gaussian Blur...", "sigma=gausBlurSigma");; 
setAutoThreshold("Li");	
run("Convert to Mask");
run("Invert");
run("Fill Holes");
run("Create Selection");


//Get dimensions of the image and reset ROI manager	
roiManager("reset");
run("Analyze Particles...", "size=0-Infinity add");

// Check number of ROIs, if nROI > 1, send error message
nROIs = roiManager("count");
	
if(nROIs!=1){
	Dialog.create("ERROR");
	Dialog.addMessage("Number of ROI is more than one!");
	Dialog.show();
}
	
	
//Fit ellipse and measure
run("Set Measurements...", "centroid fit");
run("Clear Results");
run("Measure");
close("Thresholded");

//Extract results
ellipseAngle = getResult('Angle',0);
majorAxisLength = getResult('Major',0);
centerX = getResult('X',0);
centerY = getResult('Y',0);

//Get X and Y coordinates of vertex:
vertexX = majorAxisLength/2 * cos(ellipseAngle*PI/180)+centerX;
vertexY = centerY-majorAxisLength/2 * sin(ellipseAngle*PI/180);

//If these coordinates are inside the image, rotate by ellipseAngle, if they are not, rotate by angle+180
 if(vertexX>0 && vertexX<width && vertexY>0 && vertexY<width){
 	angleToRotate = ellipseAngle;
 } else {
 	angleToRotate = ellipseAngle+180;
 }
 

selectWindow(title);
run("Duplicate...", "duplicate");
rename("Rotated");
run("Rotate... ", "angle=angleToRotate grid=1 interpolation=Bilinear");
	









