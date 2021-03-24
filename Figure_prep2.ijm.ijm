/*
duplicate the frame defined by the variable 'frame_to_use' from the video, 

if 'split_channels' parameter is equal to 1 split channels defined by 'channels_to_use',
combine them and add scale bar with font size defined by 'scalebar_size' 

if 'split_channels' is 0, add the scale bar on merged image

save in the directory of the original image 
*/

//frame_to_use=1-96
frame_to_use=1
channels_to_use = 1-2
scalebar_size = 100

split_channels = 0


dir = getDirectory("image"); 

run("Properties...", "unit=micron pixel_width=0.1625 pixel_height=0.1625 voxel_depth=0.5000000 frame=[30 sec]");
run("Duplicate...", "duplicate channels=channels_to_use frames=frame_to_use");

name=getTitle;


if (split_channels) {
run("Split Channels");

title_C1='C1-'+name;
title_C2='C2-'+name;

selectWindow(title_C1);
run("RGB Color");

selectWindow(title_C2);
run("RGB Color");

run("Combine...", "stack1=["+title_C1+"] stack2=["+title_C2+"]");
run("Scale Bar...", "width=20 height=12 font=scalebar_size color=White background=None location=[Lower Right] label");
new_name='combined_'+name;

}

else {

run("RGB Color");

run("Scale Bar...", "width=20 height=12 font=scalebar_size color=White background=None location=[Lower Right] label");
new_name=name+'_scale_bar';

}

saveAs("Tiff",  dir + new_name);