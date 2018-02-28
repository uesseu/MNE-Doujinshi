# 開発環境の準備（脳波、脳磁図の場合。出来るだけリッチに。）
- freesurferだけ使う人は開発環境は要りません。読み飛ばして下さい。
- 試すだけだとか、質素な開発環境でいい人も読み飛ばして下さい。

開発環境はMNE使うなら必要です。詳しい人からは「docker[^docker]じゃダメなん？」という質問が
来そうですが、ライセンスの問題がありますし、セットアップは自分でできなければ
困ることもありましょう。僕はanaconda[^conda]を使います。何故ならインストールが楽だからです。

[^docker]:最近流行りの仮想化環境です。性能が高いのが特徴ですが、反面使いこなすのには力が必要です。

[^conda]:anacondaとはContinuumAnalytics社で開発されているデータサイエンティスト向けのpythonディストリビューションです。もちろん好みに応じてpyenvなどを使うのもありと思うのですが、mayaviというインストールの鬼門が存在するのでanacondaが楽です。

https://www.continuum.io/downloads

このサイトからインストールプログラムをダウンロードします。
anacondaは2と3があり、それぞれpython2と3に対応しています。どちらを選ぶか悩ましいです。
3は現時点ではソースベース解析出来ませんが、そのうちpython2自体のサポートが切れます…。
anacondaにspyderというIDEが付いてくるのでそれを使うのもいいでしょう。
spyderはとても素直な挙動のIDEでipythonの補完機能も手伝って使いやすいです。
しかし、僕のおすすめはjupyter+anaconda2で多言語切り替えながら使う方法です。
jupyterはwebベースの開発環境で、他の人とデータやソースコードの共有が容易なので捗ります。[^kirikae]


![jupyterの画面。webベースでインタラクティブにコーディング・共有できる。詳しい人に「githubじゃダメなん？」と言われましたが、ここでいう共有ってそういう意味じゃないんですよ。非プログラマの先輩が後輩に教えながらコーディングする小さなラボで…という意味ですよ。まぁ、触ってみればわかります。また、本格的なソースの共有はできないので、git併用するのが良いかと思います。](img/jupyter.jpg){width=14cm}

![spyderの画面。ごく普通の素直な挙動のIDE。jupyterより動作が軽いのも魅力。一人で解析するならこれも良いものです。](img/spyder.jpg){width=14cm}

[^kirikae]: 僕がjupyterを推す他の理由としては遠隔操作が簡単であること、有名なスクリプト言語の殆どに対応している事が挙げられます。

MACはanacondaのインストーラーをダウンロードしてクリックしていけばどうにかなります。
linuxではanacondaはダウンロード後、ターミナルで以下のようにコマンドを叩いて
インストールします。bashです。ただのshじゃインストールできません。

```{frame=single}
bash Anaconda3-4.3.0-Linux-x86_64.sh
```

インストール先はホームフォルダでいいかとか、色々質問が出てきますが、
そのままホームフォルダにインストールするのが~~気持ち悪くても~~スムーズに行くかと思います。

## jupyterの設定(やり得)
素のjupyterでも強力ですが、折角なので拡張しておきましょう。ターミナルで下記を叩いてください。

```{frame=single}
conda install -c conda-forge jupyter_contrib_nbextensions
jupyter contrib nbextension install --user
ipcluster nbextension enable --user
```

これでextensionが使えるようになります。jupyterは機能が拡張できるので便利です。

## jupyterでのplot

jupyterはplotの方法を指定できます。
表示したい場合は、予め下記コードをjupyter上に書いておいてください。

jupyter上に直接出力したい時
```{frame=single}
%matplotlib inline
```

python2環境下で別ウィンドウで表示したい時
これはスクロールが必要な時に便利です。
```{frame=single}
%matplotlib qt
```

python3環境下で別ウィンドウで表示したい時
python3とpython2は使うqtのバージョンが違うので
qt5が必要になります。
```{frame=single}
%matplotlib qt5
```

三次元画像をグリグリ動かしながら見たい時
(mayavi使用)
```{frame=single}
%gui qt
```
これについては後でまた詳しく記載します。

## python2,3二刀流(現時点では不要)

このセクションは必要ありませんが、将来的にきっと
python2から3に移行する時がMNEにもやってくると思いますので記しておきます。

python2と3を二刀流すべくキーボードを叩きます。現時点ではmayaviと言う
結果の図示に必要なモジュールが古い環境でしか動かず、通常はpython2系を使うべきと考えます。
以下、anaconda2から入れた場合です。逆の場合python2.7と読み替えて下さい。

```{frame=single}
ipython kernel install --user
conda create -n python3 python=3.6 anaconda
source activate python3
ipython kernel install --user
conda info -e
```
1行目から順に何をやっているか述べます。

1. 今のpython2の環境をjupyterに載せておく
1. condaで別バージョンのpython環境を作る
1. 切り替える
1. jupyterに組み込む
1. 確認

source activateコマンドでpythonの環境を切り替えられます。これでjupyterでpython2と3を
切り替えられると思います。ちなみに間違って環境を作った場合は以下のコマンドで消せます。

```{frame=single}
conda remove -n python3 --all
```

## Rをjupyterで動かすために(非常に便利)

anacondaを使っているなら下記でRがインストールできます。
```{frame=single}
conda install libiconv
conda install -c r r-essentials
conda install -c r rpy2
```
これによりRが動くようになり、貴方は少しだけ楽になります。
何故なら、実験結果を同じ環境で動くRに吸い込ませられるので、
「実験結果を入力するだけでワンクリックで統計解析結果まで出る」[^toukei]ような
スクリプトが実現できるからです。具体的にはjupyter上で
```{frame=single}
%load_ext rpy2.ipython
```
とした後
```{frame=single}
%%R -i input -o output
hogehoge
```
という風に記述すればhogehogeがRとして動きます。plotも出来るし、引数、返り値も
上述のとおり直感的です。さて、この-iですが、通常の数字や一次元配列は普通に入りますが、
Rならデータフレームからやりたいものです。その場合はpandasというモジュールを使って
受け渡しをします。例えばこのような感じです。
```{frame=single}
import pandas as pd
data=pd.Dataframe([二次元配列])
```
```{frame=single}
%%R -i data
print(summary(data))
```

pythonとRをシームレスに使いこなすことがこれで出来るようになります。
