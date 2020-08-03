function ridgeArray = GetRidgeArray(sz, s1, s2, v1, v2, v3, v4, xRidgeStart, border)
% sz = 200 x 200
% s1 = 10
% s2 = 5
% v1 = trough strength
% v2 = ridge strength

break1 = v4*ones(s1, (sz(2)*xRidgeStart) - border);
ridge = v1*ones(s1, (sz(2)*(1-xRidgeStart))- border);
vertedgeR = zeros(s1, border);   % zero spreading on borders

break2 = v4*ones(1, (sz(2)*xRidgeStart) - border);
angular = v3*ones(1, (sz(2)*(1-xRidgeStart)) - border);
vertedgeA = zeros(1, border);

break3 = v4*ones(s2-2, (sz(2)*xRidgeStart) - border);
trough = v2*ones(s2-2, sz(2)*(1-xRidgeStart) - border);
vertedgeT = zeros(s2-2, border);

horizedge = zeros(border, sz(2));

ridgeArray = [horizedge; ...
    repmat([vertedgeR, break1, ridge, vertedgeR; ...
    vertedgeA, break2, angular, vertedgeA; ...
    vertedgeT, break3, trough, vertedgeT; ...
    vertedgeA, break2, angular, vertedgeA], ...
    200, 1)]; ...   %repeat many times (increase if necessary); top edge is bottom edge
    
ridgeArray = ridgeArray(1:sz(1), :) ;
end