
## bad channelの設定

苦行その1です。次にダメなチャンネルの設定や眼球運動の除去を行います。
http://martinos.org/mne/stable/auto_tutorials/plot_artifacts_correction_rejection.html
これには2つのやり方があります。

### やり方1
jupyterで%matplotlib qtとしたあとでraw.plot()でデータを見ながらひたすら下記のように
badchannelを設定していってください。それだけです。

```{frame=single}
raw.info['bads'] = ['MEG 2443']
```
badchannelは、例えば明らかに一個だけ滅茶苦茶な波形…
振幅が大きくて他のとぜんぜん違う動きしているとか、
物凄い周波数になっているとか、毛虫っぽいとか、そういうやつを選んでください。

### やり方2
raw.plot()
をした上で、画面上でポチポチクリックしていけば、rawにbadが
入っていくように出来ています。便利ですね！

### interpolation
選び終わったら、badchannelを補正します。
隣接するチャンネルを平均したようなやつで置き換えることになります。
それには下記を走らせるだけでいいです。
```{frame=single}
raw.interpolate_bads()
```
後でbadchannelを無視したICAを掛けるとか、色々出来るわけです。

### maxfilter
MNEpythonにmaxfilterがあります。
MEG使いの人はこれを使うのも一つの手です。
[https://mne-tools.github.io/stable/generated/mne.preprocessing.maxwell_filter.html](https://mne-tools.github.io/stable/generated/mne.preprocessing.maxwell_filter.html)

さて、maxfilterには2つファイルが必要です。
この2つのファイルは、それぞれの施設によって違うものです。
一つはcalibration用のdatファイル、一つはcrosstalk用のfifファイルです。
これについてはelektaの機械ならあるはずなので、そこから抜き出すといいでしょう。
ここについては僕は詳しくないので、周囲の賢者に聞いて下さい。

もう一つ、MNEのmaxfilterには特徴があって、
badchannelを設定してあげないとうまく動きません。
因みに、elektaのは自動でbadchannelを設定しちゃうそうです。

```python
from mne.preprocessing import maxwell_filter
cal = 'hoge.dat'
cross = 'fuga.fif'
raw = maxwell_filter(raw,calibration=cal,
                     cross_talk=cross, st_duration=10)
```
このmaxwell_filter関数で行います。
calibrationとcross_talkは見てのとおりと思いますが、
st_durationも大事なやつです。
MNEpythonの標準の設定ではst_durationはNoneなのですが、
実際は数値を設定しないと酷いことになります。
公式サイトには「俺たちのMEGはキレイだからNoneで良いんだ」と
ドヤ顔していましたが、町中のMEGだと地下鉄通るだけで酷いことになるので、
大草原の小さなラボとかでないなら設定してあげましょう。
元祖elekta maxfilterではここが10になっています。

このst_durationの数字は実はhighpass filterの役割も果たします。
だから、注意が必要です。
1/st_duration以下の周波数がカットされるので、
遅い周波数を見たい人は気をつけて下さい。
その他、いろいろな理由でst_durationは出来れば大きな値が良いそうですが、
計算コストが上がるという欠点がありますので、程々に。


## ICAをかけよう

苦行その2です。ICAは日本語で言うと独立成分分析と言い、
何をするかというとノイズ取りです。前回やったノイズとは違うノイズを取ります。
例えば眼球運動や心電図が脳波、脳磁図に混じることがあるので、これを除去するのです。
これはICAという方法(独立成分分析)で波を幾つかの波に分け、
その上で眼球運動や心電図っぽい波を除去するフィルタを作ります。

順を追って内容を説明します。
```{frame=single}
from mne.preprocessing import ICA
from mne.preprocessing import create_eog_epochs, create_ecg_epochs
```

まずは、ICAのモジュールをインポートします。
```{frame=single}
picks_meg = mne.pick_types(raw.info, meg=True, eeg=False, eog=False,
                           stim=False, exclude='bads')
```
次に、どのような波にICAをかけるか選びます。基本、解析したい脳磁図(脳波)に
ICAをかけるので、それをTrueにします。badchannelも弾きます。

```{frame=single}
n_components = 25  
method = 'fastica'  
decim = 4  
random_state = 9
```
n_componentsはICAが作る波の数です。
ICAで作る波の数は何個が良いのか僕にはよく分かりません。
多分現時点で決まりはないと思うので、ここではひとまず適当に25個にしています。

methodはicaの方法です。
方法は三種類選べます。API解説ページをご参照ください。

decimはどの程度詳しくICAをかけるかの値です。
数字が大きくなるほど沢山かけますが、数字を入力しなければ最大限にかけます。

random_stateは乱数発生器の番号指定です。
pythonでは乱数テーブルを指定することが出来ます。
そうすると、再現可能な乱数(厳密には乱数ではない)が生成できるようになります。
実はICAは乱数を使うので、結果に再現性がないのですが、
この擬似乱数テーブルを用いることにより再現性を確保しつつ乱数っぽく出来るのです。
便利ですね！

```{frame=single}
ica = ICA(n_components=n_components,
        method=method, random_state=random_state)
ica.fit(raw, picks=picks_meg, decim=decim,reject = dict( grad=4000e-13))
```
icaのセットを作り、データに適用しています。
この時点ではまだ何も起こっていません。
先に%matplotlib qtと入力した上で下記を実行してください。
```{frame=single}
ica.plot_sources(raw)
```


![icaで分離した波。明らかに眼球運動や心電図が分離された図が出てくると思います。](img/ICA_wave.png){width=14cm}

個人的には生波形を見るのが明快で好きです。
ちなみに、これを凄く詳しく見るには下記のようになります。重いですが、これも結構良いです。

```{frame=single}
ica.plot_properties(raw, picks=0)
```

![ica propertyの図。左上を御覧ください。これこそが典型的な眼球運動のtopomapです。](img/ICA_property1.png){width=14cm}

最後に、0番目と10番目の波をrawデータから取り除きます。
```{frame=single}
filtered_raw=ica.apply(raw,exclude=[0,10])
```
これでicaはかけ終わりです。
上記の出力結果や取り除いたチャンネル、random_stateは保存しておきましょう。


## EpochとEvoked
なんのことやら分かりにくい単語ですが、波形解析には重要なものです。
epochは元データをぶつ切りにしたものです。
元データ(raw)に「ここで刺激したよ！」という印を付けておいて、
後からその印が入っているところだけ切り出してきます。
evokedは切り出したものを加算平均したものです。

例えば元データ(raw)に刺激提示したタイミングを記録しているならば、
下記のコードでその一覧を取得できます。
```{frame=single}
events=mne.find_events(raw)
```
このevents情報からほしいものを抜き出してきて、
epochやevokedを作ります。
上記eventsの内容は例えばこうなります。
```{frame=single}
221 events found
Events id: [1 2 4 7 8]
Out[205]:
array([[ 15628,      0,      2],
       [ 18053,      0,      2],
       [ 20666,      0,      4],
       [ 23131,      0,      1],
       [ 25597,      0,      8],
```
この場合刺激チャンネルには1,2,4,8という刺激が入っています。
このうち、刺激情報1を使って切り出したいときは下記です。
```{frame=single}
epochs=mne.Epochs(raw,event_id=[1],events=events)
```
先程のeventsを使っています。
event_idは配列にしてください。ここは[1,2]とかも出来るのでしょう。
evokedを作るのはとても簡単で、下記のとおりです。
```{frame=single}
evoked=epochs.average()
```
