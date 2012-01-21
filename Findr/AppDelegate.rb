require File.dirname(__FILE__) + '/global_var.rb'
require File.dirname(__FILE__) + '/ns_index_set'
class AppDelegate
    attr_accessor :window, :split_panel, :show_hidden_menu_item
		attr_accessor :status_label, :status_label_cell, :progress_indicator
    attr_accessor :left_dir_delegate, :right_dir_delegate
    attr_reader :queue

    def initialize
	    NSLog 'init AppDelagate'
	    @queue = Dispatch::Queue.new('findr.queue')
    end

    def applicationDidFinishLaunching(a_notification)
        NSLog "Howdy!"
	    @left_dir_delegate.applicationDidFinishLaunching a_notification
	    @right_dir_delegate.applicationDidFinishLaunching a_notification
    end

    def awakeFromNib
	    @left_dir_delegate.dir_view.doubleAction = 'left_view_double_click:'
	    @right_dir_delegate.dir_view.doubleAction = 'right_view_double_click:'

	    @observers = []
	    @observers << @left_dir_delegate << @right_dir_delegate

			@left_dir_delegate.twin = @right_dir_delegate
			@right_dir_delegate.twin = @left_dir_delegate

	    @window.zoom self

			self.progress_indicator.setDisplayedWhenStopped false
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

	def update(path, operation)
		@observers.each {|observer| observer.notify path, operation}
	end
end