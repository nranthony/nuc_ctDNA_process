%% load raw signal to count
rootpath = 'D:\tmp\Leon';
dirraw = uigetdir(rootpath, 'Select 3 chn tiff raw data folder - DAPI, DIC, Rh-DNA');
rawfiles = dir(fullfile(dirraw, '*.tif'));
nraw = length(rawfiles);
sigchn = 3;

%% load jpgs to add overlays
rootpath = 'D:\tmp\Leon';
dirraw = uigetdir(rootpath, 'Select normalized jpg folder');
jpgfiles = dir(fullfile(dirraw, '*_nrmNuc.jpg'));
nraw = length(jpgfiles);

%%  load probability maps of nuclei and create 3D masks
rootpath = 'D:\tmp\Leon';
dirprob = uigetdir(rootpath, 'Select ilastik 4 chn output folder');
probfiles = dir(fullfile(dirprob, '*_nrmNuc_prob.tiff'));
%probfiles = dir(fullfile(dirprob, '*_nrmNuc_nrmPCall.tiff'));
nprob = length(probfiles);

%%  other stuff

if (nprob ~= nraw)
    disp('WARNING: # of files in raw and prob folders does not match.  Continuing with concurrent files.');
    return
end

s = struct('filename',{},'cancer_type',{},'voxel_count',{},'total_signal',{});

params.wid = 3;                 % width of dilation in outline overlay
params.pc = 0.15;               % percent of Fourier space to keep - smaller numbers -> more blurred out larger images
params.pad = 1;                 % pad Fourier space to the next power of 2
params.smth = 3;                % one of the smooths, not if used anymore
params.umpx = 0.09;             % image pix size
params.umpz = 0.3;              % again in z
params.fft_smth = 3;            % smoothing of the eliptical Fourier space mask
params.gauss_smth = 3;          % sigma of Guass smooth for Guass, Otsu, Fill, BW
params.scl = [1 1 1/0.3];       % scale ratios for volume viewer
params.fft_xz_factor = 1;       % factor to increase or decrease the amount of z FFT smoothing compared to xy

parfor i = 1:nraw
    
    [~,rawname,~] = fileparts(rawfiles(i).name);
    [~,probname,~] = fileparts(probfiles(i).name);
    cmp = strfind(probname, rawname);
    s(i).filename = rawname;
    if (~isempty(cmp))

        fpath = fullfile(rawfiles(i).folder, rawfiles(i).name);
        rimg = import_tif(fpath, 3, 3);
        
        fpath = fullfile(probfiles(i).folder, probfiles(i).name);
        pimg = import_tif(fpath, 4, 4);
        
        if (size(rimg,3) ~= size(pimg,3))
            disp(['z size does not match for ' rawfiles(i).name]);
            % TODO: add zero entry or error details in collated array
            continue
        end
        
        lpimg = LPFFT3D_p(pimg, params);
        lpimg_bw = otsu_bw(lpimg);
        prob_vox_cnt = nnz(lpimg_bw);
        sig_total = sum(sum(sum(rimg .* pimg)));
        s(i).voxel_count = prob_vox_cnt;
        s(i).total_signal = sig_total;
        %ovly_jpg = imoverlay(jpg, bw_out, 'cyan');
    end
end

%
% load target signal data
% 
% load nuclear classifications - leaf number 4 for normPC.ilp
% use otsu_bw to create mask
% measure signal in mask


% collate...
% create colon cancer type categories
% link cancer types to filenames


% save images of some sort



