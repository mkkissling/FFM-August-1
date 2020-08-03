%% Forest Fire Model
clear
close all
clc

%% Model parameters

% Global parameters
sz = [306, 606];
nn = 48;
iterMax = 20000;

% Tree growth parameters
pGrow = 0.00;
rGrow = 0.6;

% Surface parameters
s1 = 9;
s2 = 16;
v1 = 0.40; % how fast is spreading ATOP RIDGE
v2 = 0.10; % how fast is spreading IN TROUGH
v3 = 1.0; % how fast is spreading ON THE SIDE OF RIDGE
v4 = 0.70; % dictates how fast is preading in OPEN AREA
xRidgeStart = 0.5;
border = 3;
ridgeArray = GetRidgeArray(sz, s1, s2, v1, v2, v3, v4, xRidgeStart, border);

% Fire spreading parameters
igniteXLoc = 201;
igniteYLoc = 301;
pIgnite = 1;
pSpread = 0.85;

% Initialize variables
treeDensity = 0.8;
treeArray = rand(sz) < treeDensity;
fireArray = zeros(sz);
recentFireArray = zeros(sz);

%% Save movie
writerObj = VideoWriter([...
    'C:\Users\mkissling3464\Documents\TREND 2020\Progress\FFM Images\', ...
    'Refraction Study nn=48', ...
    ', pSpread = ', num2str(pSpread), ', take = ', num2str(3) ...
    '.avi']);  
writerObj.FrameRate = 10;
open(writerObj);

%% Simulate

h1 = imagesc(zeros([sz, 3])); axis equal off; drawnow;
numTroughs = round( (sz(1)-(2*border))/(s1 + s2) );
%troughPenetrance = zeros(numTroughs, 1);

iter = 1;
while iter < iterMax
    
    % Evolution:
    [treeArray, fireArray] = ForestFireEvolution_Ridges(treeArray, fireArray, pIgnite, pSpread,  pGrow, rGrow, ridgeArray, sz, nn, igniteXLoc, igniteYLoc);
%     [ridgeFire, incidentAngles] = grabTrough(fireArray, sz, s1, s2, xRidgeStart, border, igniteXLoc, igniteYLoc);
%     [troughFireIndicesX] = perItTroughFireIndeX(ridgeFire);
    
    %troughPenetrance = cat(2, troughPenetrance, troughFireIndicesX);

    if ~ismember(1, fireArray)
        iterMax = iter;
    end
    
    % Plot
    if 1
        [x, y] = find(fireArray == 1); % set the color of the fire to red
        imrgb_fire = cat(3, zeros(sz), treeArray, zeros(sz));
        rInd = sub2ind([sz, 3], x, y, 1 + zeros(size(x)));
        gInd = sub2ind([sz, 3], x, y, 2 + zeros(size(x)));
        bInd = sub2ind([sz, 3], x, y, 3 + zeros(size(x)));
        imrgb_fire(rInd) = 1;
        imrgb_fire(gInd) = 0;
        imrgb_fire(bInd) = 0;

        set(h1, 'cdata', imrgb_fire);
        drawnow;
    end
    
    F(iter) = getframe(gcf);
    iter = iter + 1;

end

%% Saving movie with structure
for i = 1:length(F)
    frame = F(i).cdata;
    writeVideo(writerObj, frame);
end
close(writerObj);

%%
% maxTroughPenetrance = max(troughPenetrance, [], 2);
