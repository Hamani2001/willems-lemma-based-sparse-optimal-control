function save_case_result(caseDir, data, isPrep)
%SAVE_CASE_RESULT  Save prep or result data into caseDir.
%
% Usage:
%   save_case_result(caseDir, result)
%       -> save to caseDir/result.mat
%          (delete prep.mat if it exists)
%
%   save_case_result(caseDir, prepData, true)
%       -> save to caseDir/prep.mat
%
% Inputs:
%   caseDir : full path to case directory
%   data    : struct to save
%   isPrep  : (optional) logical flag
%             true  -> save as prep.mat
%             false -> save as result.mat (default)

    arguments
        caseDir (1,:) char
        data struct
        isPrep (1,1) logical = false
    end

    %% --- Safety check ---
    if ~exist(caseDir, 'dir')
        error('Case directory does not exist: %s', caseDir);
    end

    %% =========================================================
    % Decide file name and variable name
    %% =========================================================
    if isPrep
        fileName = 'prep.mat';
        varName  = 'prep';
    else
        fileName = 'result.mat';
        varName  = 'result';
    end

    filePath = fullfile(caseDir, fileName);

    %% =========================================================
    % Attach metadata
    %% =========================================================
    if ~isfield(data, 'meta')
        data.meta = struct();
    end
    data.meta.savedAt   = datetime('now');
    data.meta.matlabVer = version;

    %% =========================================================
    % Save
    %% =========================================================
    S.(varName) = data; %#ok<STRNU>
    save(filePath, '-struct', 'S');

    %% =========================================================
    % If result is saved, delete prep.mat
    %% =========================================================
    if ~isPrep
        prepFile = fullfile(caseDir, 'prep.mat');
        if exist(prepFile, 'file')
            delete(prepFile);
        end
    end

end
