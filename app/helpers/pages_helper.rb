module PagesHelper
  def translated_page(page_name)
    locale = %i(it hr nl).include?(I18n.locale) ? I18n.locale : 'en'
    "pages/#{locale}/#{page_name}"
  end

  def jumbotron_bg_image_path
    image_path("jumbotron-bg-random-#{rand(2..2)}.jpg")
  end

  def story_type_title(story_type)
    case story_type
    when :commoners_voice
      s_('Home title|Commoners Voices')
    when :good_practice
      s_('Home title|Good Practices')
    when :welfare_provision
      s_('Home title|Public Benefits')
    end
  end

  def story_type_subtitle(story_type)
    case story_type
    when :commoners_voice
      s_('Home text|A collection of stories for, with and by people.')
    when :good_practice
      s_('Home text|Selected bottom-up initiatives to connect and inspire.')
    when :welfare_provision
      s_('Home text|Get informed about local welfare provisions.')
    end
  end

  def piwik_image_url(start_date, end_date)
    params = {
      module: 'API',
      method: 'ImageGraph.get',
      idSite: ENV['PIWIK_SITE_ID'],
      apiModule: 'VisitsSummary',
      apiAction: 'get',
      token_auth: 'anonymous',
      graphType: 'evolution',
      period: 'day',
      date: "#{start_date},#{end_date}",
      legendFontSize: 12,
      fontSize: 12,
      showLegend: 0,
      colors: '#E7472E',
      width: '976',
      height: '250',
      language: I18n.locale
    }
    ENV['PIWIK_URL'] + '/index.php?' + params.to_query
  end

  def social_graph_legend
    <<-eos
    <h6>Legend</h6>
    <ul class="list-unstyled">
      <li>
        <i class="fa fa-circle" aria-hidden="true" style="color: steelblue"></i>
        #{s_('Social graph legend|Commoner')}
      </li>
      <li>
        <i class="fa fa-circle" aria-hidden="true" style="color: red"></i>
        #{s_('Social graph legend|Story')}
      </li>
      <li>
        <i class="fa fa-circle" aria-hidden="true" style="color: lightgreen"></i>
        #{s_('Social graph legend|Tag')}
      </li>
      <li>
        <i class="fa fa-circle" aria-hidden="true" style="color: purple"></i>
        #{s_('Social graph legend|Listing')}
      </li>
    </ul>
    eos
  end
end
