# UBC キャンパスを Bedrock 版で

![メインモールを上空から見下ろす](docs/screenshots/main-mall-aerial.jpg)

ブリティッシュコロンビア大学（UBC）バンクーバー校のキャンパスを 1:1 で再現した Minecraft の世界を、
統合版（Bedrock 版）で遊べるように変換したもの。

元の世界は [ashtanmistal/minecraftUBC](https://github.com/ashtanmistal/minecraftUBC)
（リリース 3.0.0、Java 版 1.20.4）。LiDAR の点群と UBC の地理データから作られ、
Version 2.0 では大勢の人が建物を手作業で建てている。この変換は、その世界を Bedrock 版の形式に移しただけで、
建物には手を加えていない。

## すぐ遊ぶ

1. [Releases](../../releases) から `ubc_campus.mcworld` をダウンロードする（約 80MB）
2. マインクラフトで「プレイ」→「ワールド」の一覧の右上にある「**ワールドをインポート**」を押し、
   ダウンロードした `ubc_campus.mcworld` を選ぶ
3. 一覧に出た「UBC Campus」を開く

- ファイルのダブルクリックでも取り込める PC があるが、Windows で .mcworld を開くアプリが
  決まっていないと何も起きない（2026-10-11、作者の PC で確認）。そのときは上の「ワールドをインポート」を使う
- 同じ名前のワールドが既にあると、「UBC Campus (インポート完了)」のような名前で取り込まれる
- 変換したゲームの版は 1.26.50（形式 `BEDROCK_R26_50`）。これより古いゲームでは開けない
- 描画モードが「Vibrant Visuals」だと、空気のかすみで 40 ブロックほど先から白く霞む。
  見渡したいときは、タイトル画面の 設定 → ビデオ →「モード」を「描画優先」にする
  （ワールドの中からは切り替えられない）
- チートは有効。最初はサバイバルなので、歩き回るなら `/gamemode creative` が楽

## 見どころ

| | | |
|---|---|---|
| ![メインモール](docs/screenshots/main-mall.jpg) | ![高層棟とクレーン](docs/screenshots/towers.jpg) | ![森の中の建物](docs/screenshots/south-campus.jpg) |
| メインモールの並木道 | 高層棟。建設中のクレーンもある | 森の中に建物が点在する一帯 |

どれも出現地点の上空から撮った。一番上の画像と同じ眺めは `/tp @s 2325 150 -1380 0 32` で見られる。

## 世界の大きさ

- 範囲: x −1024〜6143、z −3072〜4095（約 7km 四方）
- 出現地点: (2317, 29, −1294)

## 自分で変換し直す

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\convert.ps1
```

`out\ubc_campus.mcworld` ができる。ゲームの版に合わせるときは `-Format BEDROCK_R26_40` のように指定する。
変換には [Chunker](https://github.com/HiveGamesOSS/Chunker) の CLI を使う（Java のインストールは不要）。
Windows 専用。

スクリプトは変換のあとに次の 3 つをする。

- ワールド名を「UBC Campus」にする。Chunker は名前を「UBC」にし、ゲームは `level.dat` の名前を使うので、
  `level.dat` と `levelname.txt` の両方を書き換える
- `assets/world_icon.jpeg`（一覧に出るアイコン、800×450）を世界に入れる
- zip の中のパスを `/` 区切りで書く。PowerShell 5.1 の `Compress-Archive` は、zip の規格に反して `\` 区切りで書く

## 権利と公開について

- 元のリポジトリのライセンスは GPL-2.0。ただし世界には UBC の地理データと、
  Version 2.0 で大勢の人が手作業で建てた建物が含まれる。建てた人の一覧は元のリポジトリの
  [docs/building.md](https://github.com/ashtanmistal/minecraftUBC/blob/master/docs/building.md) にある
- 一般に公開する前に、作者の Ashtan Mistal さんに許可を取る（元の README にある Discord が連絡先）
- Bedrock の「アドオン」には世界を入れられない。公開するなら `.mcworld` か `.mctemplate` の形になる
- このリポジトリの画像は、変換した世界をゲームの中で撮ったもの

## 確認すること

- [x] ゲームで開けるか（2026-10-11、1.26.52 で確認）
- [ ] Java 版にしかないブロックが、別のものに置き換わっていないか（看板・扉など）
- [ ] 出現地点がキャンパスの中か
