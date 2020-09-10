/*
duplicate the frame defined by the variable 'frame_to_use' from the video, split first two
channels, combine them, add the scale bar and save in the directory of the original image 
*/

frame_to_use=1-120

dir = getDirectory("image"); 

run("Properties...", "unit=micron pixel_width=0.1625 pixel_height=0.1625 voxel_depth=0.5000000 frame=[30 sec]");
run("Duplicate...", "duplicate channels=1-2 frames=frame_to_use");
name_merge=getTitle;

run("Duplicate...", "duplicate channels=1 frames=frame_to_use");
name_c1=getTitle;


selectWindow(name_merge);
run("RGB Color");

selectWindow(name_c1);
run("RGB Color");

run("Combine...", "stack1=["+name_merge+"] stack2=["+name_c1+"]");
run("Scale Bar...", "width=20 height=12 font=70 color=White background=None location=[Lower Right] label");
