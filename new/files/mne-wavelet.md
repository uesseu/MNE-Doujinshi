## センサーレベルwavelet変換

これは解析のゴールの一つと言えましょう。

### そもそもwavelet変換とは何なのか

特定の周波数の波の強さや位相を定量化するための計算方法です。
僕は数学が苦手なので、適当な説明です。フーリエ変換という言葉をご存知でしょうか？
これは波をsin波の複合体として解釈することで波を一つの式として表す方法です。
ほぼ全ての波はフーリエ変換によって近似的に変換できるのです。
凄いですね！しかし、これには欠点があります。不規則な波の変化に対応できないのです。
何故なら、sin波は未来永劫減衰しない波だからです。
フーリエ変換において、波は未来永劫つづくのが前提なのです。
(擬似的に切り取ることは出来る)
そこで、減衰するwaveletという波を使って波を表す方法を使います。
そのため、減衰する波を単純な数式で表現する必要があります。
これを理解するためには高校数学を理解する必要があります。
詳しくは後半の「初心者のための波形解析」を御覧ください。

![waveletの例。これはmorlet waveletという種類。morletはモルレと読む。青は実数部分、緑は虚数部分。](img/wavelet_base.png){width=14cm}

![morlet waveletの実数軸、虚数軸、角度軸による3d plot。](img/3d_wavelet_base.png){width=14cm}


### wavelet変換にまつわる臨床的な単語

wavelet変換に登場する単語としては以下のものが挙げられます。

|単語|内容|特徴|
|--|--|--|
|evoked power|波を加算平均した後にwavelet変換、波の強さ|ノイズにやや強い|
|induced power|waveletした後に結果加算平均、波の強さ|ノイズに弱いが後期成分に強い|
|phase locking factor|同一部位での位相同期性|ノイズにやや強い|
|phase locking value|色々な部位同士の同期性|後期成分に強い|

このなかで、phase locking factorは別名 inter-trial coherence(itc)といいます。
MNEpythonではitcという言い方しています。 
それぞれ生理学的には違うものを見ているらしいです。
これらの特徴の違いが何故生まれるかについても後半の
「初心者のための波形解析」を御覧ください。

ではevoked power,induced power,phase locking factorについて
解析を行いましょう。

### wavelet変換の実際

morletのやり方は臨床研究的にメジャーなやり方と僕は思っています。
下記のスクリプトで実行できます。

```{frame=single}
freqs=np.arange(30,100,1)
n_cycles = 6
evoked_power=mne.time_frequency.tfr_morlet(evoked,n_jobs=4,
  freqs=freqs,n_cycles=n_cycles, use_fft=True,
  return_itc=False, decim=1)
```

- freqs : どの周波数帯域について調べるか。
 上の例では30Hzから100Hzまで1Hz刻みに計算しています。
- n_cycles : 一つのwaveletに含まれる波のサイクル数。
 5~7という値で固定する方法がよく用いられます。
　MNEではこのサイクル数を可変にすることも出来ます。
- n_jobs : CPUのコアをいくつ使うか。重い処理なのです。
 ちなみに、n_jobsを大きくするよりも、n_jobsを1にして
 同時にたくさん走らせたほうが速いです…が、メモリは食います。
- use_fft : FFTによる高速wavelet変換を行うかどうか。
 数学の話になるので、詳しい所は本書では扱いません。
 要するに速く計算するかどうかです、Trueでいいかと。
- decim : この値を大きくすると処理が軽くなりますが、
 出力結果がちょっと荒くなります。
- return_itc : これをTrueにするとphaselocking factorも
 算出してくれます。


この関数はevokedもepochsも引数として取ることが出来ます。
return_itcがTrueかFalseかでも大きく挙動が違います。
挙動の組み合わせについてですが、下記のとおりです。

|return_itc|引数|返り値1つ目|返り値2つ目|
|--|--|--|--|
|False|evoked|evoked_power|なし|
|False|epochs|induced_power|なし|
|True|epochs|induced_power|phaselocking_factor|

itcを計算したい時は返り値が2つになりますから、下記のです。

```{frame=single}
freqs=np.arange(30,100,1)
n_cycles = 6
induced_power,plf=mne.time_frequency.tfr_morlet(epochs,n_jobs=4,
  freqs=freqs,n_cycles=n_cycles, use_fft=True,
  return_itc=False, decim=1)
```
