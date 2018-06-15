# MNE/pythonのインストール(脳波、脳磁図をする場合)

こちらはanacondaの存在下ではかなり簡単です。
mne 0.16からは少しインストールの仕方が変わりました。
仮想環境で構築することになります。
このやり方のメリットは、いつでも同じ環境を整える事ができるので、
ソフトのバージョンが変わっても対応しやすいということです。
反面、毎回仮想環境に入らないといけないという小さなデメリットがあります。

公式サイトをみながら頑張りましょう。
http://martinos.org/mne/stable/install_mne_python.html

anacondaのバージョンは新しくしておきましょう。
新しくすればこのように確認できます。
```{frame=single}
$ conda --version && python --version
conda 4.4.10
Python 3.6.4 :: Continuum Analytics, Inc.
```

要約すれば...
- curl[^curl]でenvironment.ymlをダウンロードする
- conda env create -f environment.yml

これでmneの仮想環境が整いました。
下記のコマンドでmneの環境に入れます。
```{frame=single}
conda activate mne
```
今後はmneを使うときは必ず上記のコマンドを打って下さい。

これで完結…と言いたいところなのですが、残念ながら
mnepythonとfreesurferのコマンドラインツールにはまだ
python2依存の部分があります。
なので、python2の環境も作りましょう。
ここ、公式に書いてない落とし穴です。

```{frame=single}
conda create -n python2 python=2.7 anaconda
```
mneの環境に入るには
```{frame=single}
conda activate mne
```
です。
さっきのpython2に入るのはもちろん
```{frame=single}
conda activate python2
```
ちなみに、出るのは
```{frame=single}
conda deactivate
```
macなら下記も必要です。
```{frame=single}
pip install --upgrade pyqt5>=5.10
```

[^curl]:unix界隈では大人気のダウンローダー

## MNE環境を複数作りたい！
MNEの環境が複数欲しくなることもあると思います。
僕は欲しくなりましたし、今後MNEがバージョンアップしていくたびに
古いのを残しながら音故知新する必要が出てくるはずです。
さっき色々やったなかでcurlでenvironment.ymlをダウンロードしたはずです。
このenviroment.ymlは普通にテキストエディタで開けます。
内容はインストールすべきパッケージの列挙です。
一番上の所に
```{frame=single}
name: mne
```
とあると思うので、単純にこいつを別の名前に変えてから
続きのコマンドを叩いていけばいいだけです。

## jupyter kernel
jupyterを使うのであれば、上記の環境をjupyterに登録する必要があります。
まずは、仮想環境に入って下さい。
```{frame=single}
conda activate mne
```
では、登録しましょう。下記は「今いる環境をjupyterに登録する」やつです。
 
```{frame=single}
ipython kernel install --user --name hoge
```
もし、要らなくなったら

```{frame=single}
ipython kernel uninstall --name hoge
```
ですね。

## CUDA
CUDA[^cuda](GPGPU)についてもそのサイトに記載があります。
CUDAはnvidiaのGPUしか動きません。インストールについては
nvidiaのサイトも参照して下さい。
ソースベースの解析をする場合はスピードが6倍くらいになります。

僕の環境では下記二行のコマンドを予め入れていないと動かないです。
.bash_profileや.bashrcに書き加えておけばいいでしょう。
```{frame=single}
export LD_PRELOAD='/usr/$LIB/libstdc++.so.6'
export DISPLAY=:0
```

さらに、jupyter内で下記を実行しないといけません。
```{frame=single}
%gui qt
```
[^cuda]:nVidiaのGPUを使った高速な計算ができる開発環境

# MNE/Cのインストール(脳波、脳磁図をするばあい)

MNECも必要です。下記サイトにメールアドレスを登録し、ダウンロードさせていただきましょう。
http://www.nmr.mgh.harvard.edu/martinos/userInfo/data/MNE_register/index.php
ダウンロードしたものについてはこのサイトの通りにすればインストールできます。
http://martinos.org/mne/stable/install_mne_c.html
僕はホームディレクトリに入れました。
```{frame=single}
tar zxvf MNE-hogehoge
mv MNE-hogehoge MNE-C
cd MNE-C
export MNE_ROOT=/home/fuga/MNE-C
. $MNE_ROOT/bin/mne_setup_sh
```
これでMNE-Cも動くようになるはずです。


## *コラム1-SNSの活用*

```{basicstyle=\normalfont frame=shadowbox}
皆さんはSNSはしていますか？SNSには様々な効能と副作用があります。
時に炎上する人だって居ます。廃人になる人も居ます。
しかし、最先端の科学にとって、SNSは大変有用なのです。
twitterでMEGやMRIの研究者をフォローしてみてください。
いい情報、最新の情報がピックアップされ、エキサイティングです。
僕は新着情報はtwitterで研究者、開発者、有名科学雑誌のアカウントを
フォローしてアンテナはっています。
ちなみに、若いエンジニアはよくするらしいです。
```
