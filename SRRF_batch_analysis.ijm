

//Define parameters for SRRF

//Channel 1
ring_ch1 =	1				//default: 0.5
radiality_mag_ch1 = 2		//default: 5
axes_ch1 = 6				//default: 6

frames_per_time_ch1 = 0		//0 - auto
start_ch1=0 				//0 - auto
end_ch1=0 					//0 - auto
max_ch1=200					//default:100


//Channel 2
ring_ch2 =	1				//default: 0.5
radiality_mag_ch2 = 2		//default: 5
axes_ch2 = 6				//default: 6

frames_per_time_ch2 = 0		//0 - auto
start_ch2=0 				//0 - auto
end_ch2=0 					//0 - auto
max_ch2=200					//default:100



//Specify master folder
dir = getDirectory("Choose a Directory to PROCESS"); 


//Get list of folders 
folders_list = getFileList(dir); 


//Go through all the i folders
for (i=0; i<folders_list.length; i++){
	list = getFileList(dir+folders_list[i]);
	dir2 = dir+folders_list[i];

	//open video in the folder (the file(s) that end with .tiff
	for (f=0; f<list.length; f++){ 
		path=dir+folders_list[i]+list[f];
		
		if(endsWith(list[f], ".tif")){		
		open(path);
	}
	}


getDimensions(width, height, channels, slices, frames);
image_title = getTitle();
title_C1='C1-'+image_title;
title_C2='C2-'+image_title;

run("Split Channels");

//do SRRF on channel 1

		selectImage(title_C1);		
		run("Duplicate...", "duplicate slices=1");
		duplicated_title = getTitle();
		run("SRRF Analysis", "ring=ring_ch1 radiality_magnification=radiality_mag_ch1 axes=axes_ch1 frames_per_time-point=frames_per_time_ch1 start=start_ch1 end=end_ch1 max=max_ch1");
		
		first_title = getTitle();
		
		//selectImage(duplicated_title);
		//close();
		
	for (f=2; f<=slices; f++){
		selectImage(title_C1);		
		run("Duplicate...", "duplicate slices=f");
		duplicated_title = getTitle();
		run("SRRF Analysis", "ring=ring_ch1 radiality_magnification=radiality_mag_ch1 axes=axes_ch1 frames_per_time-point=frames_per_time_ch1 start=start_ch1 end=end_ch1 max=max_ch1");
		
		tempTitle = getTitle();
		run("Copy");

		selectImage(first_title);
		run("Add Slice");
		run("Paste");

		selectImage(tempTitle);
		close();
		
		selectImage(duplicated_title);
		close();
	}


//do SRRF on channel 2

		selectImage(title_C2);		
		run("Duplicate...", "duplicate slices=1");
		duplicated_title = getTitle();
		run("SRRF Analysis", "ring=ring_ch2 radiality_magnification=radiality_mag_ch2 axes=axes_ch2 frames_per_time-point=frames_per_time_ch2 start=start_ch2 end=end_ch2 max=max_ch2");
		
		second_title = getTitle();
		
		//selectImage(duplicated_title);
		//close();
		
	for (f=2; f<=slices; f++){
		selectImage(title_C2);		
		run("Duplicate...", "duplicate slices=f");
		duplicated_title = getTitle();
		run("SRRF Analysis", "ring=ring_ch2 radiality_magnification=radiality_mag_ch2 axes=axes_ch2 frames_per_time-point=frames_per_time_ch2 start=start_ch2 end=end_ch2 max=max_ch2");
		
		tempTitle = getTitle();
		run("Copy");

		selectImage(second_title);
		run("Add Slice");
		run("Paste");

		selectImage(tempTitle);
		close();
		
		selectImage(duplicated_title);
		close();
	}


run("Merge Channels...", "c1=["+first_title+"] c2=["+second_title+"] create");

setSlice(1);
run("Green");
run("Enhance Contrast", "saturated=0.35");

setSlice(2);
run("Magenta");
run("Enhance Contrast", "saturated=0.35");

rename(image_title + '-SRRF');
final_title = getTitle();
saveAs("Tiff",  dir2 + final_title);

	
//close all open images and start with new folder
      while (nImages>0) { 
          selectImage(nImages); 
          close(); 
      } 
}