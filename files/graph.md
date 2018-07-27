
## graph
ここはまだ僕は詳しくないのでお試しです。
お試しな同人誌の中で更にお試しです。

graph理論でなにかやりたい場合はこうです。

```{frame=single}
pip install bctpy
```
これでbctpyがインストールされました。
コネクティビティの結果である三角行列を突っ込みたいですね。
突っ込みます。

```{frame=single}
import bct
```

例えばconmatというnumpy三角行列があったとして、こいつを放り込むなら
まずは三角行列を普通の行列にしてやるべきでしょう。
(方向ありの行列なら三角行列にはならないのでそのままでいいです)
```{frame=single}
dcon=conmat+conmat.T
```

global efficiencyを重み付けありで計算したいならこうと思います。
```{frame=single}
bct.efficiency_wei(dcon)
```
すると、スカラー値が算出されます。

