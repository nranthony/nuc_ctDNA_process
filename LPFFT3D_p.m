function lpimg = LPFFT3D_p(img, params)
%LPFFT3D - Long Pass Fast Fourier Transform in 3 Dimensions
%
% Syntax: lpimg = LPFFT3D(img, pad, pc)
%
% input image: img
% padding: pad
% percentage -> long pass cut off: pc
% smoothing of ellipsoid Fourier domain mask: smth

% pad >= 0, padding uses nextpower, with > 0 adding a power to nextpower
% pad < 0 multiplies the img size by abs(pad)
[fx, fy, fz, psd, imgfft] = makepsd3(img, params.pad, params.umpx, params.umpz);

% determine size of low pass filter
% % of width of the fft - i.e. scales with increased padding
% a,b,c are %'s of below sx, sy, sz; scale z % based on ...?
sx = size(imgfft,1);
sy = size(imgfft,2);
sz = size(imgfft,3);

[xm, ym, zm] = meshgrid(-sx/2:sx/2-1,-sy/2:sy/2-1,-sz/2:sz/2-1);

% cx = size(imgfft,1)/2 + 1;
% cy = size(imgfft,2)/2 + 1;
% cz = size(imgfft,3)/2 + 1;
% centers not needed as meshgrids are signed about zero
cx = 0;
cy = 0;
cz = 0;

a = params.pc * ( length(fx) - 1 );
b = a;
c = params.pc * params.fft_xz_factor * params.umpx/params.umpz * ( length(fz) - 1 );

elpsmask = ellipsoid_mask(xm,ym,zm,cx,cy,cz,a,b,c);

e1s = round(sx/2-a+1);
e1f = round(sx/2+a);
e2s = round(sy/2-b+1);
e2f = round(sy/2+b);
e3s = round(sz/2-c+1);
e3f = round(sz/2+c);

elptmp = elpsmask(e1s:e1f, e2s:e2f, e3s:e3f);
if params.fft_smth > 0 
    elpTmpSmth = imgaussfilt3(elptmp,params.fft_smth);
else
    elpTmpSmth = elptmp;
end

elpmasksmth = elpsmask;
elpmasksmth(e1s:e1f, e2s:e2f, e3s:e3f) = elpTmpSmth(:, :, :);

Hem = fftshift(elpmasksmth);
LPFS_img = Hem .* imgfft;
LPF_img = real(ifftn(LPFS_img));
%LPF_img_ph = imag(ifftn(LPFS_img));

lpimg = LPF_img(1:size(img,1), 1:size(img,2), 1:size(img,3));
%LPF_img_ph = LPF_img_ph(1:size(img,1), 1:size(img,2), 1:size(img,3));

end