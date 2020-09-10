

//Specify master folder
dir = getDirectory("Choose a Directory to PROCESS"); 


//Get list of folders 
folders_list = getFileList(dir); 


//Go through all the i folders
for (i=0; i<folders_list.length; i++){
	list = getFileList(dir+folders_list[i]);
	dir2 = dir+folders_list[i];

	
	//Open all files in i_th folder with suffix .tif
for (k=1; k<4; k++){
	new_title='Oocyte_'+k;

	for (f=0; f<list.length; f++){ 
		path=dir+folders_list[i]+list[f];
		if(endsWith(list[f], ".tif")){
			run("Bio-Formats Importer" , "open=["+ path +"] autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+k);		
		}		
	}

//Concatenate
open_images = getList("image.titles");
run("Concatenate...","title=["+new_title+"]  image1=["+open_images[0]+"] image2=["+open_images[1]+"]");

open_images = getList("image.titles");
for (f=0; f<open_images.length-1; f++){
	run("Concatenate...", "title=["+new_title+"] image1=["+new_title+"] image2=["+open_images[f]+"]");
	
}


//set channel colors
setSlice(1);
run("Green");
run("Enhance Contrast", "saturated=0.35");

setSlice(2);
run("Red");
run("Enhance Contrast", "saturated=0.35");


Stack.setDisplayMode("composite");	


//duplicate first and second to last frame and save them in the saving directory

run("Duplicate...", "duplicate frames=1");
title_first=new_title+'_first';
Stack.setDisplayMode("composite");
saveAs("Tiff",  dir2 + title_first);          

selectWindow(new_title);
getDimensions(channels, height, channels, slices, frames);
last_frame=frames-1;
run("Duplicate...", "duplicate frames="+last_frame);
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

Stack.setDisplayMode("composite");
saveAs("Tiff",  dir2 + 'SUM_'+new_title);


//SUM of middle slices (30-50)
selectWindow(new_title);
run("Z Project...", "start=30 stop=50 projection=[Sum Slices] all");

setSlice(1);
run("Enhance Contrast", "saturated=0.35");

setSlice(2);
run("Enhance Contrast", "saturated=0.35");


Stack.setDisplayMode("composite");
saveAs("Tiff",  dir2 + 'SUM_'+new_title+'_z_30_50'); 


//Save the main file 
selectWindow(new_title);
saveAs("Tiff",  dir2 + new_title);  


//close all open images and start with new folder
      while (nImages>0) { 
          selectImage(nImages); 
          close(); 
      } 
}




     
}


