class FileController
	GIGA_SIZE = 1073741824.0
	MEGA_SIZE = 1048576.0
	KILO_SIZE = 1024.0

	def get_files(path)
		#NSLog "get files for path #{path}"
		files = []
		directories = []

		Dir.foreach(path) do |file_name|
			next if file_name == '.'
			
			file_info = FileInfo.new
			abs_file_name = File.absolute_path file_name, path
			file_ftype = File.ftype(abs_file_name)
			case file_ftype
				when 'link' then file_info.display_name = "#{file_name}@ -> #{File.readlink abs_file_name}"
				when 'directory' then file_info.display_name = "[#{file_name}]"
				else file_info.display_name = file_name
			end
			file_info.name = file_name
			file_info.size = readable_file_size(File.size(abs_file_name), 2)
			file_info.ext = File.ftype abs_file_name
			file_info.date = File.atime(abs_file_name).strftime("%d/%m/%Y %H:%M:%S")
			file_info.attr = File.world_readable? abs_file_name
			file_info.path = abs_file_name

			if file_ftype == 'link' || file_ftype == 'directory'
				#directories << file_info
				files << file_info
			else
				files << file_info
			end
		end

		# sort dirs and then files
		#sort_predicate = lambda {|file1, file2| file1.name.downcase <=> file2.name.downcase}
		#directories.sort! &sort_predicate
		#files.sort! &sort_predicate
		#directories + files
		files
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