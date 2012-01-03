class NewFolderDelegate
	attr_accessor :dir_text_field, :parent, :new_folder_window

	def submit_new_dir_window(sender)
		dir_name = '' << @path << '/' << self.dir_text_field.stringValue
		NSLog "mkdir #{dir_name}"
		Dir.mkdir dir_name
		self.parent.reload
		NSApp.endSheet(new_folder_window)
		new_folder_window.orderOut(sender)
	end

	def hide_new_dir_window(sender)
		NSApp.endSheet(new_folder_window)
		new_folder_window.orderOut(sender)
	end

	def show_new_folder_window(path)
		@path = path
		NSApp.beginSheet(new_folder_window,
		                modalForWindow: self.parent.window,
		                modalDelegate: nil,
		                didEndSelector: nil,
		                contextInfo: nil)
	end
end