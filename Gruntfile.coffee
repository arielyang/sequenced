module.exports = (grunt) ->

	# Project configuration.
	grunt.initConfig
		pkg: grunt.file.readJSON('package.json')
		# Task configuration.
		exec:
			compile:
				command: 'coffee -c -b dest/sequenced.coffee'
				cwd: '.'

		concat:
			dist:
				src: [
					'lib/sequenced.coffee'
					'lib/canvasHelper.coffee'
					'lib/definationParser.coffee'
				]
				dest: 'dest/sequenced.coffee'

		uglify:
			compress:
				options:
					mangle: true
				target:
					files:
						'dest/sequenced.min.js': ['lib/sequenced.js']

		watch:
			build:
				options:
					spawn: false
					livereload: true
				files: [
					'lib/*'
					'test/*'
				]
				tasks: [
					'concat:dist'
					'exec:compile'
				]

		connect:
			server:
				options:
					keepalive: true
					port: 8080
					base: '.'

	# These plugins provide necessary tasks.
	grunt.loadNpmTasks 'grunt-contrib-concat'
	grunt.loadNpmTasks 'grunt-contrib-connect'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-exec'

	# Serve a static HTTP server.
	grunt.registerTask 'server', [
		'connect:server'
	]

	# Build coffee file to js file.
	grunt.registerTask 'monitor', [
		'concat:dist'
		'exec:compile'
		'watch:build'
	]

	# Uglify and compress dest js file.
	grunt.registerTask 'compress', [
		'uglify:compress'
	]