class Sequenced
	# Constants.
	COLOR_OBJECT_BORDER = '#c0c0c0' #C0C0C0
	COLOR_LIFELINE = '#80aada' #87CEFA
	COLOR_MESSAGE = '#f7ab42' #F4A460
	DEFAULT_CANVAS_WIDTH = 800
	DEFAULT_OBJECT_WIDTH = 120
	DEFAULT_OBJECT_HEIGHT = 40
	DEFAULT_FONT_FAMILY = 'Arial'
	DEFAULT_FONT_COLOR = '#000'
	DEFAULT_FONT_SIZE = 12
	ROW_HEIGHT = 48
	MARGIN = 10

	# Predefined values.
	@COLOR_OBJECT = [
		'#fdd9b4'
		'#bae0ec'
		'#c2e2c7'
		'#e5cff4'
		'#c9d1f7'
		'#f8cdd4'
	]

	# Globals variables.
	ctx = null
	objectWidth = null
	objectHeight = null
	fontFamily = null
	fontColor = null
	fontSize = null

	canvasElement = null
	sequenceData = null
	columnHeight = null
	columnWidth = null

	@renderAll = ->
		initVariables()

		canvasElements = document.getElementsByTagName 'canvas'

		for canvasElement in canvasElements
			if canvasElement.hasAttribute 'sequenced'
				renderCanvasElement canvasElement

	# Render a canvas element with sequence diagram data.
	@render = (canvasElementId) ->
		initVariables()

		canvasElement = document.getElementById canvasElementId

		renderCanvasElement canvasElement

	@setObjectSize = (width, height) ->
		objectWidth = width
		objectHeight = height

	@setFontFamily = (value) ->
		fontFamily = value

	@setFontColor = (value) ->
		fontColor = value

	@setFontSize = (value) ->
		fontSize = value

	renderCanvasElement = (canvasElement) ->
		sequenceData = DefinationParser.getSequenceData canvasElement

		initCanvas()

		drawObjects()
		drawMessages()

	initCanvas = ->
		columnHeight = objectHeight + ROW_HEIGHT * (sequenceData.maxRow + 2 / 3 - 1 / 2)
		columnWidth = (DEFAULT_CANVAS_WIDTH - objectWidth - MARGIN * 2) / (sequenceData.objectCount - 1)

		CanvasHelper.defineColumnWidth columnWidth

		width = parseInt canvasElement.width
		height = (columnHeight + MARGIN * 2) / DEFAULT_CANVAS_WIDTH * width
		scaleWidth = width * 2
		scaleHeight = height * 2
		scale = scaleWidth / DEFAULT_CANVAS_WIDTH

		# Set canvas element properties.
		canvasElement.style.width = width + 'px'
		canvasElement.style.height = height + 'px'
		canvasElement.width = scaleWidth
		canvasElement.height = scaleHeight

		# Set canvas drawing scale.
		ctx = canvasElement.getContext '2d'
		ctx.scale scale, scale

	initVariables = ->
		objectWidth = DEFAULT_OBJECT_WIDTH if objectWidth is null
		objectHeight = DEFAULT_OBJECT_HEIGHT if objectHeight is null
		fontFamily = DEFAULT_FONT_FAMILY if fontFamily is null
		fontColor = DEFAULT_FONT_COLOR if fontColor is null
		fontSize = DEFAULT_FONT_SIZE if fontSize is null

	# Render all objects.
	drawObjects = ->
		index = 0

		for objectKey of sequenceData.objects

			x = MARGIN + columnWidth * index++
			y = MARGIN

			object = sequenceData.objects[objectKey]

			drawObject x, y, objectWidth, objectHeight, objectKey, object

	# Render concrete object.
	drawObject = (x, y, width, height, objectName, object) ->
		# Get a color by index from inner color table.
		getObjectColor = (index) ->
			colorIndex = if index > 5 then index - 6 else index

			Sequenced.COLOR_OBJECT[colorIndex]

		# Draw lifeline.
		CanvasHelper.drawLifeline ctx, x + objectWidth / 2, y + objectHeight,
			ROW_HEIGHT * sequenceData.maxRow, '#fff', COLOR_LIFELINE

		# Draw activations.
		drawActivations(x, y, object)

		# Draw object.
		CanvasHelper.drawRoundedRect ctx, x, y, width, height,
			getObjectColor(object.id), COLOR_OBJECT_BORDER, 5

		# Draw object text.
		CanvasHelper.drawWrapText ctx, objectName, x + objectWidth / 2, y + (objectHeight) / 2 + fontSize / 3,
			objectWidth - 10, 'bold', fontSize, fontColor, fontFamily

	drawActivations = (x, y, object) ->
		for activation in object.activations
			activationY = if activation is 1 then MARGIN + objectHeight else MARGIN + objectHeight + ROW_HEIGHT * (activation - 5 / 6)
			activationHeight = if activation is 1 then ROW_HEIGHT * (1 + 1 / 6) else ROW_HEIGHT
			CanvasHelper.drawActivation ctx, x + objectWidth / 2, activationY,
				activationHeight, ROW_HEIGHT * sequenceData.maxRow, '#fff', COLOR_LIFELINE

	drawMessages = ->
		drawMessage message for message in sequenceData.messages

	drawMessage = (message) ->
		getColumnPositionX = (objectIndex) ->
			MARGIN + objectWidth / 2 + (DEFAULT_CANVAS_WIDTH - objectWidth - MARGIN * 2) / (sequenceData.objectCount - 1) * objectIndex

		y = ROW_HEIGHT * (message.row + 2 / 3)

		switch message.direction
			when 'self'
				x = getColumnPositionX(message.fromObjectIndex)

				CanvasHelper.drawSelfArrow ctx, x, y - ROW_HEIGHT * 3 / 8, y  + ROW_HEIGHT * 3 / 8, COLOR_MESSAGE,
					fontSize, fontColor, fontFamily, message.text, message.isDashed
			when 'right'
				x1 = getColumnPositionX(message.fromObjectIndex)
				x2 = getColumnPositionX(message.toObjectIndex)

				CanvasHelper.drawRightArrow ctx, x1, x2, y, COLOR_MESSAGE,
					fontSize, fontColor, fontFamily, message.text, message.isDashed
			when 'left'
				x1 = getColumnPositionX(message.toObjectIndex)
				x2 = getColumnPositionX(message.fromObjectIndex)

				CanvasHelper.drawLeftArrow ctx, x1, x2, y, COLOR_MESSAGE,
					fontSize, fontColor, fontFamily, message.text, message.isDashed

