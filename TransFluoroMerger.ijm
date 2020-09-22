


originalDirectory = getDirectory("image");

//use only First frame
function onlyFirstFrame() { 
	name=getTitle();
	run("Duplicate...", "title=Duplicated use");
	close(name);
	selectWindow("Duplicated");
	rename(name);
}



openImages = getList("image.titles");

if (indexOf(toLowerCase(openImages[0]), "trans")>=0){
	transTitle = openImages[0];
	fluorescentTitle = openImages[1];
} else {
	transTitle = openImages[1];
	fluorescentTitle = openImages[0];	
}

selectWindow(transTitle);
onlyFirstFrame();

selectWindow(fluorescentTitle);
onlyFirstFrame();

//*******Get new title from original directory and original name*****///7


dateIndex = indexOf(originalDirectory, "Ana\\")+4;
date=substring(originalDirectory, dateIndex, dateIndex+8);

underScoreIndex = indexOf(originalDirectory, "_");
folderTitle=substring(originalDirectory, dateIndex+9, underScoreIndex);


newTitle = date + "_" + folderTitle + "_"  + "_" + getTitle();


//**** Merge trans channel with fluorescent channels ******///
title=getTitle();
getDimensions(width, height, channels, slices, frames);
run("Split Channels");

titleC1 = 'C1-'+title;
titleC2 = 'C2-'+title;

selectWindow(titleC1);
run("16-bit");

selectWindow(titleC2);
run("16-bit");


run("Merge Channels...", "c1=["+titleC1+"] c2=["+titleC2+"] c3=["+transTitle+"] create");
rename(newTitle);


//saveAs("Tiff",  savingDirectory + newTitle);

