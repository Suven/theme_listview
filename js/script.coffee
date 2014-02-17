movieTable = undefined

cut = (str, l) ->
	if Array.isArray(str)
		str = str.join(", ")
	if str.length - 3 > l
		return "#{str.substr(0, l - 3)}..."
	if str?
		""

shortDate = (d) ->
	d = new Date(d.substr(0,10))
	"#{d.getDate()}.#{d.getMonth() + 1}.#{d.getFullYear()}"

getQualityLabel = (mov) ->
	w = if mov.streamdetails.video[0]? then mov.streamdetails.video[0].width else 0

	if w is 8192 or w is 7680
		quality = "8K"
		cssClass = "eightK"
	else if w is 4096
		quality = "4K"
		cssClass = "fourK"
	else if 1915 < w < 1925
		quality = "HD"
		cssClass = "fullHD"
	else if 1275 < w < 1285
		quality = "HD"
		cssClass = "semiHD"
	else if w is 640 or w is 720
		quality = "SD"
		cssClass = "sd"
	else if 0 < w < 640
		quality = "LQ"
		cssClass = "lq"
	else
		return ""

	return """<span class="quality #{cssClass}">#{quality}</span>"""

getRes = (mov) ->
	w = if mov.streamdetails.video[0]? then mov.streamdetails.video[0].width else 0
	h = if mov.streamdetails.video[0]? then mov.streamdetails.video[0].height else 0

	res = "???"

	if 1915 < w < 1925 and 1075 < h < 1085
		res = "1080p"
	else if 1435 < w < 1445 and 1075 < h < 1085
		res = "1080i"
	else if 1595 < w < 1605 and 895 < h < 905
		res = "HD+"
	else if 1275 < w < 1285 and 715 < h < 725
		res = "720p"
	else if 2043 < w < 2053 and 1147 < h < 1157
		res = "2k"
	else if 3835 < w < 3845 and 2155 < h < 2165
		res = "4k UHD"
	else if 4091 < w < 4101 and 2299 < h < 2309
		res = "4k"
	else if 8187 < w < 8197 and 4603 < h < 4613
		res = "8k"
	else if 1019 < w < 1029 and 571 < h < 581
		res = "PAL"
	else if 571 < w < 581
		res = "576"

	return res

getChannels = (mov) ->
	c = 2
	if mov.streamdetails.audio.length > 0
		for audio in mov.streamdetails.audio
			c = audio.channels if audio.channels > c

	c = "2.0" if c is 2
	c = "2.1" if c is 3
	c = "5.1" if c is 6

	return c

getCodec = (mov) ->
	c = if mov.streamdetails.video[0]? then mov.streamdetails.video[0].codec else "???"
	return c

getACodec = (mov) ->
	c = 0
	codec = "???"
	if mov.streamdetails.audio.length > 0
		for audio in mov.streamdetails.audio
			if audio.channels > c
				c = audio.channels 
				codec = audio.codec

	return codec

getRatio = (mov) ->
	aspect = if mov.streamdetails.video[0]? then mov.streamdetails.video[0].aspect.toFixed(2) else ""
	
	console.log(typeof aspect, typeof "2.4", aspect, aspect is "2.4")

	if aspect is "1.78" or aspect is "1.77" or aspect is "2.35" or aspect is "2.40" or aspect is "1.83"
		aspect = "16:9"
	else if aspect is "1.6"
		aspect = "16:10"
	else if aspect is "1.33"
		aspect = "4:3"
	else if aspect is "1.25"
		aspect = "5:4"

	return aspect

updateList = ->
	movieTable.html ''

	p = 0
	for mov in data
		p++
		movieTable.append """
			<tr data-pos="#{p}" data-id="#{mov.movieid}">
				<td>#{mov.label}</td>
				<td>#{mov.rating.toPrecision 2}</td>
				<td>#{getQualityLabel(mov)}</td>
			</tr>
		"""

getMovie = (id) ->
	for mov in data
		return mov if mov.movieid is id

updateDetails = (id) ->
	mov = getMovie id
	console.log mov
	if mov?
		$('.movie_plot').html mov.plot
		$('.movie_plot_short').html cut(mov.plot, 200)
		$('.movie_poster').attr('src', "./img/poster.png")
		$('.movie_poster').attr('data-original', "./thumbs/#{id}.jpg")
		$('.movie_poster').lazyload(
			effect: 'fadeIn'
			event: 'load'
		)
		$('.movie_res').html getRes mov
		$('.movie_channels').html getChannels mov
		$('.movie_codec').html getCodec mov
		$('.movie_acodec').html getACodec mov
		$('.movie_ratio').html getRatio mov

resizeBoxes = ->
	$('.container > .row > .box').css('height', "#{$(window).height() - 14}px");

resizeTimer = null
resizeTriggered = ->
	window.clearTimeout(resizeTimer) if resizeTimer?
	resizeTimer = window.setTimeout(resizeBoxes, 100)

$ ->
	movieTable = $('#movies tbody')

	$(window).resize resizeTriggered	

	$('#options .grab').click (e) ->
		$('#options').toggleClass('closed')
		$('#overlay').fadeToggle()

	movieTable.on(
		'click'
		'tr'
		->
			movieTable.find('tr').removeClass('active')
			$(@).addClass('active')
			updateDetails $(@).data 'id'
	)

	$('body').on(
		'keydown'
		(e) ->
			if e.keyCode is 38 or e.keyCode is 40

				e.preventDefault()

				currentActive =  movieTable.find('tr.active')
				pos = if currentActive.length > 0 then currentActive.data 'pos' else 0
				switch e.keyCode
						when 40 then pos++
						when 38 then pos--

			maxPos = movieTable.find('tr').last().data 'pos'

			if pos < 1
				pos = maxPos
			if pos > maxPos
				pos = 1

			movieTable.find('tr.active').removeClass('active')
			newActive = movieTable.find("tr[data-pos='#{pos}']")
			newActive.addClass('active')
			updateDetails newActive.data 'id'

			newOffset = (pos * 37) - ($('.box.movs').height() / 2)
			$('.box.movs').scrollTop newOffset
	)

	$(window).trigger('resize')
	updateList()
	movieTable.find('tr').first().trigger('click')
