/*

# Detection of calbindin spheroids or foci or puncta

Usage: *Run it in FIJI (www.fiji.sc)  

Author: Paolo Marchi, Sheffield Institute of Translational Neuroscience (SITraN), 
pmarchi1@sheffield.ac.uk April 2020  

Credit to Sébastien Tosi (IRB Barcelona) for SpotDetection algorithm:
https://github.com/Neubias-WG5/W_SpotDetection-Dmap-IJ/blob/master/IJSpotDetection.ijm

## Description: 
Code to use in a FIJI-macro for the batch detection/analysis of Calbindin spheroids. 


*/


/*
**First install PTBIOP and ImageScience plugings**

- Open FIJI
- Go to Help < Update...
- Wait for the bar to complete and then press Manage update sites
- Scroll down and go to PTBIOP and IMAGESCIENCE, select them and then close window
- Finally press Apply changes in the ImageJ updater window already open
- Once it finishes the download, restart FIJI and open it again and try the macro

*/


/*
### Open a single image in FIJI

*/

open("C:/Users/mdp18pm/Desktop/FIJI Macro for detecting puncta-foci-spheroids/Picture3.tif");

				
/*
### Getting image information + Normalise the data name

*/

title = getTitle();

run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");	


/*
### We now create a rectangle (region of interest- ROI); this can be later changed by the user for its size and location
The analysis will be performed only in the selected ROI

*/
makeRectangle(211, 181, 150, 150);
setTool("rectangle");


/*
 Now the user can select a region of interest by moving the yellow square
 
 */
 
waitForUser("Please move ROI into a region of interest; in our case is Deep Cerebellar Nuclei (DCN). \n\nThen press OK");

run("Duplicate...", " ");
duplicated1 = getImageID();
run("Duplicate...", " ");
run("8-bit");
duplicated2 = getImageID();



/*

## Let's start our Connected Components Analysis 
We will use FeatureJ Laplacian filter.
You will see a first image with a first detection and 
then a second image in which restrictions are applied (i.e. size= 5-350 or circularity = 0.7-1)
 */

selectImage(duplicated2);

run("FeatureJ Laplacian", "compute smoothing=1");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Watershed");
	run("Analyze Particles...", 
	"size=5-350 pixel  circularity=0.70-1.00 show=Masks display exclude clear add");

run("Clear Results");

selectImage(duplicated2);

roiManager("Show All without labels");
n=roiManager("count");


/*

## Exclude all of those ROIs below a certain mean threshold value (i.e. 41)

 */

for(i=n-1;i>0;i=i-1) {
	roiManager("Select", i);
	run("Measure");
	if(getResult("Mean",nResults-1)<41){
		roiManager("Delete");
	};
};

roiManager("Show None");
roiManager("Show All");
run("Clear Results");
roiManager("Deselect");
roiManager("Measure");

/* 

## Save the results
Now we save the results.
*/

saveAs("results", "C:/Users/mdp18pm/Desktop/FIJI Macro for detecting puncta-foci-spheroids/results.xls");

/* 

## Save the image containing the detected spheroids
- you can open it once the macro is finished 
*/
selectImage(duplicated2);
roiManager("Show None");
roiManager("Show All without labels");

run("Enhance Contrast", "saturated=0.35");
run("Enhance Contrast", "saturated=0.35");
run("Enhance Contrast", "saturated=0.35");
run("Enhance Contrast", "saturated=0.35");

run("Flatten");
saveAs("Tiff", "C:/Users/mdp18pm/Desktop/FIJI Macro for detecting puncta-foci-spheroids/Spheroids.tif");


/* 

## Save the detected spheroids (ROIs)
- so you will be able to upload them anytime from the ROI manager
and they will not be lost
*/

roiManager("Save", "C:/Users/mdp18pm/Desktop/FIJI Macro for detecting puncta-foci-spheroids/RoiSet.zip");




	

	
