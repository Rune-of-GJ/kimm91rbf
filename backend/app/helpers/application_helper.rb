module ApplicationHelper
  def app_nav_link(label, path, key)
    classes = ["site-nav__link"]
    classes << "is-active" if nav_active?(key)

    link_to label, path, class: classes.join(" ")
  end

  def design_nav_link(label, path, _key = nil, _active_page = nil)
    link_to label, path, class: "site-nav__link"
  end

  def nav_active?(key)
    case key
    when :dashboard
      current_page?(root_path)
    when :categories
      current_page?(categories_path)
    when :courses
      current_page?(courses_path) || request.path.match?(%r{\A/courses/\d+\z})
    when :membership
      current_page?(membership_path) || current_page?(membership_plans_path) || current_page?(membership_checkout_path) || current_page?(membership_account_path)
    when :coaching
      current_page?(coaching_products_path) || current_page?(new_coaching_request_path) || current_page?(coaching_requests_path)
    when :my_courses
      current_page?(my_courses_path)
    when :progress
      current_page?(progress_path)
    when :login
      current_page?(login_path)
    else
      false
    end
  end

  def course_progress_stats(user, course)
    total = course.lectures.size
    watched = user ? user.progresses.where(lecture_id: course.lecture_ids, watched: true).count : 0
    rate = total.zero? ? 0 : ((watched.to_f / total) * 100).round

    {
      total: total,
      watched: watched,
      rate: rate
    }
  end

  def overall_progress_stats(user)
    courses = user ? user.learning_courses : []
    total_lectures = courses.sum { |course| course.lectures.size }
    watched_lectures = user ? user.progresses.where(watched: true).count : 0
    rate = total_lectures.zero? ? 0 : ((watched_lectures.to_f / total_lectures) * 100).round

    {
      courses_count: courses.size,
      total_lectures: total_lectures,
      watched_lectures: watched_lectures,
      rate: rate
    }
  end

  def watched?(user, lecture)
    user&.progresses&.find_by(lecture: lecture)&.watched?
  end

  def duration_label(duration)
    return "미정" if duration.blank?

    minutes = duration.to_i
    return "#{minutes}분" if minutes < 60

    hours = minutes / 60
    remain = minutes % 60

    remain.positive? ? "#{hours}시간 #{remain}분" : "#{hours}시간"
  end

  def display_date(value)
    return "미정" if value.blank?

    value.strftime("%Y.%m.%d")
  end

  def youtube_embed_url(url)
    return if url.blank?

    case url
    when %r{youtu\.be/([^?&/]+)}
      "https://www.youtube.com/embed/#{Regexp.last_match(1)}"
    when /[?&]v=([^&]+)/
      "https://www.youtube.com/embed/#{Regexp.last_match(1)}"
    when %r{youtube\.com/embed/([^?&/]+)}
      "https://www.youtube.com/embed/#{Regexp.last_match(1)}"
    end
  end

  def rehearsal_audio_path(note)
    note.to_s[/업로드 파일:\s*(\/uploads\/rehearsal_audio\/[^\s]+)/, 1] ||
      note.to_s[/\/uploads\/rehearsal_audio\/[^\s]+/, 0]
  end

  def rehearsal_note_body(note)
    note.to_s
      .gsub(/업로드 파일:\s*\/uploads\/rehearsal_audio\/[^\s]+/, "")
      .gsub(/\/uploads\/rehearsal_audio\/[^\s]+/, "")
      .strip
  end
end
