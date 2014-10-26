class OSDAggregator

	new: =>
		@script = { }
		@subscribers = { }
		@subscriberCount = 0
		@w = 0
		@h = 0

		redrawFrequency = 0.05
		@updateTimer = mp.add_periodic_timer 2, @\updateDisplaySize
		@updateTimer = mp.add_periodic_timer redrawFrequency, @\update
		mp.observe_property 'fullscreen', 'bool', @\badFullscreenHack
		-- mp.observe_property 'pause', 'bool', @\pause
		mp.register_event 'seek', @\forceUpdate
		mp.register_event 'shutdown', ->
			@updateTimer\kill!

	setDisplaySize: ( w, h ) =>
		needsRedraw = false
		if w != @w or h != @h
			@w, @h = w, h
			for sub = 1, @subscriberCount
				theSub = @subscribers[sub]
				if theSub\updateSize w, h
					needsRedraw = true
					@script[sub] = tostring theSub

		if true == needsRedraw
			@forceUpdate!

	-- The fullscreen change property gets called before the display size
	-- is actually updated, so we need to wait some small amount of time
	-- before actually setting the new display size. 100ms appears
	-- to work reliably here.
	badFullscreenHack: =>
		mp.add_timeout 0.1, ->
			@setDisplaySize mp.get_screen_size!

	updateDisplaySize: =>
		@setDisplaySize mp.get_screen_size!

	addSubscriber: ( subscriber ) =>
		return if not subscriber
		@subscriberCount += 1
		subscriber.aggregatorIndex = @subscriberCount
		@subscribers[@subscriberCount] = subscriber
		@script[@subscriberCount] = tostring subscriber

	removeSubscriber: ( index ) =>
		for i = index+1, @subscriberCount
			@subscribers[i].aggregatorIndex -= 1

		table.remove @subscribers, index
		table.remove @script, index

		@subscriberCount -= 1

	update: ( force = false ) =>
		needsRedraw = force
		x, y = mp.get_mouse_pos!
		for sub = 1, @subscriberCount
			theSub = @subscribers[sub]
			if theSub\update x, y
				needsRedraw = true
				@script[sub] = tostring theSub

		if true == needsRedraw
			mp.set_osd_ass @w, @h, table.concat @script, '\n'

	pause: ( event, @paused ) =>
		if @paused
			@updateTimer\stop!
		else
			@updateTimer\resume!

	forceUpdate: =>
		@updateTimer\kill!
		@update true
		unless @paused
			@updateTimer\resume!
