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
