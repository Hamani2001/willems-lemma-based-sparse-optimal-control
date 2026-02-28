function cfg = idinput_cfg()

    % PRBS
    cfg.idinput = @idinput_PRBS;
    cfg.prbs.band = [1 1/100];     % デフォルト
    cfg.prbs.band_step = 50;       % 入力次元ごとに変えるなら
end

function u_id = idinput_PRBS(cfg, T, input_dim)
% 入力の次元はモデルに依存させるためここでは定義しない
    u_id = zeros(input_dim,T);
    for i=1:input_dim
        u_id(i,:) = idinput(T,'prbs',[1/cfg.prbs.band(1),1/(1/cfg.prbs.band(2)+cfg.prbs.band_step*(i-1))],[-1,1]).';
    end
end