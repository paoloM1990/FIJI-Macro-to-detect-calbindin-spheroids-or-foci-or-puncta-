/*

Usage: *Run it in FIJI (www.fiji.sc)  

Author: Paolo Marchi, Sheffield Institute of Translational Neuroscience (SITraN), 
pmarchi1@sheffield.ac.uk April 2020  

Credit to Sébastien Tosi (IRB Barcelona) for SpotDetection algorithm:
https://github.com/Neubias-WG5/W_SpotDetection-Dmap-IJ/blob/master/IJSpotDetection.ijm

Description: 
Code to use in a FIJI-macro for the batch detection/analysis of Calbindin spheroids. 


*/



//First install PTBIOP and ImageScience plugings

//Open FIJI
//Go to Help < Update...
//Wait for the bar to complete and then press Manage update sites
//Scroll down and go to PTBIOP and IMAGESCIENCE, select them and then close window
//Finally press Apply changes in the ImageJ updater window already open
//Once it finishes the download, restart FIJI and open it again and try the macro


//get Directory function will give a string variable (input_path) which is the path of your directory
input_path = getDirectory("input files");

//fileList will be an array which is 'contained' inside the variable input path
fileList = getFileList(input_path); 

//.legth gives the number of compartments in my array fileList
for (f=0; f<fileList.length; f++){	
	open(input_path + fileList[f]);
	print(input_path + fileList[f]); //displays file that is processed


	
// rest of the code down here.....
//Step1: Getting image information + Normalise the data name
//get general information
title = getTitle();

//remove scale to work with pixels
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");	

//make ROI (square of 150x150 pixel)
makeRectangle(211, 181, 150, 150);
setTool("rectangle");

//user has to move ROI into the right DCN region
waitForUser("Please move ROI into a DCN region. \n\nThen press OK");

//duplicate original image's ROI and convert to 16-bit
run("Duplicate...", " ");
duplicated1 = getImageID();
run("Duplicate...", " ");
run("8-bit");
duplicated2 = getImageID();


//select first image and enhance contrast
//selectImage(title);
//rename("original");



//Connected components analysis (on the duplicated image)
//Credit to Sébastien Tosi (IRB Barcelona) for SpotDetection algorithm:
selectImage(duplicated2);

run("FeatureJ Laplacian", "compute smoothing=1");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Watershed");
	run("Analyze Particles...", 
	"size=5-350 pixel  circularity=0.70-1.00 show=Masks display exclude clear add");

//roiManager("reset");	
run("Clear Results");

//now we go to the original image and overlay the thresholded contours
selectImage(duplicated2);

roiManager("Show All without labels");
n=roiManager("count");

//exclude all of those ROIs below a certain mean threshold value (i.e. 40)
for(i=n-1;i>0;i=i-1) {
	roiManager("Select", i);
	run("Measure");
	if(getResult("Mean",nResults-1)<41){
		roiManager("Delete");
	};
};
//roiManager("Set Fill Color", "blue");
roiManager("Show None");
roiManager("Show All");
run("Clear Results");
roiManager("Deselect");
roiManager("Measure");

//save results
saveAs("results", input_path+title+"results.xls");


//to have a check for the ROIs that fiji selected I want to save them
selectImage(duplicated2);
roiManager("Show None");
roiManager("Show All without labels");
//run("Brightness/Contrast...");
run("Enhance Contrast", "saturated=0.35");
run("Enhance Contrast", "saturated=0.35");
run("Enhance Contrast", "saturated=0.35");
run("Enhance Contrast", "saturated=0.35");
//run("Capture Image");
//run("Flatten");

saveAs("Tiff", input_path+title+"-Spheroids.tif");

roiManager("Save", input_path+title+"-RoiSet.zip");



	//Final step: Clean-up to prepare for next image
	roiManager("reset");	
	run("Close All");
	run("Clear Results");
	
}
	
