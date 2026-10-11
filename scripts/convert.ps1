# UBC キャンパスの Java 版ワールドを、Bedrock 版のワールド (.mcworld) に変換する。
#
# 前提: Windows、gh (GitHub CLI) にログイン済み。Java は不要（Chunker CLI が実行環境を同梱）。
# 使い方:
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\convert.ps1
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\convert.ps1 -Format BEDROCK_R26_50
# 何をするか:
#   1. ashtanmistal/minecraftUBC のリリース 3.0.0 から FULL.zip（約 160MB）を取ってくる
#   2. HiveGamesOSS/Chunker の CLI を取ってくる
#   3. Bedrock 版に変換し、out\ubc_campus.mcworld を作る（ダブルクリックでゲームに取り込める）
# -Format は、遊ぶ端末のゲームの版に合わせる。新しすぎる版にすると、古いゲームでは開けない。

param(
    [string]$Format = 'BEDROCK_R26_50',
    [string]$WorldTag = '3.0.0',
    [string]$ChunkerTag = '1.21.0'
)
$ErrorActionPreference = 'Stop'

$root = Split-Path $PSScriptRoot -Parent
$work = Join-Path $root 'work'
$out = Join-Path $root 'out'
New-Item -ItemType Directory -Force $work, $out | Out-Null

# 1. 元のワールド
$worldZip = Join-Path $work 'FULL.zip'
if (-not (Test-Path $worldZip)) {
    gh release download $WorldTag -R ashtanmistal/minecraftUBC -p FULL.zip -D $work
    if ($LASTEXITCODE -ne 0) { throw 'FULL.zip を取ってこられませんでした' }
}
$javaWorld = Join-Path $work 'java\FULL'
if (-not (Test-Path $javaWorld)) { Expand-Archive $worldZip (Join-Path $work 'java') }

# 2. 変換ツール
$cliZip = Join-Path $work 'chunker-cli.zip'
if (-not (Test-Path $cliZip)) {
    gh release download $ChunkerTag -R HiveGamesOSS/Chunker -p chunker-cli-windows-x86.zip -O $cliZip
    if ($LASTEXITCODE -ne 0) { throw 'Chunker CLI を取ってこられませんでした' }
}
$cli = Join-Path $work 'chunker\chunker-cli\chunker-cli.exe'
if (-not (Test-Path $cli)) { Expand-Archive $cliZip (Join-Path $work 'chunker') }

# 3. 変換（5 分ほど）
$bedrock = Join-Path $work 'bedrock'
if (Test-Path $bedrock) { Remove-Item -Recurse -Force $bedrock }
& $cli -i $javaWorld -o $bedrock -f $Format
if ($LASTEXITCODE -ne 0) { throw "変換に失敗しました（終了コード $LASTEXITCODE）" }
[IO.File]::WriteAllText((Join-Path $bedrock 'levelname.txt'), 'UBC Campus')

$mcworld = Join-Path $out 'ubc_campus.mcworld'
if (Test-Path $mcworld) { Remove-Item -Force $mcworld }
$tmpZip = Join-Path $out 'ubc_campus.zip'
Compress-Archive -Path (Join-Path $bedrock '*') -DestinationPath $tmpZip -Force
Move-Item $tmpZip $mcworld

$mb = [math]::Round((Get-Item $mcworld).Length / 1MB)
Write-Host "できました: $mcworld（$mb MB）"
Write-Host 'ダブルクリックするとマインクラフトに取り込まれ、「遊ぶ」の一覧に「UBC Campus」が出ます。'
