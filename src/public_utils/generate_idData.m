function [t_id,u_id,y_id,u_sys_ini,y_sys_ini,maxU] = generate_idData(T,dt,idinput_cfg,model_cfg)

% 同定データ生成（M系列）
t_id = linspace(0,(T-1)*dt,T);
u_id = idinput_cfg.idinput(idinput_cfg,T,model_cfg.input.dim);
y_id = model_cfg.model(u_id,t_id,model_cfg);

% フォーマット
u_id = formatDataAlign(u_id,T);
t_id = formatDataAlign(t_id,T);
y_id = formatDataAlign(y_id,T);

u_sys_ini = zeros(size(u_id(:,1)));
y_sys_ini = zeros(size(y_id(:,1)));
maxU = max(u_id);