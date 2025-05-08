module Event
  class Assignment < Base
    receiver_roles :assigner, :assignee
    self.description = 'Assigned a user to a package'
    self.notification_explanation = 'Receive notifications for assignments.'

    payload_keys :id, :assigner, :assignee, :project, :package

    def subject
      ''
    end

    def parameters_for_notification
      super.merge(notifiable_type: 'Assignment', type: 'NotificationAssignment')
    end

    def event_object
      ::Assignment.find_by(payload['assignment_id'])
    end
  end
end

# == Schema Information
#
# Table name: events
#
#  id          :bigint           not null, primary key
#  eventtype   :string(255)      not null, indexed
#  mails_sent  :boolean          default(FALSE), indexed
#  payload     :text(16777215)
#  undone_jobs :integer          default(0)
#  created_at  :datetime         indexed
#  updated_at  :datetime
#
# Indexes
#
#  index_events_on_created_at  (created_at)
#  index_events_on_eventtype   (eventtype)
#  index_events_on_mails_sent  (mails_sent)
#
