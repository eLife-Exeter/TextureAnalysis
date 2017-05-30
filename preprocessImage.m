function [image, varargout] = preprocessImage(image0, varargin)
% preprocessImage Preprocess the image by going to log space, block
%   averaging, filtering, and quantizing colors.
%   image = preprocessImage(image0, blockAF) preprocesses the image by
%   taking the logarithm of the entries and block averaging using the given
%   factor. `image0` can either be the filename for an image, or a matrix
%   containing the image data itself. If it is a file name, it is read
%   using `loadLUMImage`.
%
%   preprocessImage(image0, blockAF, filter) also performs a filtering with
%   the given `filter` after the logarithm and the block averaging. See the
%   options below for more control over the filtering.
%
%   preprocessImage(image0, blockAF, filter, nLevels, [patchSize]) ends by
%   discretizing the gray levels in the image, resulting in an image with
%   `nLevels` levels. This is done for the whole image at once if
%   `patchSize` is missing, or using patches or surround areas of size
%   `patchSize` if it is present (see `quantize`). See the options below
%   for more control over the quantization. Setting `filter` to an empty
%   matrix performs the discretization without the filtering.
%
%   [image, origImage] = preprocessImage(...) also returns the original
%   image, before any processing. This is useful if the first argument is a
%   file name.
%
%   [image, mask1, mask2, ..., maskN, origImage] = ...
%       preprocessImage(image0, mask1, mask2, ..., maskN, ...) preprocesses
%   the image together with a number of 'masks' -- images that will be
%   downsampled without averaging and cropped if necessary, but not
%   filtered or quantized. This is useful to ensure that the masks are
%   aligned with the preprocessed image. Note that since the downsampling
%   is done without any averaging, masks with high-frequency components can
%   lead to confusing results. In that case, it might make more sense to
%   not downsample the masks, but instead use the `crops` output argument
%   (see below) to convert between coordinates in the masks and coordinates
%   in the preprocessed image.
%
%   [..., origImage, logImage, averagedImage, filteredImage] = preprocessImage(...)
%   also returns copies of the image along the preprocessing pipeline.
%
%   [..., crops] = preprocessImage(...) also returns a structure indicating
%   where the images returned along the pipeline fit on the original image
%   coordinates. So, crops.averaged, crops.filtered, and crops.final are
%   vectors of four elements [row1, col1, row2, col2] indicating the ranges
%   of rows and columns in the original image that correspond to each of
%   the steps along the preprocessing pipeline. These can be used to convert
%   between coordinates in these images, and coordinates in the original
%   image.
%
%   Options:
%    'averageType': char
%       This is passed to `blockAverage` to set the type of averaging that
%       is performed.
%       (default: use `blockAverage`s default)
%    'doLog': logical
%       Set to `false` to skip the conversion of the image to logarithmic
%       space.
%       (default: true)
%    'filterType': char
%       This is passed to `filterImage` to set the type of filtering that
%       is performed.
%       (default: use `filterImage`s default)
%    'quantType': char
%       This is passed to `quantize` to set the type of color quantization
%       that is used.
%       (default: use the `quantize` default)
%    'threshold': double
%       Threshold used by the conversion to logarithmic space to avoid
%       taking the logarithm of zero or negative numbers.
%       (default: use `convertToLog`s default)
%
%   See also: loadLUMImage, convertToLog, blockAverage, filterImage, quantize.

% check for masks
firstNonMaskIdx = find(~cellfun(@(m) isreal(m) && ismatrix(m) && ~isscalar(m), ...
    varargin), 1);
if isempty(firstNonMaskIdx) || firstNonMaskIdx == 1
    masks = {};
else
    masks = varargin(1:firstNonMaskIdx-1);
    varargin = varargin(firstNonMaskIdx:end);
end

% parse optional arguments
parser = inputParser;
parser.CaseSensitive = true;
parser.FunctionName = mfilename;

