class ProjectsController < ApplicationController
  def index
    @projects = Project.all
  end

  def show
    shuffled_projects = Project.all.reject { |project| project.title == params[:title] }.shuffle
    @project_snippets = shuffled_projects[0..3]

    @project = Project.find_by(title: "#{params[:title]}")
  end
end