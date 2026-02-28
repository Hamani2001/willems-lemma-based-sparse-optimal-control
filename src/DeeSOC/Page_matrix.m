function P_L = Page_matrix(data, L)
    %{ 
    Page行列の生成
    data \in \doubleR^{dataDim \times dataLength}
    dataLegngth/Lは整数
    %}
    
    [dataDim, dataLength] = size(data);
    
    col_len = floor(dataLength/L);
    P_L = zeros(L*dataDim,col_len);

    for col = 1:col_len
        for row = 1:L
            P_L((row-1)*dataDim+1:row*dataDim,col) = data(:,row+(col-1)*L);
        end
    end
end