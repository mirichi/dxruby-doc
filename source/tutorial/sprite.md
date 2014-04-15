# Spriteを使うためのチュートリアル

## 基本
Spriteは描画に必要なデータと描画機能を持ちます。衝突判定をこなすこともできます。
これら機能の使い方や応用方法などを解説していきます。

### 最も基本的な使い方
```ruby
require 'dxruby'

s = Sprite.new(100, 100, Image.new(100, 100, C_WHITE))

Window.loop do
  s.draw
end
```

こんな感じでしょうか。
Sprite.newの引数はx座標、y座標、画像データで、画像データはImage.newして直接渡しています。
最低限この3つのデータがあれば、Sprite#drawで画面に絵を描画することができます。

### 絵を動かす
```ruby
require 'dxruby'

s = Sprite.new(0, 100, Image.new(100, 100, C_WHITE))

Window.loop do
  s.x += 1
  s.draw
end
```

ベタですが、このようにするとSpriteオブジェクトのx座標を1ずつ増やしていくことができます。
同様にy座標も変更することができます。
Spriteオブジェクトごとに別々に座標を持っているので、例えば以下のようにすると2つのキャラを別々に動かすことができます。

```ruby
require 'dxruby'

image = Image.new(100, 100, C_WHITE)
s1 = Sprite.new(0, 0, image)
s2 = Sprite.new(200, 0, image)

Window.loop do
  s1.x += 1
  s1.draw

  s2.y += 1
  s2.draw
end
```

### 回転など
Window.draw_exの持つエフェクト機能はすべて同じ名前の代入/参照メソッドを持っていて、同様の指定方法で設定することができます。

```ruby
require 'dxruby'

s = Sprite.new(100, 100, Image.new(100, 100, C_WHITE))

Window.loop do
  s.angle += 1
  s.alpha = s.alpha == 0 ? 255 : s.alpha - 5
  s.draw
end
```

----

## クラスの継承
Spriteの機能はクラスを継承することでより一層便利になります。
そこで今回はSpriteを継承してクラスを定義してみます。
initializeで初期値を設定し、updateで移動などをさせます。
updateはSpriteクラスに定義されてはいますが、中身はからっぽです。
継承したクラスで上書きして使います。

```ruby
require 'dxruby'

class MySprite < Sprite
  @@image = Image.new(100, 100, C_WHITE)

  def initialize
    super
    self.x = 0
    self.y = 100
    self.image = @@image
  end

  def update
    self.x += 1
  end
end

s = MySprite.new

Window.loop do
  s.update
  s.draw
end
```

メソッドを呼び出すときはself.xのようにselfをつけて呼び出すようにすると、無駄にバグを作りこむことがなくなりますのでオススメです。
また複数オブジェクトを生成して画像を共有する場合は、クラス変数にImageオブジェクトを入れておくようにするとクラス定義時に1回だけ生成されるようになりますので、速度的に有利です。
initializeでImage.new/loadするとSpriteオブジェクトを作るたびに毎回新しいImageオブジェクトが生成されていまいます。

### クラスメソッドを使う
Sprite.update、Sprite.drawを使うと複数のオブジェクトを配列に入れてまとめて管理することができます。

```ruby
require 'dxruby'

class MySprite1 < Sprite
  @@image = Image.new(100, 100, C_WHITE)

  def initialize
    super
    self.x = 0
    self.y = 0
    self.image = @@image
  end

  def update
    self.x += 1
  end
end

class MySprite2 < Sprite
  @@image = Image.new(100, 100, C_WHITE)

  def initialize
    super
    self.x = 200
    self.y = 0
    self.image = @@image
  end

  def update
    self.y += 1
  end
end

s = [MySprite1.new, MySprite2.new]

Window.loop do
  Sprite.update(s)
  Sprite.draw(s)
end
```

### Spriteオブジェクト以外もまとめて管理する
Sprite.update、Sprite.drawはSpriteオブジェクト以外のオブジェクトが配列に入っていても、updateやdrawを呼び出そうと試みます。
無くてもエラーにはならず呼ばれないだけです。
したがって自作クラスのupdate/drawの定義されたオブジェクトを配列に入れておけば、Sprite以外のオブジェクトも同様に動作させることができます。

