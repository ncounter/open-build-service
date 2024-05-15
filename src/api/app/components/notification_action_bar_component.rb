# frozen_string_literal: true

class NotificationActionBarComponent < ApplicationComponent
  attr_accessor :selected_filter, :update_path, :show_read_all_button

  def initialize(selected_filter:, update_path:, show_read_all_button: false)
    super

    @selected_filter = selected_filter
    @update_path = add_params(update_path)
    @show_read_all_button = show_read_all_button
  end

  def button_text(all: false)
    text = selected_filter[:read].present? ? 'Unread' : 'Read'
    selection_text = all ? 'all' : 'selected'

    "Mark #{selection_text} as '#{text}'"
  end

  def multiple_selection_button_disabled?
    %w[unread read].all? { |p| @selected_filter[p] }
  end

  def disable_with_content(all: false)
    spinner = tag.i(class: 'fas fa-spinner fa-spin ms-2')
    button_text(all: all) + spinner
  end

  private

  def add_params(path)
    return "#{path}&update_all=true" if path.include?('?')

    "#{path}?update_all=true"
  end
end
