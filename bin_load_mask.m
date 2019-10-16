function mask = bin_load_mask(path, froot)
%  here path is full or rel path to the file
% froot is the file root string sans .bin and _dims.bin

fbin = fopen(fullfile(path, [froot '.bin']), 'r');
fdims = fopen(fullfile(path, [froot '_dims.bin']), 'r');

bin = fread(fbin, 'uint8');
dims = fread(fdims, 'uint16');

% reshape here
mask = reshape(bin,dims');

fclose(fbin);
fclose(fdims);

end