parser.addRequired('blockAF', @(n) isscalar(n) && isreal(n) && n >= 1);
parser.addOptional('filter', [], @(m) isempty(m) || (ismatrix(m) && isreal(m)));
parser.addOptional('nLevels', [], @(n) isempty(n) || (isnumeric(n) && isscalar(n) && n > 1));
parser.addOptional('patchSize', [], @(p) isempty(p) || (isnumeric(p) && isscalar(p) && p >= 1) || ...
    (isnumeric(p) && isvector(p) && numel(p) == 2 && all(p >= 1)));

parser.addParameter('averageType', [], @(s) isempty(s) || (ischar(s) && isvector(s)));
parser.addParameter('doLog', true, @(b) islogical(b) && isscalar(b));
parser.addParameter('filterType', [], @(s) isempty(s) || (ischar(s) && isvector(s)));
parser.addParameter('quantType', [], @(s) isempty(s) || (ischar(s) && isvector(s)));
parser.addParameter('threshold', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x > 0));

% parse
parser.parse(varargin{:});
params = parser.Results;

% load the image from file, if needed
if ischar(image0)
    image = loadLUMImage(image0);
else
    image = image0;
end

% keep track of the original image
origImage = image;

if params.doLog
    if isempty(params.threshold)
        image = convertToLog(image);
    else
        image = convertToLog(image, params.threshold);
    end
end
logImage = image;

% block average
if params.blockAF > 1
    if isempty(params.averageType)
        avgOpts = {};
    else
        avgOpts = {params.averageType};
    end
    image = blockAverage(image, params.blockAF, avgOpts{:});
    
    % block average the masks, if any
    for i = 1:numel(masks)
        if ~isempty(masks{i})
            masks{i} = blockAverage(masks{i}, params.blockAF, 'sub'); %#ok<AGROW>
        end
    end
end
averagedImage = image;

if ~isempty(params.filter)
    % filter
    if isempty(params.filterType)
        filterOpts = {};
    else
        filterOpts = {params.filterType};
    end
    [image, filterCrop] = filterImage(image, params.filter, filterOpts{:});
    
    % crop the masks, if necessary
    for i = 1:numel(masks)
        if ~isempty(masks{i})
            masks{i} = masks{i}(filterCrop(1):filterCrop(3), filterCrop(2):filterCrop(4)); %#ok<AGROW>
        end
    end
else
    filterCrop = [1 1 size(image)];
end
filteredImage = image;

if ~isempty(params.nLevels)
    % discretize colors
    if isempty(params.patchSize)
        if ~isempty(params.quantType)
            error([mfilename ':badqtype'], 'Non-default quantization types require a patch size.');
        end
        [image, qCrop] = quantize(image, params.nLevels);
    else        
        if isempty(params.quantType)
            quantOpts = {};
        else
            quantOpts = {params.quantType};
        end
        [image, qCrop] = quantize(image, params.nLevels, params.patchSize, quantOpts{:});
    end
    
    % crop the masks, if necessary
    for i = 1:numel(masks)
        if ~isempty(masks{i})
            masks{i} = masks{i}(qCrop(1):qCrop(3), qCrop(2):qCrop(4)); %#ok<AGROW>
        end
    end
else
    qCrop = [1 1 size(image)];
end

% update the crops
crops.averaged = [1 1 size(averagedImage)*params.blockAF];
% filtered crop is in scaled coordinates
crops.filtered = [(filterCrop(1:2)-1)*params.blockAF+1 filterCrop(3:4)*params.blockAF];
% combine filter with quantization crop to obtain coordinates in scaled but
% non-trimmed image
qfCropOrigin = filterCrop(1:2) + qCrop(1:2) - 1;
qfCrop = [qfCropOrigin qfCropOrigin+qCrop(3:4)-1];
% scale back to coordinates in original image
crops.final = [(qfCrop(1:2)-1)*params.blockAF+1 qfCrop(3:4)*params.blockAF];

% return the image with the masks, if there are any masks
varargout = [masks {origImage logImage averagedImage filteredImage crops}];

end
