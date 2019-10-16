function elpsmask = ellipsoid_mask(xm,ym,zm,cx,cy,cz,a,b,c)
%
% Syntax: elpsmask = ellipsoid_mask(xm,ym,zm,cx,cy,cz,a,b,c)
%
% creates 3D ellipsoid mask centered at cx,cy,cz with axis lengths a,b,c

elpsmask = zeros(size(xm));
elpsmask = ((xm - cx)/a).^2 + ((ym - cy)/b).^2 + ((zm - cz)/c).^2 <= 1;

elpsmask = elpsmask .* 1.0;

end