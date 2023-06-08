\newpage

## bad channelの設定

苦行その1です。次にダメなチャンネルの設定や眼球運動の除去を行います。
http://martinos.org/mne/stable/auto_tutorials/plot_artifacts_correction_rejection.html
これには2つのやり方があります。

### やり方1
raw.plot()でデータを見ながらひたすら下記のように
badchannelを設定していってください。それだけです。

```{frame=single}
raw.info['bads'] = ['MEG 2443']
```
badchannelは、例えば明らかに一個だけ滅茶苦茶な波形…
振幅が大きくて他のとぜんぜん違う動きしているとか、
物凄い周波数になっているとか、毛虫っぽいとか、そういうやつを選んでください。

### やり方2(おすすめ)　

```{frame=single}
raw.plot()
```
をした上で、画面上でポチポチクリックしていけば、rawにbadが
入っていくように出来ています。便利ですね！
もちろん、あとで保存しないとちゃんと残りません。

```{frame=single}
raw.save('hoge.fif')
```

pythonの対話モードを使って毎回一々やっていくのは超絶面倒なのでスクリプトにしたいかと思います。
しかし、その場合plotし終わったらすぐpythonが終了して図が即消えます。
それを防ぐには以下の一行を入れましょう。

```{frame=single}
input()
```

### interpolation
選び終わったら、badchannelを補正します。
隣接するチャンネルを平均したようなやつで置き換えることになります。
それには下記を走らせるだけでいいです。
```{frame=single}
raw.interpolate_bads()
```
後でbadchannelを無視したICAを掛けるとか、色々出来るわけです。

### maxfilter
ここはEEGには不要です。
しかし、MEGはEEGと違ってノイズがのりやすいです。
何故なら、地球の磁力は脳みその磁力の1000倍だからです！
MEG使う人はmaxfilterを使ってノイズを除去することが出来ます。
maxfilterはelekta製のとmne製のがあります。

