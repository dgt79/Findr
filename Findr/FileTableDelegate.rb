require File.dirname(__FILE__) + '/file_info.rb'

class FileTableDelegate
	attr_accessor :parent

    #cocoa override
    def numberOfRowsInTableView(tableView)
	    NSLog "table size #{parent.left_dir_files.size}"
        parent.left_dir_files.size
    end

    #cocoa override
    def tableView(tableView, objectValueForTableColumn:column, row:row)
        #NSLog("Asked for row: #{row}, column: #{column}")
        if row < parent.left_dir_files.size
            return parent.left_dir_files[row].valueForKey(column.identifier)
        end
        nil
    end
end
