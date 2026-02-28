function cfg = plot_cfg()
    set(0, 'DefaultAxesLineWidth', 1, ...
       'DefaultAxesFontSize', 14, ...
       'DefaultAxesFontWeight', 'bold', ...
       'DefaultLineLineWidth', 2, ...
       'DefaultAxesXGrid', 'on', ...
       'DefaultAxesYGrid', 'on', ...
       'DefaultAxesZGrid', 'on');

    %以下は変更予定

    
    cfg = struct;

    % データディレクトリ名
    cfg.name.dir = 'motor_Hankel';

    % 図のデフォルト設定
    cfg.axesLineWidth   = 1;
    cfg.fontSize        = 14;
    cfg.fontWeight      = 'bold';
    cfg.lineWidth       = 2;
    cfg.gridX = 'on';
    cfg.gridY = 'on';
    cfg.xLabel = 'Time [s]';
    cfg.uYLabel = 'input';
    cfg.yYLabel = 'output';
    cfg.legendLocation    = 'best';
    cfg.legendInterpreter = 'latex';


    % ===============================
    % plot_prep specific
    % ===============================
    cfg.figurePrep   = 1;
    cfg.tField       = 't_id';
    cfg.uField       = 'u_id';
    cfg.yField       = 'y_id';

    cfg.legendLabels = {'$y$', '$\dot{y}$'};
end
