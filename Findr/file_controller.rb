require "fileutils"

class FileController
	GIGA_SIZE = 1073741824.0
	MEGA_SIZE = 1048576.0
	KILO_SIZE = 1024.0

	def get_files(path, show_hidden = true)
		#NSLog "get files for path #{path}"
		files = []
		directories = []

		Dir.foreach(path) do |file_name|
			next if file_name == '.'
			next if !show_hidden && file_name =~ /^\.[^\.]+/         #match anything that starts with . followed by any char except .

			file_info = FileInfo.new
			abs_file_name = File.absolute_path file_name, path
			file_ftype = File.ftype(abs_file_name)
			case file_ftype
				when 'link' then file_info.display_name = "#{file_name}@ -> #{File.readlink abs_file_name}"
				when 'directory' then file_info.display_name = file_name
				else file_info.display_name = file_name
			end
			file_info.name = file_name
			file_info.type = File.ftype abs_file_name
			file_info.ext = File.extname abs_file_name
			file_info.date = File.atime(abs_file_name).strftime("%d/%m/%y %H:%M")
			file_info.path = abs_file_name
			file_info.size = readable_file_size(File.size(abs_file_name), 2)

			attr = ''
			attr = 'd' if file_ftype == 'directory'
			file_info.attr = attr << get_access_control_list(abs_file_name)

			#file_info.icon = NSWorkspace.sharedWorkspace.iconForFile(abs_file_name)
			file_info.ext = file_ftype

			files << file_info
		end

		# sort dirs and then files
		#sort_predicate = lambda {|file1, file2| file1.name.downcase <=> file2.name.downcase}
		#directories.sort! &sort_predicate
		#files.sort! &sort_predicate
		#directories + files
		files
	end

	def mkdir(dir_name)
		NSLog "mkdir dir #{dir_name}"
		Dir.mkdir dir_name
	end

	def delete(file)
		NSLog "rmdir #{file.path}"
		FileUtils.rm_rf file.path, verbose: true, secure: true
		#if (File.directory? file.path)
		#	Dir.rmdir file.path
		#else
		#	NSLog "delete #{file.path}"
		#	File.delete file.path
		#end
	end

	def get_access_control_list(path)
		file_stat = File.stat(path)
		mode = file_stat.mode & 0777
		mode = mode.to_s(8)
		access_control_list = ''
		mode.each_char {|c|
			case
				when c == '0' then access_control_list << '---'
				when c == '1' then access_control_list << '--x'
				when c == '2' then access_control_list << '-w-'
				when c == '3' then access_control_list << '-wx'
				when c == '4' then access_control_list << 'r--'
				when c == '5' then access_control_list << 'r-x'
				when c == '6' then access_control_list << 'rw-'
				when c == '7' then access_control_list << 'rwx'
			end
		}
		access_control_list << 't' if file_stat.sticky?
		access_control_list
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