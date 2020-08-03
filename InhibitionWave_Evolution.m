function [treeArray, fireArray] = InhibitionWave_Evolution(treeArray, fireArray, pIgnite, pSpread, clusterDistance, clusterThreshold, pCluster, pGrow, growthRate, ridgeArray, sz, nn, igniteXLoc, igniteYLoc)
%% Step 1 - Burning turns the current cell empty
indList = find(fireArray == 1); % index is position going down columns one by one
% [fRow, fCol] = find(fireArray==1);

treeArray(indList) = 0;
fireArray(indList) = 0;

%% Step 2 - Burning spreads to neighbors

if length(indList) > 200
    % LEGI
    
    clusterCount = zeros(length(indList),1);
    for i = indList
        if ismember( i + [-clusterDistance:clusterDistance] + ([-clusterDistance:clusterDistance]*sz(1)), indList)
            clusterCount(i) = clusterCount(i) + 1;
        end
    end

    regList = zeros(length(indList),1);
    clusterList = zeros(length(indList),1);
    clusterlessList = zeros(length(indList),1);
    if clusterCount(1:length(clusterCount)) > clusterThreshold(2)*(((2*clusterDistance)+1)^2)
        clusterList(1:length(clusterCount)) = indList(1:length(clusterCount));
    elseif clusterCount(1:length(clusterCount)) < clusterThreshold(1)*(((2*clusterDistance)+1)^2)
        clusterlessList(1:length(clusterCount)) = indList(1:length(clusterCount));
    else
        regList(1:length(clusterCount)) = indList(1:length(clusterCount));
    end 


    if ~isempty(regList)
        [xArray, yArray,  ~, ~, ~, neighborArray] = GetCandidateNeighborsAndDirectionWeights(sz, nn, regList);
        fireList = sub2ind(sz, xArray, yArray);
        treeList = treeArray(fireList);
        treeList = rand(size(treeList)) < pSpread.*treeList.*ridgeArray(fireList).*neighborArray;
        fireArray(fireList(treeList)) = 1;
    end

    if ~isempty(clusterList)
        [xUpArray, yUpArray,  ~, ~, ~, neighborUpArray] = GetCandidateNeighborsAndDirectionWeights(sz, nn, clusterList);
        fireUpList = sub2ind(sz, xUpArray, yUpArray);
        treeUpList = treeArray(fireUpList);
        treeUpList = rand(size(treeUpList)) < (1+pCluster(2))*pSpread.*treeUpList.*ridgeArray(fireUpList).*neighborUpArray;
        fireArray(fireUpList(treeUpList)) = 1;
    end

    if ~isempty(clusterlessList)
        [xDownArray, yDownArray,  ~, ~, ~, neighborDownArray] = GetCandidateNeighborsAndDirectionWeights(sz, nn, clusterlessList);
        fireDownList = sub2ind(sz, xDownArray, yDownArray);
        treeDownList = treeArray(fireDownList);
        treeDownList = rand(size(treeDownList)) < (1-pCluster(1))*pSpread.*treeDownList.*ridgeArray(fireDownList).*neighborDownArray;
        fireArray(fireDownList(treeDownList)) = 1;
    end
    
else
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