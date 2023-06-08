
\newpage
## 開発環境の準備（脳波、脳磁図の場合。出来るだけリッチに。）

- freesurferだけ使う人は開発環境は要りません。読み飛ばして下さい。
- 試すだけだとか、質素な開発環境でいい人も読み飛ばして下さい。
- 玄人も読み飛ばして下さい。

プログラミング得意な人はこのセクションは見なくていいです。

開発環境はMNE使うなら必要です。
MNEはpythonで動くため、まずはpythonの環境を用意してあげないといけないのです。
pythonの環境は構築の方法がいくらでもあるのですが、それぞれ一長一短です。

詳しい人からは「docker[^docker]じゃダメなん？」という質問が
来そうですが、セットアップは自分でできなければ困ることもありましょう。
普通はanaconda[^conda]を使います。何故ならMNE公式がanaconda推しだからです。
anacondaもいい所悪い所色々あってエンジニアの中には毛嫌いする向きもあります。
僕はよりpythonistaっぽくvenv[^venv]を使っています。
pipenv[^pipenv]やpoetry[^poetry]を使う方法もあります。
venvとpoetryはpython本体までは用意してくれないので、
pyenvと併用する必要があります。

[^venv]: python標準の仮想環境です。非常にシンプルで、シンプルである故にトラブルが少ないですが、少し煩雑です。

[^pipenv]: 昔python公式がオヌヌメしていた仮想環境作りツールです。かなりリッチです。重いのとトラブりやすいのが欠点です。

[^poetry]: pipenvの代替。pipenvがpython界でメジャーになったのですが、割と不安定なところもあったので、開発されたやつです。速くて安定していて、控えめに言って神なのですが大げさかも？

[^docker]:最近流行りの仮想化環境です。性能が高いのが特徴ですが、反面使いこなすのには力が必要です。

[^conda]:anacondaとはContinuumAnalytics社で開発されているデータサイエンティスト向けのpythonディストリビューションです。もちろん好みに応じてpipenvなどを使うのもありですが、面倒いので書きません。

