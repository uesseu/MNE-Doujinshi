
# ソースレベルMEG解析

ついにソースレベルの解析を行います。これがMNE/pythonの真髄です。
難しいのです。頑張りましょう。

ソースレベル解析については冒頭の記述を見ていただくとして、
MRIとMEGをくっつけていきます。(MRIがない場合は標準脳を使える)
目標は「脳内の信号を算出するための式を作る」事です。
式さえできればなんとか計算できるわけです。
手順としては以下のとおりです。

1. MRIから脳の形を取ってきて計算できる形にする。
 これをBEMという。
1. 脳の形から「推定するべき脳の位置」を特定する。
 この脳内の位置情報をソーススペース(source space)という。
1. 「推定するべき脳の部位」とMEGで取れる頭の形情報を重ねる。
 この作業は手動で行われる。(やればわかる)
 この重ね合わせ情報はtransというファイル形式で保存される。
1. 脳の部位情報と頭の形情報とセンサーの位置から、
 脳活動によってどのようにセンサーに信号が届くかを計算する。
 これを脳磁図における順問題(forward solution)という。
1. ノイズについて考慮する。この時、covariance matrixと言うものが必要になる。
1. 上記の脳部位とセンサーの関係性から、特定の脳部位での電源活動の波形を推定する。
 これを脳磁図における逆問題(inverse solution)という。
 逆問題を解くために数式を作る。その数式をinverse operatorという。
 逆問題には決まった解答はない。「最も良い解を得る方法」が幾つか提案されている。
1. 脳全体で推定した波形のうち、欲しいものをとってくる。

その後は色々なストーリーがあるでしょう。

- 推定された波形をwavelet変換する。
- PSDやERPをしてみる。
- 脳の各部位のコネクティビティを算出する。
- 何か僕達が思いつかなかった凄いアイデアを実行する。

などなど。
でははじめましょう。

## 手順1、BEM作成

上記の通り、MRIから抽出してくる形データとして、BEMと言うものを使います。
BEMは脳の全体を包み込むサランラップみたいなデータです。
頭蓋骨とか皮とか、そういうのいろいろ考慮するために、BEMは三枚一組で
出力されます。実装上は3枚あるということを意識しなくても大丈夫です。

作るためにはfreesurferによる解析データが必要となります。
freesurferを既に使っているならSubject関連は既に馴染んだ言葉でしょうか？
もちろんSUBJECTやSUBJECTS_DIRは読み替えてください。
```{frame=single}
mne watershed_bem -s subject -d subjects_dir
```

これにより、BEM(脳の形情報を変換したやつ)が作成されました。
再びpythonに戻り、下記を入力してみてください。
```{frame=single}
mne.viz.plot_bem(subject = subject, subjects_dir = subjects_dir,
                 brain_surfaces = 'white', orientation = 'coronal')
```
これでBEMが表示されるはずです。

![BEMの図示。](img/bem.png){width=14cm}

もし、標準脳を使うなら、以下のコマンドをターミナルから叩いて下さい。
```bash
mne coreg
```
guiの画面が現れると思います。
'fsaverage→SUBJECTS_DIR'というボタンを押して下さい。
freesurferの標準脳であるfsaverageが現れます。
以降、subjectにはfsaverageを入れると標準脳を使うことになります。

## 手順2、trans

GUIでの操作となります。
下記のコードを実行すると画面が立ち上がります。

```{frame=single}
mne.gui.coregistration()
```

subjectやmegへのpathを指定しない場合は、GUI上で指定することになります。
もし0から立ち上げた場合、山のようにあるMRIのsubjectから該当の
subjectを探さねばならなくなります。

pythonの関数に色々入れてから起動すれば、
既にデータが読み込まれているので、楽です。
```{frame=single}
mne.gui.coregistration(subject = subject,subjects_dir = subjects_dir,
                       inst = file_path)
```
instはmegデータ…rawでもepochでも良いらしいですが、どれかを指定して下さい。

![mne coregistrationの画面。大して苦行ではない。](img/trans.png){width=14cm}

手順はこうです。

