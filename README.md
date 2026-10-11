# UBC キャンパスを Bedrock 版で

ブリティッシュコロンビア大学（UBC）バンクーバー校のキャンパスを 1:1 で再現した Minecraft の世界を、
統合版（Bedrock 版）で遊べるように変換したもの。将来はアドオン／ワールドとしての公開を目指す。

元の世界は [ashtanmistal/minecraftUBC](https://github.com/ashtanmistal/minecraftUBC)
（リリース 3.0.0、Java 版 1.20.4）。

## すぐ遊ぶ

1. [Releases](../../releases) から `ubc_campus.mcworld` をダウンロードする
2. ダブルクリックする（マインクラフトが開き、世界が取り込まれる）
3. 「遊ぶ」→「ワールド」の一覧から「UBC Campus」を開く

変換したゲームの版は 1.26.50（形式 `BEDROCK_R26_50`）。これより古いゲームでは開けない。

## 自分で変換し直す

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\convert.ps1
```

`out\ubc_campus.mcworld` ができる。ゲームの版に合わせるときは `-Format BEDROCK_R26_40` のように指定する。
変換には [Chunker](https://github.com/HiveGamesOSS/Chunker) の CLI を使う（Java のインストールは不要）。

## 世界の大きさ

- 範囲: x −1024〜6143、z −3072〜4095（約 7km 四方）
- 元の世界の出現地点: (2317, 29, −1294)

## 公開の前に

- 元のリポジトリのライセンスは GPL-2.0。ただし世界には UBC の地理データと、
  Version 2.0 で大勢の人が手作業で建てた建物が含まれる
- 公開する前に、作者の Ashtan Mistal さんに許可を取る（元の README にある Discord が連絡先）
- Bedrock の「アドオン」には世界を入れられない。公開するなら `.mcworld` か `.mctemplate` の形になる

## 確認すること

- [ ] ゲームで開けるか
- [ ] Java 版にしかないブロックが、別のものに置き換わっていないか
- [ ] 出現地点がキャンパスの中か
