class Webui::Users::NotificationsController < Webui::WebuiController
  include Webui::NotificationsFilter

  ALLOWED_FILTERS = %w[all comments requests incoming_requests outgoing_requests relationships_created relationships_deleted build_failures
                       reports reviews workflow_runs appealed_decisions].freeze
  ALLOWED_STATES = %w[all unread read].freeze

  before_action :require_login
  before_action :set_filter_kind, :set_filter_state, :set_filter_project, :set_filter_group
  before_action :set_notifications
  before_action :set_notifications_to_be_updated, only: [:update]
  before_action :set_show_read_all_button
  before_action :set_selected_filter
  before_action :paginate_notifications

  def index
    @current_user = User.session
  end

  def update
    # The button value specifies whether we selected read or unread
    deliver = params[:button] == 'read'
    # rubocop:disable Rails/SkipsModelValidations
    @count = @notifications.where(id: @notification_ids, delivered: !deliver).update_all(delivered: deliver)
    # rubocop:enable Rails/SkipsModelValidations

    respond_to do |format|
      format.html { redirect_to my_notifications_path }
      format.js do
        render partial: 'update', locals: {
          notifications: @notifications,
          all_filtered_notifications: @all_filtered_notifications,
          selected_filter: @selected_filter,
          show_read_all_button: @show_read_all_button,
          user: User.session
        }
      end
      send_notifications_information_rabbitmq(deliver, @count)
    end
  end

  private

  def set_filter_kind
    @filter_kind = Array(params[:kind].presence || 'all') # in case just one value, we want an array anyway
    raise FilterNotSupportedError unless (@filter_kind - ALLOWED_FILTERS).empty?
  end

  def set_filter_state
    @filter_state = params[:state].presence || 'unread'
    raise FilterNotSupportedError if ALLOWED_STATES.exclude?(@filter_state)
  end

  def set_filter_project
    @filter_project = params[:project] || []
  end

  def set_filter_group
    @filter_group = params[:group] || []
  end

  def set_notifications
    @notifications = User.session!.notifications.for_web
    @notifications = filter_notifications_by_project(@notifications, @filter_project)
    @notifications = filter_notifications_by_group(@notifications, @filter_group)
    @notifications = filter_notifications_by_state(@notifications, @filter_state)
    @notifications = filter_notifications_by_kind(@notifications, @filter_kind)
    @all_filtered_notifications = @notifications
    @notifications = @notifications.includes(notifiable: [{ commentable: [{ comments: :user }, :project, :bs_request_actions] }, :bs_request_actions, :reviews])
  end

  def set_notifications_to_be_updated
    return @notification_ids = @notifications.map(&:id) if params[:update_all]
    return unless params[:notification_ids]

    @notification_ids = @notifications.where(id: params[:notification_ids]).map(&:id)
  end

  def set_show_read_all_button
    @show_read_all_button = @notifications.count > Notification::MAX_PER_PAGE
  end

  def set_selected_filter
    @selected_filter = { kind: @filter_kind, state: @filter_state, project: @filter_project, group: @filter_group }
    @filtered_by_text = "State: #{@filter_state.to_s.humanize} - Type: #{@filter_kind.map { |s| s.to_s.humanize }.join(', ')}"
  end

  def show_more(notifications)
    total = notifications.size
    flash.now[:info] = "You have too many notifications. Displaying a maximum of #{Notification::MAX_PER_PAGE} notifications per page." if total > Notification::MAX_PER_PAGE
    notifications.page(params[:page]).per([total, Notification::MAX_PER_PAGE].min)
  end

  def send_notifications_information_rabbitmq(delivered, count)
    action = delivered ? 'read' : 'unread'
    RabbitmqBus.send_to_bus('metrics', "notification,action=#{action} value=#{count}") if count.positive?
  end

  def paginate_notifications
    @notifications = params[:show_more] ? show_more(@notifications) : @notifications.page(params[:page])
    params[:page] = @notifications.total_pages if @notifications.out_of_range?
  end
end
