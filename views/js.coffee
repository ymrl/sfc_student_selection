jQuery ->
	content = ""
	label   = "ツイート"
	l = $('#list')
	m = l.find('li')
	n = m.length
	console.log l,m,n
	if l.length > 0
		label = "履修選抜結果をツイート"
		if n > 0
			if l.hasClass('outside')
				content = "履修選抜 #{n} 個通った"
			else
				content = "#{m.map((i,e)->$(e).text().replace(/\s/g,'')).toArray().join('と')}の履修選抜通った"
		else
			content = "履修選抜まだ通ってない"
	twttr.anywhere (T)->
		T("#tbox").tweetBox
			label: label
			defaultContent: "#{content} #SFC履修選抜 http://xn--8uqs71aoyeyq7c.xn--s9j219o.jp/"

		

		


