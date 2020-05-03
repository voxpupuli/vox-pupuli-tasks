# frozen_string_literal: true

module ApplicationHelper
  def markdown(text)
    return '' unless text

    options = {
      filter_html: true,
      hard_wrap: true,
      link_attributes: { rel: 'nofollow', target: '_blank' },
      space_after_headers: true,
      fenced_code_blocks: true
    }

    extensions = {
      autolink: true,
      superscript: true,
      disable_indented_code_blocks: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(text.to_s).html_safe
  end

  def color_by_passed_checks(passed, total)
    percentage = (passed.to_f/total.to_f) * 100
    case percentage
    when 0..20
      'red'
    when 21..70
      'orange'
    when 71..90
      'yellow'
    when 91..100
      'green'
    end
  rescue StandardError
    'red'
  end
end
