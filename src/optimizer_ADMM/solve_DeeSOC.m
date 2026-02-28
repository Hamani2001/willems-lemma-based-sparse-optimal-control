function [g_end,opt] = solve_DeeSOC(U_p,U_f,Y_p,Y_end,Y_end_ref,u_init,y_init,inv_G,cfg)
%{
    ADMMを用いたデータ駆動型スパース最適制御の最適化
    
    入力は1で標準化したもの
%}

% 入力の最大値
maxU = max([abs(max(U_p)),abs(max(U_f))]);
if maxU>1
    error('入力の最大値は1にしてください');
end

% 最適化用変数
Phi = [U_p; Y_p];
zeta = [u_init; y_init];

% 最適化の変数
rho0 = cfg.admm.rho.w0/norm(Phi,"fro"); % モデル
rho3 = cfg.admm.rho.w3/norm(Y_end,"fro"); % 終端の収束

% initialization
g = zeros(size(Phi,2),cfg.admm.maxIter);
z0 = zeros(size(Phi,1),cfg.admm.maxIter); % 拘束条件
z1 = zeros(size(U_f,1),cfg.admm.maxIter);
z2 = zeros(size(z1));
z3 = zeros(size(Y_end,1),cfg.admm.maxIter);

v0 = zeros(size(z0));
v1 = zeros(size(z1));
v2 = zeros(size(z2));
v3 = zeros(size(z3));


% 最適化
tic
% h = waitbar(0, 'Progress...');
for k = 1:cfg.admm.maxIter-1
    g(:,k+1) = inv_G*(Phi'*(z0(:,k)-v0(:,k)) + U_f'*(z1(:,k)-v1(:,k)) + U_f'*(z2(:,k)-v2(:,k)) + Y_end'*(z3(:,k)-v3(:,k)));

    a0 = Phi*g(:,k+1) + v0(:,k);
    a1 = U_f*g(:,k+1)  + v1(:,k);
    a2 = U_f*g(:,k+1)  + v2(:,k);
    a3 = Y_end*g(:,k+1) + v3(:,k);
    
    z0(:,k+1) = (2+rho0)\(2*zeta + rho0*a0);
    z1(:,k+1) = cfg.prox.sparse(a1,maxU);
    z2(:,k+1) = projection_operator(a2, maxU);  % 入力の制限
    z3(:,k+1) = (2+rho3)\(2*Y_end_ref + rho3*a3);
    
    v0(:,k+1) = v0(:,k) + Phi*g(:,k+1) - z0(:,k+1);
    v1(:,k+1) = v1(:,k) + U_f*g(:,k+1) - z1(:,k+1);
    v2(:,k+1) = v2(:,k) + U_f*g(:,k+1) - z2(:,k+1);
    v3(:,k+1) = v3(:,k) + Y_end*g(:,k+1) - z3(:,k+1);

    % 進捗更新
    % waitbar(k/cfg.admm.maxIter, h, sprintf('Progress: %3.1f%% (%d / %d)', k/cfg.admm.maxIter*100, k, cfg.admm.maxIter));
end
% close(h); % 終了後にウィンドウを閉じる

% g = 

opt.ElapsedTime = toc;
opt.optTimes = cfg.admm.maxIter;
opt.rho0 = rho0;
opt.rho3 = rho3;
opt.g = g;
opt.z0 = z0;
opt.z1 = z1;
opt.z2 = z2;
opt.z3 = z3;

g_end = g(:,k+1);
end