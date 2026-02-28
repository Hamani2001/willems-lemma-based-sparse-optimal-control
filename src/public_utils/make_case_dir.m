function [caseDir, meta] = make_case_dir(caseName)
%MAKE_CASE_DIR  Create or reuse a directory for a simulation case.
%
% Directory structure:
%   data/
%     caseName/
%       prep/
%       result/

    arguments
        caseName (1,:) char
    end

    %% --- Find project root ---
    thisFileDir = fileparts(mfilename('fullpath'));
    projRoot    = fileparts(fileparts(thisFileDir));

    %% --- Data directory ---
    dataDir = fullfile(projRoot, 'data');
    if ~exist(dataDir, 'dir')
        mkdir(dataDir);
    end

    %% --- Case directory (fixed name) ---
    caseDir = fullfile(dataDir, caseName);

    reused = exist(caseDir, 'dir');

    if ~reused
        mkdir(caseDir);
    end

    %% --- Metadata ---
    meta = struct();
    meta.caseName  = caseName;
    meta.caseDir   = caseDir;
    meta.reused    = reused;
    meta.time      = datetime('now');
    meta.matlabVer = version;
    meta.host      = getenv('COMPUTERNAME');
    if isempty(meta.host)
        meta.host = getenv('HOSTNAME');
    end

end
