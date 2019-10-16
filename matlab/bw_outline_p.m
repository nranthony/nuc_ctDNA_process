function bw_out = bw_outline_p(img, params)

if (size(img,3)>1)
    img = max(img,[],3);
end

if (~islogical(img))
    img = imbinarize(img);
end

se = strel('disk',params.wid,4);
dimg = imdilate(img, se);
bw_out = xor(dimg,img);

end