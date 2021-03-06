% make plots comparing NI predictions to measured PP thresholds for third
% and fourth order ternary texture planes

%% Load the data

pp = loadTernaryPP(fullfile('data', 'mtc_soid_xlsrun_summ.mat'), ...
    'subjects', '*');

%% Load the NI predictions

ni = open(fullfile('save', 'TernaryNIPredictions_PennNoSky_2x32_square.mat'));

%%

uniqueSubjects = unique(pp.subjects);
% uniqueColors = lines(length(uniqueSubjects));
uniqueColors = get_palette();
uniqueColors = [uniqueColors(1:5, :) ; uniqueColors(7, :)];
colorMap = containers.Map(uniqueSubjects, num2cell(uniqueColors, 2));

% color for NI
colorMap('subject') = uniqueColors(1, :);

fig = figure;
fig.Units = 'inches';
totalX = 5.08;
totalY = 2.54;
fig.Position = [2 2 totalX totalY];

ax = zeros(7, 1);
figX = 1.27;
figY = 1.27;
factorX = 0.8;
factorY = 0.8;
edgeX = 0.04;
edgeY = -0.08;
crtX = edgeX;
crtY = totalY - figY - edgeY;
for i = 1:length(ax)
    crtAx = axes;
        
    crtAx.Units = 'inches';
%     crtAx.OuterPosition = [crtCol*figX + edgeX totalY - (crtRow+1)*figY - edgeY ...
%         figX*factorX figY*factorY];
    crtAx.OuterPosition = [crtX crtY figX*factorX figY*factorY];
    ax(i) = crtAx;
    
    if mod(i, 4) == 0
        crtX = edgeX;
        crtY = crtY - figY;
    else
        crtX = crtX + figX;
        if crtX > totalX
            crtX = edgeX;
            crtY = crtY - figY;
        end
    end
end

plusMinus = '+-';
plotTernaryMatrix({ni.predictions, pp}, 'ellipse', false, ...
    'groupMaskFct', @(g) length(g) > 6 && sum(g == ';') == 0, ...
    'beautifyOptions', {'ticks', 'off', 'ticklabels', false, ...
        'titlesize', 12, 'titleweight', 'normal', 'noaxes', true, ...
        'fontscale', 0.667}, ...
    'triangleOptions', {'edgelabels', 'none', 'axisovershoot', 0}, ...
    'limits', 1.5, ...
    'plotterOptions', {'fixedAxes', ax}, ...
    'titleShift', [0 -0.5], 'titleAlignment', {'center', 'bottom'}, ...
    'labelOptions', {'FontSize', 8, 'subscriptSpacing', -0.42, ...
        'coeffToStr', @(i) plusMinus(i), 'squareSubscripts', true}, ...
    'colorFct', colorMap);

preparegraph;

set(fig, 'Renderer', 'painters');

safePrint(fullfile('figs', 'draft', 'higherOrderThresholds'));

%% Plot legend

fig1 = figure;
fig1.Units = 'inches';
fig1.Position(3:4) = [1.5 1.2];
hold on;
h = zeros(1 + length(uniqueSubjects), 1);
mask = cellfun(@(g) length(g) > 6 && sum(g == ';') == 0, pp.groups);
usedSubjects = unique(pp.subjects(mask));
for i = 1:length(uniqueSubjects)
    if ~ismember(uniqueSubjects{i}, usedSubjects)
        continue;
    end
    h(i) = plot(nan, nan, 'x', 'color', uniqueColors(i, :), 'markersize', 5);
end
h(end) = plot(nan, nan, '.', 'color', colorMap('subject'), 'markersize', 8);
legend(h(h ~= 0), [uniqueSubjects(h(1:end-1) ~= 0) ; {'prediction'}], 'fontsize', 8);

beautifygraph;
axis off;

preparegraph;

safePrint(fullfile('figs', 'draft', 'multipleSubjectLegend'));
