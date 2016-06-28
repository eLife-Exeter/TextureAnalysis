function images = parseImageNameFile(imgNameFile, path)
% parseImageNameFile Parse file of image names.
%   images = parseImageNameFile(imgNameFile, path) parses a text file
%   containing image names (in the format '<something> = <image name>') and
%   returns a structure containing all the names.
%
%   The function processes the file names in the following way. It first
%   removes the extension and checks whether a file ending in '_LUM.mat'
%   exists in the given path. If not, it checks for a file '.mat'. If both
%   of these don't exist, the file name is stored as-is. The file is also
%   stored as-is if the extension was '.mat' to start with.

%get images for estimating statistics
images = struct('path', {});

fid = fopen(imgNameFile);
raw = textscan(fid, '%s', 'delimiter', '\n\r');
fclose(fid);

raw = raw{1};
postfixes = {'_LUM.mat', '.mat'};

n = 1;

for i = 1:length(raw)
    s = raw{i};
    k = find(s == '=', 1);
    if ~isempty(k)
        fname = s(k+1:end);
        [~, name, ext] = fileparts(fname);
        
        if ~strcmp(ext, '.mat')
            found = false;
            for j = 1:length(postfixes)
                fnameCheck = fullfile(path, name, postfixes{j});
                if exist(fnameCheck, 'file') == 2
                    found = true;
                    break;
                end
            end
            if found
                fname = fullfile(name, postfixes{j});
            end
        end
        images(n).path = fname;
        n = n + 1;
    end
end

end