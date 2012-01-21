class DirView < NSTableView
	attr_accessor :on_key_down

	#override
	def keyDown(event)
		#NSLog event.characters.inspect
		characters = event.characters
		character = characters.characterAtIndex(0)
		#NSLog "#{character}"
		if (event.modifierFlags & NSCommandKeyMask) == NSCommandKeyMask
			NSLog "Cmd + #{character}"
		elsif (event.modifierFlags & NSShiftKeyMask) == NSShiftKeyMask
			NSLog "Shift + #{character}"
		elsif (event.modifierFlags & NSControlKeyMask) == NSControlKeyMask
			NSLog "Ctrl + #{character}"
		elsif (event.modifierFlags & NSAlternateKeyMask) == NSAlternateKeyMask
			NSLog "Alt + #{character}"
		elsif (event.modifierFlags & NSFunctionKeyMask) == NSFunctionKeyMask
			NSLog "F + #{character}"
		else
			NSLog "#{character}"
		end

		self.on_key_down.call(character, event.modifierFlags, self.selectedRow)
		super
	end

	def becomeFirstResponder
		@focus = true
		super
	end

	def resignFirstResponder
		@focus = false
		super
	end

	def has_focus
		@focus
	end
end