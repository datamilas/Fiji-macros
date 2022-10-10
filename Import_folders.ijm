

//Specify master folder
dir = getDirectory("Choose a Directory to PROCESS"); 


//Get list of folders 
folders_list = getFileList(dir); 


//Go through all the i folders
for (i=0; i<folders_list.length; i++){
	list = getFileList(dir+folders_list[i]);
	dir2 = dir+folders_list[i];

	//create the title for the concatenated file 

	position_ = indexOf(folders_list[i], "_");
	new_title=substring(folders_list[i], 0,position_);

	
	//Open all files in i_th folder with suffix .tif

	for (f=0; f<list.length; f++){ 
		path=dir+folders_list[i]+list[f];
		if(endsWith(list[f], ".tif")){
		
			run("Bio-Formats Importer" , "open=["+ path +"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	}

}

//Concatenate and set channels
open_images = getList("image.titles");
run("Concatenate...","title=["+new_title+"]  image1=["+open_images[0]+"] image2=["+open_images[1]+"]");

open_images = getList("image.titles");
for (f=0; f<open_images.length-1; f++){
	run("Concatenate...", "title=["+new_title+"] image1=["+new_title+"] image2=["+open_images[f]+"]");
	
}

setSlice(1);
run("Green");
run("Enhance Contrast", "saturated=0.35");

setSlice(2);
run("Red");
run("Enhance Contrast", "saturated=0.35");

setSlice(3);
run("Grays");
run("Enhance Contrast", "saturated=0.0");

Stack.setDisplayMode("composite");



//duplicate first and last frame and save it in the saving directory
run("Duplicate...", "duplicate frames=1");
title_first=new_title+'_first';
Stack.setDisplayMode("composite");
saveAs("Tiff",  dir2 + title_first);          


selectWindow(new_title);
getDimensions(channels, height, channels, slices, frames);
if (frames==142){
run("Duplicate...", "duplicate frames=frames");
}
else {
	frames=frames-1;
	run("Duplicate...", "duplicate frames=frames");
}
title_last=new_title+'_last';
Stack.setDisplayMode("composite");
saveAs("Tiff",  dir2 + title_last);          


//calculate max/sum and save to the saving directory

//SUM of all slices
selectWindow(new_title);
run("Z Project...", "projection=[Sum Slices] all");

setSlice(1);
run("Enhance Contrast", "saturated=0.35");

setSlice(2);
run("Enhance Contrast", "saturated=0.35");

setSlice(3);
run("Enhance Contrast", "saturated=0.0");

Stack.setDisplayMode("composite");
saveAs("Tiff",  dir2 + 'SUM_'+new_title);


//SUM of middle slices
selectWindow(new_title);
run("Z Project...", "start=10 stop=40 projection=[Sum Slices] all");

setSlice(1);
run("Enhance Contrast", "saturated=0.35");

setSlice(2);
run("Enhance Contrast", "saturated=0.35");

setSlice(3);
run("Enhance Contrast", "saturated=0.0");

Stack.setDisplayMode("composite");
saveAs("Tiff",  dir2 + 'SUM_'+new_title+'_z_10_40'); 


//MAX of all slices
selectWindow(new_title);
run("Z Project...", "projection=[Max Intensity] all");

setSlice(1);
run("Enhance Contrast", "saturated=0.35");

setSlice(2);
run("Enhance Contrast", "saturated=0.35");

setSlice(3);
run("Enhance Contrast", "saturated=0.0");

Stack.setDisplayMode("composite");
saveAs("Tiff",  dir2 + 'MAX_'+new_title); 

//MAX of middle slices
selectWindow(new_title);
run("Z Project...", "start=10 stop=40 projection=[Max Intensity] all");

setSlice(1);
run("Enhance Contrast", "saturated=0.35");

setSlice(2);
run("Enhance Contrast", "saturated=0.35");

setSlice(3);
run("Enhance Contrast", "saturated=0.0");

Stack.setDisplayMode("composite");
saveAs("Tiff",  dir2 + 'MAX_'+new_title+'_z_10_40');


//Save the main file 
selectWindow(new_title);
saveAs("Tiff",  dir2 + new_title);  


//close all open images and start with new folder
      while (nImages>0) { 
          selectImage(nImages); 
          close(); 
      } 

     
}


