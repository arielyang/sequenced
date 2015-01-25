class Sequenced
	# Globals variables.
	ctx = null
	objectWidth = null
	objectHeight = null
	lineHeight = null
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
	DefaultObjectHeight = 50
	DefualtLineHeight = 18
	DefaultFontFamily = 'Verdana'
	DefaultFontColor = '#000'
	DefaultFontSize = 14
	MaxObjectWidth = 150
	RowHeight = 50
	Margin = 10

	# Predefined values.
	@COLOR_OBJECT = [
		'#fdd9b4'
		'#bae0ec'
		'#c2e2c7'
		'#c9d1f7'
		'#e5cff4'
		'#f8cdd4'
	]

	# Render a canvas element with sequence diagram data.
	@render = (canvasElementId) ->
		canvasElement = document.getElementById canvasElementId

		sequenceData = DefinationParser.getSequenceData canvasElement

		#initSequenceData()
		initCanvas()
		initVariables()

		drawObjects()
		drawMessages()

	@setLineHeight = (height) ->
		lineHeight = height

	@setObjectSize = (width, height) ->
		objectWidth = width
		objectHeight = height

	@setFontFamily = (value) ->
		fontFamily = value

	@setFontColor = (value) ->
		fontColor = value

	@setFontSize = (value) ->
		fontSize = value

	initSequenceData = ->
		# Initialize object index.
		objectIndex = 0
		objectDictionary = {}

		for object in sequenceData.objects
			object.index = objectIndex++
			objectDictionary[object.id] = object.index

		# Initialize max row count and message index.
		maxRow = 1
		#messageIndex = 0

		for message in sequenceData.messages
			#message.index = messageIndex++
			message.fromObjectIndex = objectDictionary[message.from]
			message.toObjectIndex = objectDictionary[message.to]
			maxRow = message.row if message.row > maxRow

		sequenceData.maxRow = maxRow

	initCanvas = ->
		columHeight = RowHeight * (sequenceData.maxRow + 1.5)

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
		lineHeight = DefualtLineHeight if lineHeight is null
		fontFamily = DefaultFontFamily if fontFamily is null
		fontColor = DefaultFontColor if fontColor is null
		fontSize = DefaultFontSize if fontSize is null

	# Render all objects.
	drawObjects = ->
		index = 0

		for objectKey of sequenceData.objects

			x = Margin + (DefaultCanvasWidth - objectWidth - Margin * 2) / (sequenceData.objectCount - 1) * index++
			y = Margin

			drawObject x, y, objectWidth, objectHeight, objectKey, sequenceData.objects[objectKey]

	# Render concrete object.
	drawObject = (x, y, width, height, objectName, objectIndex) ->
		# Get a color by index from inner color table.
		getObjectColor = (index) ->
			colorIndex = if index > 5 then index - 6 else index

			Sequenced.COLOR_OBJECT[colorIndex]

		# Draw lifeline.
		CanvasHelper.drawLifeline ctx, x + objectWidth / 2, y + objectHeight,
			canvasElement.height / 2 - Margin * 2 - objectHeight, '#fff', COLOR_LIFELINE

		# Draw object.
		CanvasHelper.drawRoundedRect ctx, x, y, width, height,
			getObjectColor(objectIndex), COLOR_OBJECT_BORDER, 5

		# Draw object text.
		CanvasHelper.drawWrapText ctx, objectName, x + objectWidth / 2, y + (objectHeight) / 2 + fontSize / 3,
			objectWidth - 10, 'bold', fontSize, fontColor, fontFamily

	drawMessages = ->
		drawMessage message for message in sequenceData.messages

		console.log sequenceData.messages

	drawMessage = (message) ->
		getColumnPositionX = (objectIndex) ->
			Margin + objectWidth / 2 + (DefaultCanvasWidth - objectWidth - Margin * 2) / (sequenceData.objectCount - 1) * objectIndex

		y = RowHeight * (message.row + 1)

		switch message.direction
			when 'self'
				x = getColumnPositionX(message.fromObjectIndex)

				CanvasHelper.drawSelfArrow ctx, x, y, COLOR_MESSAGE,
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
