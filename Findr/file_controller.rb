require "fileutils"
require "pathname"

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

	def delete(files)
		trash = "#{ENV['HOME']}/.Trash"
		files.each do |file|
			NSLog "mv #{file} to #{trash}"
			::FileUtils.mv file, trash, force: true, verbose: true
			yield file if block_given?
		end
	end

	def copy(files, destination, &callback)
		#FileUtils.cp_r file.path, destination, verbose: true
		if File.directory? destination
			files.each do |file|
				if File.directory? file
					low_level_copy(file, destination, &callback)
				else
					dest_file = '' << destination << '/' << File.basename(file)
					low_level_copy file, dest_file, &callback
				end
			end
		else
			if files.size == 1
				destination_path = File.dirname destination
				if !File.directory? destination_path
					NSLog "mkdir_p #{destination_path}"
					::FileUtils.mkdir_p destination_path
				end
				low_level_copy(files[0], destination, &callback)
			else
				NSLog "mkdir_p #{destination}"
				::FileUtils.mkdir_p destination
				files.each {|file| low_level_copy(file, destination + '/' + file.name, &callback)}
			end
		end
	end

	def low_level_copy(src, dest, &block)
		NSLog "copy #{src} to #{dest}"
		if File.directory? src
			copy_dir(src, dest, &block)
		else
			copy_file(dest, src, &block)
		end
	end

	def copy_dir(src, dest, &block)
		dir = '' << dest << '/' << File.basename(src)
		NSLog "mkdir #{dir}"
		Dir.mkdir dir
		Pathname(src).each_child do |file|
			if File.directory? file
				low_level_copy file, dir, &block
			else
				dest_file = '' << dir << '/' << File.basename(file)
				low_level_copy file, dest_file, &block
			end
		end
	end

	def copy_file(dest, src)
		in_file = File.new(src, "r")
		out_file = File.new(dest, "w")
		in_size = File.size(src)
		buffer_size = in_size < 1024 * 16 ? in_size : 1024 * 16
		total = 0
		buffer = in_file.sysread(buffer_size)
		while total < in_size do
			out_file.syswrite(buffer)
			total += buffer_size
			progress = (total * 100 / in_size).to_s + '%'
			yield(src, progress) if block_given?
			buffer_size = in_size - total if (in_size - total) < buffer_size
			buffer = in_file.sysread(buffer_size)
		end
		in_file.close
		out_file.close
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