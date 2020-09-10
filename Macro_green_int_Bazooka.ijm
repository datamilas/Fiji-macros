/*
 * For each oocyte, there should be a cropped video, with only the channel to measure in,
 * this video should be named DATE_Exp#_color
 * 
 * These videos should be placed in seperated folder, without any other files,
 * path to this folder will be asked for after executing the macro
 * 
 * Videos should be cropped so that mostly posterior compartment is visible.
 * 
 * 
 * If the size of anterior compartment visible is to big, error message will appear.
 * 
 * 
 */

//Specify size of filter applied, shrinkage of the ROI and size od the ROI
enlargement = -12; //-12 means it is shrinking, instead of enlarging
median_fil = 15;
particle_size = 100000; //in pixels
particle_size2 = 50000;

frame_num = 130 //last frame in which to measure

//Specify folders for saving		(all files are saved in the same folders)
dir_XY = "D:\\amilas\\Analysis\\Baz\\macro\\xy_roi\\"
dir_channels = "D:\\amilas\\Analysis\\Baz\\macro\\Intensities\\"


//Get the directory with videos to process
dir = getDirectory("Choose a Directory to PROCESS");


//Get list of files in the directory
files_list = getFileList(dir);


//Go through all the files, increment of the for loop has to be set to 2 

for (p = 0; p < files_list.length; p++) {

        open(dir + files_list[p]); //open green channel video
        run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel"); //set scale to pixels
        title = getTitle(); //get the title of the green channel image


        //Generate beginning of the title for txt files from the original title
        position_ = indexOf(title, "_green");
        new_title = substring(title, 0, position_ + 1);


        //Duplicate the green channel image and convert to 16 bit
        selectWindow(title);
        run("Duplicate...", "duplicate");
        rename("Thresholded");
        run("16-bit");

        /*
        	//Filter and apply Triangle threshold
        	run("Median...", "radius=median_fil stack");
        	setAutoThreshold("Triangle dark");	
          	run("Convert to Mask", "stack");
        	//run("Invert", "stack");
        	run("Fill Holes", "stack");
        */

        run("Median...", "radius=median_fil stack");
        setAutoThreshold("Li dark");
        run("Convert to Mask", "stack");
        run("Invert", "stack");
        run("Fill Holes", "stack");



        //Get dimensions of the image and reset ROI manager	
        getDimensions(width, height, channels, slices, frames);
        roiManager("reset");


        //Go from frame to frame and get ROI

        for (i = 1; i <= frames; i++) {

                selectWindow("Thresholded");
                Stack.setFrame(i)

                run("Analyze Particles...", "size=" + particle_size + "-Infinity add"); //add to ROI-Manager by running analyze particles


        }


        // Check number of ROIs, if nROI > number of frames, send error message
        nROIs = roiManager("count");

        if (nROIs < frames) {
                roiManager("reset");
                for (i = 1; i <= frames; i++) {

                        selectWindow("Thresholded");
                        Stack.setFrame(i)

                        run("Analyze Particles...", "size=" + particle_size2 + "-Infinity add"); //add to ROI-Manager by running analyze particles
                }
        }


        nROIs = roiManager("count");

        if (nROIs != frames) {
                Dialog.create("ERROR");
                Dialog.addMessage("Number of ROIs is not the same as the number of frames!");
                Dialog.show();
        }

        close("Thresholded");


        //Apply ROIs and get profile

        for (i = 1; i <= frame_num; i++) {
                selectWindow(title);
                Stack.setFrame(i)
                roiManager("Select", i - 1);
                run("Enlarge...", "enlarge=enlargement");
                run("Line Width...", "line=10");
                run("Area to Line");
                run("Fit Spline", "straighten");

                //Save results
                Stack.getPosition(channel, slice, frame)

                //Get titles for files with results
                if (lengthOf(d2s(frame, 0)) == 1) {
                        title_XY_coordinates = new_title + '00' + d2s(frame, 0) + '_XY';
                        title_ROI = new_title + '00' + d2s(frame, 0) + '_roi';
                        title_green = new_title + '00' + d2s(frame, 0) + '_green.txt';
                }

                if (lengthOf(d2s(frame, 0)) == 2) {
                        title_XY_coordinates = new_title + '0' + d2s(frame, 0) + '_XY';
                        title_ROI = new_title + '0' + d2s(frame, 0) + '_roi';
                        title_green = new_title + '0' + d2s(frame, 0) + '_green.txt';
                }

                if (lengthOf(d2s(frame, 0)) == 3) {
                        title_XY_coordinates = new_title + d2s(frame, 0) + '_XY';
                        title_ROI = new_title + d2s(frame, 0) + '_roi';
                        title_green = new_title + d2s(frame, 0) + '_green.txt';
                }

                //Save XY coordinates and ROI
                saveAs("XY Coordinates", dir_XY + title_XY_coordinates);
                saveAs("Selection", dir_XY + title_ROI);


                //Get green channel intensities
                selectWindow(title);
                Stack.getPosition(channel, slice, frame)

                // Get profile and display values in "Results" window
                run("Clear Results");
                profile = getProfile();
                for (k = 0; k < profile.length; k++)
                        setResult("Value", k, profile[k]);
                updateResults;

                // Plot profile if you want
                //Plot.create("Profile", "X", "Value", profile);

                // Save as text file
                saveAs("Results", dir_channels + title_green);


        }



        //Close open images
        close(title);


}