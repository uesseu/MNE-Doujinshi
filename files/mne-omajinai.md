
\newpage
## jupyter用作図用おまじないセット

このへんのおまじないは素のpython使っているならいりませんが、
jupyterやipythonのときは必要でしょう。

下記はjupyter/ipythonのコマンド
```{frame=single}
%matplotlib inline
%gui qt
```
%matplotlib inlineについては、この設定ならjupyter上に表示されます。
もし、別窓[^betumado]を作りたいなら、inlineを変えてください。
python3の場合
```{frame=single}
%matplotlib qt5
```
python2の場合
```{frame=single}
%matplotlib qt
```
となります。
下の%gui qtはmayaviによる3D表示のためのものです。
mayaviがpython3で動くかどうかは僕はまだ確認してないです。

他に、こういうのもあります。
```{frame=single}
import seaborn as sns
```
matplotlibの図を自動で可愛くしてくれるゆるふわパッケージです。

[^betumado]:生の波形を見たいときなどにはそのほうが向いてる
