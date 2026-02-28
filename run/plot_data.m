clear; clc; 
% close all; 
setup_path; % パスを追加
% sim_para;   % シミュレーションで使用するパラメータをワークスペースに格納
plot_cfg;    % 図のデフォルト設定

caseName = 'closedloop/20260113Nc100'; % 参照するディレクトリ名
caseDir = fullfile('../data/',caseName);
%%
load(fullfile(caseDir,'result.mat'));

% --- Plot ---
figure(1); clf;

% Input
subplot(2,1,1)
plot(result.t_id, result.u_id, 'LineWidth', 2);
grid on
ylabel('input')
% xlim([0,16])

% Output
subplot(2,1,2)
plot(result.t_id, result.y_id, 'LineWidth', 2);
grid on
ylabel('output')
xlabel('Time [s]')
legend({'$y$', '$\dot{y}$'}, 'Location', 'best', 'Interpreter', 'latex')
% xlim([0,16])

plot_result(result)

% 解析結果
disp("スパース性")
disp(length(reshape(result.u_result(abs(result.u_result)<=1e-2),[],1))/length(reshape(result.u_result,[],1)))

disp('シミュレーション結果')
disp(result.y_result(:,end))