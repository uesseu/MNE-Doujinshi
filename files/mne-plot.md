
## データのplot、主にjupyter周り、そしてPySurfer

是非自らplotしてみてください。
何をやっているのか理解が早まると思います。
```{frame=single}
epochs.plot()
evoked.plot()
```

![epochsの例](img/epochs.png){width=14cm}

![evokedの例](img/evoked.png){width=14cm}

epochsやrawをプロットしたとき、どうなったでしょうか？
jupyterではどのように表示するかを選ぶことが出来ます。

jupyterにそのまま表示したい場合は下記を先にjupyter上で実行してください。
```{frame=single}
%matolotlib inline
```
別のwindowに表示したいときは下記のようにしてください。
```{frame=single}
%matplotlib qt
```
また、3D画像を表示したい場合は
```{frame=single}
%gui qt
```
jupyterに表示するメリットはjupyter自体を実験ノート風に使えること、
別ウィンドウに表示するメリットはrawやepoch等大きなデータを表示する時に
スクロールさせることが出来ることです。

実はjupyter上でスクロール出来る表示もあるのですが、重くてあまり良くないです。
詳しくはqiitaで検索してください。親切な記事がいくらでもあります。

また、PySurferについては例えば下記のような感じです。
これはmacの場合ですが、ubuntuも同じ感じです。
subjectやsubjects_dirはfreesurferの設定で読み替えてください。
jupyterで下記の呪文を唱えましょう。
```{frame=single}
import surfer
%gui qt
```
そしてこうです。この場合ブロードマン１を赤く塗っています。

```{frame=single}
brain = surfer.Brain(subject, "lh", "inflated",
subjects_dir=subjects_dir)
brain.add_label("BA1.thresh", color="red")
```
注意すべき点として、拡張子や左右半球にかんしてはadd_label関数では
省略して入力する必要があります。

![pysurferで表示したfreesurferのラベルファイル](img/label.png){width=14cm}

ちなみに、labelファイルはそれぞれのsubjectの中のlabelフォルダの中にあります。
このlabelについてはブロードマンの脳磁図ベースの古典的なものが多いですね。
新しい系はannotファイルの中に多いです。

![pysurferで表示したfreesurferのannotationファイル](img/annot.jpg){width=14cm}

```{frame=single}
brain = surfer.Brain(subject, "lh", "inflated",
subjects_dir = subjects_dir)
brain.add_annotation('aparc.a2009s')
```


沢山表示されていますね。僕はちょっと気持ち悪いなぁと思いました。

## numpyのplot
これ、結構面倒くさいです。では、表示していきましょう。
numpyの情報をdataとします。
しかし、例えばwavelet変換をした情報なんかなら、
時間軸、周波数軸、チャンネルというふうに、多次元です。
二次元のほうが皆さん見やすくて好きですよね？
では、二次元にします。
```{frame=single}
data_mean = data.mean(axis=0)
```
mneでは三次元配列を多用しますが、
とりあえずaxis=0でうまくいくことが多いですね。
ここは適当ですが、いい感じに調整して下さい。

さて、僕はゆるふわで図がオシャレな方が好きなのでseabornを使います。
```{frame=single}
import seaborn as sns
import matplotlib.pyplot as plt
def make_and_save_fig(data, fname)-> None:
    ax = sns.heatmap(data, vmax=0.25,
                     cbar=True, cmap='rainbow')
    ax.set_yticks(np.arange(85, 0, -5))
    ax.set_yticklabels(np.arange(15, 100, 5))
    ax.set_xticks(np.arange(0, 1000, 100))
    ax.set_xticklabels(np.arange(-300, 700, 100))
    ax.invert_yaxis()
    plt.savefig(fname)
    plt.clf()
```
何故snsと略すんでしょうね？一応習慣であるそうです。
で、heatmapはseabornのもので、matplotlibで言うimshowです。
二次元の画像データをplotするやつですね。
set_yticksはデータのどの部分に目盛りをつけるかを指定したもの。
set_yticklabelsはデータの目盛りに書き込む内容です。
ここでは、15から100Hzの周波数について解析して、
5Hzずつ目盛りをつけていったのですね。
matplotlibは突然pltとして出てきていますが、これは仕様です。
axに吐き出したものはpltで色々するんですね。
詳しくはググって下さい。

matplotlib使うならimshowで読み替えましょう。
```{frame=single}
import matplotlib.pyplot as plt
def make_and_save_fig(data, fname)-> None:
    ax = sns.imshow(data, vmax=0.25, cmap='rainbow')
    ax.set_yticks(np.arange(85, 0, -5))
    ax.set_yticklabels(np.arange(15, 100, 5))
    ax.set_xticks(np.arange(0, 1000, 100))
    ax.set_xticklabels(np.arange(-300, 700, 100))
    ax.invert_yaxis()
    plt.savefig(fname)
    plt.clf()
```
カラーバーが無いじゃないかって？
それは解説が超絶だるいのでググって下さい。

## 多チャンネル抜き出し

もし、多チャンネルのevokedを平均したものを割り出したいなら
貴方はnumpyを使うことになります。
ここでは脳波のevokedを例にしておきます。他のデータでも応用ききます。
下記のチャンネルを選択したいとします。
```{frame=single}
channels = ['Fz', 'FCz', 'FC1', 'FC2',
            'Cz', 'C1', 'C2', 'F1', 'F2']
```

pythonの配列では、中の項目を逆引きで探し出す.index()関数があります。
加工した波形データは.data変数の中に格納されています。その一番初めの情報が
チャンネル別なので、1チャンネル…例えば'Fz'なら下記のようにすれば割り出せます。
```{frame=single}
evoked.data[evoked.info['ch_names'].index('Fz')]
```
この'Fz'をfor文で書きかえていけば良いのです。
```{frame=single}
data = []
for channel in channels:
  wave = evoked.data[evoked.info['ch_names'].index(ch)]
  data.append(wave)
```

