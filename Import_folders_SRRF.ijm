
//set number of frames per SRRF image
frame_num=200;

//number of channels
channel_num=2;

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
		
			run("Bio-Formats Importer" , "open=["+ path +"] autoscale color_mode=Colorized rois_import=[ROI manager] open_all_series view=Hyperstack stack_order=XYCZT");
	}

}

//Concatenate and transform to hyperstack
run("Concatenate...", "all_open");
getDimensions(width, height, channels, slices, frames);
z_num=slices/frame_num;
run("Stack to Hyperstack...", "order=xyczt(default) channels=2 slices=z_num frames=frame_num display=Color");


//remove first two frames
getDimensions(channels, height, channels, slices, frames);
Stack.setFrame(1);
run("Delete Slice", "delete=frame");	
run("Delete Slice", "delete=frame");	

//set channel colors and contrast
setSlice(1);
run("Green");
run("Enhance Contrast", "saturated=0.35");

setSlice(2);
run("Red");
run("Enhance Contrast", "saturated=0.35");

//save
final_title=new_title+'_conc';
saveAs("Tiff",  dir2 + final_title);  

//close all open images and start with new folder
      while (nImages>0) { 
          selectImage(nImages); 
          close(); 


} 

     
}

