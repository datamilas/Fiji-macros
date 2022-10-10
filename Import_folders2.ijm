

//Specify master folder
dir = getDirectory("Choose a Directory to PROCESS"); 


//Get list of folders 
folders_list = getFileList(dir); 


//Go through all the i folders

	list = getFileList(dir+'trans');
	dir2 = dir+'trans//';

	//create the title for the concatenated file 


	new_title='green';

	
	//Open all files in i_th folder with suffix .tif

	for (f=0; f<list.length; f++){ 
		path=dir2+list[f];
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
