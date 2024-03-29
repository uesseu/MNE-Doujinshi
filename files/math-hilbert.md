\newpage
## ヒルベルト変換

wavelet変換は1つの実数の波から実軸と虚軸を分離しました。
でも、そもそも元々の波は実軸に存在します。おかしいですね？
ということは、もしかして波って本来実軸と虚軸があるのか？ってなります。
そう、実はそうなのです！
男と女、ウサギとカメ、sinとcos、実軸と虚軸の様に、
一つの波があればその相方が存在するのです！
そう、今君は相方の波を探しに行きたくなりました。

元々の実軸をそのまま実軸にして、新たな虚軸を生み出す変換が
ヒルベルト変換です。導出の仕方は、フーリエ変換と似ています。
ヒルベルト変換の結果は、元の波をcosとするとsin。
つまり、まるでWavelet変換のように波の振幅を計算できるのです。
凄いですね！

Wavelet変換は掛け算をして積分をして算出していましたがヒルベルト変換では双曲線を掛け算します。
ここについて数学を理解するためにはコーシー主値だとか
ディラックのデルタ関数を使う必要があります。
デルタ関数とかコーシー主値の解説は出来るけど超絶めんどいのでしません！
というか、この本で読むより別にいい本がいくらでもあります。
それらの出ないところだけ解説します！
一部無限大が出てきて気持ち悪さが残りますが、仕様です。
![双曲線](./img/soukyoku.png)
これについては、既にwavelet変換と同等の性能を持っていることが
分かっている…らしいですが、実際どうなんでしょうね？
なお、このセクションは数学者がブチ切れると思うので、恐恐書いています。

### 複素フーリエ級数とフーリエ逆変換の復習
波とは、時間軸と振幅の軸がある二次元のデータです。
とりあえず、フーリエ変換の式を書いてみましょう。
$f(t)$が元の波、$\hat{f}(w)$がフーリエ変換結果、tが時間、wが周波数として、
細かい所を省いてこんな感じです。

$$\hat{f}(w) = \int_{-\infty}^\infty f(t)e^{-iwt}dt$$

波というのは時間と振幅の二次元データですね。
それを$-\infty$ ~ $\infty$の周波数に変換しちゃうのがフーリエ変換でした。
こんな感じです。

```
振幅 * 時間　→　周波数 * 周波数ごとの複素数
```
そんで、フーリエ逆変換はこんな感じでした。

$$f(t) = \int_{-\infty}^\infty \hat{f}(w)e^{iwt}dw$$


```
周波数 * 周波数ごとの複素数　→　振幅 * 時間
```

さて、このフーリエ逆変換は複素フーリエ級数の書き方で書くとこう書けます。
$$f(t) = \sum_{n=-\infty}^{\infty}{C_n e^{iwt}}$$

これは、単に$\int$を$\Sigma$に、$\hat{f(w)}$を$C_n$にそれぞれの書き換えただけです。
つまり、各周波数nについて、$-\infty$ ~ $\infty$までを全部足し算するのがフーリエ逆変換です。
ちなみに、$C_n$は複素数です。

フーリエ逆変換はこの無限の$C_n$で出来た複素数の級数から実際の波を求める計算といえます。

### フーリエ変換の負の位相の性質
さて、$\hat{f(w)}$の$w$は$-\infty$ ~ $\infty$の周波数(スカラー値)なのですが、
ここで複素数$\hat{f}(w)$と$\hat{f}(-w)$について
$$\hat{f}(w) = \overline{\hat{f}(-w)}$$
と、複素共役になるという事が知られています。
ぱっと言われて「ん？」となった人はフーリエ変換の導出を復習してみてください。

### 相方の波を求める
さて、$\hat{f}(w)$というのは複素数です。$a(\cos\theta + i\sin\theta)$という形をしています。
つまり、
$$\hat{f}(w)+\overline{\hat{f}(-w)} = a(\cos\theta + i\sin\theta) + a(cos\theta - isin\theta)$$
となりますね。だから
$$\hat{f}(w)+\overline{\hat{f}(-w)} = 2a\cos\theta$$
これは実軸のcos波です。フーリエ逆変換はこのように共役な複素数を全部を足し合わせていく変換で、
正と負の周波数は複素共役の関係であったわけですから、実数が出てくるのは感覚的には普通でしょう。

では、虚軸だとかsin波はどうでしょう？こうすればいいだけです！
$$\hat{f}(w)-\overline{\hat{f}(-w)} = 2ai\sin\theta$$
相方が出てきました！フーリエ逆変換を足し算とすれば、ヒルベルト変換は引き算なのかもしれない！

### 式の形にする
全ての正の周波数のフーリエ級数から、負の周波数のフーリエ級数を引き算することで
sin波が出るのですが、これをきちんと式で表してみましょう。sgn関数を使います。
sgn関数とはsgn(x)のxが正のときは1、負のときは-1を吐き出す関数で、sinに似てますが関係ないです。

$$sgn(w)\hat{f}(w)$$

という感じにすると、正の成分から負の成分を引いていったことになりますね。
では、こいつを元に、フーリエ逆変換の$\hat{f}(w)$を全部引き算にしてやりましょう。
ただ、これだけでは虚数になっちゃうので-iを掛け算してあげます。
ヒルベルト変換の結果…つまり、欲しかった虚軸の波を$H(t)$とすると
$$H(t) = \int_{-\infty}^{\infty} -isgn(w)\hat{f}(w)e^{iwt}dw$$
となります。やりました！ヒルベルト変換です！

### さらに形を整える
上の式からフーリエ変換の成分を駆逐してやります。
sgn関数をフーリエ変換すると$-i\pi/t$になることが知られています。
(これを示すためにはデルタ関数のフーリエ変換について書くことになり、超絶めんどいので書きません)
では、加工するまえにフーリエ変換の畳み込みの復習をしていきましょう。

### 畳み込み定理
フーリエ変換やラプラス変換において以下のような公式があります。
Fをフーリエ変換やラプラス変換とすると以下が成立します。

$$F(a * b) = F(a)F(b)$$

a*bというのは畳み込みを表します。掛け算したうえで積分するというやつですね。

これを使ってヒルベルト変換っぽく作ってみます。ここで、畳み込みの公式を示しておきます。
$$F(a*b)=\int_{-\infty}^{\infty}a(x)b(t-x)dx$$

### よく見るヒルベルト変換の式の導出
ヒルベルト変換をフーリエ変換してみます。
$$F(H(t)) = sgn(w)\hat{f}(w) =-isgn(w)F(f(t))$$
これは畳み込みにすごーく近くないですか？ここで、仮にsgnのフーリエ逆変換の結果をGとします。
$$=F(G)F(f(t)) = F(G*f())$$
で、両辺のフーリエ変換を解除します。
$$H(t) = G*f(t)$$
理由を話し出すとちょっと終わらないので今回は言いませんが、実はGは1/tであることが知られています。
$$H(t) = 1/t*f(t)$$
凄いですね！これやこの、ヒルベルト変換です！

うん、数学者は見ていないね？...窓に！窓に！
