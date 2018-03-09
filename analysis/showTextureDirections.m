% show patches in certain texture directions

%% Generate ternary patches

% AD_1_2 long axis:  [0.3985 0.7147 -0.1132]
%        short axis: [1 0 0]
% same for AB_1_2
% AD_1_1 long axis:  [0 1 0]
%        short axis: [0.8604 0.2279 -0.0883]
% AB_1_1 long axis:  [0.1140 0.9302 -0.0442]
%        short axis: [1 0 0]

% AB_1_1, AD_1_1 vs. AB_1_2, AD_1_2
% groups = {'AB_1_1', 'AD_1_1', 'AB_1_2', 'AD_1_2'};
% tex_axes = {[0 1 0], [0 1 0], [0 1 0], [0 1 0]};
% tex_axes = repmat({[0.8604    0.2279   -0.0883]}, 1, length(groups));
% groups = {'AB_1_1', 'AB_1_1', 'AB_1_2', 'AB_1_2'};
groups = {'AB_1_1', 'AB_1_1', 'AB_1_2', 'AB_1_2'};
% tex_axes = {[0, 1, 0], [2/3, -1/3, 2/3], [0, 1, 0], [2/3, -1/3, 2/3]};
tex_axes = {[0.1140, 0.9302, -0.0442], [1, 0, 0], ...
    [0.3985, 0.7147, -0.1132], [1, 0, 0]};
n_locs = 8;
patch_size = 64;
max_loc = 0.74;

patches = cell(length(groups), n_locs);
locations = cell(size(groups));

patch_count = 1;
progress = TextProgress('generating ternary patches', 'prespace', 28, 'length', 20);

evs = cell(size(patches));

for i = 1:length(groups)
    % generate patches in this direction
    generator = PatchAxisGenerator(groups{i}, tex_axes{i}, patch_size);
    generator.nLocations = n_locs;
    generator.maxLocation = max_loc;
    
    j = 1;
    while generator.next
        patches{i, j} = generator.samples;
        [~, evs{i, j}] = processBlock(patches{i, j}, 3);
        j = j + 1;
        progress.update(100*patch_count/numel(patches));
        patch_count = patch_count + 1;
    end
    locations{i} = generator.getLocations;
end
progress.done('done');

%% Draw patches

patch_count = 1;

patch_scaling = 2;
ax_size = patch_scaling*patch_size + 24;
border_size = 24;
margin_size = 128;

% crt_y = border_size;
fig = figure;
fig.Units = 'pixels';
fig.Position = [50 50 margin_size + border_size + n_locs*ax_size 2*border_size + length(groups)*ax_size];
crt_y = fig.Position(4) - ax_size - border_size;
for i = 1:size(patches, 1)
    crt_x = margin_size;
    text_ax = axes;
    text_ax.Units = 'pixels';
    text_ax.Position = [0 crt_y margin_size patch_scaling*patch_size];
    axis off;
    text(0.1, 0.5, [groups{i} '[' num2str(tex_axes{i}, '%.1f ') ']']);
    for j = 1:size(patches, 2)
%         subplot(size(patches, 1), size(patches, 2), patch_count);
        
        ax = axes;
        ax.Units = 'pixels';
        ax.Position = [crt_x crt_y patch_scaling*patch_size patch_scaling*patch_size];
        
        imagesc(patches{i, j}, [0 1]);
        colormap('gray');
        axis equal;
        axis off;
        patch_count = patch_count + 1;
        
%         title([groups{i} '[' num2str(tex_axes{i}, '%d') '], x=' num2str(locations{i}(j), '%.2f')]);
        title(['x=' num2str(locations{i}(j), '%.2f')]);
        
        crt_x = crt_x + ax_size;
    end
    crt_y = crt_y - ax_size;
end