class CanvasHelper
	# Constants.
	LIFELINE_WIDTH = 8
	ACTIVATION_WIDTH = 12
	ARROW_HANDLE_HEIGHT = 8

	# Globals variables.
	colWidth = null

	@defineColumnWidth = (columnWidth) ->
		colWidth = columnWidth

	@drawRect = (ctx, x, y, width, height, color) ->
		ctx.fillStyle = color
		ctx.fillRect x, y, width, height

	@drawRoundedRect = (ctx, x, y, width, height, color, borderColor, radius) ->
		x += 0.5
		y += 0.5
		ctx.beginPath()
		ctx.arc x + radius, y + radius, radius, Math.PI, 1.5 * Math.PI
		ctx.lineTo x + width - 2 * radius, y
		ctx.arc x + width - radius, y + radius, radius, 1.5 * Math.PI, 2 * Math.PI
		ctx.lineTo x + width, y + height - radius
		ctx.arc x + width - radius, y + height - radius, radius, 0, 0.5 * Math.PI
		ctx.lineTo x + radius, y + height
		ctx.arc x + radius, y + height - radius, radius, 0.5 * Math.PI, Math.PI
		ctx.lineTo x, y + radius
		ctx.closePath()
		ctx.fillStyle = color
		ctx.fill();
		ctx.lineWidth = 1;
		ctx.strokeStyle = borderColor;
		ctx.stroke();

	@drawRightArrow = (ctx, x1, x2, y, color, fontSize, fontColor, fontFamily, text, isDashed) ->
		if isDashed
			ctx.setLineDash [ARROW_HANDLE_HEIGHT, ARROW_HANDLE_HEIGHT] # A "- - - - " dashed line.
		else
			ctx.setLineDash [1, 0]

		x1 = x1 + ACTIVATION_WIDTH - LIFELINE_WIDTH / 2
		x2 = x2 - ACTIVATION_WIDTH + LIFELINE_WIDTH / 2

		# Arrow handle.
		ctx.beginPath()
		ctx.moveTo x2 - ARROW_HANDLE_HEIGHT, y
		ctx.lineTo x1, y
		ctx.lineDashOffset = ARROW_HANDLE_HEIGHT / 3
		ctx.strokeStyle = color
		ctx.lineWidth = ARROW_HANDLE_HEIGHT
		ctx.stroke()
		ctx.setLineDash [1, 0] # Restore to solid line.

		# Arrow.
		ctx.beginPath()
		ctx.moveTo x2 - ARROW_HANDLE_HEIGHT, y - ARROW_HANDLE_HEIGHT
		ctx.lineTo x2, y
		ctx.lineTo x2 - ARROW_HANDLE_HEIGHT, y + ARROW_HANDLE_HEIGHT
		ctx.closePath()
		ctx.fillStyle = color
		ctx.fill();

		@drawWrapText ctx, text, (x1 + x2) / 2, y - fontSize, x2 - x1 - fontSize,
			'normal', fontSize, fontColor, fontFamily, 'center', true

	@drawLeftArrow = (ctx, x1, x2, y, color, fontSize, fontColor, fontFamily, text, isDashed) ->
		if isDashed
			ctx.setLineDash [ARROW_HANDLE_HEIGHT, ARROW_HANDLE_HEIGHT] # A "- - - - " dashed line.
		else
			ctx.setLineDash [1, 0]

		x1 = x1 + ACTIVATION_WIDTH - LIFELINE_WIDTH / 2
		x2 = x2 - ACTIVATION_WIDTH + LIFELINE_WIDTH / 2

		# Arrow handle.
		ctx.beginPath()
		ctx.moveTo x1 + ARROW_HANDLE_HEIGHT, y
		ctx.lineTo x2, y
		ctx.lineDashOffset = ARROW_HANDLE_HEIGHT / 3
		ctx.strokeStyle = color
		ctx.lineWidth = ARROW_HANDLE_HEIGHT
		ctx.stroke()
		ctx.setLineDash [1, 0] # Restore to solid line.

		ctx.beginPath()
		ctx.lineTo x1 + ARROW_HANDLE_HEIGHT, y - ARROW_HANDLE_HEIGHT
		ctx.lineTo x1, y
		ctx.lineTo x1 + ARROW_HANDLE_HEIGHT, y + ARROW_HANDLE_HEIGHT
		ctx.closePath()
		ctx.fillStyle = color
		ctx.fill()

		@drawWrapText ctx, text, (x1 + x2) / 2, y - fontSize, x2 - x1 - fontSize,
			'normal', fontSize, fontColor, fontFamily, 'center', true

	@drawSelfArrow = (ctx, x, y1, y2, color, fontSize, fontColor, fontFamily, text, isDashed) ->
		if isDashed
			ctx.setLineDash [ARROW_HANDLE_HEIGHT, ARROW_HANDLE_HEIGHT] # A "- - - - " dashed line.
		else
			ctx.setLineDash [1, 0]

		x = x + ACTIVATION_WIDTH - LIFELINE_WIDTH / 2
		y1 = y1 + ARROW_HANDLE_HEIGHT / 2
		y2 = y2 - ARROW_HANDLE_HEIGHT / 2
		radius = (y2 - y1) / 2

		# Arrow handle.
		ctx.beginPath()
		ctx.moveTo x, y1
		ctx.lineTo x + ARROW_HANDLE_HEIGHT, y1
		ctx.arc x + ARROW_HANDLE_HEIGHT, y1 + radius, radius, 1.5 * Math.PI, 0.5 * Math.PI, false
		ctx.lineDashOffset = 2
		ctx.strokeStyle = color
		ctx.lineWidth = ARROW_HANDLE_HEIGHT
		ctx.stroke()
		ctx.setLineDash [1, 0] # Restore to solid line.

		ctx.beginPath()
		ctx.lineTo x + ARROW_HANDLE_HEIGHT, y2 - ARROW_HANDLE_HEIGHT
		ctx.lineTo x, y2
		ctx.lineTo x + ARROW_HANDLE_HEIGHT, y2 + ARROW_HANDLE_HEIGHT
		ctx.closePath()
		ctx.fillStyle = color
		ctx.fill()

		@drawWrapText ctx, text, x + ARROW_HANDLE_HEIGHT * 2 + radius, (y1 + y2) / 2 + fontSize / 2, colWidth - radius - ARROW_HANDLE_HEIGHT * 2 - fontSize,
			'normal', fontSize, fontColor, fontFamily, 'left'

	@drawLifeline = (ctx, x, y, height, startColor, stopColor) ->
		gradient = ctx.createLinearGradient(0, 0, 0, height);
		gradient.addColorStop(0, startColor);
		gradient.addColorStop(1, stopColor);

		ctx.beginPath()
		ctx.moveTo x, y + height
		ctx.lineTo x, y
		ctx.setLineDash [LIFELINE_WIDTH * 2, LIFELINE_WIDTH] # A "-- -- -- -- " dashed line.
		ctx.strokeStyle = gradient
		ctx.lineWidth = LIFELINE_WIDTH
		ctx.stroke()
		ctx.setLineDash [1, 0] # Restore to solid line.

	@drawActivation = (ctx, x, y, height, lifeLineHeight, startColor, stopColor) ->
		gradient = ctx.createLinearGradient(0, 0, 0, lifeLineHeight);
		gradient.addColorStop(0, startColor);
		gradient.addColorStop(1, stopColor);

		ctx.beginPath()
		ctx.moveTo x, y + height
		ctx.lineTo x, y
		ctx.strokeStyle = gradient
		ctx.lineWidth = ACTIVATION_WIDTH
		ctx.stroke()

	@drawWrapText = (ctx, text, x, y, maxWidth, fontWeight, fontSize, fontColor, fontFamily, textAlign, isDoubleLine) ->
		ctx.font = "#{fontWeight} #{fontSize}px #{fontFamily}"
		ctx.textAlign = if textAlign then textAlign else 'center'
		ctx.fillStyle = fontColor

		x += fontSize * 1 / 3
		splitter = if /\\n/.test(text) then '\\n' else ' '
		words = text.split splitter
		line = ''
		yd = 0
		if isDoubleLine
			lineHeight = ARROW_HANDLE_HEIGHT * 2 + fontSize * 2
		else
			lineHeight = fontSize * 1.2

		for i in [0...words.length]
			testLine = line + words[i] + ' '
			testWidth = ctx.measureText(testLine).width

			if (testWidth > maxWidth and i > 0)
				yd = fontSize / 2
				if isDoubleLine
					ctx.fillText line, x, y
				else
					ctx.fillText line, x, y - yd
				line = words[i] + ' '
				y += lineHeight
			else
				line = testLine;

		ctx.fillText line, x, y - yd

