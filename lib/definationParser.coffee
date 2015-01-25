class DefinationParser
	@getSequenceData = (element) ->
		getInnerText = (element) ->
			if element.childNodes.length is 0
				''
			else
				element.childNodes[0].nodeValue

		regex = /(.+\b)\s*(-->|->|<--|<-)\s*(.+\b)\s*:\s*(.+)\n?/gm

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

			if objectFrom is objectTo
				direction = 'self'
			else if messageType[0] is '<'
				direction = 'left'
			else
				direction = 'right'

			if sequenceData.objects[objectFrom] is undefined
				sequenceData.objects[objectFrom] = objectIndex
				objectIndex++

			if sequenceData.objects[objectTo] is undefined
				sequenceData.objects[objectTo] = objectIndex
				objectIndex++

			fromObjectIndex = sequenceData.objects[objectFrom]
			toObjectIndex = sequenceData.objects[objectTo]

			if sequenceData.messages.length is 0
				row = 1
			else
				preMessage = sequenceData.messages[sequenceData.messages.length - 1]

				if preMessage.direction is 'self'
					row = preMessage.row + 2
				else if fromObjectIndex is preMessage.toObjectIndex and direction is preMessage.direction
					row = preMessage.row
				else
					row = preMessage.row + 1

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
