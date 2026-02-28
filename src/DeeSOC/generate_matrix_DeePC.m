function [U_p, U_f, Y_p, Y_f] = generate_matrix_DeePC(input, output, T, T_ini, N, matrix_func)
    % Hankel行列などによる行列を生成
    % matrix_funcは引数が@(x,L)の関数ハンドラ
    
    % 行列の向きをそろえる   
    input_format = formatDataAlign(input,T);
    output_format = formatDataAlign(output,T);

    [inputDim, ~] = size(input_format);
    [outputDim, ~] = size(output_format);

    Mu = matrix_func(input_format, T_ini+N);
    My = matrix_func(output_format, T_ini+N);

    U_p = Mu(1:T_ini*inputDim,:);
    U_f = Mu(T_ini*inputDim+1:end,:);
    Y_p = My(1:T_ini*outputDim,:);
    Y_f = My(T_ini*outputDim+1:end,:);
end