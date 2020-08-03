function [treeArray, fireArray] = ForestFireEvolution_Ridges(treeArray, fireArray, pIgnite, pSpread,  pGrow, growthRate, ridgeArray, sz, nn, igniteXLoc, igniteYLoc)
%% Step 1 - Burning turns the current cell empty
indList = find(fireArray == 1);
treeArray(indList) = 0;
fireArray(indList) = 0;

%% Step 2 - Burning spreads to neighbors

if ~isempty(indList)
    [xArray, yArray,  ~, ~, ~, neighborArray] = GetCandidateNeighborsAndDirectionWeights(sz, nn, indList);
    fireList = sub2ind(sz, xArray, yArray);
    treeList = treeArray(fireList);
    treeList = rand(size(treeList)) < pSpread.*treeList.*ridgeArray(fireList).*neighborArray;
    fireArray(fireList(treeList)) = 1;
    
end

%% Step 3 - Trees in specified location ignite with some probability
indList = treeArray > 0;
fireList = zeros(sz);

fireList(igniteYLoc, igniteXLoc) = rand(1,1) < pIgnite;

fireArray(indList(:) & fireList(:)) = 1;

%% Step 4 - Empty spaces are filled with trees
treeList = rand(prod(sz), 1) < pGrow;
idx = (treeArray(:) < 1) & treeList;
treeArray(idx) = treeArray(idx) + growthRate;