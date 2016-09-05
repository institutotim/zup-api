namespace :feature_flags do
  desc 'Populate feature flags table'
  task populate: :environment do
    flags = %w(
      explore
      create_report_clients
      create_report_panel
      stats
      social_networks_facebook
      social_networks_twitter
      social_networks_gplus
      allow_photo_album_access
      cases
      inventory
      reports
      show_resolution_time_to_clients
      show_answer_to_requester
    )

    flags.each do |flag|
      FeatureFlag.create_with(status: :enabled).find_or_create_by(name: flag)
    end
  end
end