1. 必要ならば、MRIのsubjectを読み込む
1. 必要ならば、fifファイルを読み込む
1. 左側、setのところで耳と眉間の位置を入力(MEGのスタイラスでポチるところです)
1. それの一寸上の所、lockをポチる。
1. 右側、Fit LPA/RPAボタンを押す。
1. 中の人の顔データをマウスでグリグリしながら、右上の±ボタンを押して調整。
1. ちゃんとfitしたら右下のsave as ボタンを押して保存。

あとで、保存したtransを
```{frame=single}
trans = mne.read_trans('/Users/hoge/fuga/trans.fif')
```
みたいな感じで読み込んで使います。

## 手順3、ソーススペース作成

脳磁図で見れる空間のうち、どの部分の電源を推定するかを
設定する必要があります。その設定がソーススペースです。
subjects_dirは環境変数に設定していれば要らないです。
```{frame=single}
src = mne.setup_source_space(subject = subject, spacing = 'oct6',
      subjects_dir = subjects_dir)
```
もちろん、標準脳が欲しい場合は黙ってfsaverage。
これで、srcという変数にソーススペースが入りました。

見慣れぬ単語が出てきました。oct6とは何でしょうか？
それはここに書いてあります。
http://martinos.org/mne/stable/manual/cookbook.html#setting-up-source-space

ソーススペースを作るためには計算上正十二面体や正八面体で
区画分けするので、その設定ですね。
やり方によってソーススペースの数も変わるみたいです。
臨床的に意味があるかはわかりません。

標準脳を使う場合は'fsaverage'をsubjectに指定して下さい。
ない場合は手順2のmne.gui.coregistration()でボタンを押して下さい。

![ソーススペースの図示。小さい点々がソーススペース。](img/src.png){width=14cm}

## 手順4、順問題

先程作ったBEMは3枚あります。
EEGの場合は3枚必要です。何故なら、磁力と違って電力は
脳脊髄液と頭蓋骨と頭皮を素通りしにくいからです。
だから、BEMを三枚仮定するのです。
MEGの場合は一枚だけで十分だそうです。

では、BEMで順問題を解く準備をしましょう。
```{frame=single}
conductivity = (0.3,)
model = mne.make_bem_model(subject = 'sample', ico = 4,
                           conductivity = conductivity,
                           subjects_dir = subjects_dir)
bem = mne.make_bem_solution(model)
```
これにより、BEMを読み込み、順問題解きモードに入りました。
icoはどの程度細かく順問題を解くかの数値です。icoの数字が高いほうが詳しいです。
conductivityは電気や磁力の伝導性のパラメータです。
EEGの場合はこれが(0.3, 0.006, 0.3)とかになったりします。

では、先程作った色々なものと組み合わせて順問題を解きます。
```{frame=single}
trans = mne.read_trans('/hoge/fuga')
mindist = 5
fwd = mne.make_forward_solution(raw.info,
                             trans = trans,
                             src = src, bem = bem,meg = True,
                             eeg = False,
                             mindist = mindist, n_jobs = 4)
```
ここまでやった方にとって、上記のパラメータはだいたい分かるでしょう。
mindistは頭蓋骨から脳までの距離です。単位はmm。
ここで使うのはraw.infoです。
mindistは頭蓋骨からみて、一番浅い部分にあるソーススペースの距離です。


## 手順5、コヴァリアンスマトリックス関連

次に、MAP推定という方法を用いて脳活動を推定します。
この推定にはcovariance matrixというものを使ってソースベースのデータの
ノイズ周囲の事を計算していかねばなりません。
これにはMEGを空撮りした空データを使います。下記でからの部屋データを読み込みます。
```{frame=single}
cov = mne.compute_raw_covariance(raw_empty_room,
                              tmin = 0, tmax = None)
```
これでコヴァリアンスを作ることになりますが…MNEには更に追加の方法があります。
上記の空室の方法は広く行われている方法ですが、
誘発電位を見たい場合はrestingstate(脳が何もしていない時の活動電位)
がノイズ(本来ノイズではないが、ここではノイズ)として乗る可能性があります。
それを含めるならば、下記のようにすることも出来ます。

