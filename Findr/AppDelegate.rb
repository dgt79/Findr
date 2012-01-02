require File.dirname(__FILE__) + '/global_var.rb'

class AppDelegate
    attr_accessor :window, :split_panel, :show_hidden_menu_item
    attr_accessor :left_dir_delegate, :right_dir_delegate

    def initialize
	    NSLog 'init AppDelagate'
    end

    def applicationDidFinishLaunching(a_notification)
        NSLog "Howdy!"
	    @left_dir_delegate.applicationDidFinishLaunching a_notification
	    @right_dir_delegate.applicationDidFinishLaunching a_notification
    end

    def awakeFromNib
	    @left_dir_delegate.dir_view.doubleAction = 'left_view_double_click:'
	    #@left_dir_delegate.id = 'LEFT'

	    @right_dir_delegate.dir_view.doubleAction = 'right_view_double_click:'
	    #@right_dir_delegate.id = 'RIGHT'

	    @window.zoom self
    end

    def left_view_double_click(sender)
	    @left_dir_delegate.dir_view_double_click sender
	    end

    def right_view_double_click(sender)
	    @right_dir_delegate.dir_view_double_click sender
    end

	def show_hidden(sender)
		state = @show_hidden_menu_item.state == NSOffState ? NSOnState : NSOffState
		@show_hidden_menu_item.setState state
		reload
	end

	def reload
		@left_dir_delegate.reload
		@right_dir_delegate.reload
	end

    def open_path_twin_view source_id, file
	    puts 'open in twin'
	    @left_dir_delegate.load_path file.path if @left_dir_delegate.__id__ != source_id
	    @right_dir_delegate.load_path file.path if @right_dir_delegate.__id__ != source_id
    end
end