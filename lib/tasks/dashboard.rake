namespace :dashboard do
  desc "Populates the YAML file with the latest biweekly data"
  task :populate_yml => [:init_piwik] do
    site = Piwik::Site.load(ENV['PIWIK_SITE_ID'])
    date = 7.days.ago.strftime('%F')
    start_date = 2.weeks.ago.beginning_of_week.strftime('%F')
    end_date = 1.weeks.ago.end_of_week.strftime('%F')
    date_span = "#{start_date},#{end_date}"
    visits_summary = site.visits.summary(period: :range, date: date_span)
    actions_summary = site.actions.summary(period: :range, date: date_span)
    site_searches = Piwik::Actions.getSiteSearchKeywords(
      idSite: ENV['PIWIK_SITE_ID'],
      period: :range,
      date: date_span
    )
    inactive_commoners_count = Currency.find(ENV['QR_CODE_ENABLED_CURRENCIES'].split(',').map(&:to_i))
      .map(&:group)
      .map{|g| g.inactive_commoners.count}
      .reduce(:+)

    data = {}
    data['week_of'] = date
    data['start_date'] = start_date
    data['end_date'] = end_date
    data['nb_registered_commoners'] = Commoner.count - inactive_commoners_count
    data['nb_uniq_visitors'] = visits_summary.nb_uniq_visitors
    data['nb_visits'] = visits_summary.nb_visits
    data['nb_pageviews'] = actions_summary.nb_pageviews
    data['site_searches'] = site_searches.first(5).map { |s| {'label' => s['label'], 'nb_visits' => s['nb_visits']} }
    write_to_file(data)
  end

  desc "Copy the latest social graph data into the dashboard"
  task update_social_graph: :environment do |t|
    end_date = 1.weeks.ago.end_of_week.strftime('%F')
    new_file_path = File.join(commonshare_data_path, '/output/graphdata/biweekly/1.json')
    latest_file_path = File.join(host_tmp_path, 'dashboard_graph_data.json')
    backup_file_path = File.join(host_tmp_path, "dashboard_graph_data_until_#{end_date.gsub('-', '_')}.json")
    # create a backup copy of the latest file
    FileUtils.cp(latest_file_path, backup_file_path)
    # overwrite the latest file
    FileUtils.cp(new_file_path, latest_file_path)
  end

  task init_piwik: :environment do |t|
    Piwik::PIWIK_URL = ENV['PIWIK_URL']
    Piwik::PIWIK_TOKEN = ENV['PIWIK_AUTH_TOKEN']
  end

  def host_tmp_path
    "/host_tmp" # A volume defined in the proper docker-compose file
  end

  def commonshare_data_path
    "/commonshare-data"
  end

  def write_to_file(data)
    start_date = 2.weeks.ago.beginning_of_week.strftime('%F')
    end_date = 1.weeks.ago.end_of_week.strftime('%F')
    new_file_path = File.join(host_tmp_path, "dashboard_data_#{start_date}_#{end_date}.yml")
    latest_file_path = File.join(host_tmp_path, 'dashboard_data.yml')
    # write the new file (to be stored as backup)
    File.write(new_file_path, data.to_yaml)
    # overwrite the latest file with the new one
    FileUtils.cp(new_file_path, latest_file_path)
  end
end