```{frame=single}
cov = mne.compute_covariance(epochs, tmax = 0., method = 'auto')
```
ちなみに、このmethod = autoというのはMNEに実装された新しいやり方だそうです。
tmax = 0にしているので、刺激が入る前までの波を取り除きます。
つまりベースラインコレクションみたいな感じになるのです。
ちなみに、epochsでcovariance…特にautoですると結構重いです。

他に、rawデータからcovariance matrixを作る方法もあります。
```{frame=single}
compute_raw_covariance(raw, tmin = 0, tmax = 20)
```
これはresting stateとかに良さそうですね？
…最早当然ですが、tmin,tmaxは時間です。単位は秒です。

## 手順6、逆問題

最終段階です。順問題とコヴァリアンスを組み合わせて逆問題を解きましょう。
下記のとおりです。
```{frame=single}
inverse_operator = make_inverse_operator(epochs.info, fwd,
                                 cov,loose = 0.2, depth = 0.8)
```
inverse_operatorと言うのは何かというと、逆問題を算出するための式です。
このinverse_operatorを作るために頑張ってきたと言っても過言なしです。

ここで、第一引数にepochs.infoを入れていますが、infoなら
rawでもevokedでも良いはずです。

さて、ここでlooseとdepthという耳慣れぬ物が出てきました。
一寸大事なパラメータです。
脳内の電流源推定と言っても、電流の向きを考慮しなくてはならないわけです。
looseはその向きがどのくらいゆるゆるかの指標です。
脳磁図はコイルで磁場を測る関係上、**脳の表面と水平な方向**の成分を
捉えやすいように出来ています。
でも、脳波複雑だから完全な水平ってないよね？どのくらいのを想定する？
という風なパラメータです。
looseは0〜1の値をとりますが、looseが1というのは超ユルユル、
どの方向でも良いですよということです。
ちなみに、looseが0の時は一緒にfixedをTrueにする必要があります。
fixedがTrueの時は、MNEpythonが脳の形に沿って自動調整してくれます。

depthは何かというと、どのくらい深い部分を見たいか、です。
MNEという計算手法は脳の表面の情報を拾いやすい偏った計算方法です。
故に、深い部分に対して有利になるようにする計算方法があります。
depthを設定すると、脳の深い所を探れるわけです。
depthをNoneに設定すると、ほぼ脳の表面だけ見ることになります。

他にlimit_depth_chsというパラメータもあります。
これをTrueにすると、完全に脳の表面だけ見ます。
即ち、マグネトメータをやめて、グラディオメータだけで見るのです。


ここまで長かったので保存しておきましょう！
```{frame=single}
write_inverse_operator('/home/hoge/fuga',
                       inverse_operator)
```
このinverse_operatorが作れたら、あとは色々出来ます。

## 手順7 ソース推定

まずは、ソース推定をやってみましょう。
```{frame=single}
from mne.minimum_norm import apply_inverse
source = apply_inverse(evoked, inverse_operator)
```
これで出てきたものの中にdataという変数があります。
まさに膨大な数です。脳内の膨大な場所について電流源推定したのです。
これは、一つ一つが脳内で起こった電流と考えて良いと思います。
…とは言え、推定ではあるので本物かどうかはわかりませんが。
細かい所は公式サイト見てください。

さて…こんな膨大な数列があっても困りますよね？
脳のどこの部位なのかわかりませんし。
そこで、freesurferのラベルデータを使います。
それによって、脳のどの部分なのか印をつけてやるのです。

## 手順8、前半ラベル付け
freesurferにはいくつかのアトラスがあります。
詳しくはここをみて下さい。
https://surfer.nmr.mgh.harvard.edu/fswiki/CorticalParcellation
desikan atlasとかDestrieux Atlasとか色々ありますよね。
こういうのを読み込まねばなりません。
ターミナルでこのように打ってみて下さい。
```{frame=single}
ls $SUBJECT_DIR
```
freesurferのサブジェクトが沢山出てくるはずです。
サブジェクトの中身にはlabelというディレクトリがあります。
この中にいっぱいそういうfreesurferのアトラスが入っています。

