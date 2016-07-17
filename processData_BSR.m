function dataNI = processData_BSR(varargin)
% processData_BSR Process image files from the BSR Database, calculating
% texture statistics.
%
%   This calls 'processData' with appropriate options; any options passed
%   to this function are redirected to 'processData'.
%
%   See also: processData.

% names of files to be used are read from imgNamesFile
imgNamesFile='./BSR_Test_Index.txt';
% files are located in imgDirectory
imgDirectory='../BSR/BSDS500/data/images/train/';

% similar for the files that will be used to get the whitening filter
%imgNamesFile_filter='./Natural_Images_Large_NoSky_Index.txt';
%imgDirectory_filter = './NaturalImages/';
imgNamesFile_filter='Natural_NoSky_Plus_Bsr_Index.txt';
imgDirectory_filter='NaturalImages/';

% name and directory of output statistics file
analysesDirectory='./BSRAnalyses/';

% which image to be considered most in-focus
focusImg = 25;

dataNI = processData(imgNamesFile, imgDirectory, ...
    imgNamesFile_filter, imgDirectory_filter, ...
    analysesDirectory, 'focusImg', focusImg, ...
    varargin{:});

end