class DefinationParser
	@getSequenceData = (element) ->
		getInnerText = (element) ->
			if element.childNodes.length is 0
				''
			else
				element.childNodes[0].nodeValue

		addActivation = (objectKey, row) ->
			object = sequenceData.objects[objectKey]

			if object.activations.length is 0
				object.activations.push row
			else if object.activations[object.activations.length - 1] isnt row
				object.activations.push row

		regex = /(.+\b) *(-->|->) *(.+\b) *: *(.+)\n?/gm

		sequenceData = {
			objects: {}
			objectCount: 0
			messages: []
			maxRow: 0
		}

		innerText = getInnerText element

		objectIndex = 0

		while match = regex.exec(innerText)
			objectFrom = match[1].trim()
			messageType = match[2].trim()
			objectTo = match[3].trim()
			text = match[4].trim()

			if sequenceData.objects[objectFrom] is undefined
				sequenceData.objects[objectFrom] = {
					'id': objectIndex
					'activations': []
				}
				objectIndex++

			if sequenceData.objects[objectTo] is undefined
				sequenceData.objects[objectTo] = {
					'id': objectIndex
					'activations': []
				}
				objectIndex++

			fromObjectIndex = sequenceData.objects[objectFrom].id
			toObjectIndex = sequenceData.objects[objectTo].id

			if objectFrom is objectTo
				direction = 'self'
			else if fromObjectIndex > toObjectIndex
				direction = 'left'
			else
				direction = 'right'

			if sequenceData.messages.length is 0
				row = 1
			else
				preMessage = sequenceData.messages[sequenceData.messages.length - 1]

				if fromObjectIndex is preMessage.toObjectIndex and
					direction is preMessage.direction and
					preMessage.direction is not 'self'
				then row = preMessage.row
				else row = preMessage.row + 1

			addActivation objectFrom, row
			addActivation objectTo, row

			sequenceData.messages.push
				'text': text
				'direction': direction
				'fromObjectIndex': fromObjectIndex
				'toObjectIndex': toObjectIndex
				'isDashed': /--/.test messageType
				'row': row

			sequenceData.objectCount = objectIndex
			sequenceData.maxRow = row

		return sequenceData
