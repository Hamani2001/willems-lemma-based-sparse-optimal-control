%% データ駆動に関する
% 終端の状態
Y_end_ref = [2; 0]; 
% Y_end_ref = [10]; 

matrix_func = @(data,L) Hankel_matrix(data,L);
% matrix_func = @(data,L) Page_matrix(data,L);
T_ini = 100;       % 初期系列長
N = 1000;          % 予測ホライズン(状態が0になるステップ数)

%% シミュレーションパラメータ
% T = (N + T_ini)*13; % サンプリング数
T = 2500;        % 同定データ長 Hankelでよく使う
dt = 0.01; % サンプリング間隔

% /dataでの保存名
% caseName = 'Robust_cogA';
% caseName = 'Robust_Fs';
% caseName = 'Robust_uncertain_zeta';
% caseName = 'Robust_uncertain_k';
caseName = 'hoge';

% 後でmodel_cfgにまとめる
prepMatName = 'prep';