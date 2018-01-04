# MNEを使う

いよいよ解析の準備に入ります。以下、MNEの公式サイトのチュートリアルのスクリプトなのですが…
かなり流暢なpythonistaが書いていると思われます。
そのため、初心者が見るには敷居が高目です。
一回はそれをなぞろうと思いますが、その後は噛み砕いてシンプルに紹介します。
http://martinos.org/mne/stable/tutorials.html
http://martinos.org/mne/stable/auto_examples/index.html
http://martinos.org/mne/stable/python_reference.html

## jupyterの起動

ターミナルで下記を叩いてください
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
jupyterはターミナルでctr-cを二回叩けば終了できます。
では、左上のnewボタンからpython2を起動しましょう。

## MNEpythonを使う前に学んでおくべきモジュール

とりあえず、pythonとnumpy[^numpy]の基礎を学ばねばなりません。
これは最低限のことです。これが書けないのであればmne/pythonは無理です。
PySurferはpythonでfreesurferのデータをプロットするために必須です。

他に学んでおくべきモジュールは
- matplotlib(作図用。seabornで代用可能なこともある。)
- pandas(python版excel。必須ではないが、劇的にやりやすくなる。)

pandasやmatplotlibもググってください。qiitaも結構良いです。
毎日何らかの課題に向けてpythonスクリプトを書きましょう。指が覚えます。
適当にググって良いサイトを見つければいいでしょう。

Python入門から応用までの学習サイト http://www.python-izm.com/](http://www.python-izm.com/)

pythonを初めて使う場合は、どうせならjupyterを初めから使って
慣れておけば良いのではないかと思います。
素のpythonも悪くはないですが、MNEの公式サイトにはjupyter notebook形式のスクリプトが
用意されていますから、使わない手はないでしょう。

[^numpy]:python用行列計算ライブラリ。科学計算に広く用いられています。

## numpyで遊ぼう

詳しくはググって下さい。numpyは本書では語りつくせるわけがありません。以上です。

…ではあんまりなので、ほんのさわりだけ紹介しておきます。
下記サイトが参考になります。

Pythonの数値計算ライブラリ NumPy入門 http://rest-term.com/archives/2999/](http://rest-term.com/archives/2999/)

```{frame=single}
import numpy as np
a=np.array([5,6])
b=np.array([7,8])
```

解説します。
1行目はnumpyを使うけれども長いからnpと略して使うよ、という意味です。
二行目と三行目で、aとbに5,6と7,8を代入しました。ここから下記を入力します。

```{frame=single}
print(a+b)
```

結果
```{frame=single}
[12,14]
```

このように計算できます。
ちなみに、numpyの配列と素のpythonの配列は違うものであり、素のpythonならこうなります。

```{frame=single}
a=[5,6]
b=[7,8]
print(a+b)
```
結果
```{frame=single}
[5,6,7,8]
```

numpyと普通のlistはlist関数やnumpy.array関数で相互に変換できます。
他にnumpy.arange等非常に有用です。

```{frame=single}
import numpy as np
np.arange(5,13,2)
```
結果
```{frame=single}
array([5,7,9,11])
```

これは5〜13までの間、2刻みの数列を作るという意味です。
そのほか、多くの機能がありMNEpythonのベースとなっています。
出力結果がnumpy配列で出てくるので、MNEがあるとはいえ使い方は覚える必要があります。


## データの読み込み…の前にmaxfilter(脳磁図の場合)

maxfilterをかけると数学的に脳の外のノイズを取ることができます。
これはMNEpythonでも出来はするのですが、今のところまだ成熟していないらしいので、
エレクタ社のソフトを使うのが適当です。特許の問題もあり、MNEpythonでは
当面難しいのかもしれません。
これがないとかなりノイズだらけのデータになりますので、必須です。

## 解析を始める前のwarning!

ここまでは単なるunix系の知識だけで済んでいましたが、この辺りからは数学の知識、
pythonを流暢に書く技術、脳波脳磁図のデータ解析の常識等、色々必要です。
pythonを書くのは本気でやればすぐ出来ますが、
微分方程式だとか行列計算を全部理解して応用するのはかなり面倒くさいです。
同人誌で完璧に説明するのは無理なので、一寸だけしかしません。
また、データ解析の常識は進化が速いうえにその手の論文を
読めていないと正確なところは書けません。
僕はあまり強くないのでここからは不正確な部分が交じるでしょう。
本書は純粋な技術書であることに留意し、最新の知識を入れ続けましょう。
