function H_L = Hankel_matrix(data, L)
    % ハンケル行列の生成
    % data \in R^{dataDim × dataLength}
    
    [dataDim, dataLength] = size(data);
    hankelWidth = dataLength - L + 1;

    % サイズチェック
    if hankelWidth > 10000
        answer = questdlg( ...
            sprintf('Hankel行列の列数が %d になります。続行しますか？', hankelWidth), ...
            '警告', ...
            'OK', 'キャンセル', 'キャンセル');

        if ~strcmp(answer, 'OK')
            error('処理がキャンセルされました。');
        end
    end

    % Hankel行列生成
    H_L = zeros(L*dataDim, hankelWidth);
    for index = 1:L
        H_L((index-1)*dataDim+1:index*dataDim, :) = ...
            data(:, index:dataLength-L+index);
    end
end
