# maxfilterのインストール(MEG研究の場合)

maxfilterというフィルタがMEG研究ではほぼ必須です。
これは外から飛んでくるノイズを数学的に除去するフィルタなのですが、
MNEでは特許の問題もあって信頼に足る実装が出来ていません。泣き所の一つです。
DANAというソフトとmaxfilterというソフトをELEKTA社から貰う必要があります。
また、環境はRedhat5またはCentOs5の64bit版を使うことになっています。
僕はdocker[^docker]でcentos5のコンテナをダウンロードしてインストールを試みました。
```{frame=single}
docker run -it --name centos5 -v ~:/home/hoge centos:5
```
[^docker]:仮想化ソフトの一つ。ほぼネイティブの速度が出るのが特徴です。

これでcentos5がダウンロードされ、centos5の端末に入ります。
ELEKTA社製のソフトは32bit,64bitのソフトが混在しています。
依存しているものとしては32bitと64bitのfortran、whichコマンドです。
また、neuromagというユーザーをneuroというグループに入れる必要があります。
```{frame=single}
yum install compat-libf2c-34.i386
yum install compat-libf2c-34.x86_64
yum install which
useradd neuromag
groupadd neuro
usermod -a neuromag neuro
```

その上で、DANAとmaxfilterのインストールスクリプトをそれぞれ動かします。
```{frame=single}
sh install
```
僕は難しいこと考えるのが嫌だったので、インストールファイルをHDDにコピーして
スクリプトを動かしました。インストールできたら
```{frame=single}
/neuro/bin/admin/license_info
```
として出力結果をELEKTAに送り、ライセンスを取得します。
最後に脳磁図計のキャリブレーションファイルを入れる必要があります。
つまり「人が入っていない時の状態」を入れることになります。
/neuro/databases/sss/sss_cal.dat
/neuro/databases/ctc/ct_sparse.fif
この2つが必要です。ライセンスなどは日本法人の人に聞いたほうが良いです。
細則があります。以上でmaxfilterのインストールは終わりです。
