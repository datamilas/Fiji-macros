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

pixelSize = 0.1625;  //in microns
useOnlyFirstFrame = true;

savingDirectory = getDir("Choose directory for SAVING");

gausBlurSigma = 100;
channelForThresholding = 2;
frameForThresholding = 1;

colors = newArray("Green", "Magenta", "Grays");

title = getTitle();	

originalDirectory = getDirectory("image");
if(originalDirectory.length>0){
	getNewTitle();
	title = getTitle();	
}

if (useOnlyFirstFrame){
	onlyFirstFrame();
}

run("Set Scale...", "distance=0 known=0 unit=pixel");
getDimensions(width, height, channels, slices, frames);

//remove last frame if it is black
if (frames>1) {
	Stack.setFrame(frames);
	run("Set Measurements...", "mean");
	run("Measure");
	meanValue = getResult("Mean", 0);

	if (meanValue==0) {
		run ("Delete Slice", "delete=frame");
	}

	Stack.setFrame(1);
}


for (i=0; i<channels; i++){
	Stack.setChannel(i+1);
	run("Enhance Contrast", "saturated=0.35");
	run(colors[i]);
}



thresholdAndFitEllipse(channelForThresholding, frameForThresholding, gausBlurSigma);
extractResultsAndCalculateVertex();

ellipseAngle = getResult("Angle", 0);
vertexXFirst = getResult("vertexXFirst", 0);
vertexYFirst = getResult("vertexYFirst", 0);

vertexXSecond = getResult("vertexXSecond", 0);
vertexYSecond = getResult("vertexYSecond", 0);


//If these coordinates are inside the image, rotate by ellipseAngle, if they are not, rotate by angle+180
if (vertexXFirst < 0 || vertexXFirst > width || vertexYFirst < 0 || vertexYFirst > width
 || vertexXSecond < 0 || vertexXSecond > width || vertexYSecond < 0 || vertexYSecond > width
){
	vertexX=vertexXFirst;
	vertexY=vertexYFirst;
	//If these coordinates are inside the image, rotate by ellipseAngle, if they are not, rotate by angle+180
if (vertexX > 0 && vertexX < width && vertexY > 0 && vertexY < width) {
        angleToRotate = ellipseAngle;
} else {
        angleToRotate = ellipseAngle + 180;
}
	}
	
else {
	  makePoint(vertexXFirst, vertexYFirst, "xxl yellow hybrid");
	  
	  Dialog.create("Warning");
      Dialog.addMessage("Both vertexes are inside the image, is the right vertex selected?");
	  Dialog.addCheckbox("Yes", true);
      Dialog.show();
      
      vertexChoice = Dialog.getCheckbox();
      run("Select None");
      
      if (vertexChoice){
	angleToRotate = ellipseAngle;
} else {
	angleToRotate = ellipseAngle + 180;
}

}






//Rotate original image
selectWindow(title);
run("Duplicate...", "duplicate");
rename("Rotated");
run("Rotate... ", "angle=angleToRotate grid=1 interpolation=Bilinear");


//Re-Threshold rotated image to get new position of vertex and draw rectangle around posterior tip
thresholdAndFitEllipse(channelForThresholding, frameForThresholding, gausBlurSigma);

extractResultsAndCalculateVertex();

vertexXFirst = getResult("vertexXFirst", 0);
vertexYFirst = getResult("vertexYFirst", 0);
vertexXSecond = getResult("vertexXSecond", 0);
vertexYSecond = getResult("vertexYSecond", 0);

if (vertexXFirst > vertexXSecond) {
	vertexX = vertexXFirst;
	vertexY = vertexYFirst;
} else {
	vertexX = vertexXSecond;
	vertexY = vertexYSecond;	
}

majorAxisLength = getResult("Major", 0);

if (vertexX < 0){
	vertexX = vertexX + majorAxisLength;
}

selectImage("Rotated");
if ((vertexX + 200) < width){
	makeRectangle(vertexX-400, vertexY-500, 600, 1000);
} else {
	makeRectangle(vertexX-(600-(width-vertexX)), vertexY-500, 600, 1000);
}



run("Duplicate...", "duplicate");
splitChannelsAndCombine();
rename("posterior");


minorAxisLength = getResult("Minor", 0);

selectImage("Rotated");
getDimensions(width, height, channels, slices, frames);
makeRectangle(0, vertexY-minorAxisLength/2-200, width, minorAxisLength+400);
run("Duplicate...", "title=wholeOocyte duplicate");

getDimensions(width, height, channels, slices, frames);
if (height<(minorAxisLength+400)){
	scaleFactor = height/1000;
} else {
	scaleFactor = ((minorAxisLength+400) / 1000);
}


Stack.setActiveChannels("110");
run("RGB Color", "frames");
rename("wholeOocyte (RGB)");

