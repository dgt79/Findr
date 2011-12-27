class Animations
	# Utility function for a common ObjC pattern of 'create, then call several setters'
	def self.mass_assign(obj, params)
		obj.tap do |object|
			params.keys.each do |key|
				msg = "#{key}="
				object.send(msg, params[key])
			end
		end
	end

	# Establish a fade-in and fade-out animation (color is set in the layer below)
	def self.yellow_fade(sender, view)
		rowIndex = sender.clickedRow
		cellFrame = view.rectOfRow(rowIndex)

		layer = CALayer.layer
		layer.delegate = self
		yellowFadeView = mass_assign(NSView.alloc.init, wantsLayer:true, frame:cellFrame, layer:layer, alphaValue:0.0)
		layer.setNeedsDisplay
		sender.addSubview(yellowFadeView)

		# Fade from 0 alpha (invisible) to opaque
		fadeIn  = mass_assign(CABasicAnimation.animationWithKeyPath("alphaValue"), beginTime:0.0, fromValue:0.0, toValue:1.0, duration:0.25)
		# Fade from opaque back to 0 alpha
		fadeOut = mass_assign(CABasicAnimation.animationWithKeyPath("alphaValue"), beginTime:0.25, fromValue:1.0, toValue:0.0, duration:0.25)

		# Pair the animations together
		yfa = mass_assign(CAAnimationGroup.animation, delegate:self, animations:[fadeIn, fadeOut], duration:2.0)

		yellowFadeView.animations = {"frameOrigin" => yfa}
		# Start the animation
		yellowFadeView.animator.frame = yellowFadeView.frame
	end

	# Utility function to extract the RGBA values from a color
	def self.split_color(color)
		r = Pointer.new(:double)
		g = Pointer.new(:double)
		b = Pointer.new(:double)
		a = Pointer.new(:double)
		color.getRed(r, green:g, blue:b, alpha:a)

		[r[0], g[0], b[0], a[0]]
	end

	# This draws a simple layer of a yellow outline, with a translucent yellow interior.
	# This layer is then faded in and out by the animation above.
	def self.drawLayer(layer, inContext:ctx)
	radius = 4
	nsGC = NSGraphicsContext.graphicsContextWithGraphicsPort(ctx, flipped:false)
	NSGraphicsContext.saveGraphicsState
	NSGraphicsContext.currentContext = nsGC

	aRect = layer.frame
	rect = NSMakeRect(aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height)

	# Solid outside line
	NSBezierPath.defaultLineWidth = 2
	highlightPath = NSBezierPath.bezierPathWithRoundedRect(rect, xRadius:radius, yRadius:radius)
	NSColor.yellowColor.set
	highlightPath.stroke

	# Translucent inner filled rounded rectangle
	r, g, b, a = split_color(NSColor.cyanColor)
	transparentYellow = NSColor.colorWithCalibratedRed(r, green:g, blue:b, alpha:0.5)
	fillPath = NSBezierPath.bezierPathWithRoundedRect(rect, xRadius:radius, yRadius:radius)
	transparentYellow.set
	fillPath.fill

	NSGraphicsContext.restoreGraphicsState
	end
end