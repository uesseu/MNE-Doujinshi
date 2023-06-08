
\newpage

## MNEpython実装時の小技
一応、実装が苦手な人が読者と思っているので、 ありふれた小技ですが紹介します。
Object指向とか関数型とかは他の本を読んで下さい。得られるものが多いでしょう。

### メソッド・チェーン
今回は超手軽に解析してみましょう！
何度もフィルタ掛けるの面倒くさいから、一気にかけちゃう方法です。
メソッド・チェーンを使います。
メソッド・チェーンとはドットで数珠つなぎに処理をしていく技法です。
MNEpythonではrawオブジェクト辺りで割とできる感じです。実際見てみましょう。

```{frame=single}
from mne.io import Raw
Raw('hoge.fif').filter(1, 100).notch_filter(60).save('fuga.fif')
```

どんだけ略してんだよ！というくらい略されてますね。
このケースでは、読み込んでフィルタを2つ掛けて保存しています。
まぁ、使いすぎは色々大変になるので良くないです。

### 変数を減らしてみる
rawを弄る時raw.filter関数などを使うとraw自体が書き換わってしまいます。
これ自体は正しい動作なのですが、一寸わかりにくさを感じるかも知れません。
rawはrawとしてどっしり構えてもらって、加工品だけ作って行きたいかも知れません。
そんなときはraw.copy関数がいいです。

```{frame=single}
raw2 = raw.copy()
raw3 = raw2.filter(1, 100)
raw4 = raw3.notch_filter(60)
```
これでrawのcopyが出来ましたね。しかし、どうも変数が多くなります。
raw2, raw3, raw4と作るうちにraw∞とかなって死にます。
それの対策にはメソッドチェーンがいい味を出すと思っています。

```{frame=single}
filtered = raw.copy().filter(1, 100).notch_filter(60)
```
raw2など要らなかった。

### MNEのAPI引数多すぎだろ死ね！
確かにMNEのmethodは引数が多すぎである。
引数が多すぎて毎回引数入れるのがダルいし、ミスも多くなりそうだ。
だが、落ち着いて聞いてほしい。pythonには良い道具があるのだ。

```{frame=single}
from functools import partial
```
こいつは関数を部分的に解いちゃう関数だ。

今君は、複数のepochオブジェクトを作りたいとする。event_idは1､2､3､4､5､6だとする。
その都度入力するのはダルいし、変数が増えすぎると管理も大変だ。そんなときはこのようにすればいい。

```{frame=single}
from mne.io import Raw
from mne.epochs import Epochs 
from mne import find_events

raw = Raw('hoge.fif', preload=True)
events = find_events(raw)
make_my_epochs = partial(Epochs, raw, events)
```

これでmake_my_epochsという割と決め打ち的な関数が出来た。以降は例えば

```{frame=single}
make_my_epochs(4)
```
とかでevent_idが4のepochオブジェクトが返る。これで君の怒りが少しでもおさまってくれたら嬉しい。

### ここまでのまとめ
というわけで、凄く省略すれば、epochingまで下記のように書けるのです。

```{frame=single}
from mne.io import Raw
from mne import Epochs
raw = Raw('hoge').interpolate_bads().filter(1, 100).notch_filter(60)
make_epochs = partial(Epochs,
                      raw, mne.find_events(raw),
                      tmin=-0.2, tmax=5.0)
epochs = [make_epochs(n) for n in range(1, 7)]
```
まぁ、ICAとか省いているから本当はもうちょっと長いです。

### 解析失敗したやつをスキップしたいんだが
気持はよく分かる。たまに失敗した実験が紛れてたりするんですよね。
そんな君にはtry文とfilter関数をおすすめしましょう。これにより、だいぶ楽になります。

#### try文
やってみて、失敗したらやめるというやつ。
```{frame=single}
try:
    raw = Raw('hoge.fif')
except FileNotFoundError:
    return None
```
こんな感じで使います。これで万一どれかで失敗しても処理が止まらない！
エラーの書き方は、まぁ、ググって調べてください。

#### filter関数
例えば、何らかの理由でepochsを作れなかったrawがあったとします。
(トリガーが入ってなかったとか、色々あると思う)
そんなのが紛れ込んででfor文が動かんくなったら糞面倒くさいです。
ここで、os.pathモジュールのexists関数[^exist]を
filter関数やlambda式[^lambda_stat]と組み合わせて使うといいです。

[^exist]: というか、bool型を返してくれるやつなら何でも行ける。
[^lambda_stat]: 無名関数。１行の使い捨てのやつ。

filter関数はlistやtupleの中で、条件に合うやつだけを抜き出すものです。
これは高階関数といって、関数を引数に取る関数です。
こんなかんじ。filter(関数, list)
では今回は存在するrawだけを抜き出すという操作をやってみましょう。

```{frame=single}
from os.path import exists

file_list = ['hoge', 'fuga', 'piyo']
fnames = list(filter(exists, file_list))
```
これで存在するものだけを読み込めます！成功例のみ続けていけますね！
でも、「どれが読み込めたか分からない」って思いましたか？

大丈夫。epochsとかのオブジェクトにはたいていfilename的なメンバー変数が
入っているからそれを参照して下さい。
つまり、こんな感じですね。

```{frame=single}
from mne import read_epochs

file = 'hoge'
epochs = read_epochs('file')
...
print(epochs.filename)
epochs.save(f'modified-{epochs.filename}')
```

Rawの場合は連結できたりする関係上、flenamesのようです。

他にmap関数とか、reduce関数も時に有用です。
MNE使う時は割と関数型パラダイムは有効っぽそうです。ただ、気をつけて下さい。
mapとかfilterとかは一度値を取り出すと空っぽになります。
使いまわす場合はlistとかに一々保存したほうが良いでしょうね。

また、上記の方法ではファイルが壊れていた場合に対応できないので、
結局はtry文を使うことになるかと思います。

### file名じゃなくてフォルダ名が欲しいん

概ねこんな感じでゲットできます。

```{frame=single}
from pathlib import Path
path = Path(epochs.filename).parent
dirname = str(path)
``` 

こういう小技、大事ですよね...いや、工学部の人は良いんだけどさ...