```ruby
require 'dxruby'

class MySprite1 < Sprite
  @@image = Image.new(100, 100, C_WHITE)

  def initialize
    super
    self.x = 0
    self.y = 0
    self.image = @@image
  end

  def update
    self.x += 1
  end
end

class Count
  @@font = Font.new(32)

  def initialize
    @count = 0
  end

  def update
    @count += 1
  end

  def draw
    Window.draw_font(0, 300, @count.to_s, @@font)
  end
end

s = [MySprite1.new, Count.new]

Window.loop do
  Sprite.update(s)
  Sprite.draw(s)
end
```

これで何ができるのかと言うと、例えばゲームの進行を制御するオブジェクトなどを一緒に配列に入れておいて動かすとか、背景やスコアなどの描画も同様に扱ってしまうとか、そういったSpriteを継承するのが変な場合などに使えます。
もちろん使わなくてもゲームは作れます。

### Spriteのライフサイクルを管理する
Sprite#vanishという一風変わったメソッドがあります。
これはSpriteオブジェクトが不要になったときに呼び出すもので、Sprite#vanishを呼び出すとSprite#vanished?がtrueになります。
trueになったオブジェクトはSprite#drawを呼び出しても描画されません。
また、Sprite.cleanメソッドで配列から削除することができます。

Sprite.cleanを毎フレーム呼び出すようにしておいて、画面から外に出たとか、キャラが破壊されて消えるときとか、なんらかの条件でキャラを消す場合にSprite#vanishを呼び出すようにすればSprite.cleanで配列から削除されますので、キャラのオブジェクトの管理が自然にできます。

```ruby
require 'dxruby'

class MySprite1 < Sprite
  @@image = Image.new(50, 50, C_WHITE)

  def initialize
    super
    self.x = -50
    self.y = rand() * 400
    self.image = @@image
  end

  def update
    self.x += 1
    self.vanish if self.x > 300
  end
end

s = []
count = 20

Window.loop do
  count -= 1
  if count == 0
    s.push(MySprite1.new)
    count = 20
  end

  Sprite.update(s)
  Sprite.draw(s)
  Sprite.clean(s)
end
```

### まとめ
Spriteのクラスメソッドは、Spriteを継承したクラスのオブジェクトをまとめてごそっと配列に入れて扱うことを想定していて、そのような使い方をする場合に威力を発揮します。


----

## 衝突判定
Spriteクラスには柔軟で高速な衝突判定機能が備わっています。
キャラをたくさん動かして衝突判定する必要のある弾幕シューティングゲームや、複雑な形状での衝突判定が必要なゲームなどで使うとラクができます。

### 衝突判定の使い方
Sprite#collision=で衝突判定範囲を設定し、Sprite.check/Sprite#check/Sprite#===で判定することができます。
Sprite#collision=で設定していないと画像データサイズの矩形で判定されます。
今回はSprite.check/Sprite#check/Sprite#===の使い分けに焦点を当てて解説します。

最も簡単なのはSprite#===を使う方法です。

```ruby
require 'dxruby'

image = Image.new(100, 100, C_WHITE)
s = Sprite.new(100, 100, image)
m = Sprite.new(0, 0, image)
font = Font.new(32)

Window.loop do
  m.x, m.y = Input.mouse_pos_x, Input.mouse_pos_y

  s.draw
  m.draw

  if m === s
    Window.draw_font(0, 0, "hit!", font)
  end
end
```

Sprite#===は衝突していたらtrueを返すメソッドなので、このような形に書くことができます。
また、===の右側にはSpriteオブジェクトの配列を指定することもでき、どれか1つに当たっていたらtrueが返ります。

```ruby
require 'dxruby'

s = [Sprite.new(100, 100, Image.new(100, 100, C_RED)),
     Sprite.new(200, 200, Image.new(100, 100, C_GREEN)),
     Sprite.new(300, 300, Image.new(100, 100, C_BLUE))]
m = Sprite.new(0, 0, Image.new(50, 50, C_WHITE))
font = Font.new(32)

Window.loop do
  m.x, m.y = Input.mouse_pos_x, Input.mouse_pos_y

  Sprite.draw(s)
  m.draw

  if m === s
    Window.draw_font(0, 0, "hit!", font)
  end
end
```

Sprite#===はRubyのcase～whenでの比較に使われるメソッドなので、case～whenで比較することもできます。

