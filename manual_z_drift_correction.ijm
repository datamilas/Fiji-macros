
# @ File(label = "File with results", style = "open") inputFile
//dir = getDir("choose");
Table.open(inputFile)

imageID = getImageID();
imageTitle = getTitle();
positions = Table.getColumn("C1");


indices_max = Array.findMaxima(positions, 1);
max = positions[indices_max[0]];
indices_min = Array.findMinima(positions, 1);
min = positions[indices_min[0]];
diff = max-min

getDimensions(width, height, channels, slices, frames);

for (i = 1; i <= frames; i++) {
	Stack.setFrame(i);
	run("Duplicate...", "duplicate frames=i");
	duplicate_id = getImageID();
	
	position = positions[i-1];
	front = max - position;
	back = diff-front;
	print(front+back);
	
	
	for (k=0; k<front; k++){
		selectImage(duplicate_id);
		run("Add Slice", "add=slice prepend");
	}

	
	for (k=0; k<back; k++){
		selectImage(duplicate_id);
		Stack.setSlice(slices+front);
		run("Add Slice", "add=slice");
	}
	wait(100);
	
	//getDimensions(width, height, channels, slices, frames);
	//if (slices!=117){dfdf}
	selectImage(imageID);
	getDimensions(width, height, channels, slices, frames);
	
	
}
selectImage(imageID);
close();
run("Concatenate...", "all_open open");
final_slice_num = slices+diff;
run("Stack to Hyperstack...", "order=xyczt(default) channels=2 slices=final_slice_num frames=frames display=Color");
rename(imageTitle+"_z_corrected");