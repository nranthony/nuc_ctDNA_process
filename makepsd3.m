function [fx, fy, fz, psd, imgfft] = makepsd3(img, pad, umpx, umpz)

    sx = size(img,1);
    sy = size(img,2);
    sz = size(img,3);
        
    % here we have sampling frequency of 1 AU of length per pixel
    % should be scaled to be, e.g. 90 nm / px
    % deltaF = sampleFreq / Nsamples;
    dfx = umpx / sx;
    dfy = umpx / sy;
    dfz = umpz / sz;

    % padding to increasing fft resolution
    if (pad < 0 )
        mfactor = abs(pad);
        lxpad = sx .* mfactor;
        lypad = sy .* mfactor;
        lzpad = sz .* mfactor;
    else
        lxpad = 2.^(nextpow2(sx) + pad);
        lypad = 2.^(nextpow2(sy) + pad);
        lzpad = 2.^(nextpow2(sz) + pad);
    end
    
    imgfft = fftn(img,[lxpad,lypad,lzpad]);
    psd = log(1 + abs(fftshift(imgfft)));
    %psd = log((abs(fftshift(imgfft)).^2));
    %psd = (abs(fftshift(imgfft)).^2);
    
    fx = -umpx/2:dfx:umpx/2;
    fy = -umpx/2:dfy:umpx/2;
    fz = -umpz/2:dfz:umpz/2;
    
end