```ruby
require 'dxruby'

s1 = Sprite.new(100, 100, Image.new(100, 100, C_RED))
s2 = Sprite.new(200, 200, Image.new(100, 100, C_GREEN))
s3 = Sprite.new(300, 300, Image.new(100, 100, C_BLUE))
m = Sprite.new(0, 0, Image.new(50, 50, C_WHITE))
font = Font.new(32)

Window.loop do
  m.x, m.y = Input.mouse_pos_x, Input.mouse_pos_y

  s1.draw
  s2.draw
  s3.draw
  m.draw

  case m
    when s1
      Window.draw_font(0, 0, "red hit!", font)
    when s2
      Window.draw_font(0, 0, "green hit!", font)
    when s3
      Window.draw_font(0, 0, "blue hit!", font)
  end
end
```

### 衝突したオブジェクトを取得する
Sprite#===で配列を対象に判定した場合、true/falseが返るだけでどれが衝突しているのかを知ることはできません。
衝突したオブジェクトを取得したい場合はSprite#checkを使います。
Sprite#checkはあるSpriteオブジェクトと衝突しているオブジェクトの配列を返すメソッドです。

```ruby
require 'dxruby'

image1 = Image.new(100, 100, C_WHITE)
image2 = Image.new(100, 100, C_RED)

s = Array.new(10) do
  Sprite.new(rand * 600, rand * 440, image1)
end

m = Sprite.new(0, 0, image1)

Window.loop do
  m.x, m.y = Input.mouse_pos_x, Input.mouse_pos_y

  m.check(s).each do |t|
    t.image = image2
  end

  Sprite.draw(s)
  m.draw
end
```

### 衝突コールバック機能
Sprite.checkは引数に2つのオブジェクト(どちらも配列指定可)のすべての組み合わせを判定し、衝突しているオブジェクトのメソッドを呼び出します。

```ruby
Sprite.check(o, d, shot=:shot, hit=:hit)
```

oとdがそれぞれ攻撃側と防御側というイメージで、衝突している組み合わせのo側のオブジェクトのshotメソッドと、d側のオブジェクトのhitメソッドが呼ばれます。
3つ目と4つ目の引数でそれぞれメソッド名を変更することができます。
shot/hitメソッドはそれぞれ衝突相手のオブジェクトを引数に渡してきますので、例えば衝突相手の攻撃力を取得するとかの場合に活用できます。
受け取る必要はありますが、使い道が無ければ無理に使う必要はありません。

```ruby
require 'dxruby'

class Box < Sprite
  @@image = Image.new(100,100,C_RED)
  def initialize(x, y)
    super
    self.angle = rand * 360
    self.image = @@image
  end

  def update
    self.y += 1
    self.vanish if self.y > 480
  end

  def hit(o)
    self.vanish
  end
end

s = []
m = Sprite.new(0, 0, Image.new(100,20,C_WHITE))
count = 50

Window.loop do
  count -= 1
  if count == 0
    count = 50
    s << Box.new(rand*540,-100)
  end
  m.x, m.y = Input.mouse_pos_x - 50, Input.mouse_pos_y - 10
  m.angle -= 5 if Input.mouse_down?(M_LBUTTON)
  m.angle += 5 if Input.mouse_down?(M_RBUTTON)

  Sprite.update(s)
  Sprite.check(m, s)
  Sprite.draw(s)
  m.draw
end
```

### 同じ配列同士の衝突判定
画面内に描画されるすべての物体を相互に衝突判定したい時は、Sprite.checkのoだけを設定するか、oとdに同じ配列を指定します。
衝突していたらそれぞれのhitメソッドが呼び出されます。

```ruby
require 'dxruby'

class Toufu < Sprite
  @@image = Image.new(50,50,[150,150,150])

  def initialize
    super
    self.x = rand(590)
    self.y = rand(430)
    @dx = rand(2) * 2 - 1
    @dy = rand(2) * 2 - 1
    self.image = @@image
  end

  def update
    self.x += @dx
    self.y += @dy
    @dx = -@dx if self.x < 0 or self.x > 590
    @dy = -@dy if self.y < 0 or self.y > 430
  end

  def hit(obj)
    if (self.x - obj.x).abs < (self.y - obj.y).abs
      @dy = -@dy
    else
      @dx = -@dx
    end
  end
end

s = Array.new(10) { Toufu.new }

Window.loop do
  Sprite.update(s)
  Sprite.check(s)
  Sprite.draw(s)

  break if Input.keyPush?(K_ESCAPE)
end
```

### まとめ
Rubyで衝突判定を処理すると大変遅くなりますが、Sprite.checkでの複数対複数のチェックはRubyで書いた場合に比べてかなり高速になります。
逆に1対1の判定などをする場合は、複雑な形状の判定でないと遅くなると思います。
速度が重要でなければ、ラクなように作るのがよいでしょう。

