function cfg = model_cfg()
    % cfg = get_plant_cfg('motor'); 
    % cfg = get_plant_cfg('second_order_uncertain');
    cfg = get_plant_cfg('double_integrator_diff');
    % cfg = get_plant_cfg('motor_coulomb_friction');

    % model/plants/***/model_defに格納すべきかも
    cfg.input.dim = 1;
    cfg.output.dim = 2;

    %
    cfg.model = @(input,t_data,cfg) model_func(input,t_data,cfg);
end

function cfg = get_plant_cfg(plantName)
    plant_loader(plantName);
    cfg = model_def();
    cfg.name =plantName;
end

function [output,opt_out] = model_func(input_std, t_data, opt_in)
    plant_loader(opt_in.name); % opt_inのモデル名が変わった場合は対応するモデルに変更が可能
    [output,opt_out] = model(input_std,t_data,opt_in);
    output = formatDataAlign(output,length(t_data));

    opt_out.name = opt_in.name;
    opt_out.input.dim = length(input_std(:,end));
    opt_out.output.dim = length(output(:,end));
end
