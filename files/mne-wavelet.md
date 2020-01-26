
\newpage
## センサーレベルwavelet変換

これは解析のゴールの一つと言えましょう。
特定の周波数の波の強さとか、揃い具合を数字に出来れば論文が
書けるってわけです！ヒャッホゥ！

### そもそもwavelet変換とは何なのか

特定の周波数の波の強さや位相を計算する方法です。僕は数学が苦手なので、適当な説明です。
フーリエ変換という言葉をご存知でしょうか？
フーリエ変換は全ての波をsin波の合算として解釈することで波を一つの式として表す方法です。
余程ヤバイ波じゃなければ、ほぼ全ての波はフーリエ変換によって近似的に変換できるのです。
凄いですね！しかし、これには欠点があります。不規則な波の変化に対応できないのです。
何故なら、sin波は未来永劫減衰しない波だからです。
フーリエ変換において、波は未来永劫つづくのが前提なのです。
(擬似的に切り取ることは出来るし、普通にそれだけでも研究は成立する)

そこで、減衰するwaveletという波を使って波を表す方法を使います。
そのため、減衰する波を単純な数式で表現する必要があります。

これを理解するためには高校数学を理解する必要があります。[^kousotsu]
なんと！この同人誌は高校を卒業した人向けの同人誌であったのか！？
まぁ、中卒の人でも高校数学の特定の数学を勉強すれば十分いけます。勉強するべきなのは

- 三角関数
- 複素数
- 指数・対数
- 微分方程式

と、このあたりです。詳しくは後半の「初心者のための波形解析」を御覧ください。

[^kousotsu]: 高校を卒業した事のある人は目をそらさないでいただこうか。

![waveletの例。これはmorlet waveletという種類。morletはモルレと読む。青は実数部分、緑は虚数部分。](img/wavelet_base.png){width=14cm}

![morlet waveletの実数軸、虚数軸、角度軸による3d plot。](img/3d_wavelet_base.png){width=14cm}


### wavelet変換にまつわる臨床的な単語

波の強さや揃い具合を測れると言っても、まずは用語がないとどうしようもありません。
脳活動に関する用語としては以下のようなものがあります。(ただし、コネクティビティ系は除く)

| 単語                 | 内容                                          |
|----------------------|-----------------------------------------------|
| total power          | 何らかの刺激を受けて出てくるpower             |
| evoked power         | 何らかの刺激を受けた直後に同期して出るpower   |
| induced power        | 何らかの刺激を受けて刺激に同期せずに出るpower |
| phase locking factor | 同一部位での位相同期性                        |

どういうことでしょう？
つまり、何か刺激を受けた時に「受け取った直後にすぐ起こる」のがevoked
何か刺激を受けた後「なんかよく分からんけど生じる不規則な波」がinduced
上記の合算がtotalです。

total powerは簡単に計算できます。単にwavelet変換して
結果の絶対値を二乗すればそれで終わりであります。
evoked powerは二種類の出し方があります。まぁ、流派みたいなものでしょうか。
induced powerもまた、二種類の出し方があります。
これは後で書きます。

このなかで、Phase Locking Factorは別名 Inter Trial Coherence(itc)といいます。
MNEpythonではitcという言い方しています。[^plv]
それぞれ生理学的には違うものを見ているらしいです。
本書ではitcという言い方にしておきましょうか…。

MNEpythonではセンサーベースならどれも実装されています。
ソースベースではinduced powerとitcの計算方法が実装されています。[^evoked_power]

ではEvoked Power,Induced Power,Inter Trial Coherenceについて解析を行いましょう。

[^plv]: ちなみにphase locking valueという全然別のものがあります。これはコネクティビティ用語ですので分野が違います。あとで書きます。
[^evoked_power]: これは実質itcと似たようなもの…という考え方もあります。

### 2つの流儀とMNE
InducedPowerの計算の仕方に2つの流儀があります。
名前については適当につけました。どっちが正しいとかはない。

#### 生波形引き算派
生波形を合算していくと、そのうちキレイにEvokedの波形が出ます。
この波形を生波形から引き算します。しかる後、Wavelet変換して、これをInducedPowerとします。
その上で、TotalPowerからInducedPowerを引き算します。

#### EvokedPower引き算派
生波形をまずWavelet変換して、TotalPowerを出します。
そして、生波形の合算もWavelet変換してEvokedPowerを出します。
TotalPowerからEvokedPowerを引き算してInducedPowerを計算します。

### wavelet変換の実際

morletのやり方は臨床研究的にメジャーなやり方と僕は思っています。
まずはEvokedPowerからやりましょう。下記のスクリプトで実行できます。
この場合は合算の後にWavelet変換ですね。

```{frame=single}
from mne.time_frequency import tfr_morlet
freqs=np.arange(30,100,1)
n_cycles = 6
evoked_power = tfr_morlet(evoked, n_jobs=4, freqs=freqs,
                          n_cycles=n_cycles, use_fft=True,
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
return_itcがTrueかFalseかで大きく挙動が違います。
挙動の組み合わせについてですが、下記のとおりです。

| return_itc | 引数   | 返り値1つ目 | 返り値2つ目         |
|------------|--------|-------------|---------------------|
| False      | evoked | EvokedPower | なし                |
| False      | epochs | TotalPower  | なし                |
| True       | epochs | TotalPower  | InterTrialCoherence |

Inducedが無いじゃないか！ってなりましたね？
Inducedを計算したければ、Epochsのオブジェクトで以下のようにします。

```{frame=single}
epochs.subtract_evoked()
```

これをすると波形からEvokedが引かれて計算できるようになります。または、

itcを計算したい時は返り値が2つになりますから、下記の通りです。

```{frame=single}
freqs=np.arange(30,100,1)
n_cycles = 6
total_power, itc = tfr_morlet(epochs, n_jobs=4, freqs=freqs,
                              n_cycles=n_cycles, use_fft=True,
                              return_itc=True, decim=1)
```

ここで一つ注意点があります。
wavelet変換は基準になる波を実際の波に掛け算して行うのですが、
波の始まりと終わりのところだけは切れちゃうはずです。そこは十分注意して下さい。
どの程度のwaveletの波の長さなのかについては、勉強して適当に計算して下さい。
