function [output, opt_out] = model(input_std, t_data, opt_in)
    % 角度 + 角速度
    [th,  opt_out] = second_order(input_std, t_data, opt_in, "angle");
    % omg            = second_order(input_std, t_data, opt_in, "angle_velocity");

    output = [th];
    % output = [th; omg];
    % output = output/100;
end

function [output, cfg_out] = second_order(input_std, t_data, cfg, observe)
%SECOND_ORDER_UNCERTAIN
%  x¨ + (2ζ+Δζ)ωn x˙ + (1+Δk)ωn^2 x = u
%
% 状態: [x; xdot] = [angle; angle_velocity]
% Δζ, Δk は cfg.unc に固定値として与える

if nargin < 4 || isempty(observe)
    observe = "";
end

% ---- parameters ----
wn   = cfg.plant.wn;
zeta = cfg.plant.zeta;

dZeta = cfg.unc.dZeta;
dK    = cfg.unc.dK;

a1 = (2*zeta + dZeta) * wn;
a0 = (1 + dK) * wn^2;

% ---- input ----
u = cfg.in.gainU * input_std;

% ---- simulation settings ----
N  = numel(t_data);
dt = t_data(2) - t_data(1);

x = zeros(2, N);
x(:,1) = cfg.state.ini(:);   % [x; xdot]

% ---- simulation loop (semi-implicit Euler) ----
for k = 1:N-1
    acc = u(k) - a1*x(2,k) - a0*x(1,k);
    x(2,k+1) = x(2,k) + dt*acc;       % velocity
    x(1,k+1) = x(1,k) + dt*x(2,k+1);  % position
end

% ---- output ----
switch string(observe)
    case "angle"
        output = x(1,:);
    case "angle_velocity"
        output = x(2,:);
    otherwise
        output = x;
end

cfg_out = cfg;
cfg_out.state.data = x;
end
