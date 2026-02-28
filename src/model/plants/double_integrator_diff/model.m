function [output, opt_out] = model(input_std, t_data, opt_in)
%MODEL  Unified plant interface
%
% [output, opt_out] = model(input_std, t_data, opt_in)
%
% input_std : input time series scaled to [-1, 1]
% t_data    : time vector (assumed equally spaced)
% opt_in    : config struct (usually model_def() output)
%
% output    : observed output
% opt_out   : post-run info (state history etc.)

    if nargin < 3 || isempty(opt_in)
        opt_in = model_def();
    end

    % time step (assume equal spacing)
    if numel(t_data) < 2
        error('t_data must have at least 2 elements.');
    end
    dt = t_data(2) - t_data(1);

    % map standardized input [-1,1] to actual input
    u = opt_in.u_max .* input_std;

    % build SS system
    sys = ss(opt_in.A, opt_in.B, opt_in.C, opt_in.D);

    % simulate
    % lsim can return states if requested
    if isfield(opt_in, 'save_state_history') && opt_in.save_state_history
        [y, ~, x] = lsim(sys, u, t_data, opt_in.x0);
    else
        y = lsim(sys, u, t_data, opt_in.x0);
        x = [];
    end

    % output: scaled position + bandlimited diff
    y_scaled = opt_in.y_scale .* y;
    y_diff   = bandlimited_diff(y, dt);

    output = [y_scaled, y_diff];

    % pack opt_out
    opt_out = struct();
    opt_out.y = y;
    opt_out.y_scaled = y_scaled;
    opt_out.y_diff = y_diff;
    opt_out.dt = dt;
    opt_out.u = u;
    opt_out.t = t_data;
    if ~isempty(x)
        opt_out.x = x;
    end
end
