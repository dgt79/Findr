class AppDelegate
    attr_accessor :window, :split_panel, :show_hidden_menu_item
    attr_accessor :left_path, :left_path_label, :left_dir_files, :left_dir_view
    attr_accessor :right_path, :right_path_label, :right_dir_files, :right_dir_view

    def initialize
	    NSLog 'init AppDelagate'
	    @file_controller = FileController.new
        @left_path = '/'
	    @left_dir_files = @file_controller.get_files @left_path
	    @right_path = '/'
	    @right_dir_files = @file_controller.get_files @right_path

	    @on_the_left_side = lambda {|path|
		    old_path = @left_path
		    @left_path = path
		    show_hidden_flag = @show_hidden_menu_item.state == NSOnState
		    @left_dir_files = @file_controller.get_files @left_path, show_hidden_flag
		    @left_path_label.stringValue = @left_path
		    self.left_dir_view.reloadData
		    index = 0
		    index = @left_dir_files.index {|x| x.path == old_path} if old_path[path]
		    indexes = NSIndexSet.alloc.initWithIndex(index)
		    self.left_dir_view.selectRowIndexes(indexes, byExtendingSelection:false)
	    }

	    @on_the_right_side = lambda {|path|
		    old_path = @right_path
		    @right_path = path
		    show_hidden_flag = @show_hidden_menu_item.state == NSOnState
		    @right_dir_files = @file_controller.get_files @right_path, show_hidden_flag
		    @right_path_label.stringValue = @right_path
		    self.right_dir_view.reloadData
		    index = 0
		    index = @right_dir_files.index {|x| x.path == old_path} if old_path[path]
		    indexes = NSIndexSet.alloc.initWithIndex(index)
		    self.right_dir_view.selectRowIndexes(indexes, byExtendingSelection:false)
	    }
    end

    def applicationDidFinishLaunching(a_notification)
        NSLog "Howdy!"
	    @left_path_label.stringValue = @left_path

	    @left_dir_view.on_key_down = lambda {|key, row|
		    if key == 13
		        open_file left_dir_files[row], @on_the_left_side
			elsif key == 127
				open_file left_dir_files[0], @on_the_left_side
			end
	    }

        @right_dir_view.on_key_down = lambda {|key, row|
		    if key == 13
		        open_file right_dir_files[row], @on_the_right_side
			elsif key == 127
				open_file right_dir_files[0], @on_the_right_side
			end
	    }

    end

	def awakeFromNib
		self.left_dir_view.doubleAction = 'left_dir_view_double_click:'
		self.right_dir_view.doubleAction = 'right_dir_view_double_click:'
	end

	def left_dir_view_double_click(sender)
		open_file left_dir_files[sender.clickedRow], @on_the_left_side
	end

    def right_dir_view_double_click(sender)
	    open_file right_dir_files[sender.clickedRow], @on_the_right_side
		#open_right_path right_dir_files[sender.clickedRow].path
	end

    def open_file(file, side)
	    #Animations.yellow_fade(sender, table_view)
	    if (file.type == 'link' || file.type == 'directory')
		    NSLog "open dir #{file.path}"
		    side.call file.path
	    else
		    NSWorkspace.sharedWorkspace.openFile(file.path)
	    end
    end

	def show_hidden(sender)
		NSLog 'okay'
		state = @show_hidden_menu_item.state == NSOffState ? NSOnState : NSOffState
		@show_hidden_menu_item.setState state
		reload
	end

	def reload
		@on_the_left_side.call @left_path
		@on_the_right_side.call @right_path
	end
end

