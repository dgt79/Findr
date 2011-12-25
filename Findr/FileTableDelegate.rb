require File.dirname(__FILE__) + '/file_info.rb'

class FileTableDelegate
	GIGA_SIZE = 1073741824.0
	MEGA_SIZE = 1048576.0
	KILO_SIZE = 1024.0

    attr_accessor :parent

    def initialize
	    @files = getFiles '/'
    end
    
    def numberOfRowsInTableView(tableView)
        @files.size
    end
    
    def tableView(tableView, objectValueForTableColumn:column, row:row)
        #NSLog("Asked for row: #{row}, column: #{column}")
        if row < @files.size
            return @files[row].valueForKey(column.identifier)
        end
        return nil
    end

	def getFiles(path)
        files = []
		Dir.foreach(path) do |file_name|
			next if file_name == '.' || file_name == '..'
			abs_file_name = File.absolute_path file_name, path
			display_name = file_name
			if (File.ftype(abs_file_name) == 'link')
				display_name << "@ -> #{File.readlink abs_file_name}"
			elsif (File.ftype(abs_file_name) == 'directory')
				display_name = "[#{display_name}]"
			end
			file_info = FileInfo.new display_name
			file_info.size = readable_file_size(File.size(abs_file_name), 2)
			file_info.ext = File.ftype abs_file_name
			file_info.date = File.atime(abs_file_name).strftime("%d/%m/%Y %H:%M:%S")
			file_info.attr = File.world_readable? abs_file_name
			files << file_info
		end
		return files
	end

    # Return the file size with a readable style.
    def readable_file_size(size, precision)
	    case
		    when size < KILO_SIZE
			    "%d B" % size
		    when size < MEGA_SIZE
			    "%.#{precision}f Kb" % (size / KILO_SIZE)
		    when size < GIGA_SIZE
			    "%.#{precision}f Mb" % (size / MEGA_SIZE)
		    else "%.#{precision}f Gb" % (size / GIGA_SIZE)
	    end
    end
end
