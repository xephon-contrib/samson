class Admin::EnvironmentVariableGroupsController < ApplicationController
  before_action :authorize_admin!
  before_action :authorize_super_admin!, only: [:create, :new, :update, :destroy]
  before_action :env_var_group, only: [:edit, :update, :destroy]

  def index
    @env_var_groups = EnvironmentVariableGroup.all
  end

  def new
    @env_var_group = EnvironmentVariableGroup.new
    render 'edit'
  end

  def edit
    respond_to do |format|
      format.html { render 'edit' }
      format.json { render json: @env_var_group.as_json(include: :environment_variables) }
    end
  end

  def create
    env_var_group = EnvironmentVariableGroup.create(env_var_group_params)
    if env_var_group.persisted?
      render json: { msg: 'success' }
    else
      render json: { msg: env_var_group.errors.full_messages.join("\n") }, status: :bad_request
    end
  end

  def update
    if env_var_group.update_attributes(env_var_group_params)
      flash[:notice] = "Successfully saved deploy group: #{env_var_group.name}"
      redirect_to action: 'index'
    else
      flash[:error] = env_var_group.errors.full_messages
      render 'edit'
    end
  end

  def destroy
    env_var_group.destroy!
    flash[:notice] = "Successfully deleted deploy group: #{env_var_group.name}"
    redirect_to action: 'index'
  end

  def options_for_scope_select
    options = [
      { title: 'All', id: 0, disabled: false },
      { title: '-- Environments --', id: -1, disabled: true }
    ]
    Environment.all.each { |env| options << { title: env.name, id: "Environment.#{env.id}", disable: false } }
    options << { title: '-- Deploy Groups --', id: -1, disabled: true }
    DeployGroup.all.each { |dg| options << { title: dg.name, id: "DeployGroup.#{dg.id}", disable: false } }
    render json: { options: options }
  end

  private

  def env_var_group_params
    params.require(:environment_variable_group).permit(
      :name,
      environment_variables_attributes: [
        :key,
        :value,
        :scope,
        :environment_variable_group_id,
        :id,
        :created_at,
        :updated_at
      ])
  end

  def env_var_group
    @env_var_group ||= EnvironmentVariableGroup.includes(:environment_variables).find(params[:id])
  end
end
