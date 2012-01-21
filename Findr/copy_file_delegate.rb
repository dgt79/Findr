class CopyFileDelegate
	attr_accessor :copy_to_text_field
	attr_accessor :parent, :copy_file_window

	def initialize
		@file_controller = FileController.new
	end

	def submit_copy_file_window(sender)
		@parent.queue.async do
			destination = @copy_to_text_field.stringValue
			@file_controller.copy(@files_to_copy, destination) do |src, progress|
				@parent.status_label.stringValue = "#{src} #{progress}"
			end
			self.parent.update destination, Const::COPY
		end
		NSApp.endSheet(@copy_file_window)
		@copy_file_window.orderOut(sender)
	end

	def hide_copy_file_window(sender)
		NSApp.endSheet(@copy_file_window)
		@copy_file_window.orderOut(sender)
	end

	def show_copy_folder_window(files_to_copy, destination)
		@files_to_copy = files_to_copy
		@copy_to_text_field.stringValue = destination
		NSApp.beginSheet(@copy_file_window,
										 modalForWindow: self.parent.window,
										 modalDelegate: nil,
										 didEndSelector: nil,
										 contextInfo: nil)
	end
end