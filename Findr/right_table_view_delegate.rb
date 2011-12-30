require File.dirname(__FILE__) + '/file_info.rb'

class RightTableViewDelegate
	attr_accessor :parent

	#cocoa override
	def numberOfRowsInTableView(tableView)
		NSLog "table size #{parent.right_dir_files.size}"
		parent.left_dir_files.size
	end

	#cocoa override
	def tableView(tableView, objectValueForTableColumn:column, row:row)
		if row < parent.right_dir_files.size
			return parent.right_dir_files[row].valueForKey(column.identifier)
		end
		nil
	end
end