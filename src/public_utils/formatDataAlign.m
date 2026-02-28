function formatData = formatDataAlign(data, dataLength)
    % data のサイズを取得
    [rows, cols] = size(data);

    if cols == dataLength
        formatData = data;
        return;
    end

    if rows == dataLength
        formatData  = data.';
        return;
    end

    error('データ長が一致しません: dataLength = %d, data size = [%d, %d]', ...
              dataLength, rows, cols);
end