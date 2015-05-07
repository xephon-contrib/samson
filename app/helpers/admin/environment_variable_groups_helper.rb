module Admin::EnvironmentVariableGroupsHelper
  def options_for_scope_select
    [
      ['All', 0],
      ['-- Environments --', 0, { disabled: true }],
      ['Production', 'env-1'],
      ['Staging', 'env-2'],
      ['Master', 'env-3'],
      ['-- Deploy Groups --', 0, { disabled: true }],
      ['Pod1', 'dg-1'],
      ['Pod2', 'dg-2'],
      ['Pod3', 'dg-3'],
      ['Pod4', 'dg-4']
    ]
  end
end
