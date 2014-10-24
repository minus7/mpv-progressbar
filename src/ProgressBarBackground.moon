class ProgressBarBackground extends Rect

	new: ( @animationQueue ) =>
		super 0, 0, 0, 0

		@line = {
			[[{\an1\bord0\c&H2D2D2D&\p1\pos(]]
			0
			[[)\fscy]]
			100
			[[}m 0 0 l ]]
			0
		}

		@hovered = false
		@needsUpdate = false
		@animationCb = @\animateHeight
		@heightAnimation = Animation 100, 400, 0.25, @animationCb

	__tostring: =>
		return table.concat @line

	updateSize: ( w, h ) =>
		@y = h - hover_zone*bar_height
		@w, @h = w, hover_zone*bar_height

		@line[2] = [[%d,%d]]\format 0, h
		@line[6] = [[%d 0 %d %d 0 %d]]\format w, w, bar_height, bar_height
		return true

	animateHeight: ( animation, value ) =>
		@line[4] = ([[%g]])\format value
		@needsUpdate = true

	update: ( mouseX, mouseY ) =>
		update = @needsUpdate
		if @containsPoint mouseX, mouseY
			unless @hovered
				update = true
				@hovered = true
				@heightAnimation\interrupt false, @animationQueue
		else
			if @hovered
				update = true
				@hovered = false
				@heightAnimation\interrupt true, @animationQueue

		@needsUpdate = false
		return update
