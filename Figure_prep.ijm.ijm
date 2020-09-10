/*
duplicate the frame defined by the variable 'frame_to_use' from the video, split first two
channels, combine them, add the scale bar and save in the directory of the original image 
*/

frame_to_use=1-96

dir = getDirectory("image"); 

run("Properties...", "unit=micron pixel_width=0.1625 pixel_height=0.1625 voxel_depth=0.5000000 frame=[30 sec]");
run("Duplicate...", "duplicate channels=1-2 frames=frame_to_use");

name=getTitle;


run("Split Channels");

title_C1='C1-'+name;
title_C2='C2-'+name;

selectWindow(title_C1);
run("RGB Color");

selectWindow(title_C2);
run("RGB Color");

run("Combine...", "stack1=["+title_C1+"] stack2=["+title_C2+"]");
run("Scale Bar...", "width=20 height=12 font=70 color=White background=None location=[Lower Right] label");
new_name='combined_'+name

saveAs("Tiff",  dir + new_name);