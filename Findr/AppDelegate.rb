class AppDelegate
    attr_accessor :window
    attr_accessor :table_view, :path_label
    attr_accessor :path, :files

    def initialize
	    NSLog 'init AppDelagate'
	    @file_controller = FileController.new
        @path = '/'
	    @files = @file_controller.get_files @path
    end

    def applicationDidFinishLaunching(a_notification)
        NSLog "Howdy!"
	    @path_label.stringValue = @path

	    @table_view.instance_eval {
		    def on_key_down=(on_key_down)
			    @on_key_down = on_key_down
		    end

		    def on_key_down
			    @on_key_down
		    end

		    alias old_key_down keyDown

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
			    else
				end

			    self.on_key_down.call(character, self.selectedRow)
			    old_key_down(event)
		    end

		    def acceptsFirstResponder
			    true
		    end
	    }

	    @table_view.on_key_down = lambda {|key, row|
		    if key == 13
		        open_path files[row].path
			    true
			elsif key == 127
				open_path files[0].path
			    true
			end
		    false
	    }
    end

	def awakeFromNib
		self.table_view.doubleAction = 'double_click:'
	end

	def double_click(sender)
		#Animations.yellow_fade(sender, table_view)
		NSLog "open dir #{files[sender.clickedRow].path}"
		open_path files[sender.clickedRow].path
	end

	def open_path(path)
		@path = path
		@files = @file_controller.get_files @path
		@path_label.stringValue = @path
		self.table_view.reloadData
		indexes = NSIndexSet.alloc.initWithIndex(0)
		self.table_view.selectRowIndexes(indexes, byExtendingSelection:false)
	end
end

