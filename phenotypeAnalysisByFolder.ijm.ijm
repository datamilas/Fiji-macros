# @ String(label = "Analyst name", description = "Your Name") analystName
# @ String(label = "Date of ANALYSIS", description = "Date in YYYYMMDD form") analysisDate
# @ String(label = "Date of EXPERIMENT", description = "Date in YYYYMMDD form") date
# @ String(label = "Fly Line", choices = ("w; sqh>UTR::GFP/+; GR1>GAL4/+", "w; sqh>UTR::GFP/+ ; GR1>GAL4/UAS>hop-RNAi", "w; UASp>Bazooka::mGFP/mata4-GAL4; Jupiter::mCherry/Jupiter::mCherry", "w; UASp>GFP::PAR1(N1S)/mata4-GAL4; Jupiter::mCherry/Jupiter::mCherry", "w; UASp>Bazooka::mCherry/mata4-GAL4; sqh>UTR::GFP/+"), style = "list") defaultFlyLine
# @ Double(label = "Temperature of the cross", value = 25) defaultTemperature
# @ String(label = "Reporter for the Gap", choices = ("Jupiter", "UTR", "Tubulin", "NA"), style = "radioButtonHorizontal", value = "NA") gapMarker
# @ String(label = "Camera", choices = ("ZYLA", "iXON"), value="ZYLA", style = "radioButtonHorizontal") defaultCamera
# @ String(label = "Objective", choices = ("40X WI", "10X", "60X oil"), value="40X WI", style = "radioButtonHorizontal") defaultObjective
# @ File(label = "File with results", style = "open") inputFile
# @ File(label = "Choose a Directory to process", style = "directory") dir
# @ Boolean (label = "Rewrite Image with Composite Image", value = true) saving

/*	Author: Ana Milas
 * 	Date: 20201015
 * 	
 * "By folder" analysis of phenotype.
 * 
 * Usage:
 * 1) Run the script
 * 2) In File with results field, specify the path to the .csv file with pooled results
 * 3) In "Choose a Directory to process" specify the path to the master folder containing folders with images to be analysed (these subfolders should come directly from the microscope and contain images and .txt file with imaging info)
 * 4) Fill in remaining info
 * 
 */



flyLines = newArray("w; sqh>UTR::GFP/+; GR1>GAL4/+", "w; sqh>UTR::GFP/+ ; GR1>GAL4/UAS>hop-RNAi", "w; UASp>Bazooka::mGFP/mata4-GAL4; Jupiter::mCherry/Jupiter::mCherry", "w; UASp>GFP::PAR1(N1S)/mata4-GAL4; Jupiter::mCherry/Jupiter::mCherry", "w; UASp>Bazooka::mCherry/mata4-GAL4; sqh>UTR::GFP/+");
commentBoxSize = 50;

// close all images
close("*");
// empty the results table
run("Clear Results");


open(inputFile);
nPreviousResults = nResults;


//Get list of folders 
folders_list = getFileList(dir);


