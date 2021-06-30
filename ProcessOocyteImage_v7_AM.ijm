//Lucrezia Ferme and Cecile Carrere
//October 2019 - rotation project in Telley Lab
//Select region of interest using segmented line tool for the frame of interest
//Adjust width in Image>Adjust>Line width and select "spline fit"

//AM: added few changes to adjust for data that I had

//AM: adjusted for measuring two channels (30/11/2020)


//title='20201117_Oocyte7_before'
//title='20201117_Oocyte7_after'
main_title = getDirectory("image");
main_title = main_title.substring(indexOf(main_title, "20"), lengthOf(main_title)-1);
title = main_title+"_before";
//title = main_title+"_after";


dir = getDirectory("Select a directory to save results")


//check if files with specified filename already exist
selection = dir + title + "_ROI.roi";
if (File.exists(selection)){
	answer = getBoolean("Data for "+title+" already exists in this folder, do you want to reanalize it?");
	if (answer == 0){
		run("Fresh Start");
		exit()};
};





run("Set Measurements...", "mean min median redirect=None decimal=3"); //set measurements

//Calculate the median value of the background (cytoplasm of oocyte) to normalize the measurements
Stack.setChannel(1);;
setTool("rectangle");
waitForUser("Square selection", "Draw a rectangle in the cytoplasm of the oocyte. It will be used to normalize the data extracted from the segmented line. Press ok when ready.");
Roi.getBounds(x, y, width, height);
makeRectangle(x, y, width, height);
roiManager("add");
roiManager("measure");

Stack.setChannel(2);
run("Restore Selection");
run("Measure");


bg_median_green = getResultString("Median", 0);
bg_mean_green = getResultString("Mean", 0);

bg_median_red = getResultString("Median", 1);
bg_mean_red = getResultString("Mean", 1);

run("Clear Results");
roiManager("delete");

//Draw a segmented line on the cortex of the oocyte where the signal of interest is
setTool("polyline");
waitForUser("Line selection","Specify a segmented line. Press ok when ready.");
run("Fit Spline");

//Save the selction
saveAs("Selection", dir + title + "_ROI.txt"); //save(dir + File.separator + title + ".txt");





n = getValue("selection.width"); //Get width of the line
if (selectionType!=6) //record all the points the line passes through
     exit("Segmented line required");
  run("Interpolate", "interval=1");
  getSelectionCoordinates(xpoints, ypoints);
  Table.create("Points");
  Table.setColumn("X", xpoints);
  Table.setColumn("Y", ypoints);
  Table.save( dir + title + "_xy.txt");



image_title = getTitle();
run("Split Channels");
C1_title = "C1-" + image_title;
C2_title = "C2-" + image_title;

selectImage(C1_title);
run("Restore Selection");
//Calculate median value for each pixel array along the length of the line
profile = getProfile();
run("Straighten...","line = "+n+" title = myname");
run("Clear Results");
for (i=0; i<profile.length; i++){
	makeRectangle(i, 0, 1, n);
	roiManager("Add");
	}
roiManager("Show All");
roiManager("Measure");
for (roi=0; roi<roiManager("count"); roi++){
	roiManager("select",roi);
	max = getResult("Median", roi);
	median = getResult("Median", roi);
	mean = getResult("Mean", roi);
	headings = split(String.getResultsHeadings);
	line = "";
	for (a=0; a<lengthOf(headings); a++)
    	line = line + getResult(headings[a],roi) + "  ";
		print(line);
	
	setResult("Max_to_bgmean", roi, max/bg_mean_green);
	setResult("Median_to_bgmedian", roi, median/bg_median_green);
	setResult("Mean_to_bgmean", roi, mean/bg_mean_green);
	//setResult("RMean_to_Rbg", roi, mean_Rayleigh/bg_Rayleigh_mean);
	}
updateResults();

//Save results as txt file
saveAs("Results", dir + title + "_green.txt"); //save(dir + File.separator + title + ".txt");

//Close images and clean roi manager and tables
run("Clear Results");
roiManager("delete");






selectImage(C1_title);
selectImage(C2_title);
run("Restore Selection");
//Calculate median value for each pixel array along the length of the line
profile = getProfile();
run("Straighten...","line = "+n+" title = myname");
run("Clear Results");
for (i=0; i<profile.length; i++){
	makeRectangle(i, 0, 1, n);
	roiManager("Add");
	}
roiManager("Show All");
roiManager("Measure");
for (roi=0; roi<roiManager("count"); roi++){
	roiManager("select",roi);
	max = getResult("Median", roi);
	median = getResult("Median", roi);
	mean = getResult("Mean", roi);
	headings = split(String.getResultsHeadings);
	line = "";
	for (a=0; a<lengthOf(headings); a++)
    	line = line + getResult(headings[a],roi) + "  ";
		print(line);
	
	setResult("Max_to_bgmean", roi, max/bg_mean_red);
	setResult("Median_to_bgmedian", roi, median/bg_median_red);
	setResult("Mean_to_bgmean", roi, mean/bg_mean_red);
	//setResult("RMean_to_Rbg", roi, mean_Rayleigh/bg_Rayleigh_mean);
	}
updateResults();

//Save results as txt file
saveAs("Results", dir + title + "_red.txt"); //save(dir + File.separator + title + ".txt");

//Close images and clean roi manager and tables
run("Clear Results");
roiManager("delete");


while (nImages>0) { 
     selectImage(nImages); 
     close();};