ここではmne製のを紹介します。
[https://mne-tools.github.io/stable/generated/mne.preprocessing.maxwell_filter.html](https://mne-tools.github.io/stable/generated/mne.preprocessing.maxwell_filter.html)

さて、maxfilterには2つファイルが必要です。
この2つのファイルは、それぞれの施設によって違うものです。
一つはcalibration用のdatファイル、一つはcrosstalk用のfifファイルです。
これについてはelektaの機械ならあるはずなので、そこから抜き出すといいでしょう。
ここについては僕は詳しくないので、周囲の賢者に聞いて下さい。

もう一つ、MNEのmaxfilterには特徴があって、badchannelを設定してあげないとうまく動きません。
因みに、elektaのは自動でbadchannelを設定しちゃうそうです。

```python
from mne.preprocessing import maxwell_filter
cal = 'hoge.dat'
cross = 'fuga.fif'
raw = maxwell_filter(raw,calibration=cal,
                     cross_talk=cross, st_duration=10)
```
このmaxwell_filter関数で行います。
calibrationとcross_talkは見てのとおりと思いますが、st_durationも大事なやつです。
MNEpythonの標準の設定ではst_durationはNoneなのですが、
実際は数値を設定しないと酷いことになります。
公式サイトには「俺たちのMEGはキレイだからNoneで良いんだ」と
ドヤ顔していましたが、町中のMEGだと地下鉄通るだけで酷いことになるので、
大草原の小さなラボとかでないなら設定してあげましょう。
元祖elekta maxfilterではここが10になっています。

このst_durationの数字は実はhighpass filterの役割も果たします。だから、注意が必要です。
1/st_duration以下の周波数がカットされるので、遅い周波数を見たい人は気をつけて下さい。
その他、いろいろな理由でst_durationは出来れば大きな値が良いそうですが、
計算コストが上がるという欠点がありますので、程々に。


## ICAでノイズを取ろう

苦行その2です。
ICAは日本語で言うと独立成分分析と言い、古典的機械学習の一種です。
つっても、波形に関する機械学習でいえば大変有用です。[^deep]
10個の耳で聞いた一つの音を、10個の「有効っぽい成分」に分けちゃう方法です。

何故ICAをするかというと、ノイズ取りです。
前回やったノイズとは違うノイズを取ります。
例えば眼球運動や心電図、場合によっては筋電図です。
眼球運動や心電図は特徴があるので、ICAで分けた時分かれてくれるのですね！


[^deep]: DeepLearningが今の世の流行りですが、DeepLearningは画像が得意だという点があります。これはCNNという手法があるからですが、波形をCNNに適用する手法もあります。でも、これが筋が良いかと言うと色々意見もあろうかと。


順を追って内容を説明します。
```{frame=single}
from mne.preprocessing import ICA
from mne.preprocessing import create_eog_epochs, create_ecg_epochs
```

まずは、ICAのモジュールをインポートします。
```{frame=single}
picks_meg = mne.pick_types(raw.info, meg=True,
                           eeg=False, eog=False,
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

n_componentsはICAが分ける波の数です。
ICAで分ける波の数は何個が良いのか僕にはよく分かりませんが、
あまり少なすぎないほうがいいでしょう。
ここではひとまず適当に25個にしています。

methodはicaの方法です。方法は三種類選べます。API解説ページをご参照ください。

decimはどの程度詳しくICAをかけるかの値です。
数字が大きくなるほど沢山かけますが、数字を入力しなければ最大限にかけます。

random_stateは乱数発生器の番号指定です。
pythonでは乱数テーブルを指定することが出来ます。
そうすると、再現可能な乱数(厳密には乱数ではない)が生成できるようになります。
実はICAは乱数を使うので、結果に再現性がないのですが、
この擬似乱数テーブルを用いることにより再現性を確保しつつ乱数っぽく出来るのです。
(狡いけど)便利ですね！

```{frame=single}
ica = ICA(n_components=n_components,
          method=method, random_state=random_state)
raw = raw.filter(1, 100)
ica.fit(raw, picks=picks_meg, decim=decim,reject = dict( grad=4000e-13))
```

ここで、rawに周波数フィルタをかけています。これはICAが低周波の影響を
受けやすく、ノイズをとることに失敗してしまうのを防ぐためです。

icaで特徴を抽出し、データに適用しています。
この時点ではまだ何も起こっていません。下記を実行してください。
jupyterなら先に%matplotlib qtと入力した上でです。
分離した波(特徴)が表示されます。

```{frame=single}
ica.plot_sources(raw)
```

![icaで分離した波。明らかに眼球運動や心電図が分離された図が出てくると思います。](img/ICA_wave.png){width=14cm}

チャンネル名のところをクリックするとtopomapが表示されます。
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

ここでのrawはフィルタを掛けていないraw...で良いのか僕はよく分かりません。
ともかく、これでicaは終わりです。
上記の出力結果や取り除いたチャンネル、random_stateは保存しておきましょう。
random_stateを保存しておくことでICAに再現性が生まれます。
(狡いんですけどね)

## ICAコンポーネントのより良い取り除き方
実際に上記を手動でやるのは恣意的になったり、再現性が無かったり、
面倒臭すぎたりして、なにより面倒くさいので僕は大嫌いです！
(大事なことなので二回言いました)
それはともかく、抜く波が恣意的になるのはいただけません。
例えば病人だけに出る波が欲しい時に健常者から波を抜きまくってしまう
姑息な事をする輩が居るかも知れません。それはいただけません。

そこで、もっとクールなやり方が2つあります。

### 自動判定
眼球運動チャンネルや心電図をとっていたら、それに似てるやつを
自動判定してくれる機能がMNE-pythonにはあります、やったね！やり方は以下のとおりです。

まずは、眼球運動がある場所を眼球運動によってepochを作ります。

```{frame=single}
from mne.preprocessing import create_eog_epochs

eog_epochs = create_eog_epochs(raw, reject=reject)
eog_inds, scores = ica.find_bads_eog(eog_epochs)
```
簡単ですね！eog_indsは眼球運動に超似ているチャンネルの番号リストです。
scoresはどれだけ似ているかの度合いです。とりあえず、plotしましょう。

```{frame=single}
ica.plot_scores(scores, exclude=eog_inds)
```
どれが悪いコンポーネントかがplotされたかと思います。
では、どの程度浮き立っているか確認しましょう。

```{frame=single}
ica.plot_sources(eog_epochs.average(), exclude=eog_inds)
```
浮き立っている度合いがわかったかと思います。では、詳しく見てみましょう。

```{frame=single}
ica.plot_properties(eog_epochs, picks=eog_inds)
```
詳しいですね！いい感じであれば一網打尽にしてしまいましょう。

```{frame=single}
ica.exclude = eog_inds
ica.apply()
```

心電図については殆どこいつがecgになっただけだから、もう解説はしません。

### 半自動判定
眼球運動チャンネルや心電図をそもそも取っていない時はどうするのでしょう？
その時は一部のコンポーネントを「根本的なノイズだよ」と指定して、
それに似ているコンポーネントを一網打尽にすることが出来ます。では、やっていきましょう。

まずは、ICAのオブジェクトをいっぱい作ります。上記のICA.fit()で出来るやつですね！
で、それらを沢山並べてリストにします。
リストにしたものを作る時、きっと時間がかかるので、ICA.saveで保存してから
読み込むほうが良いでしょうね。
超絶面倒なのでmap関数を使います。(沢山の物に同じ関数を適用する関数)

```{frame=single}
from mne.preprocessing import read_ica
ica_paths = ['hoge.fif', 'fuga.fif', 'piyo.fif']
icas = list(map(read_ica, ica_paths))
```

で、このicaのリストの中から典型的なノイズを選んできます。
例えば5番目のicaの3番目のコンポーネントがノイズっぽい場合はこうします。

```{frame=single}
template = (5, 3)
```

で、corrmapという関数にぶち込みます。

```{frame=single}
from mne.preprocessing import corrmap
corrmap(icas, template, threshold='auto', label=None,
	ch_type='eeg', plot=True, show=True,
	verbose=None, outlines='head',
	layout=None, sensors=True, contours=6, cmap=None)
```

- icas: 要するにさっきのリストです
- template: さっきのテンプレートです
- threshold: どのくらい似てるものまで引っ掛けるかです。
    標準は'auto'なんですが、'auto'では中々何も引っかかりません。
- label: 引っ掛けたやつにつけるラベルです。文字列入れて下さい。
- ch_type: eegならeegですし、megならmagとかgradになります。

だいたい、そんな感じです。corrmapをplot=Trueの条件でかけると、
いっぱい似てるやつが引っかかってきます。
labelに何か入れていれば、icaにラベルがつきます。
ica.labels_に格納されており、labelの情報は辞書形式です。

```{frame=single}
{'eog': [1], 'ecg': [2]}
```

この例では、labelを'eog'と'ecg'の二回分corrmapをまわしたときの結果みたいなもんですな！

どの程度の閾値にすれば適切か分かんないので試行錯誤しましょう。
corrmapは違うラベルでやれば、違うラベルがどんどん追加されていきます。

ところで、ラベルに情報が入っても、print(ica.labels_)みたいに
しないと貴方はそれを見れません。
plotしてくれないのです…これでは実際のsourcesがどんな感じか分かりませんね？

```{frame=single}
raw = Raw('hoge.fif')  # ダメな例
icas[0].plot_sources(raw)
```

labelに情報が入るだけなのでこのままではダメです。

ica.excludeはList形式なのでこれをどうにかしたいですね。
まぁ、せいぜい工夫して下さい。僕ならこうします。

```{frame=single}
from operator import add
from functools reduce

ica.exclude = list(set(reduce(add, ica.labels_.values())))
```

setは重複のない値を格納するオブジェクト、reduceは調べて下さい。

python初学者は面食らうやり方ですね。こういう風にベタにかいてもいいですね。

```{frame=single}
for n in ica.labels_.values():
    if n not in ica.exclude:
        ica.exclude += n
```

こうしてやればplot_sourcesしたときに悪いコンポーネントは赤く表示できるようになります。

いい感じであればicaを保存するといいでしょう。
良くない感じなら閾値を変えたりチャンネル変えたりしてやり直しです。
このやり方をする時のコツとしては、「こいつこそが典型的な眼球運動だ！」という奴を選ぶことと、
HighpassFilterを掛けた上で作業を行うことです。

## EpochとEvoked

初心者にはなんのことやら分かりにくい単語ですが、波形解析には重要な用語です。
Epochsはぶつ切りのデータそのものです。Evokedは「誘発された波」です。

元データ(raw)に「ここで刺激したよ！」という印を付けておいて、
後からその印が入っているところだけ切り出してきます。
切り出してきたものがEpochsですね。
Evokedは切り出したものを加算平均して算出します。

例えば元データ(raw)に刺激提示したタイミングを記録しているならば、
下記のコードでその一覧を取得できます。

```{frame=single}
events=mne.find_events(raw)
```

このevents情報からほしいものを抜き出してきて、epochやevokedを作ります。
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

この場合刺激チャンネルには1, 2, 4, 8という刺激が入っています。
このうち、刺激情報1を使って切り出したいときは下記です。

```{frame=single}
epochs = mne.Epochs(raw, event_id=[1], events=events)
```

先程のeventsを使っています。
event_idは配列にしてください。ここは[1, 2]とかも出来るのでしょう。
evokedを作るのはとても簡単で、下記のとおりです。

```{frame=single}
evoked = epochs.average()
```