ファイルの形式には二種類あり、annot形式とlabel形式があります。
annot形式は新しく開発されたアトラスが入っていて、
label形式はブロードマンと思います。
annot形式の内容はこのように読みます。
```{frame=single}
mne.read_labels_from_annot(subject,annot_fname = 'hoge')
```
詳しくは公式サイト(ry
他にも読み方があります。
こうして読んだら、labelのリストが出てきます。
単体のlabelは下記で。
```{frame=single}
mne.read_label(filename, subject = None)
```

これでlabelを読み込めたら、次はそれを当てはめることになります。

### 手順8後半、label当てはめ

では、labelをベースにデータを抜き出しましょう。

```{frame=single}
source_label = mne.extract_label_time_course(stcs,
                   labels, src, mode = 'mean_flip')
```
ここではstcがソースのデータ、srcが左右半球のソーススペースのリストです。
modeはいくつかあります。
mean: それぞれのラベルの平均です
mean_flip: すみません、わかりません＞＜
pca_flip: すみません、わかりません＞＜
max: ラベルの中で最大の信号が出てきます

殆どわからなくてごめんなさい。
ただ、これで脳内の波形が取り出せたわけです。
これで、色々出来ます。なにしろ、今までwavelet等していたわけですから。

### その後のお楽しみ1、ソースベースwavelet

ソースベースでwaveletやりたいなら、特別に楽ちんな関数が
実装されています。

induced_powerとphaselocking_factorを算出する関数は下記です。
※激重注意、要WS！[^gekiomo]
```{frame=single}
induced_power, itc = source_induced_power(
        epochs, inverse_operator, frequencies, label,
        baseline = (-0.1, 0),
        baseline_mode = 'zscore',
        n_cycles = n_cycles, n_jobs = 4)
```
基本は以前wavelet変換で行った事に、いくつか追記するだけです。
まず、ベースラインコレクションはここではzscoreでしています。
やり方は色々あります。labelはfreesurferのラベルデータです。
baseline補正の時間についてはデータの端っこすぎると値がブレるので、
そこのところはデータ開始時点〜刺激提示の瞬間の間で適切な値にしておいてください。
これで算出されたwavelet変換の結果の取扱は、前に書いたwavelet変換の結果と同じです。

[^gekiomo]:これは激重です。何故なら306チャンネルのMEGからソースに落とし込むと計算方法によっては10000チャンネルくらいになります。ROIを絞ったとしても「人数×タスク×ROIの数×EPOCHの数」回wavelet変換してpowerとitcに落とし込むのですから…途方もない計算量です。

### その後のお楽しみ2、ソースベースconnectivity

ソースベースでコネクティビティ出来ます。
```{frame=single}
from mne.connectivity import spectral_connectivity
con, freqs, times, n_epochs, n_tapers = spectral_connectivity(
             source_label, method = 'coh', mode = 'multitaper',
             sfreq = 500, fmin = 30,
             fmax = 50, faverage = True, mt_adaptive = True)
```
使い方はセンサーベースコネクティビティと同じです。
この場合、さっき計算して出したラベルごとのデータと、
ラベルリストを放り込めば、先述の5つの変数が出てくるので楽ちんです。

## *コラム3-markdownで同人誌を書こう！*

```{basicstyle=\normalfont frame=shadowbox}
皆さんもこのような科学系同人誌書きたいですよね？
書いてコミケにサークル参加したいですよね？
**難しいLaTexなんて覚えなくても大丈夫。そう、markdownならね！**
LaTeXは添えるだけ。手順は下記。

macならmactexとpandocをインストールします。
ubuntuやwindowsならTeXliveをインストールします。
mactexはググれば出てきます。pandocは
brew install pandoc

ubuntuなら
sudo apt install texlive-lang-japanese
sudo apt install texlive-xetex
sudo apt install pandoc

これでpandocでmarkdownからpdfに変換できるようになります。
例えばDoujinshi.mdというマークダウンファイルを作って

pandoc Doujinshi.md -o out.pdf \
-V documentclass = ltjarticle --toc --latex-engine = lualatex\
-V geometry:margin=1in -f markdown+hard_line_breaks --listings

四角で囲われているところはコードの引用の書式に従って書いた後、
コードの上の```の末尾に{frame=single}と書き加えてください。

これで同人誌に出来るPDFになります。詳しくはググってください。
良い同人ライフを！
```
