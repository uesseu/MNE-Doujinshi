
## データの集計について

データの集計についてですが…実は結構面倒くさいです。
MNEは個人個人のデータを解析するモジュールだからです。
貴方は個人個人のデータをMNEで解析した後、
そのデータを**自分で**集計する必要があります。numpyを使う必要性はここで出てきます。

MNEのオブジェクト(itc, power, evoked, epochs, raw等)は
ユーザーがいじることが出来るようになっています。

中の実データはそれぞれのオブジェクトの中のdataという変数か、
またはget_data関数で抽出してくることになります。
powerならpower.dataに、rawならraw.get_data()に入っています。
こうして出してきた配列はnumpy形式の配列です。

ピックアップした情報は多次元配列ですから、内容は膨大です。直接見ても整理つきません。
そこで便利な変数がnumpyにはあります。例えばevokedのデータを作ったならば
```{frame=single}
evoked.data.shape
```
とすればデータの構造が確認できます。

データの構造としてはこんな感じのようです。括弧がついているのはオブジェクト内の関数です

|形式|データ|1次元目|2次元目|3次元目|
|--|--|--|--|--|
|raw|raw.get_data()|チャンネル|波形||
|epochs|epochs.get_data()|チャンネル|波形||
|evoked|evoked.data|チャンネル|波形||
|itc|itc.data|チャンネル|周波数|波形|
|power|power.data|チャンネル|周波数|波形|
揃っていませんね…。
(どうせ使うのはevoked以下くらいなので大して困りません。)

それぞれのオブジェクトは
object.save(filename)
とすれば保存できます。
読み込みは多くの形式に対応する必要があってか一寸複雑です。

|形式|読み込み関数|備考|
|--|--|--|
|raw|mne.io.Raw()|脳磁図の場合。脳波とかは公式サイトAPI参照|
|epochs|mne.read_epochs()|
|evoked|mne.read_evoked()|条件によって配列で返されることあり|
|itc|mne.time_frequency.read_tfrs()|条件によって配列で返されることあり|
|power|mne.time_frequency.read_tfrs()|条件によって配列で返されることあり|

例えば
```{frame=single}
itc=mne.time_frequency.read_tfrs('/home/hoge/piyo')[0]
```
という感じで読み込みます。行の最後についている[0]は上記のごとく
条件によって配列で返されることがある関数だからです。この場合は行列として返されます。
そうじゃない関数の場合は[0]は不要です。実際に手を動かして練習すればわかると思います。

さて、実データのみではサンプリング周波数やチャンネルの名前が分からず
困ったことになりますが、mne/pythonではこれらは
それぞれのobjectの中のinfoというpython辞書形式変数に入っています。
例えばprint(itc.info)とかprint(itc.info['ch_names'])とかで
読めたりしますから確認してみてください。僕はこのinfoを使ってチャンネルを抽出したりします。

ここまでの知識で、自分でnumpy形式で脳波脳磁図を扱えるようになります。

あとは下記のようにすれば良いと思います。

1. powerなりitcなり波形なり、個人レベルで計算する
1. numpy形式で1チャンネル抜き出したり数チャンネルの平均取ったりする
1. 個人個人で数字が出てくるので、それを保存する
1. Rでその数字を統計解析する

例えばhogeチャンネルのfugaHzからpiyoHz、
foo番目からbar番目(秒×サンプリング周波数)の反応までの
実データを抽出したいなら、
```{frame=single}
itc.data[hoge, huga:piyo, foo:bar]
```
です。ちなみに、wavelet変換時にdecimの値を設定している場合は
(秒×サンプリング周波数/wavelet変換のdecimの値)となります。
APIページでtime_frequency.tfr_morlet()関数をご参照ください。

2はnumpyのmean等で実現します。
import numpy as npの後
```{frame=single}
np.mean(itc.data[hoge, huga:piyo, foo:bar])
```
などとすれば良いと思います。

3はpythonの基本構文通りなので解説しません。
4はどのようにしたいかは人によって違うかと思います。
最近は僕は単純にcsv形式に書き出しています。
pandasなんかはとても素敵です。
numpyでも普通のlistでもcsvに変換してくれます。こうすればいいです。

```{frame=single}
from pandas import DataFrame
DataFrame(hoge).to_csv(filename)
```

## jupyterでのRとpadasの連携

「Rをjupyterで動かすために」である程度書きましたが、再掲します。
jupyter上で
```{frame=single}
%load_ext rpy2.ipython
```
とした後
```{frame=single}
%%R -i input -o output
hogehoge
```
という風に記述すればhogehogeがRとして動きます。
ここのデータの受け渡しにもpandasを使うのが良いです。
項目には名前をつけることが出来ます。

```{frame=single}
from pandas import DataFrame
data = Dataframe(data
                 columns=('group',
                          'hemisphere',
                          'test', 'value'))
```
これで、横軸にcolumsのラベルの付いたデータフレームが出来ます。
こいつをto_csvを使ったりjupyterとかでRにぶちこみます。

```{frame=single}
%%R -i data
result <- aov(
  df$value ~ df$group * df$hemisphere * df$test,
  data=df))
cat(result)
```

だいたいこんな感じです。



## RでのANOVAについて

pythonのscipyでの統計もいいのですが「なんで統計ソフト使わないん？舐めてるん？」
とrejectを食らう可能性もありますから辞めましょう。

どうせ多重検定することになるんですから、それについて一寸。
だいたいANOVAを用います。aovがRのANOVA関数です。
これをsummary関数に読ませることで結果を簡単にまとめます。
さらに、cat文を使うことで画面上に表示します。
中の式は、データフレーム内の掛け算になっています。

ANOVA詳しい人は知っていると思いますが、これは相互作用を算出するものです。
相互作用を計算しない場合は'+'演算子を使ってください。結果が算出されると思います。
あとはANOVAの本でも読んで下さい。本書では割愛します。
Rによるやさしい統計学という本が僕のおすすめです。

[^naihou]:pythonistaはリスト内包表記とか使うんでしょうが、ここは簡単のためにappend使っています。というか、この程度の処理ならappendで困りません。

