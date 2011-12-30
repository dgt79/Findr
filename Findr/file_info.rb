class FileInfo
	attr_accessor :name, :size, :ext, :date, :attr, :path, :display_name, :type
	def to_s
		@path
	end
end