class DirDelegate
	attr_accessor :parent
	attr_accessor :path, :path_label, :dir_files, :dir_view

	def initialize
		@file_controller = FileController.new
		@path = '/'
		@dir_files = @file_controller.get_files @path
	end

	def applicationDidFinishLaunching(a_notification)
		@path_label.stringValue = @path
		@dir_view.on_key_down = lambda {|key, modifier_flags, row|
			if key == $KEY_ENTER
				open_file dir_files[row]
			elsif key == $KEY_BACKSPACE
				open_file dir_files[0]
			elsif key == $KEY_F3
				NSWorkspace.sharedWorkspace.openFile dir_files[row].path, withApplication: $VIEWER
			elsif key == $KEY_F4
				NSWorkspace.sharedWorkspace.openFile dir_files[row].path, withApplication: $EDITOR
			elsif (key == $KEY_LEFT_ARROW || key == $KEY_RIGHT_ARROW) && ((modifier_flags & NSCommandKeyMask) == NSCommandKeyMask)
				@parent.open_path_twin_view self.__id__, dir_files[row]
			end
		}
	end

	#cocoa override
	def numberOfRowsInTableView(tableView)
		#NSLog "table size #{@dir_files.size}"
		@dir_files.size
	end

	#cocoa override
	def tableView(tableView, objectValueForTableColumn:column, row:row)
		if row < @dir_files.size
			return @dir_files[row].valueForKey(column.identifier)
		end
		nil
	end

	def dir_view_double_click(sender)
		open_file dir_files[sender.clickedRow]
	end

	def open_file(file)
		if (file.type == 'link' || file.type == 'directory')
			NSLog "open dir #{file.path}"
			old_path = @path
			@path = file.path
			show_hidden_flag = @parent.show_hidden_menu_item.state == NSOnState
			@dir_files = @file_controller.get_files @path, show_hidden_flag
			@path_label.stringValue = @path
			self.dir_view.reloadData
			index = 0
			index = @dir_files.index {|x| x.path == old_path} if old_path[file.path]
			indexes = NSIndexSet.alloc.initWithIndex(index)
			self.dir_view.selectRowIndexes(indexes, byExtendingSelection:false)
		else
		#   Animations.yellow_fade(sender, table_view)
			NSWorkspace.sharedWorkspace.openFile(file.path)
		end
	end

	def load_path path
		@path = path
		show_hidden_flag = @parent.show_hidden_menu_item.state == NSOnState
		@dir_files = @file_controller.get_files @path, show_hidden_flag
		@path_label.stringValue = @path
		self.dir_view.reloadData
		index = 0
		indexes = NSIndexSet.alloc.initWithIndex(index)
		self.dir_view.selectRowIndexes(indexes, byExtendingSelection:false)
	end

	def reload
		load_path @path
	end
end