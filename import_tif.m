function data = import_tif(fullpath, varargin)
% IMPORT_TIF  Import tif data files
%   data = IMPORT_TIF(fullpath)  loads all layers of tif file
%
%   data = IMPORT_TIF(fullpath, varargin)  loads subset of interleaved tif
%   files.  varargin{1} = # of interleaved layers, and varargin{2} = leaf
%   #.
%

%disp(fullpath);
%class(fullpath)
info = imfinfo(fullpath);
li = length(info);
intlev = 1;
ofst = 0;

if (~isempty(varargin))
    intlev = varargin{1};
    r = rem(li,intlev);
    if (r > 0)
        disp('Total number of tif layers not exact multiple of interleave value provided.');
        return
    end
    
    if (~isempty(varargin{2}))
        leafn = varargin{2};
        ofst = intlev - leafn;
        if (ofst < 0)
            disp('Interleave number greater than available interleaving.');
        return
        end            
    else
        leafn = 1;
        ofst = intlev - leafn;
    end
    
    
end

steps = li / intlev;

%data = zeros(info(1).Width,info(1).Height,length(info),'uint16');
data = zeros(info(1).Height, info(1).Width, steps);

ctx = 1;

for i = 1:steps
    
    data(:,:,ctx) = imread(fullpath,i*intlev-ofst);
    ctx = ctx + 1;
    
end

end