# カスタム XKB (Anne Pro 2 / VXV M61) の適用手順

## 前提

- 対象はネイティブ Linux (Ubuntu 24.04, GNOME on Wayland)。WSL2 ではキーボード配列は Windows 側で管理するので対象外
- キーボードは **US 配列** (`us` レイアウト) を使う。旧 `xkb/keymap/*` にあった `jp:2` (JIS を第 2 グループに追加) は廃止した
- Wayland では `setxkbmap` / `xkbcomp` によるランタイム適用が効かない (mutter が libxkbcommon で keymap を組み立てる)。
  そのため symbols をシステムへ配置し、**XKB オプション**として gsettings で有効化する方式にした

## ファイル構成

| リポジトリ | 配置先 | 役割 |
| --- | --- | --- |
| `xkb/symbols/anne_pro2` | `/usr/share/X11/xkb/symbols/anne_pro2` | `;` と `:` を入れ替え (`anne_pro2:swap`) |
| `xkb/symbols/xvx_m61` | `/usr/share/X11/xkb/symbols/xvx_m61` | 上記 + CapsLock→Ctrl、Win キー↔Ctrl キー入れ替え、Menu→Super (`xvx_m61:swap`) |
| `xkb/rules/evdev` | `/etc/xkb/rules/evdev` | オプション名 → symbols の対応表。末尾で `! include %S/evdev` してシステムの rules を取り込む |

rules を `/usr/share/X11/xkb/rules/evdev` に書かないのは、xkeyboard-config パッケージ所有のファイルで更新時に上書きされるため。
`/etc/xkb` は libxkbcommon の追加検索パスで、パッケージ更新の影響を受けない。
symbols 側はパッケージに含まれないファイル名なので、`/usr/share/X11/xkb/symbols/` に置いても更新で消えない。

## 適用手順

1. 配置 (sudo が必要):

   ```bash
   bash ~/dotfiles/etc/scripts/install_xkb.sh
   ```

2. レイアウトを US にする (未設定の場合。mozc 併用なら `[('xkb', 'us'), ('ibus', 'mozc-jp')]`):

   ```bash
   gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us')]"
   ```

3. 使うキーボードに合わせてオプションを有効化する (即時反映、再ログイン不要):

   ```bash
   gsettings set org.gnome.desktop.input-sources xkb-options "['anne_pro2:swap']"
   # or
   gsettings set org.gnome.desktop.input-sources xkb-options "['xvx_m61:swap']"
   ```

   GNOME の設定 UI や Tweaks の一覧には出ない (rules の XML に登録していない) ので、gsettings で操作する。

4. 元に戻す:

   ```bash
   gsettings reset org.gnome.desktop.input-sources xkb-options
   ```

## 確認方法

- rules と symbols が解決できるか (`libxkbcommon-tools` が必要。`sudo apt install libxkbcommon-tools`):

  ```bash
  xkbcli compile-keymap --layout us --options xvx_m61:swap | grep -E 'key <(AC10|CAPS|LWIN|LCTL)>'
  ```

  期待される出力 (抜粋):

  ```
  key <LCTL> { [ Super_L, Super_L ] };
  key <AC10> { [ colon, semicolon ] };
  key <CAPS> { [ Control_L ] };
  key <LWIN> { [ Control_L ] };
  ```

  オプション名を間違えると `Unrecognized RMLVO option "..." was ignored` と出て**無視される** (終了コードは 0 のまま) ので、この確認は省略しない。

- 現在の設定値: `gsettings get org.gnome.desktop.input-sources xkb-options`
- 実際のキー入力: `xkbcli interactive-wayland` (押したキーの keysym が表示される)

## 注意

- Xorg セッション ("Ubuntu on Xorg") は対象外。X サーバも mutter の X11 backend も `/etc/xkb` を読まないため、オプションが解決されない
- ログイン画面 (GDM) には反映されない
- 旧方式 (`xkbcomp -I$HOME/.xkb ... $DISPLAY` と `anne` / `xvx` エイリアス、`xkb/keymap/*`) は廃止した