[Anaconda https://www.continuum.io/downloads](https://www.continuum.io/downloads)

このサイトからインストールプログラムをダウンロードします。
anacondaにjupyterというrepl[^repl]とspyderというIDE[^ide]が付いてきます。
これらを使うのもまたいいと思います。

[^repl]:特定言語用の対話型インターフェイスのこと。
[^ide]:統合開発環境のこと。

### それぞれの使用感
あとは、自分の好きな開発環境を調達するといいでしょう。
開発環境は色々あるので軽く紹介します。

#### vscode
vscodeは現代的なテキストエディタです。
python用ではありませんが、プラグインを入れてpythonのIDEとして使うことが出来ます。
Microsoft製ですので圧倒的な安心感があります。

#### spyder
とても素直な挙動のIDEでipythonの補完機能も手伝って使いやすいです。
ただし、動作が重めなのと、企業のバックアップがなくなって今後が辛いかもです。
オススメ度は将来性を考慮するとやや低いです。


#### jupyter, ipython
replというか、shellと言うかちょっと珍しい開発環境です。
これだけで完結することも出来なくはないレベルの開発環境です。強みとしては

- webベースなので遠隔操作可能
- cythonやRといった他言語との連携が容易
- 対話的インターフェイスがメイン

弱みもあります

- 厳格なコーディングに不向き
- バージョン管理できない
- 気をつけてないと散らかり過ぎて崩壊する
- 処理速度が遅くなる

これだけでやろうとするのはやめたほうが良いです。
弱みが割と致命的になりがちで、初学者がこれだけに慣れると
コーディング技術が伸び悩みます。
使うなら、必ず他のテキストエディタと併用しましょう。


### 僕の今のおすすめは?

初心者の場合
- anaconda
- vscode
- jupyter
という組み合わせです。mneのインストールはanacondaに任せちゃいます。
基本はvscodeでスクリプトを書きますが、状況に応じてjupyterでチェックしたりします。

pythonを書いたことは無いけれど他の言語の玄人の人にはこうです。
- venvまたはpoetryとpyenv
- 好みのテキストエディタ

え？僕ですか？僕はvenvとvim[^vim]とipythonのCUIでやっています。

[^vim]: 圧倒的なテキストエディタの一つ。僕は脳波解析も、同人誌執筆も、すべてvimで行っています。

### 逆にお勧めしないもの

Windowsのnotepad.exeはお勧めしません！
力不足です！

Macのテキストエディットは最悪です！
勝手に貴方の書いた文字列を書き換えてしまいます！

jupyter一本で挑むのはやめて下さい！
初心者はjupyter依存症になって伸び悩みます！

### 構築
では、上記の初心者用環境を整える為の準備をしていきましょう。
vscodeはまぁ、導入するのは楽勝なのでググって下さい。


![jupyterの画面。webベースでインタラクティブにコーディング・共有できる。まぁ、触ってみればわかります。](img/jupyter.jpg){width=14cm}

![spyderの画面。ごく普通の素直な挙動のIDE。](img/spyder.jpg){width=14cm}

MACはanacondaのインストーラーをダウンロードしてクリックしていけばどうにかなります。
linuxではanacondaはダウンロード後、ターミナルで以下のようにコマンドを叩いて
インストールします。bashです。ただのshじゃインストールできません。

```{frame=single}
bash Anaconda3-hoge-Linux-x86_64.sh
```

インストール先はホームフォルダでいいかとか、色々質問が出てきますが、
そのままホームフォルダにインストールするのが~~気持ち悪くても~~スムーズに行くかと思います。
気持ち悪くて死ぬ人はpipenvでも使って下さい。

### Jupyterの起動
```{frame=single}
jupyter notebook
```

すると、ブラウザが起動し、画面が表示されるはずです。
起動しなければ、下記URLにアクセスしてください。
http://localhost:8888
jupyterはブラウザで動かすものですが、別にネットに繋がるものじゃないです。
ちなみに、下記の様にして起動すると、lan内で別のjupyterに接続できます。

```{frame=single}
jupyter notebook --ip hoge
```

ipは、多分ターミナルに表示されていると思います。
そうじゃないなら、例えばUbuntuなら
```sh
ip addr
```
で表示されます。
jupyterはターミナルでctr-cを二回叩けば終了できます。
では、左上のnewボタンからpythonを起動しましょう。
### jupyterの設定
jupyterを使うなら、折角なので拡張しておきましょう。ターミナルで下記を叩いてください。

```{frame=single}
conda install -c conda-forge jupyter_contrib_nbextensions
jupyter contrib nbextension install --user
ipcluster nbextension enable --user
```

これでextensionが使えるようになります。

### jupyterでのplot

jupyterはplotの方法を指定できます。
表示したい場合は、予め下記コードをjupyter上に書いておいてください。

jupyter上に直接出力したい時

```{frame=single}
%matplotlib inline
```

python3環境下で別ウィンドウで表示したい時python3とpython2は使うqtのバージョンが違うので
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

### anaconda仮想環境

anacondaは仮想環境を作れます。仮想環境はガンガン使いましょう。
何故かって？mneのバージョンが上がることがあります。
バージョンが上がるときに困るのは、バージョンを上げると
過去の解析環境が失われてしまい、再現性が損なわれることです。
そこで、大事なのは仮想環境を作り、その環境の中でやっていくことです。
MNEはanacondaを推奨しています。
anacondaはpythonの仮想環境[^kasou]を作ることが出来ますのでそれを利用するのが楽です。

[^kasou]:仮想環境にも色々あります。例えば、pipenv、poetryなどです。anacondaも同じ様な感じで使えます。

では、ipythonからやっていきましょう。
ここでは、hogeという名前のpython3.6環境をjupyter上に作ってみましょう。

```{frame=single}
ipython kernel install --user --name py3
conda create -n hoge python=3.6 anaconda
conda activate hoge
ipython kernel install --user --name hoge
conda info -e
```
1行目から順に何をやっているか述べます。

1. 今のpythonの環境をjupyterに「py3」という名前で載せておく
1. condaで別バージョンのpython環境を作る
1. 切り替える
1. jupyterに「hoge」という名前で組み込む
1. 確認

conda activateコマンドでpythonの環境を切り替えられます。
これでjupyterで色んな環境を切り替えられると思います。
ちなみに間違って環境を作った場合は以下のコマンドで消せます。

```{frame=single}
conda remove -n python3 --all
```

### Rをjupyterで動かすために

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
