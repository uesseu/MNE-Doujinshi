
\newpage
## MNE/pythonのインストール(脳波、脳磁図をする場合)

こちらはMNEの公式ではanacondaの存在下でやるようになっています。
anacondaが嫌いな人(結構いらっしゃるかと思います)は既に十分な
知識をお持ちのことと思います。

例えば、下記の意味が分かる人にはこのセクションは不要です。
あとはその都度必要になったものを適当に入れます。

```bash
python -m venv env
source env/bin/activate
pip install mne h5io matplotlib numpy mne-connectivity
```

ちなみに、意味的には
「envって名前の仮想環境を作って、その仮想環境に行って、
色々インストールするよー」という意味です。
実は僕はいつもこの方法をとっています。
ま、pythonは何通りも導入方法あるので。

あと、最近mneからコネクティビティ解析関連が
mne-connectivityとして独立したので、
使いたいならば入れて下さい。　

### 公式のインストール方法
長くmne-pythonをヲチしているけれど、
mne-pythonのインストール方法、変わりすぎて草。
バージョン変わる毎にインストール方法変わるので注意です。
現行バージョンは1.4。

現時点で公式サイトではanacondaを使うことになっています。
理由は…よく分かりませんが、多分「どこでも動くから説明が楽」なんだと思います。
インストール方法はここにあります。
[https://mne.tools/stable/install/manual_install.html](https://mne.tools/stable/install/manual_install.html)

ちなみにこういうゆるふわ簡易版なのもあります。
[https://mne.tools/stable/install/installers.html#installers](https://mne.tools/stable/install/installers.html#installers)

さて、上記の簡単版を使わないなら、下記のようにします。
```{frame=single}
conda install --channel=conda-forge --name=base mamba
mamba create --override-channels --channel=conda-forge --name=mne mne
```

これで新しい'mne'という仮想環境が出来るようです。

そう、仮想環境で構築することになります。
このやり方のメリットは、いつでも同じ環境を整える事ができるので、
ソフトのバージョンが変わっても対応しやすいということです。
反面、毎回仮想環境に入らないといけないという小さなデメリットがあります。
だけど、バージョン揃えるのは貴方の責任です。
つまり、使いましょう。(圧力)

公式サイトをみながら頑張りましょう。

```{frame=single}
conda create\
    --strict-channel-priority\
    --channel=conda-forge\
    --name=mne\
    mne-base h5io h5py pymatreader
```

--name=mneってありますよね？
これでmneという名前の仮想環境が整います。
下記のコマンドでmneの環境に入れます。

```{frame=single}
conda activate mne
```
今後はmneを使うときは必ず上記のコマンドを打って下さい。[^conda_activate]
面倒くさい？どうしても打ちたくないです？
それならば、.bashrcや.bash_profileに下記を追記してください。

```{frame=single}
conda activate mne
```

[^conda_activate]:昔はsource activateコマンドでしたが、このコマンドはanaconda以外の仮想環境ツールと衝突してクラッシュするという不具合がありました。控えめに言って糞仕様ですね。今後はconda activateコマンドを使うのがいいでしょう。

大まかにはこれで完結です。
仮想環境は複数作っておくほうが良いと思います。
hogeって環境作りますね。

```{frame=single}
conda create\
    --strict-channel-priority\
    --channel=conda-forge\
    --name=hoge\
    mne-base h5io h5py pymatreader
```
hogeの環境に入るには

```{frame=single}
conda activate hoge
```

です。ちなみに、出るのは

```{frame=single}
conda deactivate
```
macなら下記も必要です。

[^curl]:unix界隈では大人気のダウンローダー

### MAYAVIがインストール出来ない
多分今のMNE-pythonはMAYAVIは必要ないと思います。
僕の見た限りですが。昔は大変だったんだ。

### HF5をインストールしたい
時間周波数解析をする場合は、
HF5をインストールする必要が出ることがあります。
上記のanacondaの方法なら全部入りますが、pipとかでやると
入らないので一応言います。

```bash
pip install h5io
```

でおｋです。


### jupyter kernel
jupyterを使うのであれば、上記の環境をjupyterに登録する必要があります。
まずは、仮想環境に入って下さい。

```{frame=single}
conda activate mne
```
では、登録しましょう。下記は「今いる環境をjupyterに登録する」やつです。
userというのは「コンピュータ全体向けじゃなくて、僕向けにやるよ」
nameは仮想環境の名前ですね。
 
```{frame=single}
jupyter kernel install --user --name hoge
```
もし、要らなくなったら

```{frame=single}
jupyter kernelspec uninstall hoge
```
ですね。

### CUDA
CUDA[^cuda](GPGPU)についてもそのサイトに記載があります。
CUDAはnvidiaのGPUしか動きません。インストールについてはnvidiaのサイトも参照して下さい。
まぁ、各種波形フィルタでしか使えない上にさほど性能よくないです。
正直、**CPUだけで十分です。**[^no_need_gpu]

[^no_need_gpu]: MNE pythonはGPUの使い方が下手くそです。

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

[^cuda]: nVidiaのGPUを使った高速な計算ができる開発環境。うまく使いこなせればCPUの10から100倍速いです。

### MNE/Cのインストール

これはmne-pythonを普通に使うなら不要です。
つまり、レガシィな物を使いたい人が使うやつです。
**要するに不要です。**
残念ながらMNE/Cを使ったことがないので僕には何もわからないのです…。
下記サイトにメールアドレスを登録し、ダウンロードさせていただきましょう。
[MNE-C http://www.nmr.mgh.harvard.edu/martinos/userInfo/data/MNE_register/index.php](http://www.nmr.mgh.harvard.edu/martinos/userInfo/data/MNE_register/index.php)
ダウンロードしたものについてはこのサイトの通りにすればインストールできます。
[MNE-C http://martinos.org/mne/stable/install_mne_c.html](http://martinos.org/mne/stable/install_mne_c.html)
僕はホームディレクトリに入れました。

```{frame=single}
tar zxvf MNE-hogehoge
mv MNE-hogehoge MNE-C
cd MNE-C
export MNE_ROOT=/home/fuga/MNE-C
. $MNE_ROOT/bin/mne_setup_sh
```
これでMNE-Cも動くようになるはずです。


### *コラム1-SNSの活用*

```{basicstyle=\normalfont frame=shadowbox}
皆さんはSNSはしていますか？SNSには様々な効能と副作用があります。
時に炎上する人だって居ます。廃人になる人も居ます。
しかし、最先端の科学にとって、SNSは大変有用なのです。
twitterでMEGやMRIの研究者をフォローしてみてください。
いい情報、最新の情報がピックアップされ、エキサイティングです。
僕は新着情報はtwitterで研究者、開発者、有名科学雑誌のアカウントを
フォローしてアンテナはってたこともありました。
(筆者の脳の疾患が増悪して今はしてない)
ちなみに、若いエンジニアはよくするらしいです。
```
