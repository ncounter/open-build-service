class SourcediffComponent < ApplicationComponent
  attr_accessor :bs_request, :action, :index, :refresh

  delegate :diff_label, to: :helpers
  delegate :diff_data, to: :helpers

  def initialize(bs_request:, action:, index:)
    super

    @bs_request = bs_request
    @action = action
    @index = index
  end

  def commentable
    BsRequestAction.find(@action[:id])
  end

  def file_view_path(filename, sourcediff)
    return if sourcediff['files'][filename]['state'] == 'deleted'

    diff_params = diff_data(@action[:type], sourcediff)
    package_view_file_path(diff_params.merge(filename: filename))
  end

  def source_package
    Package.get_by_project_and_name(@action[:source_project], @action[:source_package], { follow_multibuild: true })
  rescue Package::UnknownObjectError, Project::Errors::UnknownObjectError
  end

  def target_package
    # For not accepted maintenance incident requests, the package is not there.
    return nil unless @action[:target_package]

    Package.get_by_project_and_name(@action[:target_project], @action[:target_package], { follow_multibuild: true })
  rescue Package::UnknownObjectError, Project::Errors::UnknownObjectError
  end
end
