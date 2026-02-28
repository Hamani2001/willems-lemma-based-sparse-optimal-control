function cfg = optimizer_para()
% 最適化に使用する変数の定義

% 終端の評価関数に使用するデータのサンプル数
cfg.terminalLength = 1;

% ADMM内のパラメータ
cfg.admm.maxIter = 1000;
cfg.admm.rho.w0 = 1;
cfg.admm.rho.w3 = 1;

% soft-thretholdingの閾値の比率
cfg.soft.lam = 5e-2; % 疎になりやすさ（大きいほど疎になりやすい）

% hard-thretholdingの閾値の比率
cfg.hard.lam = 5e-2; % 疎になりやすさ（大きいほど疎になりやすい）

% firm-thretholdingの閾値の比率
cfg.firm.c1_ratio = 5e-2; % 疎になりやすさ（大きいほど疎になりやすい）
cfg.firm.c2_ratio = 9.99e-1;

% 疎にする近接作用素
% cfg.prox.sparse = @(x,maxU) soft_thresholding(x,cfg.soft.lam);
% cfg.prox.sparse = @(x,maxU) hard_thresholding(x,cfg.hard.lam);
cfg.prox.sparse = @(x,maxU) firm_thresholding(x,cfg.firm.c1_ratio*maxU,cfg.firm.c2_ratio*maxU);
end