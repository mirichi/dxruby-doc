# 'ウィンドウを閉じる'のキャンセル

DXRuby1.0.7からInput.updateの戻り値が、ユーザーが閉じる操作（右上のｘボタンを押す、ALT+F4を押す)をした瞬間のみtrueになるように、また、ウィンドウのクローズは自動的にキャンセルされるように変更されました。
これにより、ユーザーに本当に閉じるのかを確認することができます。

```ruby
require 'dxruby'

font = Font.new(32)
image = Image.new(32,32,[255,255,255])
flag = false
x = 0

Window.create
loop do
  flag = true if Input.update
  if flag
    Window.draw_font(0,0,'とじますか(y/n)',font)
    break if Input.key_down?(K_Y)
    flag = false if Input.key_down?(K_N)
  else
    x += Input.x
  end

  Window.draw(x,100,image)

  Window.sync
  Window.update
end
```

