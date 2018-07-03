namespace :dashboard do
  desc "Task description"
  task :populate_yml => [:init_piwik] do
    site = Piwik::Site.load(ENV['PIWIK_SITE_ID'])
    date = 7.days.ago.strftime('%F')
    visits_summary = site.visits.summary(period: 'week', date: date)
    actions_summary = site.actions.summary(period: 'week', date: date)
    data = {}

    data['week_of'] = date
    data['nb_uniq_visitors'] = visits_summary.nb_uniq_visitors
    data['nb_visits'] = visits_summary.nb_visits
    data['nb_pageviews'] = actions_summary.nb_pageviews
    write_to_file(data)
  end

  task init_piwik: :environment do |t|
    Piwik::PIWIK_URL = 'https://piwik.commonfare.net'
    Piwik::PIWIK_TOKEN = ENV['PIWIK_AUTH_TOKEN']
  end

  def host_tmp_path
    "/host_tmp" # A volume defined in the proper docker-compose file
  end

  def write_to_file(data)
    File.write(File.join(host_tmp_path, 'dashboard_data.yml'), data.to_yaml)
  end
end
