function bw_out = smth_otsu_fill_p(img, params)

%disp(params);

if params.gauss_smth > 0 && params.gauss_smth <= 20
    img_smth = imgaussfilt3(img, params.gauss_smth);
elseif params.gauss_smth > 20
    disp('Sigma too large for imgaussfilt3.  Gauss smoothing step skipped.');
    img_smth = img;
else
    disp('Sigma for imgaussfilt3 must be positive.  Gauss smoothing step skipped.');
    img_smth = img;
end

bw_img_smth = otsu_bw(img_smth);
bw_out = imfill(bw_img_smth, 'holes');

end
