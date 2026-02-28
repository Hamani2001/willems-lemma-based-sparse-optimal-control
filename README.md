# データ駆動型スパース最適制御シミュレーション

本リポジトリは，データ駆動型スパース最適制御の検証をするためのMATLABコードである

---



## ディレクトリ構成
~~~
.
│  README.md    ：説明書
│  run_main.bat ：main.mの実行
│
├─config    ：srcディレクトリやscriptsディレクトリ上のプログラムのパラメータやメソッドを調整（以下参照）
│      idinput_cfg.m    ：入力の時系列データのコンフィグ
│      model_cfg.m      ：/model/plants/に格納された制御対象の選定とパラメータ定義
│      optimizer_para.m ：/src/optimizer_ADMM/での設定
│      plot_cfg.m   ：/plot_cfg上で図形の生成を設定
│      sim_para.m   ：シミュレーションでの総合的なパラメータ設定
│
├─data  ：シミュレーション結果格納用ディレクトリ（下階層のディレクトリの構造は任意）
│
├─run   ：プログラム実行用のディレクトリ
│      main.m           ：メインの実行ファイル（開ループ制御）
│      main_closeloop.m ：閉ループでのシミュレーション
│      plot_data.m      ：/dataに格納されたmatデータを図示
│      setup_path.m     ：シミュレーションプログラムを実行する上でのパスを取得
│
├─scripts   ：結果表示・評価用ディレクトリ
│      plot_prep.m
│      plot_result.m
│
└─src
    ├─DeeSOC    ：Willemsの基本補題に基づく非パラメトリックモデルの生成をする
    │      generate_matrix_DeePC.m
    │      get_predictedTrajectory.m
    │      Hankel_matrix.m
    │      initialPara_DeePC.m
    │      Page_matrix.m
    │
    ├─model
    │  │  plant_loader.m    ：model_cfgで指定したファイルのパスをplantディレクトリから取得する
    │  │
    │  ├─plants ：制御対象のメソッドを管理
    │  │  ├─motor
    │  │  │      model.m
    │  │  │      model_def.m
    │  │  │
    │  │  ├─motor_coulomb_friction
    │  │  │      model.m
    │  │  │      model_def.m
    │  │  │
    │  │  └─second_order_uncertain
    │  │          model.m
    │  │          model_def.m
    │  │
    │  └─utils
    │          bandlimited_diff.m
    │
    ├─optimizer_ADMM    ：交互乗数法による最適化問題の導出
    │  │  generate_Gram_DeeSOC.m
    │  │  generate_TerminalState.m
    │  │  solve_DeeSOC.m
    │  │
    │  └─utils  ：交互乗数法で用いられる関数
    │          firm_thresholding.m
    │          hard_thresholding.m
    │          projection_operator.m
    │          soft_thresholding.m
    │
    └─public_utils  ：パス関係なく共通で使うメソッドを格納
            formatDataAlign.m   ：時系列データを行が次元，列がデータになるようにする
            generate_idData.m   ：同定用入出力データの作成
            make_case_dir.m     ：保存データの保管場所の管理
            save_case_result.m  ：結果のデータをdataに保存
~~~
---

## 実行方法

MATLABを起動し，本リポジトリのルートディレクトリにて
以下を実行する。
もしくはrun_main.batを開くことでmain.mの実行が可能である

```matlab
run/main.m
```

---

## 実行結果の保存

実行結果は`config/sim_para.m`に格納されたcaseNameを用いて保存先を管理している

`run/main.m` を実行後，シミュレーション結果は以下に保存される（caseName=hogeの例）
```matlab
data/hoge/result.mat
```
実行結果を確認したい場合はcaseNameでディレクトリ名を指定し
`run/plot_data.m`
を実行することで結果を参照することが可能

---

## 再現実験の手順（論文 Fig.6.2.b）

論文 Fig.6.2.b の結果は，以下の手順により再現可能である。
1. `config/sim_para.m`よりシミュレーションパラメータを変更 （Table-6.2参照）
2. `config/optimizer_para.m`より最適化におけるパラメータを変更（Table-6.2参照）
3. `config/model_cfg`よりget_plant_cfgで参照するディレクトリ名を'motor'に変更
5. `run/main.m` を実行する  

---

## 制御対象の追加方法
制御対象を追加したい場合は `src/model/plants` に新しくファイルを追加する

1. `src/model/plants` に適当な名前のディレクトリを追加
2. `src/model/plants/***` に `model.m` ファイルと `model_def.m` ファイルを作成
3. `model_def.m` を実装
   - 制御対象のデフォルトのパラメータや初期状態をすべて構造体で格納する
   - 格納した構造体を出力する関数として `model_def.m` を実装する
   - 構造体は `model.m` にそのまま渡される想定なので、`model.m` が参照するフィールド名と一致させる
4. `model.m` に統一インタフェースの関数を実装（※ファイル名と先頭関数名は一致させる）
   - 形式：`function [output, opt_out] = model(input_std, t_data, opt_in)`
   - 引数：
     - `input_std` : 上下限を ±1 とした入力系列（時系列ベクトル）
     - `t_data` : 時刻列（等間隔を想定している実装が多いので注意）
     - `opt_in` : 設定 struct（通常は `model_def()` の出力）
   - 戻り値：
     - `output` : 観測出力
     - `opt_out` : 実行後の情報（状態履歴などを格納して返したい場合に使用）
5. `config/model_cfg`よりget_plant_cfgで参照するディレクトリ名を追加したディレクトリ名にする

小さく作って逐次デバッグする場合は `./test`（または `tests/`）を作成して確認する。

---

## 動作環境

- MATLAB R2024b  
- OS: Windows 11 （動作確認済）  

---

## ライセンス・注意事項

本コードは研究・教育目的での利用を想定している。  
商用利用は想定していない。


Copyright (c) 2026 Hamanishi






