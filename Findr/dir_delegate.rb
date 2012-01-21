# todo: time to break it down - mixin

class DirDelegate
	attr_accessor :parent, :new_folder_delegate, :copy_file_delegate
	attr_accessor :path, :path_label, :dir_files, :dir_view
	attr_accessor :twin

	def initialize
		@file_controller = FileController.new
		@path = ENV['HOME']
		@dir_files = @file_controller.get_files @path, false
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
				@twin.load_path dir_files[row].path
			elsif key == $KEY_F7
				@new_folder_delegate.show_new_folder_window @path
			elsif key == $KEY_F8
				delete_files
			elsif key == $KEY_F5
				copy_files
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

	def load_path(path, index = 0)
		if File.directory? path
			@path = path
		elsif
			@path = path[0, path.rindex(File.basename path)]
		end
		show_hidden_flag = @parent.show_hidden_menu_item.state == NSOnState
		@dir_files = @file_controller.get_files @path, show_hidden_flag
		@path_label.stringValue = @path
		self.dir_view.reloadData
		indexes = NSIndexSet.alloc.initWithIndex(index)
		self.dir_view.selectRowIndexes(indexes, byExtendingSelection:false)
	end

	def reload
		load_path @path
	end

	def delete_files
		files = []
		dir_view.selectedRowIndexes.each {|i| files << @dir_files[i].path unless @dir_files[i].name == '..'}

		@parent.queue.sync do
			@parent.progress_indicator.startAnimation self

			@file_controller.delete(files) do |file|
				@parent.status_label.stringValue = "Deleting #{file}"
				self.parent.update file, Const::DELETE
			end

			@parent.progress_indicator.stopAnimation self
		end
	end

	def copy_files
		files = []
		dir_view.selectedRowIndexes.each {|i| files << @dir_files[i].path unless @dir_files[i].name == '..'}
		@copy_file_delegate.show_copy_folder_window files, @twin.path
	end

	def notify(path, operation)
		if operation == Const::DELETE
			if @dir_view.has_focus
				index = @dir_files.index {|x| x.path == path}
				load_path @path, index - 1
			else
				parent = path[0, path.rindex('/')]
				load_path(parent) if @path[parent]
			end
		elsif operation == Const::NEW
			if @dir_view.has_focus
				reload
				index = @dir_files.index {|x| x.path == path}
				indexes = NSIndexSet.alloc.initWithIndex(index)
				self.dir_view.selectRowIndexes(indexes, byExtendingSelection:false)
			else
				parent = path[0, path.rindex('/')]
				load_path(parent) if @path == parent
			end
		elsif operation == Const::COPY
			reload if @path == path
		end
	end
end