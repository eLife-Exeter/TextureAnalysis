function drawTernaryMixedBackground(varargin)
% drawTernaryMixedBackground Draw guiding axes through origin and guiding
% circles for pairs of ternary texture groups.
%   drawTernaryMixedBackground draws guiding axes going through the origin
%   and guiding circles for a plot representing a mix of two ternary
%   texture groups.
%
%   Options:
%    'circles'
%       Vector of radii at which to draw guiding circles.
%    'axes'
%       Set to false to not draw the coordinate axes.
%    'circleopts'
%       Plot options for the guiding circles.
%    'axisopts'
%       Plot options for the coordinate axes.
%    'axisarrows'
%       If true, draw arrows at the end of the axis lines.
%    'axisrange'
%       Range for axis lines.
%    'arrowsize'
%       Size of arrows if 'axisarrows' is true.

% parse optional arguments
parser = inputParser;
parser.CaseSensitive = true;
parser.FunctionName = mfilename;

[~, colorDict] = get_palette();
defaultColors = containers.Map();
defaultColors('circle') = lighten(colorDict('gray'), 0.75);
defaultColors('axis') = lighten(colorDict('gray'), 0.75);

% parser.addParameter('circles', [1/4, 1/2, 3/4, 1], @(v) isempty(v) || (isvector(v) && isnumeric(v)));
parser.addParameter('circles', 1, @(v) isempty(v) || (isvector(v) && isnumeric(v)));
parser.addParameter('axes', true, @(b) isscalar(b) && islogical(b));
parser.addParameter('circleopts', {'color', defaultColors('circle'), 'linewidth', 0.5}, @(c) iscell(c));
parser.addParameter('axisopts', {'color', defaultColors('axis'), 'linewidth', 0.5}, @(c) iscell(c));
parser.addParameter('axisarrows', false, @(b) isscalar(b) && islogical(b));
parser.addParameter('axisrange', [-1, 1], @(x) isvector(x) && length(x) == 2 && isnumeric(x));
parser.addParameter('arrowsize', 0.05, @(x) isscalar(x) && isnumeric(x) && x > 0);

% show defaults if asked
if nargin == 1 && strcmp(varargin{1}, 'defaults')
    parser.parse;
    disp(parser.Results);
    return;
end

% parse
parser.parse(varargin{:});
params = parser.Results;

% we will overlay several graphical objects
wasHold = ishold;
hold on;

% we use this for drawing the circles
angleRange = linspace(0, 2*pi, 100);

% draw circles for orientation
circleRadii = params.circles;
for i = 1:length(circleRadii)
    radius = circleRadii(i);
    plot(radius*cos(angleRange), radius*sin(angleRange), params.circleopts{:});
end

% draw the main axes
plot(params.axisrange, [0 0], params.axisopts{:});
plot([0 0], params.axisrange, params.axisopts{:});

if params.axisarrows
    ax1 = params.axisrange(2);
    as1 = params.arrowsize;
    as2 = as1 * 8 / 5;
    plot(as1 * [-1 0 1], ax1 - as2 * [1 0 1], params.axisopts{:});
    plot(ax1 - as2 * [1 0 1], as1 * [-1 0 1], params.axisopts{:});
end

% revert hold state
if ~wasHold
    hold off;
end

end
