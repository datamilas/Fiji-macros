/* Automatically enhance contrast, set colors of the channels, and change display 
 * mode to composite
 * 
 * 
 */

setSlice(1);
run("Green");
run("Enhance Contrast", "saturated=0.35");

setSlice(2);
run("Magenta");
run("Enhance Contrast", "saturated=0.35");

if (getSliceNumber()==3){
setSlice(3);
run("Grays");
}



run("Enhance Contrast", "saturated=0.0");

Stack.setDisplayMode("composite");
Stack.setActiveChannels("110");