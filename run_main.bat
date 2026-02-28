@echo off

: このbatファイル自身のあるディレクトリに移動
cd /d %~dp0

: MATLABを起動して main.m を実行
matlab -nosplash -nodesktop -r "run('run/main.m');
