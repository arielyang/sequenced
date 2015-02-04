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
