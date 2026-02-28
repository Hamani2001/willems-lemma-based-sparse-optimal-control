function cfg = model_def()
%MOTOR_CFG  motor() 用のデフォルト設定を返す

    % 入力変換・ドライバ
    cfg.in.Vsup     = inf;
    cfg.in.Vsup     = 12;
    cfg.in.deadzone = 0.0;
    cfg.in.deadzone = 0.3;
    cfg.in.gain     = 12;     % input_std → [V] への倍率
    cfg.in.Rs       = 0.2;

    % 初期状態 [i; ω; θ; T]
    cfg.state.ini = [0; 0; 0; 25];

    % モータ電気・機械
    cfg.m.J  = 3.0e-4;
    cfg.m.Bv = 2.0e-4;
    cfg.m.Ke = 0.03;
    cfg.m.Kt = 0.03;
    cfg.m.R0 = 1.2;
    cfg.m.L  = 0.8e-3;
    cfg.m.alpha_R = 0.0039;
    cfg.m.T0      = 25;
    cfg.m.R_T = @(T) cfg.m.R0;
    % cfg.m.R_T = @(T) cfg.m.R0*(1 + cfg.m.alpha_R*(T - cfg.m.T0));

    % 摩擦（クーロン＋ストライベック）
    cfg.f.Fc = 0.00;
    % cfg.f.Fc = 0.02;
    % cfg.f.Fs = 0.00;
    cfg.f.Fs = 0.04;
    cfg.f.vs = 5.0;

    % 負荷トルク
    cfg.load.tau = 0.0;

    % 熱
    cfg.th.Cth  = 15.0;
    cfg.th.Rth  = 3.0;
    cfg.th.Tamb = 25.0;

    % コギング
    cfg.cog.Nc   = 0;
    % cfg.cog.Nc   = 2;
    cfg.cog.A    = [0.005, 0.002];
    cfg.cog.n    = [12,    24   ];
    cfg.cog.phi  = [0,     pi/6 ];
end
