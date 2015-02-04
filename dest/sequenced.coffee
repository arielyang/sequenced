class Sequenced
	# Globals variables.
	ctx = null
	objectWidth = null
	objectHeight = null
	fontFamily = null
	fontColor = null
	fontSize = null

	canvasElement = null
	sequenceData = null
	columHeight = null

	# Constants.
	COLOR_OBJECT_BORDER = '#c0c0c0' #C0C0C0
	COLOR_LIFELINE = '#80aada' #87CEFA
	COLOR_MESSAGE = '#f7ab42' #F4A460
	DefaultCanvasWidth = 800
	DefaultObjectWidth = 120
	DefaultObjectHeight = 40
	DefaultFontFamily = 'Arial'
	DefaultFontColor = '#000'
	DefaultFontSize = 12
	MaxObjectWidth = 100
	RowHeight = 48
	Margin = 10

	# Predefined values.
	@COLOR_OBJECT = [
		'#fdd9b4'
		'#bae0ec'
		'#c2e2c7'
		'#e5cff4'
		'#c9d1f7'
		'#f8cdd4'
	]

	@renderAll = ->
		canvasElements = document.getElementsByTagName 'canvas'

		for canvasElement in canvasElements
			if canvasElement.hasAttribute 'sequenced'
				renderCanvasElement canvasElement

	# Render a canvas element with sequence diagram data.
	@render = (canvasElementId) ->
		canvasElement = document.getElementById canvasElementId

		renderCanvasElement(canvasElement)

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

		initVariables()
		initCanvas()

		drawObjects()
		drawMessages()

	initCanvas = ->
		columHeight = objectHeight + RowHeight * (sequenceData.maxRow + 2 / 3 - 1 / 2)

		width = parseInt canvasElement.width
		height = (columHeight + Margin * 2) / DefaultCanvasWidth * width
		scaleWidth = width * 2
		scaleHeight = height * 2
		scale = scaleWidth / DefaultCanvasWidth

		# Set canvas element properties.
		canvasElement.style.width = width + 'px'
		canvasElement.style.height = height + 'px'
		canvasElement.width = scaleWidth
		canvasElement.height = scaleHeight

		# Set canvas drawing scale.
		ctx = canvasElement.getContext '2d'
		ctx.scale scale, scale

	initVariables = ->
		objectWidth = DefaultObjectWidth if objectWidth is null
		objectHeight = DefaultObjectHeight if objectHeight is null
		fontFamily = DefaultFontFamily if fontFamily is null
		fontColor = DefaultFontColor if fontColor is null
		fontSize = DefaultFontSize if fontSize is null

	# Render all objects.
	drawObjects = ->
		index = 0

		for objectKey of sequenceData.objects

			x = Margin + (DefaultCanvasWidth - objectWidth - Margin * 2) / (sequenceData.objectCount - 1) * index++
			y = Margin

			object = sequenceData.objects[objectKey]

			drawObject x, y, objectWidth, objectHeight, objectKey, object

	# Render concrete object.
	drawObject = (x, y, width, height, objectName, object) ->
		# Get a color by index from inner color table.
		getObjectColor = (index) ->
			colorIndex = if index > 5 then index - 6 else index

			Sequenced.COLOR_OBJECT[colorIndex]

		# Draw lifeline.
		# CanvasHelper.drawLifeline ctx, x + objectWidth / 2, y + objectHeight,
		# 	canvasElement.height / 2 - Margin * 2 - objectHeight, '#fff', COLOR_LIFELINE

		CanvasHelper.drawLifeline ctx, x + objectWidth / 2, y + objectHeight,
			RowHeight * sequenceData.maxRow, '#fff', COLOR_LIFELINE

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
			activationY = if activation is 1 then Margin + objectHeight else Margin + objectHeight + RowHeight * (activation - 5 / 6)
			activationHeight = if activation is 1 then RowHeight * (1 + 1 / 6) else RowHeight
			CanvasHelper.drawActivation ctx, x + objectWidth / 2, activationY,
				activationHeight, RowHeight * sequenceData.maxRow, '#fff', COLOR_LIFELINE

	drawMessages = ->
		drawMessage message for message in sequenceData.messages

	drawMessage = (message) ->
		getColumnPositionX = (objectIndex) ->
			Margin + objectWidth / 2 + (DefaultCanvasWidth - objectWidth - Margin * 2) / (sequenceData.objectCount - 1) * objectIndex

		y = RowHeight * (message.row + 2 / 3)

		switch message.direction
			when 'self'
				x = getColumnPositionX(message.fromObjectIndex)

				CanvasHelper.drawSelfArrow ctx, x, y - RowHeight * 3 / 8, y  + RowHeight * 3 / 8, COLOR_MESSAGE,
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
	# Inner Constants.
	LifelineWidth = 8
	ActivationWidth = 12
	ArrowHandleHeight = 8

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
			ctx.setLineDash [ArrowHandleHeight, ArrowHandleHeight] # A "- - - - " dashed line.
		else
			ctx.setLineDash [1, 0]

		x1 = x1 + ActivationWidth - LifelineWidth / 2
		x2 = x2 - ActivationWidth + LifelineWidth / 2

		# Arrow handle.
		ctx.beginPath()
		ctx.moveTo x2 - ArrowHandleHeight, y
		ctx.lineTo x1, y
		ctx.lineDashOffset = ArrowHandleHeight / 3
		ctx.strokeStyle = color
		ctx.lineWidth = ArrowHandleHeight
		ctx.stroke()
		ctx.setLineDash [1, 0] # Restore to solid line.

		# Arrow.
		ctx.beginPath()
		ctx.moveTo x2 - ArrowHandleHeight, y - ArrowHandleHeight
		ctx.lineTo x2, y
		ctx.lineTo x2 - ArrowHandleHeight, y + ArrowHandleHeight
		ctx.closePath()
		ctx.fillStyle = color
		ctx.fill();

		ctx.fillStyle = '#fff'
		ctx.fillRect x1, y - ArrowHandleHeight * 1.8 - fontSize, x2 - x1 - ArrowHandleHeight, ArrowHandleHeight * 2.8

		@drawWrapText ctx, text, (x1 + x2) / 2, y - fontSize, x2 - x1 - fontSize,
			'normal', fontSize, fontColor, fontFamily, 'center', true

		# @drawWrapText ctx, text, (x1 + x2) / 2, y + fontSize + ArrowHandleHeight, x2 - x1 - fontSize,
		# 	'normal', fontSize, fontColor, fontFamily, 'center', true

	@drawLeftArrow = (ctx, x1, x2, y, color, fontSize, fontColor, fontFamily, text, isDashed) ->
		if isDashed
			ctx.setLineDash [ArrowHandleHeight, ArrowHandleHeight] # A "- - - - " dashed line.
		else
			ctx.setLineDash [1, 0]

		x1 = x1 + ActivationWidth - LifelineWidth / 2
		x2 = x2 - ActivationWidth + LifelineWidth / 2

		# Arrow handle.
		ctx.beginPath()
		ctx.moveTo x1 + ArrowHandleHeight, y
		ctx.lineTo x2, y
		ctx.lineDashOffset = ArrowHandleHeight / 3
		ctx.strokeStyle = color
		ctx.lineWidth = ArrowHandleHeight
		ctx.stroke()
		ctx.setLineDash [1, 0] # Restore to solid line.

		ctx.beginPath()
		ctx.lineTo x1 + ArrowHandleHeight, y - ArrowHandleHeight
		ctx.lineTo x1, y
		ctx.lineTo x1 + ArrowHandleHeight, y + ArrowHandleHeight
		ctx.closePath()
		ctx.fillStyle = color
		ctx.fill()

		ctx.fillStyle = '#fff'
		ctx.fillRect x1 + ArrowHandleHeight, y - ArrowHandleHeight * 1.8 - fontSize, x2 - x1 - ArrowHandleHeight, ArrowHandleHeight * 2.8

		@drawWrapText ctx, text, (x1 + x2) / 2, y - fontSize, x2 - x1 - fontSize,
			'normal', fontSize, fontColor, fontFamily, 'center', true

		# @drawWrapText ctx, text, (x1 + x2) / 2, y + fontSize + ArrowHandleHeight, x2 - x1 - fontSize,
		# 	'normal', fontSize, fontColor, fontFamily, 'center', true

	@drawSelfArrow = (ctx, x, y1, y2, color, fontSize, fontColor, fontFamily, text, isDashed) ->
		if isDashed
			ctx.setLineDash [ArrowHandleHeight, ArrowHandleHeight] # A "- - - - " dashed line.
		else
			ctx.setLineDash [1, 0]

		x = x + ActivationWidth - LifelineWidth / 2
		y1 = y1 + ArrowHandleHeight / 2
		y2 = y2 - ArrowHandleHeight / 2
		radius = (y2 - y1) / 2

		# Arrow handle.
		ctx.beginPath()
		ctx.moveTo x, y1
		ctx.lineTo x + ArrowHandleHeight, y1
		ctx.arc x + ArrowHandleHeight, y1 + radius, radius, 1.5 * Math.PI, 0.5 * Math.PI, false
		ctx.lineDashOffset = 2
		ctx.strokeStyle = color
		ctx.lineWidth = ArrowHandleHeight
		ctx.stroke()
		ctx.setLineDash [1, 0] # Restore to solid line.

		ctx.beginPath()
		ctx.lineTo x + ArrowHandleHeight, y2 - ArrowHandleHeight
		ctx.lineTo x, y2
		ctx.lineTo x + ArrowHandleHeight, y2 + ArrowHandleHeight
		ctx.closePath()
		ctx.fillStyle = color
		ctx.fill()

		@drawWrapText ctx, text, x + ArrowHandleHeight * 2 + radius, (y1 + y2) / 2 + fontSize / 2, 200 - fontSize,
			'normal', fontSize, fontColor, fontFamily, 'left'

	@drawLifeline = (ctx, x, y, height, startColor, stopColor) ->
		gradient = ctx.createLinearGradient(0, 0, 0, height);
		gradient.addColorStop(0, startColor);
		gradient.addColorStop(1, stopColor);

		ctx.beginPath()
		ctx.moveTo x, y + height
		ctx.lineTo x, y
		ctx.setLineDash [LifelineWidth * 2, LifelineWidth] # A "-- -- -- -- " dashed line.
		ctx.strokeStyle = gradient
		ctx.lineWidth = LifelineWidth
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
		ctx.lineWidth = ActivationWidth
		ctx.stroke()

	@drawWrapText = (ctx, text, x, y, maxWidth, fontWeight, fontSize, fontColor, fontFamily, textAlign, isDoubleLine) ->
		ctx.font = "#{fontWeight} #{fontSize}px #{fontFamily}"
		ctx.textAlign = if textAlign then textAlign else 'center'
		ctx.fillStyle = fontColor

		x += fontSize * 1 / 3
		words = text.split ' '
		line = ''
		yd = 0
		lineHeight = fontSize * 1.2

		for i in [0...words.length]
			testLine = line + words[i] + ' '
			testWidth = ctx.measureText(testLine).width

			if (testWidth > maxWidth and i > 0)
				yd = fontSize / 2
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
