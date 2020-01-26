
\newpage
# maxfilterのインストール(elektaのやつ)

maxfilterというフィルタがMEG研究ではほぼ必須です。
これは外から飛んでくるノイズを数学的に除去するフィルタです。

これについてはMNEpythonにもあるのですが、elekta社のmaxfilterもあります。
一長一短ですが、何も考えずに使うならelekta社でしょうか…。
僕は以前はelektaのを使っていましたが、最近MNEに移行しました。MNEのは後で解説します。

それぞれの特徴としては
Elekta版

- Elekta社のMEG部門が売却されたよ…将来性どうなん？
- Redhat系linuxでないと動かないのがクソ(Docker使うところかな？)
- 自動でbadチャンネル見つけてくれるのが超最高

MNE版

- 臨床には使っちゃいけないという縛りあり
- 使用環境を選ばないのが超最高
- まだ改良中？？？

以前、コンテナを使って導入したことがあるので導入方法を説明しておきます。
DANAというソフトとmaxfilterというソフトをELEKTA社から貰う必要があります。
また、環境はRedhat5またはCentOs5の64bit版を使うことになっています。
何故Dockerを使ったかと言うと、MNEはUbuntuで動かしていて、
ELEKTA社のソフトはredhat linux系が前提だからです。

僕はdocker[^docker]でcentos5のコンテナをダウンロードしてインストールを試みました。

```{frame=single}
docker run -it --name centos5 -v ~:/home/hoge centos:5
```
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
細則があります。以上でelektaのmaxfilterのインストールは終わりです。
