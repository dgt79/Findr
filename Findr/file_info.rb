class FileInfo
	attr_accessor :name, :size, :ext, :date, :attr

	def initialize(name)
		@name = name
	end
end