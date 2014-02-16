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
	"SD"

updateList = ->
	movieTable.html ''

	c = 0
	for mov in data
		c++
		movieTable.append """
			<tr #{if c is 10 then "class='active'" else ""}>
				<td>#{mov.label}</td>
				<td>#{mov.rating.toPrecision 2}</td>
				<td><span class="quality #{getQualityLabel(mov)}">#{getQualityLabel(mov)}</span></td>
			</tr>
		"""

getMovie = (id) ->
	for mov in data
		return mov if mov.movieid is id

getWriterList = (mov) ->
	str = "<ul class='perslist'>"
	for pers in mov.writer
		str += "<li>#{pers}</li>"
	str += "</ul>"

getCastList = (mov) ->
	str = "<ul class='perslist'>"
	for pers in mov.cast
		str += "<li><strong>#{pers.name}</strong> as #{pers.role}</li>"
	str += "</ul>"

updateDetails = (id) ->
	mov = getMovie id
	if mov?
		$('.details .year').html mov.year
		$('.details .title').html mov.label
		$('.details .tagline').html mov.tagline
		$('.details .plot').html mov.plot
		$('.details .genre').html mov.genre.join(" / ")
		$('.details .cast').html getCastList mov
		$('.details .writer').html getWriterList mov
		$('.details .director').html mov.director.join(", ")
		$('.details .country').html mov.country
		$('.details .length').html "#{mov.runtime / 60} min"
		$('.details .rating').html "Rating: #{mov.rating.toPrecision(3)}"
		$('.details .id').html mov.movieid

$ ->
	movieTable = $('#movies tbody')

	$('.container > .row > .box').first().css('height', "#{$(window).height() - 14}px");

	$('#options .grab').click (e) ->
		$('#options').toggleClass('closed')

	updateList()