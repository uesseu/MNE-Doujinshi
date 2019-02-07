
# pythonでの高速化のあれこれ
MNEpythonを使う場合、GPGPU以外の高速化はあまり考えないでいいです。
理由は、numpyを使っているので十分速いと思われるからです。
しかし、独自のメソッドを実装する時なんかに、
処理速度が大事になる事もあります。
その時のやり方をいくつか記しておきます。

## for文とリスト内包表記

pythonのfor文は絶望的に遅いため、for文の入れ子はやめましょう…と言われています。
軽い処理なら良いんじゃないかと個人的には思いますが。

代わりと言ってはアレですが、このようなpython構文があります。
```{frame=single}
n=[i + 4 for i in range(5)]
```
この場合、[4,5,6,7,8]が帰ってきます。この書き方はリスト内包表記と言い、
広く使われています。詳しくはググってください。

## numpy

numpyは速いので、重い演算の時は使えるなら使いましょう。
pythonは四則演算とかfor文とかとっても遅いのです。

## 並列化(まずます速い)

pythonでの並列化はとても簡単です。
やり方は色々ありますが、Poolというのがお手軽並列化ツールです。
```{frame=single}
from multiprocessing import Pool
```
使い方は、pythonのmap関数に近いものですので、
並列化する時は必ず何か関数を定義して下さい。
```{.python frame=single}
def test(i):
    return i*8
```
これをwith文を使ってPoolの中にぶちこみます。
```{frame=single}
with Pool(4) as p:
  result=p.map(test,[1,2,3,4])
print(result)
```
ね、簡単でしょ？

ここではmap_asyncという関数を使う方法もあります。
map_asyncはmapよりも頭の良い並列化関数です。
mapは全員一斉にやる感じ、map_asyncは全員でやるけれど、終わった人は
次の課題をし始める感じです。
mapとの違いは、p.map_async(hoge).get()というふうに
getしてあげないと結果が得られないことです。

さて、mapもmap_asyncも今の所引数が1つのものじゃないと無理です。
複数ある場合は、wrapper[^wrapper]を使わねばなりません。
なので、若干魔術的になります。とりあえず、map_asyncで書いてみます。
```{frame=single}
from multiprocessing import Pool
class MultiArgs:
    def __init__(self, func):
        self.func = func
    def __call__(self, arg):
        return self.func(*arg)

def test(i,j):
    return i*j

with Pool(4) as p:
    result=p.map_async(MultiArgs(test),
                       [(1, 2), (4, 6)]).get()
print(result)
```
うわ面倒くせえ…
ここではMultiArgsというオブジェクトを作って、
test関数を包み込み、そいつに引数を渡しています。
まぁ、MNE-pythonを使うならこんなことあまり必要ないとは思います。

[^wrapper]: 関数を加工する関数みたいなもの。

## クラスタレベルの並列化(数で押す方法)
ipythonはコンピュータクラスタレベルの並列化をサポートしています。
一人二役(コントローラとエンジン)することで一台でも実現できます。

今回は複数の引数付きでやってみたいと思います。クラスタの作り方については詳しくは述べませんが、
準備段階については前述していますから参照してください。

ではpipをします。

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

この関数はグローバル変数を参照できないことに注意してください。
変数やimport文は全て関数内で宣言するようにしてください。
宗教的な理由で関数内でimport出来ない方はお引き取りください。

では、これをクラスタレベルでガン回しします。

```{frame=single}
from ipyparallel import Client
i = Client(profile='default').load_balanced_view()

def test(a):
    return a*2

result = i.map_async(test, [1,2,3])
result.wait_interactive()

print(result[:])
```
これも面倒くせえ！

まず、ipyparallelをインポートします。
Client(prifile='default').idsをprintすると一応クライアントを確認しておきます。
map_asyncに実行したい関数名を入れます。

その後、呪文を唱えれば出来上がりです。返り値はresult[:]で見れます。


## Cython(使いこなせば相当強いが、多分不要)

Cpython[^cpython]ではありません。Cythonという別ものです。
pythonをCに変換することで場合によってはpythonの100倍[^hundred]のスピードを
実現することが可能です。numpyとかは型関係が難しいですが、
新しいpythonの文法を使えばほぼそのままC並に早くしてくれます。
静的型付けとは仲良しになれます。
jupyterは大変優秀なので、下記のようにするだけでCythonを実行することが出来ます。
まず、下記のように呪文を唱えます。
```{frame=single}
%load_ext cython
```
そして、実装していきます。

```{frame=single}
%%cython -a
import cython as c
from typing import List
def speed_calc(x: List[c.float])-> float:
    result: c.float = 0
    for t in x:
        result += x
    return result
```
こんな感じなのですが、for文とか超絶速くなります。


numpyを使う場合は残念ながら上記のような文法を使えません。
下記はnumpyの例です。ちょっと型が面倒です…

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
上5行はCythonとnumpyを組み合わせた時の特有のおまじないです。
上では、numpyのためにint型とdouble型を用意してあげています。また、cdefは型指定です。
関数を宣言するときも黒魔術的にnumpyの型を指定してあげねば
なりません。じゃないと動くけど遅いままになります。ndimはnumpy配列の次元数です。

それ以外はC言語を書いた人からすると型指定が必要なただのpythonなので、
苦労はあまりないはずです？

詳しくはcythonのホームページをググってください。
http://omake.accense.com/static/doc-ja/cython/index.html

[^cpython]:pythonの正式名称
[^hundred]:誇張ではありません。実際に効率の悪いpythonコードを最適化すると100倍速くなったりします。最適化なしでも2倍くらい速くなることもあります。

## C言語、C++、FORTRAN(最終兵器)

まぁ…そういうやり方もあります。正統派なやり方なのですが、本書では触れません。
車輪の再発明に気をつけましょう。
