clear; clc; 
% close all; 
setup_path; % パスを追加
sim_para;   % シミュレーションで使用するパラメータをワークスペースに格納
plot_cfg;    % 図のデフォルト設定

[caseDir, meta] = make_case_dir(caseName);
result.meta = meta;

itarationTimesMax = 10;
sim_len = 100; % 予測ホライズンに対して実際に印加するステップ数
% sim_len = 50;

% モデルの初期状態のセットを標準機能にする

%% 変数準備
cfg_model = model_cfg();
[t_id,u_id,y_id,u_sys_ini,y_sys_ini,maxU] = generate_idData(T,dt,idinput_cfg(),cfg_model); % モデル構築用データ
[U_p, U_f, Y_p, Y_f] = generate_matrix_DeePC(u_id, y_id, T, T_ini, N, matrix_func); % 行列構築
[u_init,y_init] = initialPara_DeePC(T_ini,u_sys_ini,y_sys_ini,"initialState"); % 初期値

result.t_id=t_id;
result.u_id=u_id;
result.y_id=y_id;
result.matrix_func = matrix_func;
save_case_result(caseDir,result,true);

plot_prep(caseDir,prepMatName);

disp('初期状態')
disp(y_sys_ini)

disp('終端の状態')
disp(Y_end_ref)

disp('最適化変数の次元')
disp(size(U_f,2))


%% 最適化
Y_end = generate_TerminalState(Y_f,size(y_id,1),optimizer_para);
inv_G = generate_Gram_DeeSOC(U_p,U_f,Y_p,Y_end);


time_result = linspace(dt, dt*itarationTimesMax*sim_len, itarationTimesMax*sim_len);
u_result = zeros(model_cfg().input.dim,itarationTimesMax*sim_len);
y_result = zeros(model_cfg().output.dim,itarationTimesMax*sim_len);
y_predict = zeros(model_cfg().output.dim,itarationTimesMax*sim_len);

for itarationtimes = 1:itarationTimesMax
[g_end,g_opt] = solve_DeeSOC(U_p,U_f,Y_p,Y_end,Y_end_ref,u_init,y_init,inv_G,optimizer_para);

disp('最適化にかかった時間')
disp(g_opt.ElapsedTime)

u_tmp = get_predictedTrajectory(U_f,g_end,length(u_sys_ini));
[y_tmp,cfg_model] = cfg_model.model(u_tmp,time_result(1:N),cfg_model);


% plot用保存機能
u_result(:,(itarationtimes-1)*sim_len+1:itarationtimes*sim_len) = u_tmp(:,1:sim_len);
if sim_len == N
    y_result(:,(itarationtimes-1)*sim_len+1:itarationtimes*sim_len) = y_tmp(:,1:sim_len);
else
    y_result(:,(itarationtimes-1)*sim_len+1:itarationtimes*sim_len) = y_tmp(:,2:sim_len+1);
end
y_pre_tmp = get_predictedTrajectory(Y_f,g_end,length(y_sys_ini));
y_predict(:,(itarationtimes-1)*sim_len+1:itarationtimes*sim_len) = y_pre_tmp(:,1:sim_len);
%----------------

% 初期値更新
if sim_len == N
    cfg_model.state.ini = cfg_model.state.data(:,sim_len); % プラントの状態更新
else
    % デフォルトの制御対象のデータ更新
    cfg_model.state.ini = cfg_model.state.data(:,sim_len+1); % プラントの状態更新
end
[u_init,y_init] = initialPara_DeePC(T_ini,u_tmp(:,end-T_ini+1:end),y_tmp(:,end-T_ini+1:end));
end

%% 結果

% % データの整理
% u_result(abs(u_result)<1e-3) = 0;
% u_result((maxU-abs(u_result))<1e-3) = sign(u_result((maxU-abs(u_result))<1e-3))*maxU;

% 解析結果
disp("スパース性")
disp(length(reshape(u_result(abs(u_result)<=1e-2),[],1))/length(reshape(u_result,[],1)))

disp('シミュレーション結果')
disp(y_result(:,end))


% 結果の保存
result.T_ini = T_ini;
result.N = N;
result.T = T;
result.dt = dt;
result.Y_end_ref = Y_end_ref;

result.idinput_cfg = idinput_cfg;
result.model_cfg = model_cfg;
result.optimizer_para = optimizer_para;
result.plot_cfg = plot_cfg;

result.g_end = g_end;
result.opt = g_opt;

result.time_result = time_result;
result.u_result = u_result;
result.y_result = y_result;
result.y_predict = y_predict;
result.Y_end_ref = Y_end_ref;

result.itarationTimesMax = itarationTimesMax;
result.sim_len = sim_len;

save_case_result(caseDir,result);

plot_result(result);
