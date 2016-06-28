% loadImageAnalyses Load the image patch statistics from file.
%   This loads the statistics generated by a prior call to
%   generateStatFiles.
%
%   All the files from the folder pointed to by the variable 'analysesDirectory'
%   are loaded. The data is stored in a structure called 'dataNI', which
%   has a single member, a structure array called 'indA'. The fields of
%   this structure are:
%    ev:
%       Values of the 10 independent texture parameters for all the image
%       patches. (see analyzeImageSetModNoPC)
%    covM:
%       Covariance matrix for the texture parameters.
%       NOTE: compared to analyzeImagesSetModNoPC, indices 7 and 8 are
%             flipped in this script's covM matrices. This matches the
%             order used in the psychophysics experiments.
%    ic:
%       Contains information regarding the images from which the patches
%       come, and the location of each patch within the image.
%    N:
%       Block average factor used in the analysis.
%    R:
%       Patch size (after block averaging).
%    sharpness:
%       Vector of sharpness values for each image patch. (see getImgStats)
%
%   See also: generateStatFiles, analyzeImageSetModNoPC, getImgStats.

dr0 = analysesDirectory;
dr  = dir(fullfile(dr0,analysesFileName,'*.mat'));

dataNI=struct;
disp(['Number of analyses: ' num2str(length(dr))])
for i=1:length(dr),
    load(strcat(dr0,dr(i).name));
    dataNI.indA(i).ev   = data.ev;
    
    %reorder covM to align with psychophysics
    data.covM(:,[7 8])  = data.covM(:,[8 7]);
    data.covM([7 8],:)  = data.covM([8 7],:);
    dataNI.indA(i).covM = data.covM;
    
    dataNI.indA(i).ic   = data.imageCoordinates;
    dataNI.indA(i).N    = data.blockAvgFactor;
    dataNI.indA(i).R    = data.patchSize;
    dataNI.indA(i).sharpness = data.sharpness;
    disp(['Loading Analysis ',num2str(i)])
end

clear data dr dr0 i