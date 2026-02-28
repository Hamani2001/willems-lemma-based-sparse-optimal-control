clear; clc; 
close all; 
setup_path; % パスを追加
sim_para;   % シミュレーションで使用するパラメータをワークスペースに格納
plot_cfg;    % 図のデフォルト設定

[caseDir, meta] = make_case_dir(caseName);
result.meta = meta;

dim_min = 3;
dim_max = 30;
k_min = -0.18;
k_max = 0.6;
k_smp = 0.001;


k_list = k_min:k_smp:k_max;
num_k   = length(k_list);
num_dim = dim_max - dim_min + 1;
total_step = num_k * num_dim;

%% データ作成
step = 0;

for k = k_list
    model_stamp = model_cfg();
    % model_stamp.f.Fs = model_stamp.f.Fc + k*(model_stamp.f.Fs - model_stamp.f.Fc);
    % model_stamp.f.Fs = k;
    model_stamp.unc.dZeta = k;
    % model_stamp.unc.dK = k;
    % model_stamp.cog.A = k .* model_stamp.cog.A;  % コギングトルク

    for dim_g = dim_min:dim_max
        warning('off','all')
        loop_dim(dim_g, k, model_stamp);
        warning('on','all')

        step = step + 1;
        progress = 100 * step / total_step;
        fprintf('processed: %.3f %%\n', progress);
    end
end
%% データ格納
result_rms_k_dim = nan(num_dim,num_k);
result_sparse_k_dim = nan(num_dim,num_k);

step = 0;
for index_k = 1:num_k
    k = k_list(index_k);
    for index_dim = 1:num_dim
        dim_g = dim_min + (index_dim - 1);
        caseDir = make_case_dir(fullfile(caseName, "k"+num2str(k), "dim"+num2str(dim_g)));
        S = load(fullfile(caseDir, "result.mat"), "result");
        result_rms_k_dim(index_dim, index_k)    = S.result.y_rmse;
        result_sparse_k_dim(index_dim, index_k) = S.result.u_sparse;


        step = step + 1;
        progress = 100 * step / total_step;
        fprintf('processed: %.2f %%\n', progress);
    end
end

%% プロット
[min_result_rms_k_dim, min_result_index] = min(result_rms_k_dim);
min_result_sparse_k_dim = result_sparse_k_dim(sub2ind(size(result_sparse_k_dim), min_result_index, 1:size(result_sparse_k_dim,2)));

x_horizon = k_list;

figure(1),clf;
semilogy(x_horizon, min_result_rms_k_dim)
xlabel('非線形性の強さ')
ylabel('目標値誤差 MSE')

figure(2),clf;
plot(x_horizon, min_result_sparse_k_dim,':')
xlabel('非線形性の強さ')
ylabel('スパース性の強さ')

figure(3),clf;
plot(x_horizon, min_result_index,':o')
xlabel('非線形性の強さ')
ylabel('次元')

% save summry_k-018-6_g3-30


%% 関数
function loop_dim(dim_g, k, model_stamp)
    sim_para;   % シミュレーションで使用するパラメータをワークスペースに格納
    T = (N+T_ini)*dim_g;
    [caseDir, meta] = make_case_dir(fullfile(caseName, "k"+num2str(k), "dim"+num2str(dim_g)));
    result.meta = meta;
    % 変数準備
    % [t_id,u_id,y_id,u_sys_ini,y_sys_ini,~] = generate_idData(T,dt,idinput_cfg(),model_stamp); % モデル構築用データ

    % モデル不確かさ確認用
    [t_id,u_id,y_id,u_sys_ini,y_sys_ini,~] = generate_idData(T,dt,idinput_cfg(),model_cfg()); % モデル構築用データ

    [U_p, U_f, Y_p, Y_f] = generate_matrix_DeePC(u_id, y_id, T, T_ini, N, matrix_func); % 行列構築
    [u_init,y_init] = initialPara_DeePC(T_ini,u_sys_ini,y_sys_ini,"initialState"); % 初期値

    result.t_id=t_id;
    result.u_id=u_id;
    result.y_id=y_id;
    result.matrix_func = matrix_func;
    save_case_result(caseDir,result,true);
    
    % 最適化
    Y_end = generate_TerminalState(Y_f,size(y_id,1),optimizer_para);
    inv_G = generate_Gram_DeeSOC(U_p,U_f,Y_p,Y_end);
    
    [g_end,g_opt] = solve_DeeSOC(U_p,U_f,Y_p,Y_end,Y_end_ref,u_init,y_init,inv_G,optimizer_para);
    
    
    % 結果
    
    u_result = get_predictedTrajectory(U_f,g_end,length(u_sys_ini));
    time_result = linspace(dt, dt*N, N);
    
    % % データの整理
    % u_result(abs(u_result)<1e-3) = 0;
    % u_result((maxU-abs(u_result))<1e-3) = sign(u_result((maxU-abs(u_result))<1e-3))*maxU;
    
    % --- シミュレーション ---
    y_result = model_stamp.model(u_result,time_result,model_stamp);
    
    
    % 解析結果
    u_sparse = length(reshape(u_result(abs(u_result)<=1e-2),[],1))/length(reshape(u_result,[],1));
    y_predict = get_predictedTrajectory(Y_f,g_end,length(y_sys_ini));
    
    % 結果の保存
    result.T_ini = T_ini;
    result.N = N;
    result.T = T;
    result.dt = dt;
    
    result.idinput_cfg = idinput_cfg;
    result.model_cfg = model_cfg;
    result.optimizer_para = optimizer_para;
    result.plot_cfg = plot_cfg;
    
    % 最適化
    result.g_end = g_end;
    result.opt = g_opt;
    
    % 制御結果
    result.time_result = time_result;
    result.u_result = u_result;
    result.y_result = y_result;
    result.y_predict = y_predict;
    result.Y_end_ref = Y_end_ref;
    result.u_sparse = u_sparse;
    result.y_rmse = rmse(y_result(:,end),Y_end_ref)^2;
    
    save_case_result(caseDir,result);
end
