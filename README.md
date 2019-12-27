Please refer to the README.md file at master branch for updated information.

master ブランチの README.md が最新の情報です。

# PMD source code mirror repository

配布元:
* http://www5.airnet.ne.jp/kajapon/tool.html
* https://sites.google.com/site/kajapon/pmd

このレポジトリは、近日オープンソースとして公開されたばかりの PMD のソースコードをミラーすることを主目的としたものです。PC-98 用に限らず、全ての機種の PMD を対象とするつもりです。

ソースでしか手に入らないバイナリ (特に PMDIBM) をビルドしたものも releases にて公開しています。

また、今後、 `optasm` 以外の `masm` や `jwasm` などでコンパイルできるような修正を加えたり、移植性の高い MML コンパイラや、 ドライバの C へのトランスパイラを公開したりするかもしれません。

PMD データ形式とその音楽文化の更なる発展を願って。

改めて PMD の作者であり、またこのような形で公開してくださった KAJA さんに感謝の意を表明します。

## ビルドについて
ビルドには、現在の所 DOS(BOX) 環境の `wmake` を使います。

common/COMMON.MAK を編集することでアセンブラやリンカを変更できます。

全てのブランチで SLR Systems OPTASM 1.65, MS LINK 5.31.009 `でビルドできます (全てのブランチで、これでビルドした結果のバイナリが変わらないような最小限のソースとなるようにしています)

## ブランチについて
* original: 元のアーカイブに EOF 除去以外の変更を加えずに Makefile などを追加したもの
* master: 共通のソースを一つに集約したもの
* masm: MS MASM 6.11d でビルドできるようにしたもの
: jwasm: JWasm v2.11 でビルドできるようにしたもの

存在しないブランチは作成予定のものです。最終的には OSS ツールのみでビルドできる jwasm ブランチが目標ですが、 JWasm の masm との非互換性はバグと見做してできるだけ JWasm 側の修正に努めます。

# PMD source code mirror repository

Original websites:
* http://www5.airnet.ne.jp/kajapon/tool.html
* https://sites.google.com/site/kajapon/pmd

This repository is a place to mirror the recently open-sourced PMD's source code. It is not limited to versions for PC-98, but for any machines that have been released.

Binaries that are only available in source code (especially proper tools for IBM compatibles) can be downloaded from the releases page.

Moreover I might make some changes to the source, including modifying the source for `optasm` to make it compilable under `masm` or `wasm`, creating a portable MML compiler, or transpiling the drivers to C.

May the PMD data format and its culture to strive even further.

Thank you KAJA for developing PMD in the first place, and for generously releasing the source code of them.

## Building
Currently building requires wmake under DOS(BOX).

Which assembler and linker to use is configurable through common/COMMON.MAK.

All branches are buildable with SLR Systems OPTASM 1.65, MS LINK 5.31.009. (All branches should produce identical binaries when compiled with these tools)

## Branches
* original: imported original archive contents without modification except for EOF removal, and added makefiles
* master: common source files deduplicated
* masm: buildable with MS MASM 6.11d
* jwasm: buildable with JWasm v2.11

Nonexistent branches mean that I still have work to do. The goal is to create a version that is buildable with OSS tools, but as I will consider most of the incompatibilities between masm and JWasm as bugs, I will try to contribute to JWasm to fix them as well.