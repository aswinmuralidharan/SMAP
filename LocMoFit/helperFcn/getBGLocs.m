function [x,y,z] = getBGLocs(numAll, roiSize, finalROISize, pExp_Offset, dataDim)
switch dataDim
    case 3
        % cilinderical
        finalVol = pi*(finalROISize/2)^2*finalROISize;
        % cubic
        simVol = roiSize^3;
        ratio = simVol/finalVol;
        numAll = round(numAll*ratio);
    case 2
        % circular
        finalVol = pi*(finalROISize/2)^2;
        % square
        simVol = roiSize^2;
        ratio = simVol/finalVol;
        numAll = round(numAll*ratio);
end

pObs_Offset = rand([numAll 1]);
lKept = pExp_Offset>pObs_Offset;
numOfLabels_offset = sum(lKept);

x_offset = rand([numOfLabels_offset 1]);
y_offset = rand([numOfLabels_offset 1]);
x = x_offset*roiSize-roiSize/2;
y = y_offset*roiSize-roiSize/2;

if dataDim == 3
    % for 3D model
    z_offset = rand([numOfLabels_offset 1]);
    z = z_offset*roiSize-roiSize/2;
else
    z = [];
end
end