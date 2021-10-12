//Lucrezia Ferme and Cecile Carrere
//October 2019 - rotation project in Telley Lab
//Select region of interest using segmented line tool for the frame of interest
//Adjust width in Image>Adjust>Line width and select "spline fit"

//AM: added few changes to adjust for data that I had



main_title = getDirectory("image");
main_title = main_title.substring(indexOf(main_title, "20"), lengthOf(main_title)-1);

title = main_title+"_before";
//title = main_title+"_after";


dir = getDirectory("Select a directory to save results")
//title = getTitle();	//by default the title of active image with additional suffix is used to save results

//check if files with specified filename already exist
selection = dir + title + "_ROI.roi";
if (File.exists(selection)){
	answer = getBoolean("Data for "+title+" already exists in this folder, do you want to reanalize it?");
	if (answer == 0){
		run("Fresh Start");
		exit()};
};
//Duplicate only first channel

run("Set Scale...", "distance=0 known=0 unit=pixel");
run("Duplicate...", "duplicate channels=1");

print("Image analysed:",title);
if( endsWith(title, ".tif") ){	
   title = replace( title, ".tif", "");	//removes ".tif" from the title; so the title is used with different types (.tif, .txt, ...)
   }

run("Set Measurements...", "mean min median redirect=None decimal=3"); //set measurements

//Calculate the median value of the background (cytoplasm of oocyte) to normalize the measurements
setTool("rectangle");
waitForUser("Square selection", "Draw a rectangle in the cytoplasm of the oocyte. It will be used to normalize the data extracted from the segmented line. Press ok when ready.");
Roi.getBounds(x, y, width, height);
makeRectangle(x, y, width, height);
roiManager("add");
roiManager("measure");
bg_median = getResultString("Median", 0);
bg_mean = getResultString("Mean", 0);

//This part calculates the Rayleigh mean (check with Ivo the formula)
//If you want to use it, uncomment
//sum = 0;
//Roi.getContainedPoints(x,y);
//nb_pt = x.length;
//for (i=0; i<nb_pt; i++) {
//	luminosity=getPixel(x[i],y[i]);
//    n = parseFloat(luminosity);
//    if (isNaN(n))
//        exit("'" + luminosity + "' is not a number");
//    sum =sum +n*n;
//}
//bg_Rayleigh_mean=1.253*sqrt(sum/(2*nb_pt));

run("Clear Results");
roiManager("delete");

//Draw a segmented line on the cortex of the oocyte where the signal of interest is
setTool("polyline");
waitForUser("Line selection","Specify a segmented line. Press ok when ready.");
run("Fit Spline");

//Save the selction
saveAs("Selection", dir + title + "_ROI.txt");



n = getValue("selection.width"); //Get width of the line
if (selectionType!=6) //record all the points the line passes through
     exit("Segmented line required");
  run("Interpolate", "interval=1");
  getSelectionCoordinates(xpoints, ypoints);
  Table.create("Points");
  Table.setColumn("X", xpoints);
  Table.setColumn("Y", ypoints);
  Table.save( dir + title + "_xy.txt");


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
	//This parts calculates the Rayleigh mean, uncomment if you want to have it
	//m = 0; 
	//Roi.getContainedPoints(x,y);
	//nb_pt = x.length;
	//for (i=0; i<nb_pt; i++) {
	//	luminosity=getPixel(x[i],y[i]);
    //	n = parseFloat(luminosity);
    //	if (isNaN(n))
    //    	exit("'" + luminosity + "' is not a number");
    //	m =m +n*n;}
	//mean_Rayleigh=1.253*sqrt(m/(2*nb_pt));
	
	max = getResult("Median", roi);
	median = getResult("Median", roi);
	mean = getResult("Mean", roi);
	headings = split(String.getResultsHeadings);
	line = "";
	for (a=0; a<lengthOf(headings); a++)
    	line = line + getResult(headings[a],roi) + "  ";
		print(line);
	
	setResult("Max_to_bgmean", roi, max/bg_mean);
	setResult("Median_to_bgmedian", roi, median/bg_median);
	setResult("Mean_to_bgmean", roi, mean/bg_mean);
	//setResult("RMean_to_Rbg", roi, mean_Rayleigh/bg_Rayleigh_mean);
	}
updateResults();

//Save results as txt file
saveAs("Results", dir + title + ".txt"); //save(dir + File.separator + title + ".txt");


//Close images and clean roi manager and tables
run("Clear Results");
roiManager("delete");

/*
while (nImages>0) { 
     selectImage(nImages); 
     close();};
*/

//run("Fresh Start");
