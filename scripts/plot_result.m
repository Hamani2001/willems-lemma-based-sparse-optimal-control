function plot_result(result)
%PLOT_RESULT  Plot simulation results (supports arbitrary input/output dims).
% Assumptions (guaranteed elsewhere):
%   time_result : [1 x T]
%   u_result    : [Nu x T]
%   y_result    : [Ny x T]
%   y_predict   : [Ny x T] (optional)
%   Y_end_ref   : [Ny x 1] or [Ny x T] or scalar (optional)

    % --- Required ---
    t = result.time_result;   % [1 x T]
    u = result.u_result;      % [Nu x T]
    y = result.y_result;      % [Ny x T]

    % --- Optional ---
    hasPred = isfield(result,'y_predict') && ~isempty(result.y_predict);
    if hasPred
        yhat = result.y_predict;  % [Ny x T]
    else
        yhat = [];
    end

    hasRef = isfield(result,'Y_end_ref') && ~isempty(result.Y_end_ref);
    if hasRef
        yref = result.Y_end_ref;  % scalar or [Ny x 1] or [Ny x T]
    else
        yref = [];
    end

    hasOpt = isfield(result,'opt') && ~isempty(result.opt);
    if hasOpt
        opt = result.opt;
    else
        opt = [];
    end

    % --- Dimensions ---
    Nu = size(u,1);
    Ny = size(y,1);

    % =========================================================
    % Figure 2: Input (supports Nu >= 1)
    % =========================================================
    figure(2); clf;

    % Nuに応じてsubplot
    for i = 1:Nu
        subplot(Nu,1,i);
        plot(t, u(i,:), 'LineWidth', 1.5);
        grid on;
        ylabel(sprintf('u(%d)', i));
        if i == 1
            title('Optimized Input');
        end
        if i == Nu
            xlabel('Time [s]');
        end
        ylim([-1.5,1.5])
    end

    % もし全入力同一ylimしたいならここでまとめて設定（任意）
    % for i = 1:Nu
    %     subplot(Nu,1,i); ylim([-1.2, 1.2]);
    % end


    % =========================================================
    % Figure 3: Output vs Prediction (+ Target)
    % =========================================================
    figure(3); clf;
    
    for i = 1:Ny
        subplot(Ny,1,i);
    
        hold on;
    
        % Predicted trajectory (optional) 先に描く
        if hasPred
            plot(t, yhat(i,:), '--', 'LineWidth', 1.2);
        end
    
        % Output 後に描く（上に来る）
        plot(t, y(i,:), 'LineWidth', 1.5);
    
        % Target line (optional)（必要なら一番上に来る）
        if hasRef
            if isscalar(yref)
                yref_i = yref * ones(size(t));
            else
                if size(yref,2) == 1
                    yref_i = yref(i) * ones(size(t));
                else
                    yref_i = yref(i,:);
                end
            end
            plot(t, yref_i, ':', 'Color','k', 'LineWidth', 1.0);
        end
    
        grid on;
        ylabel(sprintf('y(%d)', i));
    
        if i == 1
            title('Result');
        end
        if i == Ny
            xlabel('Time [s]');
        end
    
        % Legend（表示順は好みで調整可）
        leg = {};
        if hasPred, leg{end+1} = 'Predicted Trajectory'; end
        leg{end+1} = 'Output';
        if hasRef,  leg{end+1} = 'Target'; end
        legend(leg, 'Location','best');
    
        if i == 1
            % ylabel({'Angle', '[×10^{-2} rad]'}, 'Interpreter','tex')
            % ylim([0,12])
        elseif i == 2
            % ylabel({'Angular velocity', '[×10^{-2} rad/s]'}, 'Interpreter','tex')
            % ylim([-1,3])
        end
    end



    % =========================================================
    % Figure 5/6: Opt transitions (if available)
    % =========================================================
    if hasOpt
        if isfield(opt,'optTimes') && isfield(opt,'g')
            figure(5); clf;
            plot(1:opt.optTimes, opt.g);
            grid on;
            ylabel('g'); xlabel('Iteration');
            title('g transition');
        end

        % z0..z3 があるものだけ描く
        zNames = {'z0','z1','z2','z3'};
        zExist = cellfun(@(n) isfield(opt,n), zNames);

        if any(zExist) && isfield(opt,'optTimes')
            figure(6); clf;

            idx = find(zExist);
            nZ  = numel(idx);

            % 2列で並べる（適当な見やすい配置）
            nCol = 2;
            nRow = ceil(nZ / nCol);

            for k = 1:nZ
                name = zNames{idx(k)};
                subplot(nRow, nCol, k);
                plot(1:opt.optTimes, opt.(name));
                grid on;
                ylabel(name); xlabel('Iteration');
            end
            sgtitle('z transitions');
        end
    end

    drawnow;
end
