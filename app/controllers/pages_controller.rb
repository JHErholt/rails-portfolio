class PagesController < ApplicationController
  def home
    @featured_repos = Project.where(featured: 1)
  end

  def about

  end
end