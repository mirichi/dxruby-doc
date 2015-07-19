# 'ウィンドウを閉じる'のキャンセル

DXRuby1.4.2からWindow.loopの引数にclose_cancel(初期値false)が追加され、trueを指定するとユーザの閉じる操作で閉じられなくできるようになりました。
この機能とInput.requested_close?を使うと閉じる操作の確認を以前より簡単に実現することができます。

```ruby
require 'dxruby'

flg = false
Window.loop(true) do
  if Input.requested_close?
    flg = true
  end

  if flg
    Window.draw_text(0, 0, "閉じる？(y/n)", Font.default)
    if Input.key_push?(K_Y)
      Window.close
    elsif Input.key_push?(K_N)
      flg = false
    end
  end
end
```