distance = 1/pixelSize;
fontSize=70*scaleFactor;
scaleBarHeight = 12*scaleFactor;
run("Set Scale...", "distance=" + distance +" known=1 unit=micron");
run("Scale Bar...", "width=20 height=" + scaleBarHeight + " font=" + fontSize + " color=White background=None location=[Lower Right] label");


selectImage("posterior");
run("Scale...", "x=" + scaleFactor + " y=" + scaleFactor + " interpolation=None process create");


run("Combine...", "stack1=[wholeOocyte (RGB)] stack2=posterior-1");

newTitle = "combined_" + title;
rename(newTitle);
saveAs("Tiff",  savingDirectory + newTitle);

selectImage(title);
saveAs("Tiff",  savingDirectory + title);


close("wholeOocyte");
close("posterior");
close("Rotated");
//close(title);





/***********Define functions here ************/



function thresholdAndFitEllipse(channelForThresholding, frameForThresholding, gausBlurSigma) {

	//Duplicate the specified channel and frame of the image and convert to 16 bit	
	run("Duplicate...", "title=Duplicated duplicate channels=channelForThresholding frames=frameForThresholding");
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


	// Check number of ROIs, if nROI > 1, send error message
	roiManager("reset");
	run("Analyze Particles...", "size=0-Infinity add");
	nROIs = roiManager("count");

	if (nROIs != 1) {
        Dialog.create("ERROR");
        Dialog.addMessage("Number of ROI is more than one, first roi will be used!");
        Dialog.show();
        roiManager("Select", 0);
	}

	//Fit ellipse and measure
	run("Set Measurements...", "centroid fit");
	run("Clear Results");
	run("Measure");
	
	close("Thresholded");
	close("Duplicated");
}



function extractResultsAndCalculateVertex(){
	
	//Extract results
	ellipseAngle = getResult('Angle', 0);
	majorAxisLength = getResult('Major', 0);
	centerX = getResult('X', 0);
	centerY = getResult('Y', 0);

	//Get X and Y coordinates of vertex:
	vertexXFirst = majorAxisLength / 2 * cos(ellipseAngle * PI / 180) + centerX;
	vertexYFirst = centerY - majorAxisLength / 2 * sin(ellipseAngle * PI / 180);

	vertexXSecond = centerX - majorAxisLength / 2 * cos(ellipseAngle * PI / 180);
	vertexYSecond = centerY + majorAxisLength / 2 * sin(ellipseAngle * PI / 180);

	setResult("vertexXFirst", 0, vertexXFirst);
	setResult("vertexYFirst", 0, vertexYFirst);

	setResult("vertexXSecond", 0, vertexXSecond);
	setResult("vertexYSecond", 0, vertexYSecond);

}




//function to split all channels and than combine them horizontally
function splitChannelsAndCombine() {
	name=getTitle;
	getDimensions(width, height, channels, slices, frames);

	distance = 1/pixelSize;
	run("Set Scale...", "distance=" + distance + " known=1 unit=micron");
	
	run("Split Channels");

	
	initialOpenImages = getList("image.titles");
	openImages = getList("image.titles");
	
	while ( openImages.length > (initialOpenImages.length-channels+1) ){
		
		firstImageIndex = initialOpenImages.length-channels;
		secondImageIndex = firstImageIndex + 1;		
		selectWindow(openImages[ firstImageIndex ]);
		run("RGB Color", "frames");
		selectWindow(openImages[ secondImageIndex ]);
		run("RGB Color", "frames");
			
		if (openImages.length == initialOpenImages.length){
			run("Combine...", "stack1=["+openImages[ firstImageIndex ]+"] stack2=["+openImages[ secondImageIndex ]+"]");
		} else {
			run("Combine...", "stack1=["+openImages[ secondImageIndex ]+"] stack2=["+openImages[ firstImageIndex ]+"]");
		}
		
		openImages = getList("image.titles");
	}

	rename(name+ "_combined" );
	run("Scale Bar...", "width=20 height=12 font=70 color=White background=None location=[Lower Right] label");

}





//use only First frame
function onlyFirstFrame() { 
	getDimensions(width, height, channels, slices, frames);
	if (frames>1){
		name=getTitle();
		run("Duplicate...", "title=Duplicated use");
		close(name);
		selectWindow("Duplicated");
		rename(name);
	}
}



//*******Get new title from original directory and original name*****///7

function getNewTitle(){

	dateIndex = indexOf(originalDirectory, "Ana\\")+4;
	date=substring(originalDirectory, dateIndex, dateIndex+8);

	underScoreIndex = indexOf(originalDirectory, "_");
	folderTitle=substring(originalDirectory, dateIndex+9, underScoreIndex);

	newTitle = date + "_" + folderTitle + "_"  + "_" + getTitle();
	rename(newTitle);
}



