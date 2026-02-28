function cfg = model_def()
%MODEL_DEF_UNCERTAIN
% 不確かさ付き2次系（Δζ, Δk を固定パラメータとして定義）

% input6
cfg.in.gainU = 1.0;

% initial state [angle; angle_velocity]
cfg.state.ini = [0; 0];

% nominal plant
cfg.plant.wn   = 1/6;   % ステップの定常値は1/wn^2
cfg.plant.zeta = 0.1;

% uncertainty (FIXED values)
cfg.unc.dZeta = 0.0;   % ← 外側スクリプトで変更
cfg.unc.dK    = 0.0;   % ← 外側スクリプトで変更
end
