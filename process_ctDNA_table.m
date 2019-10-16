function sT = process_ctDNA_table(s)

% Syntax: sT = process_ctDNA_table(s)

%% create cancer code to cancer type lookup cell array
% change these lookup filename codes to help categorized your files.
% results in category in cancer type column of resulting Excel file
colonList = {'RKO', 'HT29', 'HT-29', 'HT_29', 'HT 29', 'HT116', 'HT-116', 'HT_116', 'HT 116', 'HCT 116', 'HCT-116', 'HCT116'};
pancList = {'Panc1', 'Panac1', 'ASPC-1', 'MIA'};
myelomaList = {'MM1S', 'MM1s', 'OPM1', 'RPMI', 'KMS11', 'JJN3', 'LC3', 'JK6L', 'U266', 'L363'};

cancerLookup = {};

idx = 1;
for n = 1:length(colonList)
    cancerLookup{idx,1} = colonList{n};
    cancerLookup{idx,2} = 'colon';
    idx = idx + 1;
end

for n = 1:length(pancList)
    cancerLookup{idx,1} = pancList{n};
    cancerLookup{idx,2} = 'pancreas';
    idx = idx + 1;
end

for n = 1:length(myelomaList)
    cancerLookup{idx,1} = myelomaList{n};
    cancerLookup{idx,2} = 'myeloma';
    idx = idx + 1;
end


%% fill cancer type categories

for i = 1:length(s)
    find_count = 0;
    ctrl_count = 0;
    for n = 1:size(cancerLookup,1)
        if ( contains(s(i).signal_filename,cancerLookup{n,1}) )
            find_count = find_count + 1;
            s(i).cancer_type = cancerLookup{n,2};
            % check for Rh only ctrl
            if ( contains(s(i).signal_filename,'Rhodamine') )
                ctrl_count = ctrl_count + 1;
                s(i).cancer_type = [cancerLookup{n,2} '_ctrl'];
            end
        end
        
        if find_count > 1 || ctrl_count > 1
            s(i).cancer_type = 'error';
        end
    end       
end


%% convert to table with categories

sT = struct2table(s);
sT.cancer_type = categorical(sT.cancer_type);

%% create density and ratio columns
sT.rh_nuc_density = sT.rh_sig_int_count ./ sT.nuc_voxels;
sT.rh_sig_density = sT.rh_sig_int_count ./ sT.rh_sig_voxels;
sT.rh_sig_density = sT.rh_sig_int_count ./ sT.rh_sig_voxels;
sT.cy5_sig_density = sT.cy5_sig_int_count ./ sT.cy5_sig_voxels;
sT.cy5_nuc_density = sT.cy5_sig_int_count ./ sT.nuc_voxels;
sT.rh_nuc_cyto_sig_ratio = sT.rh_sig_int_count ./ sT.rh_cyto_sig_int_count;
sT.cy5_nuc_cyto_sig_ratio = sT.cy5_sig_int_count ./ sT.cy5_cyto_sig_int_count;
sT.rh_nuc_vol_fraction = sT.rh_sig_voxels ./ sT.nuc_voxels;
sT.cy5_nuc_vol_fraction = sT.cy5_sig_voxels ./ sT.nuc_voxels;



end