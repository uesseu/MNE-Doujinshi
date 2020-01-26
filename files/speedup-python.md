\newpage
# pythonでの高速化のあれこれ
MNEpythonを使う場合、並列化以外の高速化はあまり考えないでいいです。
理由は、numpyを使っているので十分速いと思われるからです。
しかし、独自のメソッドを実装する時なんかに、処理速度が大事になる事もあります。
その時のやり方をいくつか記しておきます。

## for文とリスト内包表記とmap

pythonのfor文は絶望的に遅いため、for文の入れ子はやめましょう…と言われています。
MNE使うときには大差ないし良いんじゃないかと個人的には思いますが。
しかし、ここの所は今後の高速化を学ぶための布石になります。

forの代わりと言ってはアレですが、いくつか良いpython構文があります。

```{frame=single}
n = [i + 4 for i in range(5)]
```

この場合、[4, 5, 6, 7, 8]が帰ってきます。
この書き方はリスト内包表記と言い、広く使われています。詳しくはググってください。

他にmapという関数があります。これも速いです。上と同じ内容をmapで書いてみます。

```{frame=single}
def plus4(num: int) -> int:
    return num + 4

n = list(map(plus4, range(5))
```
どっちが良いとかは特にありません...

一々defで名前付きのを書きたくないならlambda式というので一行で出来ます。
pythonのlambda式、読みにくくて嫌われてるけどね。

```{frame=single}
n = list(map(lambda x: x + 4, range(5))
```

## numpy(独自のメソッドを実装するときとか)

numpyは速いので、重い演算の時は使えるなら使いましょう。
上記のリスト内包とかmapなんかよりnumpyの方が圧倒的に速いです。

## 並列化(これがやりたかった！)

これ、大事！pythonでの並列化はとても簡単です。
やり方は色々ありますが、Poolというのがお手軽並列化ツールです。

```{frame=single}
from multiprocessing import Pool
```

使い方は、pythonのmap関数に近いものですので、並列化する時は必ず何か関数を定義して下さい。
(ちなみに、poolのmapはlambda式を食べることが出来ません)

```{.python frame=single}
def test(i):
    return i * 8
```

これをwith文を使ってPoolの中にぶちこみます。

```{frame=single}
with Pool(4) as pool:
  result = pool.map(test, [1, 2, 3, 4])
print(result)
```
ね、簡単でしょ？
これ、testという関数が脳波を解析する関数だったら複数人の
脳波解析を同時進行できて爆速です！
(一人分をマルチプロセスするとメモリの取り合いが生じて遅くなる)

ここではmap_asyncという関数を使う方法もあります。
map_asyncはmapよりも頭の良い並列化関数です。
mapは全員一斉にやる感じ、map_asyncは全員でやるけれど、
終わった人は次の課題をし始める感じです。

```{frame=single}
with Pool(4) as p:
  result = p.map(test, [1, 2, 3, 4]).get()
print(result)
```

mapとの違いは、p.map_async(hoge).get()というふうにgetしてあげないと結果が得られないことです。

さて、mapもmap_asyncも今の所引数が1つのものじゃないと無理です。
複数ある場合は、starmapというのがあります。
とりあえず、starmapもstarmap_asyncもあるけど、asyncで書いてみます。

```{frame=single}
from multiprocessing import Pool

def test(x, y): return x + y

with Pool(4) as p:
    result=p.map_async(test, [(1, 2), (4, 6)]).get()
print(result)
```

良いですね！これで君のpythonはコア数に比例するスピードを得たのであります。

