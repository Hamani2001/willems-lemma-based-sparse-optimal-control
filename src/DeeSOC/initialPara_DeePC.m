function [u_ini, y_ini] = initialPara_DeePC(T_ini,u0,y0,vargin)
    %{
        Up*g=u_ini
        Yp*g=y_ini
        を満たすようなu_ini,y_iniを生成する関数



        if vargin == "initialState"
            u0,y0は1サンプルのみで次元に合わせてu_ini,y_iniを生成

        if vargin == dataLenght
            u0,y0はdataLengthの長さだけの時系列データとし，末端からu_ini,y_iniを生成

    %}
    if nargin > 3
        if vargin{1} =="initialState"
            % 初期状態を一定にしてDeePC用初期値を作成
            u_ini = repmat(u0(:),T_ini,1);
            y_ini = repmat(y0(:),T_ini,1);
        end
        return;
    end
    % u0,y0はフォーマットしている前提に注意
    u0Dim = size(u0,1);
    y0Dim = size(y0,1);
    u_ini = zeros(T_ini*u0Dim,1);
    y_ini = zeros(T_ini*y0Dim,1);
    for index = 1:T_ini
        u_ini(end-u0Dim*index+1:end-u0Dim*(index-1)) = u0(:,index); 
        y_ini(end-y0Dim*index+1:end-y0Dim*(index-1)) = y0(:,index); 
    end
end