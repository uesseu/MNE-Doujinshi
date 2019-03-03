# MNEpython実装時の小技
一応、実装が苦手な人が読者と思っているので、
ありふれた小技ですが紹介します。
object指向とか関数型とかは他の本を読んで下さい。得られるものが多いでしょう。

## メソッド・チェーン
今回は超手軽に解析してみましょう！
何度もフィルタ掛けるの面倒くさいから、一気にかけちゃう方法です。
メソッド・チェーンを使います。
メソッド・チェーンとはドットで数珠つなぎに処理をしていく技法です。
MNEpythonではrawオブジェクト辺りで割とできる感じです。実際見てみましょう。
```{frame=single}
from mne.io import Raw
Raw('hoge.fif').filter(1,100).notch_filter(60).save('fuga.fif')
```

どんだけ略してんだよ！というくらい略されてますね。
このケースでは、読み込んでフィルタを2つ掛けて保存しています。
まぁ、使いすぎは色々大変になるので良くないです。

## 変数を減らしてみる
rawを弄る時raw.filter関数などを使うとraw自体が
書き換わってしまいます。
これ自体は正しい動作なのですが、一寸わかりにくさを感じるかも知れません。
rawはrawとしてどっしり構えてもらって、
加工品だけ作って行きたいかも知れません。
そんなときはraw.copy関数がいいです。
```{frame=single}
raw2 = raw.copy()
```
これでrawのcopyが出来ましたね。しかし、どうも変数が多くなります。
raw2, raw3, raw4と作るうちにraw∞とかなって死にます。
それの対策にはメソッドチェーンがいい味を出すと思っています。
```{frame=single}
filtered = raw.copy().filter(1,100).notch_filter(60)
```
raw2など要らなかった。
まぁ、一寸消費メモリとかは多くなるかも知れません。

## MNEのAPI引数多すぎだろ死ね！
確かにMNEのmethodは引数が多すぎである。
引数が多すぎて毎回引数入れるのがダルいし、ミスも多くなりそうだ。
だが、落ち着いて聞いてほしい。
pythonには良い道具があるのだ。
```{frame=single}
from functools import partial
```
こいつは関数を部分的に解いちゃう関数だ。

今君は、複数のepochオブジェクトを作りたいとする。
event_idは1､2､3､4､5､6だ。その都度入力するのはダルいし、
変数が増えすぎると管理も大変だ。
そんなときはこのようにすればいい。
```{frame=single}
from mne.io import Raw
from mne.epochs import Epochs 
from mne import find_events

raw = Raw('hoge.fif', preload=True)
events = find_events(raw)
make_epoch = partial(Epochs, raw, events)
```

これでmake_epochという関数が出来た。以降は例えば
```{frame=single}
make_epoch(4)
```
とかでevent_idが4のepochオブジェクトが返る。
これで君の怒りが少しでもおさまってくれたら嬉しい。

## ここまでのまとめ
というわけで、凄く省略すれば、epochingまで下記のように書けるのです。
```{frame=single}
from mne.io import Raw
from mne import Epochs
raw = Raw('hoge').interpolate_bads().filter(1, 100).notch_filter(60)
make_epochs = partial(Epochs,
                      raw, mne.find_events(raw),
                      tmin=-0.2, tmax=5.0)
epochs = [make_epochs(n) for n in range(1,7)]
```
まぁ、ICAとか省いているから本当はもうちょっと長いです。

## 解析失敗したやつをスキップしたいんだが
気持はよく分かる。たまに失敗した実験が紛れてたりするんですよね。
そんな君にはfilter関数をおすすめしましょう。
これにより、だいぶ楽になります。

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
fnames = list(filter(lambda fname: exists(fname), file_list))
```
これで存在するものだけを読み込めます！
成功例のみ続けていけますね！

他にmap関数とか、reduce関数も時に有用です。

