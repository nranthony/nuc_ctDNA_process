# nuc_ctDNA_process
ImageJ 1.x macros and Matlab code for processing 3D nuclear classification and quantification.  This repo is designed to help you recreate the methods use in the associated publication.  Please don't hesitate to contact if you have questions.  Happy to debug, update, etc if there's need.

## Lif files:

Use ImageJ 1.x macro in fiji folder to process lif files for subsequent ilastik and Matlab processing. Works with 3 channel data (DAPI, DIC, Rh-Red-X) and 4 channel data (DAPI, Cy5, Rh-Red-X, DIC). Generates .h5 or .tif files for ilastik raining, .jpgs for visualization and ROI overlays, and raw tif files for Matlab analysis.
### Macro Usage
Drag and drop; click Run and select .lif of interest.  Only 3D data will be included, single layer images will be noted in output.  A table of dimensions and max intensities is also created.  Save .csv image info, and .txt output log for reference.

### Organize Folder Structure
![Folder Structure](/images/folders.png)
* Place .h5 nuclear, or .tif nuclear and DIC, and .jpg thumbnail data in subfolder called “nuc”
* Place .tif raw data export into subfolder called “raw”
* Create subfolders “ilastik output” and “roi”
* Ilastik (version 1.3.2post1) trained with ~10-20% of datasets
  * Ilastik side note: currently don't know how to share Ilastik projects without getting errors on loading for the given files and filepaths present during creation. You will need to train your own models.  See NoPhotonLeftBehind for Ilastik series that includes training tips and details of features used for these data. https://www.youtube.com/channel/UCRVa5DSphB5gHMaFKPgyKSQ
* Models trained as Pixel Classifications – two classes, background and nucleus
* Ilsatik model trained to classify nuclear vs non nuclear – classical thresholding methods found to be less effective due to varying amounts on cytoplasmic DNA stain present. 
* Single match and mismatch trained using nuclear channel only; double mismatch trained using nuclear and DIC channels together
* Data separated and models trained for each cell type due to distinct morphologies, e.g. MM1S model, HCT116 model, etc etc
* Probability density files
  * Matlab looks for “*_nrmNuc.tiff“ in relative folder “.\ilastik output”, and this is the suffix added in the Fiji macro
  * In ilastik, set output format to multipage tiff, and select path to .\{nickname}.tiff.  Note, use path of .\{nickname}_nrmNuc.tiff if _nrmNuc is not added during your file collation and logistics to this point.  Also note .tiff not .tif
  * Leave image export settings as default; shape here is, for example, 16, 512, 512, 1, with axis order zyxc and data type float32
  * In Batch Processing section, select all of the .h5 or .tif files in the “nuc” folder and Process all files
* Matlab UI
  * Files Tab:
    * Set Root – select folder containing “ilastik output”, “raw”, “roi”, and “nuc” 
    * Filename list will propagate, and Overview text at the top will highlight red if the correct number of files are not present in all folders.  (TODO: - run test on error scenario to get instructions)
    * Sig Num Chns – the total number of channels in the raw data tif files
    * Rh/Cy5 Sig Chn – the 1 to N based index of the channel to measure inside the nucleus
    * Rh/Cy5 Bkgd – the number of counts considered as background/cell autoflourescene/non-specific signal during measurements; only voxels with counts above this level will be included in the measurements
    * ROI Num Chns – total number of channels in the ilastik probability density tiff files
    * ROI Chn – 1 to N based index of channel to use for generating nuclear 3D ROIs
    * Thumbnails on/off toggle when selecting images in list
    * Currently only single or double channel analyses available (signal is measured inside and outside of nucleus 3D ROI)
    * Click on files to view the nuc jpgs.  Click Processing tab to experiment with settings.  Note, above channel totals and indices do not currently have error checking.  Check correct combinations if you receive tif read errors.  Jpgs are loaded on each click, and raw is loaded on switching to Processing tab; expect short delay depending on file size and available disk read speeds.
    * Open in Explorer button – no prizes for guessing that it opens the selected file in explorer.  It defaults to the raw data.
    * Process All button runs all the files using the settings in place in the Processing Tab.
      * A dated folder in roi is created.  Inside this folder there are four different types of output file:
  * .bin – a binary mask of the 3D ROI
  * _dims.bin – the dimensions of the binary mask
  * .jpg – a thumbnail of ROI overlays
  * .mat – parameters used for generating the ROIs  (open .mat files, and click on the params variable in the Import Wizard to quickly view the relevant parameters)
    * Use Masks dropdown:
      * For faster re-processing of data with differing minimum number of voxels existing binary masks can be used 
      * Note, resulting .mat file in subsequent output will not reflect the parameters used to generate the binary masks – refer to the original folder (this is noted and will be added to newer versions)
    * 
  * Processing tab:
    * FFT % is the amount of Fourier space to keep; lower values retain low frequencies only – empirically determined for best resulting nuclear shape
    * FFT Smooth value is Gaussian smoothing value in pixels applied to the ellipsoid mask used to retain the central region of Fourier space.  Ringing can be seen for values close to 0, increase as needed.
    * Gauss Smooth is the Gaussian smoothing applied to the raw prob data prior to Otsu thresholding.  In noisy classifications thresholding leads to multiple fragmented regions; some smoothing prior to thresholding helps to ‘fuse’ these fragmented regions, prior to 3D FFT spatial filtering to smooth based on size.
    * FFT xz factor is used to avoid smoothing nuclei in the z direction more than x and y.  This value affects the ratio of xy and z of the 3D ellipsoid used to mask Fourier space.  Set empirically; Click Run and then View Volume to inspect the z ‘stretch’.
    * Button group options to apply different combinations of smoothing and FFT spatial filters:
      * Gauss – uses Gauss Smooth value above; applied to raw prob data
      * Otsu – Otsu binary threshold
      * Fill – Binary fill applied after smooth and binarization
      * FFT – 3D spatial filtering based on % of Fourier space
    * Run, well, runs the analysis
    * View Volume displays 3D viewer for resulting data set
    * Min volume slider and value are used to exclude all 3D ROIs smaller than specified value; in voxels.  Note slider is linear and plot is log.
  * Notes:
    * Requires Matlab 2018a or newer
    * Requires Parallel Computing Toolbox for parfor loop in function ProcessAllButtonPushed.  Change parfor to for if not available.
    * 
* Matlab filelist:
  * *.mlapp
  * import_tif.m
  * bw_outline_p.m
  * smth_otsu_fill_p.m
  * LPFFT3D_p.m
  * otsu_bw.m
  * makepsd3.m
  * ellipsoid_mask.m
  * bin_load_mask.m
  * process_ctDNA_table.m
  * _p refers to passed param struct:
    * wid = 3;                 % width of dilation in outline overlay
    * pc;               % percent of Fourier space to keep - smaller numbers -> more blurred out larger images
    * pad = 1;                 % pad Fourier space to the next power of 2
    * umpx = 0.09;             % image pix size
    * umpz = 0.3;              % again in z
    * fft_smth;            % smoothing of the eliptical Fourier space mask
    * gauss_smth;          % sigma of Guass smooth for Guass, Otsu, Fill, BW
    * scl = [1 1 1/0.3];       % scale ratios for volume viewer
    * fft_xz_factor;       % factor to increase or decrease the amount of z FFT smoothing compared to xy
    * minvol = 0;
