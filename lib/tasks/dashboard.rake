namespace :dashboard do
  desc "Task description"
  task :populate_yml => [:init_piwik] do
    site = Piwik::Site.load(ENV['PIWIK_SITE_ID'])
    date = 7.days.ago.strftime('%F')
    visits_summary = site.visits.summary(period: 'week', date: date)
    actions_summary = site.actions.summary(period: 'week', date: date)
    site_searches = Piwik::Actions.getSiteSearchKeywords(
      idSite: ENV['PIWIK_SITE_ID'],
      period: :month,
      date: 1.month.ago.strftime('%F')
    )
    inactive_commoners_count = Currency.find(ENV['QR_CODE_ENABLED_CURRENCIES'].split(',').map(&:to_i))
      .map(&:group)
      .map{|g| g.inactive_commoners.count}
      .reduce(:+)

    data = {}
    data['week_of'] = date
    data['nb_registered_commoners'] = Commoner.count - inactive_commoners_count
    data['nb_uniq_visitors'] = visits_summary.nb_uniq_visitors
    data['nb_visits'] = visits_summary.nb_visits
    data['nb_pageviews'] = actions_summary.nb_pageviews
    data['site_searches'] = site_searches.first(5).map { |s| {'label' => s['label'], 'nb_visits' => s['nb_visits']} }
    write_to_file(data)
  end

  task init_piwik: :environment do |t|
    Piwik::PIWIK_URL = ENV['PIWIK_URL']
    Piwik::PIWIK_TOKEN = ENV['PIWIK_AUTH_TOKEN']
  end

  def host_tmp_path
    "/host_tmp" # A volume defined in the proper docker-compose file
  end

  def write_to_file(data)
    File.write(File.join(host_tmp_path, 'dashboard_data.yml'), data.to_yaml)
  end
end
