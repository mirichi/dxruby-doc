# DXRubyExtension
## はじめに

**DXRubyExtensionは過去の互換性のために添付してあります。DXRuby1.4.0以降では同等以上に高速・高機能な衝突判定をSpriteクラスで実現していますので、特に理由が無い場合はそちらをお使いください。**

DXRubyExtensionはRuby用DirectXライブラリDXRubyでゲームを作る際に、特に負荷がかかるところ、作るのが大変そうなところを楽にするために開発された追加ライブラリです。
DXRubyのプロジェクトWebで配布していますが、DXRuby1.0.5以降には同梱されており、dxrubyexをrequireすることで使うことができます。
矩形、円、点、三角の衝突判定が実装されており、それぞれ混在していてもきちんと判定できます。
判定配列に同じ配列を指定すると、自分同士や既にチェックした判定は省略されます。

DXRubyExtensionモジュールの下に定義されていますが、自動でincludeされるので意識する必要はありません。
requrieする前に$dxrubyex_no_include = trueと書くとインクルードされなくなります。

## Collisionモジュール

```
Collision.check(o, d)
```

oとdはそれぞれ、CollisionXxxクラスのオブジェクト（以後、判定範囲オブジェクト）、もしくは判定範囲オブジェクトを格納した配列を指定してください。
衝突していたら、oの配列の衝突通知先オブジェクトのshotメソッドが、dの側はhitメソッドがそれぞれ、衝突相手のオブジェクトを引数にして呼ばれます。
shot、hitの中で、そのキャラが消滅した場合、判定範囲オブジェクトのdeleteメソッドを呼び出せば、それ以降の判定は省略されます。
oとdに同じ配列を指定すると、それぞれ1回ずつの比較がされ、衝突があった場合にはどちらもhitメソッドが1回ずつ呼ばれます。
判定範囲オブジェクトの衝突通知先がnilの場合、衝突していてもshot、hitメソッドは呼び出されません。
どれか一つでも衝突していればtrueが返ります。

## 衝突判定範囲クラス
CollisionBox（矩形範囲）、CollisionCircle（円判定）、CollisionTriangle（三角形判定）、CollisionPoint（点判定）の4種類のクラスがあります。
サポートする全てのクラス同士の判定が可能です。

```
CollisionBox.new(self, x1, y1, x2, y2)
CollisionCircle.new(self, x1, y1, r)
CollisionTriangle.new(self, x1, y1, x2, y2, x3, y3)
CollisionPoint.new(self)
```

当たったとみなされる判定範囲（キャラの絵の座標を原点とするそれぞれの形状）を指定します。
selfは衝突通知先オブジェクトを指定してください。nilを指定すると衝突通知は行われません。
矩形は左上と右下、円は中心と半径、三角は3点の座標、点は原点のみが判定範囲になります。
Triangleを応用すると、たとえば3点のうち2点を同じ座標にすると線分、Triangleを2つ使うと自由な形状の四角形など、様々な形状の判定が実現できます。

```
CollisionBox#set(x, y)
CollisionCircle#set(x, y)
CollisionTriangle#set(x, y)
CollisionPoint#set(x, y)
```

キャラの座標を設定します。
この座標に対して、newもしくはsetRangeで指定した座標範囲を適用し、衝突判定されます。
new時に範囲を指定しておけば、あとはsetで移動させるだけですむようになっています。

```
CollisionBox#setRange(x1, y1, x2, y2)
CollisionCircle#setRange(r)
CollisionTriangle#setRange(x1, y1, x2, y2, x3, y3)
```

キャラの衝突判定の範囲を変更します。
通常はnewした時の判定範囲をそのまま継続しますが、アニメーションごとに判定範囲が変わる場合などはこれを使用します。

```
CollisionBox#delete
CollisionCircle#delete
CollisionTriangle#delete
CollisionPoint#delete
```

判定範囲オブジェクトを無効にします。
内部フラグをセットするだけで、オブジェクトが消えるわけではありません。
判定中のshot、hitメソッドでは判定配列からオブジェクトを消さないでください。

```
CollisionBox#getHitRange
CollisionCircle#getHitRange
CollisionTriangle#getHitRange
CollisionPoint#getHitRange
```

当たり判定範囲の画面座標を取得します。
Boxは[x1, y1, x2, y2]、
Circleは[x, y, r]、
Triangleは[x1, y1, x2, y2, x3, y3]、
Pointは[x, y]、
と、配列で取得できます。

```
CollisionBox#notifyObject
CollisionCircle#notifyObject
CollisionTriangle#notifyObject
CollisionPoint#notifyObject
```

new時に指定した通知先オブジェクトを返します。 

## Arrayクラス拡張 ArrayExtensionモジュール
Arrayクラスにincludeして使います。
単純にメソッドを１個呼ぶだけの使い方をする場合に、eachよりも速いhs_eachと、同様にhs_delete_ifがあります。

```
ArrayExtension#hs_each(val)
```

引数にはメソッド名のシンボルもしくは文字列を指定します。
配列内の全ての要素に対して、指定されたメソッドを1回ずつ呼びます。

```
ArrayExtension#hs_delete_if(val)
```

引数にはメソッド名のシンボルもしくは文字列を指定します。
配列内の全ての要素に対して、指定されたメソッドを1回ずつ呼び、結果が真だった場合にその要素を削除します。

