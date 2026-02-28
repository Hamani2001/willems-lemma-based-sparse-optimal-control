function [output, opt_out] = model(input_std, t_data, opt_in)
    [output,opt_out] = motor(input_std,t_data,opt_in,"angle");
    output = [output; motor(input_std,t_data,opt_in,"angle_velocity")];
    output = output/100;
end

function [output, cfg_out] = motor(input_std, t_data, cfg_arg, isAllObserve)
%MOTOR  DCモータ＋ドライバモデル
%  - isAllObserve 省略/空：全状態 x_hist を返す
%  - cfg 省略/空：motor_cfg() を motor 内で呼んでデフォルトを使用

arguments
    input_std
    t_data
    cfg_arg
    isAllObserve = ""          % 省略時：全状態
end

% isAllObserve が空なら全状態
if isempty(isAllObserve)
    isAllObserve = "";
end

%-------------------- 初期値・パラメータ -------------------------
x0 = cfg_arg.state.ini;

Vsup     = cfg_arg.in.Vsup;
deadzone = cfg_arg.in.deadzone;
gainV    = cfg_arg.in.gain;
Rs       = cfg_arg.in.Rs;

J  = cfg_arg.m.J;   Bv = cfg_arg.m.Bv;
Ke = cfg_arg.m.Ke;  Kt = cfg_arg.m.Kt;
R0 = cfg_arg.m.R0;  L  = cfg_arg.m.L;
alpha_R = cfg_arg.m.alpha_R;  T0 = cfg_arg.m.T0;

Fc = cfg_arg.f.Fc;  Fs = cfg_arg.f.Fs;  vs = cfg_arg.f.vs;
tau_load = cfg_arg.load.tau;

Cth = cfg_arg.th.Cth;  Rth = cfg_arg.th.Rth;  Tamb = cfg_arg.th.Tamb;

Nc = cfg_arg.cog.Nc;
A_cog   = cfg_arg.cog.A;
n_cog   = cfg_arg.cog.n;
phi_cog = cfg_arg.cog.phi;

% 入力（std→V）
input = gainV * input_std;

%-------------------- 離散化設定 -------------------------
N  = length(t_data);
dt = t_data(2) - t_data(1);

x_hist = zeros(4, N);
x_hist(:,1) = x0;

%-------------------- ループ -------------------------
for k = 1:N-1
    u_cmd = sat_dead(input(k), Vsup, deadzone);

    i   = x_hist(1,k);
    omg = x_hist(2,k);
    th  = x_hist(3,k);
    T   = x_hist(4,k);

    R_T = cfg_arg.m.R_T(T);
    a_k = -((R_T + Rs) / L);
    b_k = -(Ke/L)*omg + (1/L)*u_cmd;

    Ad = exp(a_k*dt);
    if abs(a_k) > 1e-12
        Bd = (Ad - 1)/a_k;
    else
        Bd = dt;
    end
    i_next = Ad*i + Bd*b_k;

    sgn = signnz(omg);
    tau_f = Bv*omg + Fc*sgn + (Fs - Fc)*exp(-(abs(omg)/vs)^2) .* sgn;

    tau_cog = 0.0;
    for m = 1:Nc
        tau_cog = tau_cog + A_cog(m) * sin(n_cog(m)*th + phi_cog(m));
    end

    domg = (1/J)*( Kt*i_next - tau_f - tau_cog - tau_load );
    omg_next = omg + dt*domg;

    th_next = th + dt*omg_next;

    dT = ( i_next^2 * R_T - (T - Tamb)/Rth ) / Cth;
    T_next = T + dt * dT;

    x_hist(:,k+1) = [i_next; omg_next; th_next; T_next];
end

%-------------------- 出力選択 -------------------------
switch string(isAllObserve)
    case "current"
        output = x_hist(1,:);
    case "angle"
        output = x_hist(3,:);
    case "angle_velocity"
        output = x_hist(2,:);
    case "temperature"
        output = x_hist(4,:);
    otherwise
        output = x_hist;   % 省略時はここ
end
cfg_out = cfg_arg;
cfg_out.state.data = x_hist;
end

%====================== サブルーチン ======================
function y = sat_dead(u, Vsup, dz)
    if abs(u) < dz
        u = 0;
    else
        u = u - dz*sign(u);
    end
    y = min(max(u, -Vsup), Vsup);
end

function s = signnz(x)
    s = sign(x);
end
