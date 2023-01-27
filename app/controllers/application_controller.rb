class ApplicationController < ActionController::Base
  before_action :set_info_from_github, :set_hardcoded_info

  private

  def set_hardcoded_info
    @phone_number = "+45 30 31 96 85"
    @company_name = "Karnov Group Denmark"
    @company_url = "https://www.karnovgroup.dk/"
    @skills = %w(ruby html5 css3 javascript slack vscode rails mongodb google)
  end

  def set_info_from_github
    @client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
    user = @client.user

    @name = user.name
    @avatar_url = user.avatar_url
    @bio = user.bio
    @location = user.location
    @mail = user.email
    @github_url = user.html_url
    @twitter_username = user.twitter_username
    @start_year = user.created_at.year
    @updated_year = user.updated_at.year
    @hireable = user.hireable
    @company = user.company
    @linkedIn_name = user.name.split.map(&:downcase).values_at(0, -1).join('-')
  end
end
