履修選抜.死ぬ.jp
====================
[履修選抜.死ぬ.jp](http://xn--8uqs71aoyeyq7c.xn--s9j219o.jp/)を構成するファイル一式が含まれています。


使用方法
--------

    git clone git@github.com:ymrl/sfc_student_selection.git
		cd sfc_student_selection

		# SFCSFSライブラリの取得
		git submodule init
		git submodule update

		# SFSをクロール（初回はかなり時間がかかります）
		ruby crawler.rb

		# Webサーバー起動
		ruby app.rb

ライセンス
--------

(The MIT Lisence)

Copyright © 2012 Allu Yamane

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


