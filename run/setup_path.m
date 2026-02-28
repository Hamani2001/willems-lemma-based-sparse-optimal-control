function setup_path()
%SETUP_PATH  Add project folders to MATLAB path.
% This file is located in /run. Project root is one level up.

    % --- Find project root robustly (independent of current directory) ---
    thisFileDir = fileparts(mfilename('fullpath'));  % .../run
    projRoot    = fileparts(thisFileDir);            % .../

    % --- Define folders to add ---
    cfgDir  = fullfile(projRoot, 'config');
    srcDir  = fullfile(projRoot, 'src');
    scriptsDir  = fullfile(projRoot, 'scripts');

    % (Optional) If you want to avoid path stacking while developing:
    % remove previously added project paths (best-effort)
    % rmpath(genpath(cfgDir));
    % rmpath(genpath(srcDir));

    % --- Add paths ---
    addpath(genpath(cfgDir));
    addpath(genpath(srcDir));
    addpath(scriptsDir);

    % --- (Optional) Diagnostics ---
    % fprintf('[setup_path] Project root: %s\n', projRoot);
end