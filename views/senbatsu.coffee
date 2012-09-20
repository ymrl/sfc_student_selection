jQuery ->
	content = ""
	label   = "ツイート"
	l = jQuery('#list')
	m = l.find('li').filter(-> !jQuery(this).hasClass('nocount'))
	n = m.length
	if l.length > 0
		label = "履修選抜結果をツイート"
		if n > 0
			if l.hasClass('outside')
				content = "履修選抜 #{n} 個通った"
			else
				content = "#{m.map((i,e)->jQuery(e).text().replace(/\s/g,'')).toArray().join('と')}の履修選抜通った"
		else
			content = "履修選抜まだ通ってない"
	twttr.anywhere (T)->
		T("#tbox").tweetBox
			label: label
			defaultContent: "#{content} #SFC履修選抜 http://履修選抜.死ぬ.jp/"
	jQuery('form.numForm').bind 'submit',(e)->
		location.href = "/#{jQuery(this).find('.num').val()}"
		e.preventDefault()


