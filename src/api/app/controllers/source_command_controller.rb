class SourceCommandController < SourceController
  skip_before_action :extract_user, only: %i[global_command_orderkiwirepos global_command_triggerscmsync]
  skip_before_action :require_login, only: %i[global_command_orderkiwirepos global_command_triggerscmsync]

  before_action :require_scmsync_host_check, only: :global_command_triggerscmsync

  # POST /source?cmd=createmaintenanceincident
  def global_command_createmaintenanceincident
    prj = Project.get_maintenance_project!
    actually_create_incident(prj)
  end

  # POST /source?cmd=branch (aka osc mbranch)
  def global_command_branch
    private_branch_command
  end

  # POST /source?cmd=orderkiwirepos
  def global_command_orderkiwirepos
    pass_to_backend
  end

  # POST /source?cmd=triggerscmsync
  def global_command_triggerscmsync
    pass_to_backend("/source#{build_query_from_hash(params, %i[cmd scmrepository scmbranch isdefaultbranch])}")
  end
end