//Go through all the f folders
for (f = 0; f < folders_list.length; f++) {
	list = getFileList(dir + "\\" + folders_list[f]);
	subDir = dir + "\\" + folders_list[f];

	//Open all files in f_th folder with suffix .tif
	for (sf = 0; sf < list.length; sf++) {

		path = dir + "\\" + folders_list[f] + "\\" + list[sf];


		if (endsWith(list[sf], ".txt")) {
			txtTitle = substring(list[sf], 0, indexOf(list[sf], "."));
			pathfile = path;
			filestring = File.openAsString(pathfile);
			rows = split(filestring, "\n");
			previousPositionRow = 0;
			imageIndex = 1;

			for (i = 0; i < rows.length; i++) {


				if (indexOf(rows[i], "Repeat T") > -1) {
					columns = split(rows[i], "-");
					timeInfo = columns[1];
					timePoints = substring(timeInfo, 1, indexOf(timeInfo, "time"));
					timeInterval = substring(timeInfo, indexOf(timeInfo, "(") + 1, indexOf(timeInfo, ")"));
				}

				if (indexOf(rows[i], "Repeat Z") > -1) {
					channelIndex = 1;


					imageID = date + "_" + txtTitle + "_Oocyte" + imageIndex;
	
					//check if the image with same ID already exists:
					answer = 1;
					newRow = nResults;
					for (image = 0; image < nPreviousResults; image++) {
						if (imageID == getResultString("ImageID", image)) {
							answer = getBoolean("Image " + imageID + " is already in the results, do you want to reanalize it?");
							newRow = image;
						}
					}

					if (answer == 1) {
						imagePath = subDir + list[imageIndex];

						run("Bio-Formats Importer", "open=[" + imagePath + "] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
						imageTitle = getTitle();
						
						Dialog.create("Imaging Conditions");
						Dialog.addMessage("Imaging Conditions", 15);
						Dialog.addChoice("Camera: ", newArray("ZYLA", "iXON"), defaultCamera);
						Dialog.addToSameRow();
						Dialog.setInsets(0, 0, 0);
						Dialog.addChoice("Objective: ", newArray("40X WI", "10X", "60X oil"), defaultObjective);
						Dialog.addToSameRow();
						Dialog.addString("Time Interval:", timeInterval);
						Dialog.addToSameRow();
						Dialog.addNumber("# of Timepoints", timePoints);
						getPixelSize(unit, pw, ph, pd);
						Dialog.addMessage("Image Properties", 15);
						Dialog.addMessage("pixel size for 40x obective is 0.1625um", 12, "gray");
						Dialog.addNumber("Pixel size (um):", pw);
						Dialog.addToSameRow();
						Dialog.addNumber("Voxel Depth (um):", pd);




						for (j = previousPositionRow; j < i; j++) {

							if ((indexOf(rows[j], "Channel -") > -1) & (indexOf(rows[j], "Move Channel -") == -1)) {


								k = j + 1;
								while ((k < rows.length - 1) & (indexOf(rows[k], "Channel -") == -1)) {
									if (indexOf(rows[k], "Camera EM Gain") > -1) {
										columns = split(rows[k], "-");
										Dialog.addMessage("Channel " + channelIndex, 15);

										Dialog.addNumber("EM Gain:", parseFloat(columns[1]));
									}
									if (indexOf(rows[k], "Camera Exposure Time") > -1) {
										columns = split(rows[k], "-");
										Dialog.addToSameRow();
										Dialog.addNumber("Exposure (s):", parseFloat(columns[1]));
									}


									if (indexOf(rows[k], "AOTF Channel") > -1) {
										columns = split(rows[k], "-");

										if ((columns[1] != " ") & (columns[1] != " Current")) {
											laserPower = parseFloat(columns[1]);
										}

									}

									if (indexOf(rows[k], "AOTF Position") > -1) {
										columns = split(rows[k], "-");
										channelID = parseInt(columns[1]);
										Stack.setChannel(channelIndex)
										run("Enhance Contrast", "saturated=0.35");
										run(colorCode(channelID));

										Dialog.addToSameRow();
										Dialog.addNumber("Wavelength:", channelID);

										Dialog.addToSameRow();

										if (channelID != 0) {
											Dialog.addNumber("LP(%):", laserPower);
										} else {
											Dialog.addNumber("LP(%):", 0);
										}

										channelIndex += 1;
									}

									k = k + 1;

								}

							}

						}




						Stack.setDisplayMode("composite");
						Dialog.show();


						camera = Dialog.getChoice();
						objective = Dialog.getChoice();
						timeIntervalFinal = Dialog.getString();
						timePointsFinal = Dialog.getNumber();
						pixelSize = Dialog.getNumber();
						voxelSize = Dialog.getNumber();

						for (ch = 1; ch < channelIndex; ch++) {
							EMGain = Dialog.getNumber();
							Exposure = Dialog.getNumber();
							Wavelength = Dialog.getNumber();
							LP = Dialog.getNumber();

							setResult("Wavelength_Ch" + ch, newRow, Wavelength);
							setResult("LP_Ch" + ch, newRow, LP);
							setResult("Exposure(s)_Ch" + ch, newRow, Exposure);
							setResult("EMGain_Ch" + ch, newRow, EMGain);

						}

						phenotypeDialog("Oocyte Phenotype", flyLines, defaultFlyLine, defaultTemperature, commentBoxSize, gapMarker);



						genotype = Dialog.getChoice();
						temperature = Dialog.getNumber();
						stage = Dialog.getChoice();
						stageComment = Dialog.getString();

						nucleus = Dialog.getRadioButton();
						nucleusComment = Dialog.getString();

						gapStatus = Dialog.getRadioButton();
						gapMarker = Dialog.getRadioButton();
						gapComment = Dialog.getString();

						bazooka = Dialog.getRadioButton();
						bazookaComment = Dialog.getString();

						par1 = Dialog.getRadioButton();
						par1Comment = Dialog.getString();


						setResult("ImageID", newRow, imageID);
						setResult("Genotype", newRow, genotype);

						setResult("Temperature", newRow, temperature);

						setResult("Stage", newRow, stage);
						setResult("StageComment", newRow, stageComment);

						setResult("Nucleus", newRow, nucleus);
						setResult("NucleusComment", newRow, nucleusComment);

						setResult("GapStatus", newRow, gapStatus);
						setResult("GapMarker", newRow, gapMarker);
						setResult("GapComment", newRow, gapComment);

						setResult("BazookaExclusion", newRow, bazooka);
						setResult("BazookaComment", newRow, bazookaComment);

						setResult("Par1atPosterior", newRow, par1);
						setResult("Par1Comment", newRow, par1Comment);

						setResult("Camera", newRow, camera);
						setResult("Objective", newRow, objective);
						setResult("TimeInterval", newRow, timeIntervalFinal);
						setResult("Timepoints", newRow, timePointsFinal);
						setResult("PixelSize", newRow, pixelSize);
						setResult("VoxelSize", newRow, voxelSize);




						setResult("AnalystName", newRow, analystName);
						setResult("AnalysisDate", newRow, analysisDate);

						updateResults();

						selectWindow(imageTitle);
						Stack.setDisplayMode("composite");
						if (saving) {
							save(imagePath);
						}
						run("Close");
						
					}


					previousPositionRow = i;
					imageIndex += 1;

				}
			}


		}

	}

	selectWindow("Results");
	saveAs("Results", inputFile);


}




// Define functions here //

function phenotypeDialog(title, flyLines, defaultFlyLine, defaultTemperature, commentBoxSize, gapMarker) {

	Dialog.createNonBlocking(title);
	Dialog.addMessage("Fly Line", 15);
	Dialog.addChoice("Genotype: ", flyLines, defaultFlyLine);
	Dialog.addNumber("Temperature of the cross", defaultTemperature);

	Dialog.addMessage("Stage Analysis", 15);
	Dialog.addChoice("Stage:", newArray("9", "10A", "10B", "10AB", "11", "8", "7", "6", "5", "4", "3", "2", "1"));
	Dialog.addString("Comment on stage:", "", commentBoxSize);


	Dialog.addMessage("Position of the nucleus", 15);

	Dialog.addRadioButtonGroup("Nucleus positon:", newArray("OK", "not OK", "not visible"), 1, 4, "OK");
	Dialog.addString("Comment on position of the nucleus:", "", commentBoxSize);


	Dialog.addMessage("Gap at the posterior", 15);
	Dialog.addRadioButtonGroup("Gap at the posterior:", newArray("Yes", "No", "Not clear", "NA"), 1, 4, "NA");
	Dialog.addRadioButtonGroup("Gap Marker:", newArray("Jupiter", "UTR", "Tubulin", "NA"), 1, 3, gapMarker);
	Dialog.addString("Comment on the gap:", "", commentBoxSize);

	Dialog.addMessage("Bazooka localization", 15);
	Dialog.addRadioButtonGroup("Bazooka exclued from the posterior:", newArray("Yes", "No", "Not clear", "NA"), 1, 4, "NA");
	Dialog.addString("Comment on Bazooka localization:", "", commentBoxSize);

	Dialog.addMessage("Par-1 localization", 15);
	Dialog.addRadioButtonGroup("Par-1 at the posterior:", newArray("Yes", "No", "Not clear", "NA"), 1, 4, "NA");
	Dialog.addString("Comment on Par-1 localization:", "", commentBoxSize);

	Dialog.show();


}


function colorCode(wavelength) {
	if (wavelength == 488) {
		return "Green";
	}

	if (wavelength == 561) {
		return "Magenta";
	} else {
		return "Grays";
	}

}