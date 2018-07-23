function setupTernaryGuide(groupInfo, varargin)
% setupTernaryGuide Set up the axes with appropriate guides for
% representing a ternary texture plane.
%   setupTernaryGuide(nGroups) prepares the current axes for representing a
%   ternary texture plane with `nGroups` group. `nGroups` can be 1 or 2.
%   This sets `axis` to 'equal' and draws the appropriate guides.
%
%   setupTernaryGuide(groupName) uses the group name to infer the number of
%   groups. It also uses the group name for labeling.
%
%   Options:
%    'triangleOptions'
%       Options to pass to `drawTernaryTriangle`.
%
%   See also: drawTernaryTriangle, drawTernaryMixedBackground.

% parse optional arguments
parser = inputParser;
parser.CaseSensitive = true;
parser.FunctionName = mfilename;

parser.addParameter('triangleOptions', {}, @(c) iscell(c) && isvector(c));

% show defaults if requested
if nargin == 1 && strcmp(groupInfo, 'defaults')
    parser.parse;
    disp(parser.Results);
    return;
end

% parse options
parser.parse(varargin{:});
params = parser.Results;

% handle the two kinds of input
if ischar(groupInfo)
    groupName = groupInfo;
    nGroups = 1 + sum(groupName == ';');
else
    nGroups = groupInfo;
    groupName = [];
end

% draw guides
switch nGroups
    case 1
        drawTernaryTriangle(params.triangleOptions{:});
    case 2
        if isempty(groupName)
            groupOpts = {'Group 1', 'Group 2'};
        else
            groupOpts = strsplit(groupName, ';');
        end
        drawTernaryMixedBackground(groupOpts{:});
    otherwise
        error([mfilename ':badngrp'], 'This function only works with single groups and pairs of groups.');
end

axis equal;

end