function opt = model_def()
%MODEL_DEF  double integrator (with diff output) default settings

    % --- state space (double integrator) ---
    opt.A = [0, 1;
             0, 0];
    opt.B = [0;
             1];
    opt.C = [1, 0];
    opt.D = 0;

    % --- initial state ---
    opt.x0 = [0; 0];

    % --- input mapping ---
    % input_std is assumed to be within [-1, 1]
    % actual input u = u_max * input_std (symmetric saturation)
    opt.u_max = 1.0;

    % --- output configuration ---
    % original code: output = [0.1*y, bandlimited_diff(y, dt)]
    opt.y_scale = 0.1;

    % --- misc ---
    opt.save_state_history = true;
end
