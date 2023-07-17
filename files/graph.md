
\newpage
### graph

グラフ理論をご存知でしょうか？グラフ理論はあれです、ネットワーク図から、
何らかの指標を抜き出してくるアルゴリズム群みたいなものです。
ほら、全脳解析でコネクティビティが出るじゃないですか。
それを数値化してくれる便利なやつです。
(僕の中ではその程度の認識。ただし、多分あってる。)

pythonでgraph理論でなにかやりたい場合は有力な選択肢として
- bctpy
- NetworkX

の二つがあります。
このうち、bctpyはmatlabのbctからの移植で、脳特化型です。
NetworkXはエンジニアさんたちの汎用的な道具です。
どちらかと言うと、bctの方が重み付けにいい感じ。
NetworkXの方が量子化されている感じです。
僕の感想ですが、現状ではbctの方が使いやすい。

```{frame=single}
pip install bctpy
pip install networkx
```
これでbctpyとNetworkXがインストールされました。
公式サイトはこれです。
[https://github.com/aestrivex/bctpy](https://github.com/aestrivex/bctpy)
[https://networkx.org/](https://networkx.org/)

bctpyのドキュメントは隠れています。
[https://github.com/aestrivex/bctpy/tree/master/docs/_build/html](https://github.com/aestrivex/bctpy/tree/master/docs/_build/html)

うーん…これは、なにか生成させたかったのかな。
他の見方もあったのかも知れない。

さて、コネクティビティの結果である三角行列を突っ込みたいですね。
突っ込みます。

```{frame=single}
import bct
```

例えばconmatというnumpy三角行列があったとして、こいつを放り込むなら
まずは三角行列を普通の行列にしてやるべきでしょう。
(方向ありの行列なら三角行列にはならないのでそのままでいいです)

```{frame=single}
dcon = conmat + conmat.T
```

global efficiencyを重み付けありで計算したいならこうと思います。

```{frame=single}
global_efficiency = bct.efficiency_wei(con)
```

ね、簡単でしょ？
この場合はそれぞれの距離を求めてからglobal efficiencyを計算します。
重み付きかどうかは選べるみたいです。
重みがついていない場合は$bct.efficiency_bin$です。

すると、Global efficiencyの場合にはスカラー値が算出されます。
「このネットワークを表すスカラー値を出す」とか
「この点がどのくらい他と繋がっているか点ごとに出す」的な事をするのが
グラフ理論です。(数学者に怒られる表現)
中には、閾値を設けて「これ以上の繋がり具合なら繋がってる」とみなして
計算するやつとかもあります。

では、NetworkXの方を使ってみましょうか。
ここでは量子化につよいNetworkXの強みを活かしてMinimum spanning treeを
作って、それのGlobal efficiencyを作ってみましょう。
Global efficiencyは元々重みがついている方がレアですね。

```{frame=single}
import networkx as nx
graph = nx.Graph(con)
mst = nx.minimum_spanning_tree(graph)
global_efficiency = nx.global_efficiency(mst)
```

もちろん、途中で元のnumpyのデータに戻すことも出来るので、
NetworkXとbctpyを組み合わせて使うことも出来ます。
さっきのMinimum spanning treeをnumpyの行列に戻してみましょう。

```{frame=single}
np_con = nx.to_numpy_array(mst)
```

いいですね。これで貴方もグラフ理論で脳解析が出来るわけです。
ここは、メソッドが星の数ほどあるので、貴方はどれを使うのが良いのか
頑張って考えねばなりません。
