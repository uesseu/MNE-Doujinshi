# pythonでの高速化のあれこれ

時に、処理速度が大事になります。特にソースレベル解析ともなると膨大な計算量になります。
その時のやり方をいくつか記しておきます。

## for文とリスト内包表記

pythonのfor文は絶望的に遅いため、for文の入れ子はやめましょう…と言われています。
軽い処理なら良いんじゃないかと個人的には思いますが。

代わりと言ってはアレですが、このようなpython構文があります。
```{frame=single}
n=[i+4 for i in range(5) ]
```
この場合、[4,5,6,7,8]が帰ってきます。この書き方はリスト内包表記と言い、
広く使われています。詳しくはググってください。

## numpy

numpyは速いので、重い演算の時は使えるなら使いましょう。
pythonは四則演算とかfor文とかとっても遅いのです。

## 並列化(まずます速い)

pythonでの並列化はとても簡単です。
```{frame=single}
from multiprocessing import Pool
```
このPoolというのがお手軽並列化ツールです。
並列化する時は必ず何か関数を定義して下さい。
```{.python frame=single}
def test(i):
    return i*8
```
これをPoolの中にぶちこみます。
```{frame=single}
p=Pool(5)
result=p.map(test,[1,2,3,4])
p.close()
result.get()
```
pという変数に並列化するための箱をつくりました。
この箱には5つのCPUで並列する機能をつけました。
そして、箱の中に並列したいtest関数と、それに入れたい変数を配列の形で
入れました。pの中にmapという関数がありますが、こいつが並列化の関数です。
こいつを回せば、[8,16,24,32]という結果が出てくるのです。

ここではmap_asyncという関数を使う方法もあります。
map_asyncはmapよりも頭の良い並列化関数です。
mapは全員一斉にやる感じ、map_asyncは全員でやるけれど、終わった人は
次の課題をし始める感じです。

今の所引数が1つのものじゃないと無理です。
複数ある場合は、wrapper[^wrapper]を使わねばなりません。
```{frame=single}
from multiprocessing import Pool
def test(i,j):
    return i*j
def wrap(a):
    return test(*a)
p=Pool(5)
result=p.map_async(wrap,[(1,2),(4,6)])
p.close()
result.get()
```
うわ面倒くせえ…
wrapという関数でtestという関数を包み込み、そいつに引数を渡します。

素直に引数一つの関数でやるのが楽で好きです。

[^wrapper]: 関数を加工する関数みたいなもの。

## クラスタレベルの並列化(数で押す方法)
ipythonはコンピュータクラスタレベルの並列化をサポートしています。
一人二役(コントローラとエンジン)することで一台でも実現できます。

今回は複数の引数付きでやってみたいと思います。クラスタの作り方については詳しくは述べませんが、
準備段階については前述していますから参照してください。

その上で、おなじみのアレです。

```{frame=single}
pip install ipyparallel
```

クラスタの設定ファイルを作ります。
```{frame=single}
ipython profile create --parallel --profile=default
```

この設定ファイルのいじり方は公式サイトとか、qiitaの記事を見てください。

その後のやり方は色々ありますが、僕のやり方を書きます。
まず、元締めのコンピュータでクラスタを起動します。ターミナルで以下を叩いてください。

```{frame=single}
ipcontroller --ip=hogehoge --profile default
```
これでdefaultという名前のクラスタのコントローラをip指定で起動しました。
…もちろん、1台だけの場合はipは要りません。
次に、下記のように各計算機(子機？)でエンジンを起動していきます。


```{frame=single}
ipcluster engines --n=4 --profile=default
```
--nは使うコア数です。元締めのコンピュータでも計算するなら同じようにしてください。
これで準備が整いました。

例えば、貴方が下記のような関数を実装したとします。

```{frame=single}
calc_source_evokedpower(id,person,tmax,tmin):
    d=id+person+tmax+tmin
    return d
```
うん、立派な関数ですね。

この関数はグローバル変数を参照できないことに注意してください。
変数やimport文は全て関数内で宣言するようにしてください。
宗教的な理由で関数内でimport出来ない方はお引き取りください。

このうち、idとpersonは全ての組み合わせを、tmaxとtminは固定した値を入れたいとします。
これをクラスタレベルでガン回しします。

```{frame=single}
import itertools
from ipyparallel import Client
client=Client(profile='default')
print(client.ids)

function=calc_source_evokedpower

product=zip(*list(itertools.product(id,person)))
plus1=tuple(['20Hz']*len(arglist[0]))
plus2=tuple(['50Hz']*len(arglist[0]))

arglist=product+[plus1]+[plus2]

view=client.load_balanced_view()
async=view.map_async(function,*arglist)
async.wait_interactive()
```
これも面倒くせえ！

まず、ipyparallelをインポートします。一応クライアントを確認しておきます。
functionに実行したい関数名を入れます。

その後、itertoolsのproduct関数を使ってidとpersonの全ての組み合わせを作ります。
さらに、固定した20Hzと50Hzを後に加えます。そして、配列を足し算していきます。

その後、3行の呪文を唱えれば出来上がりです。返り値はasync[:]で見れます。


## Cython(使いこなせば相当強い)

Cpython[^cpython]ではありません。Cythonという別ものです。
pythonをCに変換することで場合によってはpythonの100倍[^hundred]のスピードを
実現することが可能です。ただし、型を指定するなど加工しないと超速にはならないため、
一寸手がかかります。さらに、numpyとかは型関係が難しいです。
純粋かつ簡単なCで実装できるコードを突っ込むべきでしょう。
jupyterは大変優秀なので、下記のようにするだけでCythonを実行することが出来ます。

```{frame=single}
%load_ext cython
```
これをjupyterで実行した後、関数を実装します。下記はnumpyの例です。
```{frame=single}
%%cython -a
import numpy as np
cimport numpy as np
DINT=np.int
ctypedef np.int_t DINT_t
DDOUBLE=np.double
ctypedef np.double_t DDOUBLE_t

def u(np.ndarray[DDOUBLE_t,ndim=1] ar):
    cdef int n
    cdef double m
    for n in xrange(5):
        m=np.mean(ar)
        print(m)
```
上5行はCythonとnumpyを組み合わせた時の特有の黒魔術です。
上では、numpyのためにint型とdouble型を用意してあげています。また、cdefは型指定です。
関数を宣言するときも黒魔術的にnumpyの型を指定してあげねば
なりません。じゃないと動くけど遅いままになります。ndimはnumpy配列の次元数です。

それ以外はC言語を書いた人からすると型指定が必要なただのpythonなので、
苦労はあまりないはずです？ちなみに、元々C言語なのでCythonを普通に使おうとすると
普通のC以上に面倒くさいコンパイルの手続きが必要になります。

詳しくはcythonのホームページをググってください。
http://omake.accense.com/static/doc-ja/cython/index.html

[^cpython]:pythonの正式名称
[^hundred]:誇張ではありません。実際に効率の悪いpythonコードを最適化すると100倍速くなったりします。最適化なしでも2倍くらい速くなることもあります。

## C言語、C++、FORTRAN(最終兵器)

まぁ…そういうやり方もあります。正統派なやり方なのですが、本書では触れません。
車輪の再発明に気をつけましょう。
