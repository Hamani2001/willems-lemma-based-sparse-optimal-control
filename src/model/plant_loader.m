function plant_loader(modelName)
% plant_loader  指定したモデルの plant パスのみを有効化する
%
%   plant_loader(modelName)
%
% 前提:
% ・この関数と同じ階層に plants ディレクトリが存在する
% ・この関数のあるパスは MATLAB に追加済み
%
% 機能:
% 1. plants/modelName が存在するか確認
% 2. 存在しなければエラー
% 3. plants/modelName 以外の plant が含まれるパスを削除

    % プラントが格納されているディレクトリ名
    plantDirName = 'plants';

    % この関数のあるディレクトリを取得
    thisFilePath = fileparts(mfilename('fullpath'));
    plantsDir = fullfile(thisFilePath, plantDirName);

    % modelName ディレクトリの存在確認
    targetPlantDir = fullfile(plantsDir, modelName);
    if ~isfolder(targetPlantDir)
        error('plant_loader:ModelNotFound', ...
            'plants ディレクトリ内に "%s" が存在しません。', modelName);
    end

    % 現在 MATLAB に追加されている全パスを取得
    allPaths = strsplit(path, pathsep);

    % "plant" を含むパスを抽出
    plantPaths = allPaths(contains(allPaths, plantsDir));

    % 削除対象: plants/modelName 以外の plant パス
    for i = 1:numel(plantPaths)
        p = plantPaths{i};

        % 対象モデルのパスでなければ削除
        if ~startsWith(p, targetPlantDir)
            rmpath(p);
        end
    end

end
