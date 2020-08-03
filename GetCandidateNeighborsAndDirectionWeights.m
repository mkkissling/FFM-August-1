function [xArray, yArray, xDir, yDir, dirWeight, NeighborType] = GetCandidateNeighborsAndDirectionWeights(sz, nn, indList, varargin)
% Find candidate neighbors
[xList, yList] = ind2sub(sz, indList);

if nn == 4 % Von Neumann neighborhood
    xArray = mod(xList + [-1 1 0 0] - 1, sz(1))+1; 
    yArray = mod(yList + [0 0 -1 1] - 1, sz(2))+1;
    xDir = zeros(size(xList)) + [-1 1 0 0];
    yDir = zeros(size(yList)) + [0 0 -1 1];
    NeighborType = zeros(size(xList)) + [1 1 1 1];
    
elseif nn == 8  %corrected diagonal neighborhood
    xArray = mod(xList + [-1 -1 -1 0 0 0 1 1 1] - 1, sz(1)) + 1;
    yArray = mod(yList + [-1 0 1 -1 0 1 -1 0 1] - 1, sz(2)) + 1;
    xDir = zeros(size(xList)) + [-1 -1 -1 0 0 0 1 1 1];
    yDir = zeros(size(yList)) + [-1 0 1 -1 0 1 -1 0 1];
%     NeighborType = zeros(size(xList)) + ...
%         [1 1 1 1 0 1 1 1 1];
    NeighborType = zeros(size(xList)) + ...
        [(2^-0.5) 1 (2^-0.5) 1 0 1 (2^-0.5) 1 (2^-0.5)];

elseif nn == 24  %5 by 5 smoothed
    i = -2:2;
    j = -2:2;
    [I,J] = meshgrid(i, j);
    xArray = mod(xList + reshape(J,1,[]) - 1, sz(1)) + 1;
    yArray = mod(yList + reshape(I,1,[]) - 1, sz(2)) + 1;
    xDir = zeros(size(xList)) + reshape(J,1,[]);
    yDir = zeros(size(yList)) + reshape(I,1,[]);
    %NeighborType = zeros(size(xList)) + [1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1];
    NeighborType = zeros(size(xList)) + ...
        [ 8^-0.5 5^-0.5 4^-0.5 5^-0.5 8^-0.5 ...
        5^-0.5 2^-0.5 1 2^-0.5 5^-0.5 ...
        0.5 1 0 1 0.5 ...
        5^-0.5 2^-0.5 1 2^-0.5 5^-0.5  ...
        8^-0.5 5^-0.5 4^-0.5 5^-0.5 8^-0.5 ];
 
elseif nn == 48  % Moore neighborhood
    i = -3:3;
    j = -3:3;
    [I,J] = meshgrid(i, j);
    xArray = mod(xList + reshape(J,1,[]) - 1, sz(1)) + 1;
    yArray = mod(yList + reshape(I,1,[]) - 1, sz(2)) + 1;
    xDir = zeros(size(xList)) + reshape(J,1,[]);
    yDir = zeros(size(yList)) + reshape(I,1,[]);
    NeighborType = zeros(size(xList)) + ...
        [ 18^-0.5 13^-0.5 10^-0.5 3^-1 10^-0.5 13^-0.5 18^-0.5 ...
        13^-0.5 8^-0.5 5^-0.5 0.5 5^-0.5 8^-0.5 13^-0.5 ...
        10^-0.5 5^-0.5 2^-0.5 1 2^-0.5 5^-0.5 10^-0.5 ...
        3^-1 2^-1 1 0 1 2^-1 3^-1 ...
        10^-0.5 5^-0.5 2^-0.5 1 2^-0.5 5^-0.5 10^-0.5 ...
        13^-0.5 8^-0.5 5^-0.5 0.5 5^-0.5 8^-0.5 13^-0.5 ...
        18^-0.5 13^-0.5 10^-0.5 3^-1 10^-0.5 13^-0.5 18^-0.5];
%     NeighborType = zeros(size(xList)) + ...
%         [1 1 1 1 1 1 1 ...
%         1 1 1 1 1 1 1 ...
%         1 1 1 1 1 1 1 ...
%         1 1 1 0 1 1 1 ...
%         1 1 1 1 1 1 1 ...
%         1 1 1 1 1 1 1 ...
%         1 1 1 1 1 1 1];
else
    error('incorrect nn');
end

% Evaluate
badIdx = ismember(xArray, xList) & ismember(yArray, yList);
xArray = squeeze(xArray(~badIdx));
yArray = squeeze(yArray(~badIdx));
xDir = squeeze(xDir(~badIdx));
yDir = squeeze(yDir(~badIdx));
NeighborType = squeeze(NeighborType(~badIdx));
if length(varargin) == 2
    efStrengthUD = varargin{1};
    efStrengthLR = varargin{2};
    dirWeight = (100 - xDir*efStrengthUD + yDir*efStrengthLR)/100;
else
    dirWeight = [];
end

end