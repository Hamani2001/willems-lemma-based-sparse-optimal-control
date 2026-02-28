function inv_G = generate_Gram_DeeSOC(Up,Uf,Yp,Yend)
% 逐次最小二乗法を用いると効率的
checkSampleSize(size(Up,2));
tic
disp('逆行列の導出時間')
G_Phi = Up'*Up + Yp'*Yp;
G = G_Phi + 2*(Uf')*Uf + Yend.'*Yend;
inv_G = pinv(G);
toc
end

function checkSampleSize(N, threshold)
% CHECKSAMPLESIZE
%   サンプリング数 N が threshold を超えた場合，
%   処理を続行するか確認ウィンドウを表示する
%
% USAGE:
%   checkSampleSize(N)
%   checkSampleSize(N, threshold)

    if nargin < 2
        threshold = 1e4;   % デフォルト閾値（次元数の閾値）
    end

    if N > threshold
        msg = sprintf( ...
            'サンプリング数は %d です。\n計算に時間がかかる可能性があります。\n続行しますか？', N);

        choice = questdlg(msg, ...
            'サンプリング数の確認', ...
            '続行', '中止', '中止');

        if ~strcmp(choice,'続行')
            error('checkSampleSize:Canceled','ユーザにより処理を中止しました');
        end
    end
end
