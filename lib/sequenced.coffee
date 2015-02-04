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
