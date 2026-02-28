clear; clc; 
% close all; 
setup_path; % パスを追加
sim_para;   % シミュレーションで使用するパラメータをワークスペースに格納
plot_cfg;    % 図のデフォルト設定

[caseDir, meta] = make_case_dir(caseName);
result.meta = meta;
%% 変数準備
[t_id,u_id,y_id,u_sys_ini,y_sys_ini,maxU] = generate_idData(T,dt,idinput_cfg(),model_cfg()); % モデル構築用データ
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

[g_end,g_opt] = solve_DeeSOC(U_p,U_f,Y_p,Y_end,Y_end_ref,u_init,y_init,inv_G,optimizer_para);

disp('最適化にかかった時間')
disp(g_opt.ElapsedTime)

%% 結果

u_result = get_predictedTrajectory(U_f,g_end,length(u_sys_ini));
time_result = linspace(dt, dt*N, N);

% % データの整理
% u_result(abs(u_result)<1e-3) = 0;
% u_result((maxU-abs(u_result))<1e-3) = sign(u_result((maxU-abs(u_result))<1e-3))*maxU;

% 解析結果
disp("スパース性")
disp(length(reshape(u_result(abs(u_result)<=1e-2),[],1))/length(reshape(u_result,[],1)))


% --- シミュレーション ---
y_result = model_cfg().model(u_result,time_result,model_cfg());

disp('シミュレーション結果')
disp(y_result(:,end))


y_predict = get_predictedTrajectory(Y_f,g_end,length(y_sys_ini));

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

save_case_result(caseDir,result);

plot_result(result);
