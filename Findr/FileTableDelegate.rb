require File.dirname(__FILE__) + '/file_info.rb'

class FileTableDelegate
	attr_accessor :parent

    #cocoa override
    def numberOfRowsInTableView(tableView)
	    NSLog "table size #{parent.files.size}"
        parent.files.size
    end

    #cocoa override
    def tableView(tableView, objectValueForTableColumn:column, row:row)
        #NSLog("Asked for row: #{row}, column: #{column}")
        if row < parent.files.size
            return parent.files[row].valueForKey(column.identifier)
        end
        nil
    end
end
