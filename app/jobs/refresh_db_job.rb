require 'octokit'

class RefreshDbJob < ApplicationJob
  queue_as :default

  def perform()
    @job_client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
    @job_client.repos.each do |repo|
      # If project is in db, but does not have portfolio in description, then delete
      if repo.description.nil? || !repo.description.include?("Portofolio")
        Project.find_by(title: repo.name).delete if Project.find_by(title: repo.name)
        next
      end

      project = Project.find_by(title: repo.name)
      details = get_repo_details(repo)

      unless project.nil?
        # # update if changed
        project.featured = details[:featured]
        project.thumbnail_url = details[:thumbnail_url]
        project.thumbnail_alt = details[:thumbnail_alt]
        project.link_to_page = details[:link_to_page]
        project.link_to_github = details[:link_to_github]
        project.content = details[:content]

        project.save
      else
        # Create a new db object
        project = Project.new(
          title: details[:title],
          featured: details[:featured],
          thumbnail_url: details[:thumbnail_url],
          thumbnail_alt: details[:thumbnail_alt],
          link_to_page: details[:link_to_page],
          link_to_github: details[:link_to_github],
          content: details[:content]
        )

        project.save
      end
    end

    sleep(5.minutes)
    perform
  end

  private

  def get_repo_details(repo)
    readme_file = @job_client.readme repo.full_name, accept: 'application/vnd.github.html'

    thumbnail_alt_regex = /alt=[\\"](Thumbnail[^\\"]+)/
    link_to_page_regex = /<a href=[\\"](https:\/\/[^[\/\\"]]+)[\/\\" rel=\\"nofollow\\">Hjemmeside]/

    hash_of_content = {}
    i = 0
    readme_file.scan(/<(\w{1,6})(?:\s|)(?:dir=[\\"]auto[\\"]|)>(?:([^<]+)|[^>]+>[^>]+>[^>]+>[^>]+>[^>]+>[^>]+>([^<]+))/).each do |text|
      next if text[0] == "h1"
      next if text[2] == "Hjemmeside"

      tag = text[0]
      content = text[1] unless text[1].nil?
      content = text[2] unless text[2].nil?
      hash_of_content[i] = { "tag" => tag, "content" => content }
      i = i + 1
    end

    title = repo.name
    featured = repo.description.include?("Featured") ? 1 : 0
    thumbnail_url = readme_file.match(/https:\/\/github\.com\/#{repo.full_name}\/raw\/main\/[^\\"]+/)
    thumbnail_alt = readme_file.match(thumbnail_alt_regex)[1] unless readme_file.match(thumbnail_alt_regex).nil?
    link_to_page = readme_file.match(link_to_page_regex)[1] unless readme_file.match(link_to_page_regex).nil?
    link_to_github = "https://github.com/#{repo.full_name}"
    content = hash_of_content

    return {title:, featured:, thumbnail_url:, thumbnail_alt:, link_to_page:, link_to_github:, content:}
  end
end