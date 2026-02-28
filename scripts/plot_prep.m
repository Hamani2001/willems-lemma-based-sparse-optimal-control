function plot_prep(caseDir,matName)
%PLOT_PREP  Plot pre-simulation input/output data.
%
%   plot_prep(caseDir)
%
% This function loads:
%   caseDir/prep/prep.mat
%
% Expected variables in prep struct:
%   prep.t_id
%   prep.u_id
%   prep.y_id

    % --- Load prep data ---
    prepFile = fullfile(caseDir, [matName, '.mat']);
    if ~exist(prepFile, 'file')
        error('%s.mat not found in %s', matName, prepFile);
    end

    S = load(prepFile);
    prep = S.prep;

    % --- Safety checks (optional but recommended) ---
    requiredFields = {'t_id', 'u_id', 'y_id'};
    for k = 1:numel(requiredFields)
        if ~isfield(prep, requiredFields{k})
            error('%s.%s is missing.', matName, requiredFields{k});
        end
    end

    % --- Plot ---
    figure(1); clf;

    % Input
    subplot(2,1,1)
    plot(prep.t_id, prep.u_id, 'LineWidth', 2);
    grid on
    ylabel('input')
    

    % Output
    subplot(2,1,2)
    plot(prep.t_id, prep.y_id, 'LineWidth', 2);
    grid on
    ylabel('output')
    xlabel('Time [s]')
    legend({'$y$', '$\dot{y}$'}, 'Location', 'best', 'Interpreter', 'latex')


    drawnow;

end
