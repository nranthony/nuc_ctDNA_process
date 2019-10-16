//  Integrated Cellular Imaging (ICI) - Emory University
//  Integrated Core Facilities
//
//  Neil R. Anthony  -  10/2019
//  Macro to process lif files for subsequent ilastik and
//  Matlab processing
//  Works with 3 channel data (DAPI, DIC, Rh-Red-X)
//  and 4 channel data (DAPI, Cy5, Rh-Red-X, DIC) 
//  Generates .h5 or .tif files for ilastik training,
//  .jpgs for visualization and ROI overlays,
//  and raw tif files for Matlab analysis


//  set flag for using nuc vs nuc+dic for ilastik training
//  - nuc generates .h5 file
//  - nuc+dic generates .tif file
nuc_only = true;  //  set to false for nuc+dic files
//  note, multichannel .h5 reportedly work in ilastik if filesize is a concern

//  option for selected file
//  path is dir + separater + name; note, dir in this case needs separater; use File.separator
path = File.openDialog("Select a File");
dir = File.getParent(path) +  File.separator;
name = File.getName(path);
flist = newArray(name);
print(flist.length);
//print("path: ", path, "\nname: ", name, "\ndir: ", dir);

//  option for whole folder
//dir = getDirectory("Choose a Directory");  //  dir in this comes with the separater
//flist = getFileList(dir);

run("Input/Output...", "jpeg=85 gif=-1 file=.csv use use_file copy_row save_column save_row");
print("");

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print(year + "-" + month + "-" +dayOfMonth + "; " + hour  + ":" + minute   + ":" + second);

setBatchMode(true);

// create results table and heading names for stats
stats_title = "img_stats";
stats_title_wnd = "["+stats_title+"]";
run("Table...", "name="+stats_title_wnd+" width=900 height=500");
stats_head_str = "\\Headings:fname\tsname\tstack_max\tn_chns\t";
print(stats_title_wnd, "\\Clear");
print(stats_title_wnd, stats_head_str);


run("Bio-Formats Macro Extensions");

for (i=0; i<flist.length; i++) {

	if (endsWith(flist[i], ".lif")){

		fullpath = dir + flist[i]; 
		Ext.setId(fullpath);
		Ext.getSeriesCount(seriesCount);
		print(fullpath + "found containing " + seriesCount + " datasets" );

		for (s=0; s<seriesCount; s++) {
			
			Ext.setSeries(s);
			Ext.getSeriesName(seriesName);
			Ext.getSizeZ(sz);
			
			if ( sz == 1 ) {
				print("s = " + (s+1) + "  " + fullpath + " " + seriesName + " omitted; only processing z-stacks.");
				
			} else {
				print("s = " + s + "  " + fullpath + " " + seriesName + " z = " + sz);
				bfStr = "open=[" + fullpath + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_" + (s+1);
			
				run("Bio-Formats Importer", bfStr);

				Stack.getDimensions(width, height, channels, slices, frames);
				if (channels == 3) {
					Stack.setChannel(1);
					run("Cyan");
					run("Enhance Contrast", "saturated=0.35");
					Stack.setChannel(3);
					run("Magenta");
					run("Enhance Contrast", "saturated=0.35");
					Stack.setDisplayMode("composite");					
				}
				if (channels == 4) {
					Stack.setChannel(1);
					run("Cyan");
					run("Enhance Contrast", "saturated=0.35");
					Stack.setChannel(2);
					run("Yellow");
					run("Enhance Contrast", "saturated=0.35");
					Stack.setChannel(3);
					run("Magenta");
					run("Enhance Contrast", "saturated=0.35");
					Stack.setDisplayMode("composite");					
				}
					
				//  save raw data to tif
				tifSav = dir + seriesName + ".tif";
				saveAs("Tiff", tifSav);
				rename("raw");

				//  normalize nuc channel
				run("Duplicate...", "duplicate channels=1");
				rename("nuc");
				Stack.getStatistics(voxelCount, mean, min, max, stdDev);
				fct = 255 / max;
				mStr = "value=" + fct + " stack";
				run("Multiply...", mStr);
				setMinAndMax(0, 255);
				run("8-bit");
				rename("norm");
	
				run("Duplicate...", "duplicate channels=1");
				rename("thumb");
				//  save jpg thumb
				run("Z Project...", "projection=[Max Intensity]");
				run("mpl-inferno");
				jpgSav = dir + seriesName + "_nrmNuc.jpg";
				saveAs("Jpeg", jpgSav);
	
				if (nuc_only) {
					selectWindow("norm");
					//  save as h5
					h5file = dir + seriesName + "_nrmNuc.h5";
					run("Scriptable save HDF5 (new or replace)...", "save=[" + h5file + "] dsetnametemplate=data formattime=%d formatchannel=%d compressionlevel=0");
				}
				if (!nuc_only) {  //  i.e. nuc and dic
					selectWindow("raw");
					if (channels == 3) {
						run("Duplicate...", "duplicate channels=2");
					}
					if (channels == 4) {
						run("Duplicate...", "duplicate channels=4");
					}
					rename("dic");
					run("Merge Channels...", "c4=dic c5=norm create ignore");
					rename("nuc_dic");
					tifSav = dir + seriesName + "_nrmNucDIC.tif";
					saveAs("Tiff", tifSav);
				}
	
				close("*");
				print(stats_title_wnd, flist[i] + "\t" + seriesName + "\t" + max + "\t" + channels);
			}
			
		}

	}

}

setBatchMode(false);
