function [bw_img, T, imgmax] = otsu_bw(img)

[N,~] = histcounts(img);
T = otsuthresh(N);
imgmax = max(max(max(img)));
bw_img = imbinarize(img, imgmax*T);

end
