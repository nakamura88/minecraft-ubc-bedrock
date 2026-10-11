# UBC キャンパスの Java 版ワールドを、Bedrock 版のワールド (.mcworld) に変換する。
#
# 前提: Windows、gh (GitHub CLI) にログイン済み。Java は不要（Chunker CLI が実行環境を同梱）。
# 使い方:
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\convert.ps1
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\convert.ps1 -Format BEDROCK_R26_50
# 何をするか:
#   1. ashtanmistal/minecraftUBC のリリース 3.0.0 から FULL.zip（約 160MB）を取ってくる
#   2. HiveGamesOSS/Chunker の CLI を取ってくる
#   3. Bedrock 版に変換し、out\ubc_campus.mcworld を作る（ゲームの「ワールドをインポート」で取り込める）
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

# ワールド名とアイコン。ゲームは一覧の名前を level.dat の LevelName から読み、
# levelname.txt はそれで上書きする。Chunker は LevelName を "UBC" にするので、両方を直す。
$name = 'UBC Campus'
[IO.File]::WriteAllText((Join-Path $bedrock 'levelname.txt'), $name)
$levelDat = Join-Path $bedrock 'level.dat'
$bytes = [IO.File]::ReadAllBytes($levelDat)
# NBT（リトルエンディアン）の文字列タグ: 型 8、名前の長さ 9、"LevelName"、値の長さ、値
$key = [byte[]](8, 9, 0) + [Text.Encoding]::ASCII.GetBytes('LevelName')
$at = -1
for ($i = 8; $i -le $bytes.Length - $key.Length; $i++) {
    $hit = $true
    for ($j = 0; $j -lt $key.Length; $j++) { if ($bytes[$i + $j] -ne $key[$j]) { $hit = $false; break } }
    if ($hit) { $at = $i; break }
}
if ($at -lt 0) { throw 'level.dat に LevelName が見つかりません' }
$valAt = $at + $key.Length
$oldLen = [BitConverter]::ToUInt16($bytes, $valAt)
$newVal = [Text.Encoding]::UTF8.GetBytes($name)
$head = $bytes[0..($valAt - 1)]
$tail = $bytes[($valAt + 2 + $oldLen)..($bytes.Length - 1)]
$patched = [byte[]]($head + [BitConverter]::GetBytes([uint16]$newVal.Length) + $newVal + $tail)
# 先頭 8 バイトは「版」と「本体の長さ」。長さを書き直す
$len = [BitConverter]::GetBytes([int]($patched.Length - 8))
for ($j = 0; $j -lt 4; $j++) { $patched[4 + $j] = $len[$j] }
[IO.File]::WriteAllBytes($levelDat, $patched)
Copy-Item (Join-Path $root 'assets\world_icon.jpeg') (Join-Path $bedrock 'world_icon.jpeg') -Force

$mcworld = Join-Path $out 'ubc_campus.mcworld'
if (Test-Path $mcworld) { Remove-Item -Force $mcworld }
# Compress-Archive（PowerShell 5.1）は zip の中のパスを "db\000.ldb" のように \ 区切りで書く。
# zip の規格は / 区切りで、展開する道具によっては正しく読めないので、/ 区切りで自分で書く。
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::Open($mcworld, 'Create')
try {
    $base = (Resolve-Path $bedrock).Path.TrimEnd('\') + '\'
    foreach ($f in Get-ChildItem $bedrock -Recurse -File) {
        $entry = $f.FullName.Substring($base.Length).Replace('\', '/')
        [void][IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $f.FullName, $entry, 'Optimal')
    }
} finally { $zip.Dispose() }

$mb = [math]::Round((Get-Item $mcworld).Length / 1MB)
Write-Host "できました: $mcworld（$mb MB）"
Write-Host 'マインクラフトの「プレイ」→「ワールドをインポート」で選ぶと、一覧に「UBC Campus」が出ます。'
