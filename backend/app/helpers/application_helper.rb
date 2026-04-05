module ApplicationHelper
  def design_nav_link(label, path, key, active_page)
    classes = []
    classes << "current" if key == active_page

    link_to label, path, class: classes.join(" ")
  end

  def course_progress_stats(user, course)
    total = course.lectures.size
    watched = user&.progresses&.where(lecture_id: course.lecture_ids, watched: true)&.count || 0
    rate = total.zero? ? 0 : ((watched.to_f / total) * 100).round

    {
      total: total,
      watched: watched,
      rate: rate
    }
  end

  def watched_label(user, lecture)
    progress = user&.progresses&.find_by(lecture: lecture)
    progress&.watched ? "시청 완료" : "미시청"
  end

  def display_value(value)
    value.present? ? value : "미정"
  end

  def boolean_label(value)
    value ? "가능" : "불가"
  end

  def duration_label(seconds)
    return "미정" if seconds.blank?

    minutes = seconds.to_i / 60
    remain_seconds = seconds.to_i % 60

    return "#{minutes}분" if remain_seconds.zero?

    "#{minutes}분 #{remain_seconds}초"
  end

  def youtube_embed_url(url)
    return if url.blank?

    case url
    when /youtu\.be\/([^?&]+)/
      "https://www.youtube.com/embed/#{$1}"
    when /[?&]v=([^&]+)/
      "https://www.youtube.com/embed/#{$1}"
    when /youtube\.com\/embed\/([^?&]+)/
      "https://www.youtube.com/embed/#{$1}"
    end
  end

  def page_links(active_page)
    content_tag(:nav, class: "page-nav") do
      safe_join([
        content_tag(:div, safe_join([
          design_nav_link("홈", root_path, :dashboard, active_page),
          design_nav_link("강의", courses_path, :courses, active_page),
          design_nav_link("카테고리", categories_path, :categories, active_page),
          (current_user ? design_nav_link("강의 시청", lecture_player_path(1), :lecture_player, active_page) : nil),
          (current_user ? design_nav_link("내 강의", my_courses_path, :my_courses, active_page) : nil),
          (current_user ? design_nav_link("진도", progress_path, :progress, active_page) : nil)
        ].compact), class: "page-nav-links"),
        content_tag(:div, safe_join([
          (current_user ? nil : design_nav_link("로그인", login_path, :login, active_page)),
          (current_user ? button_to("로그아웃", api_v1_auth_logout_path, method: :post, class: (active_page == :logout ? "current" : "")) : nil)
        ].compact), class: "page-nav-actions")
      ])
    end
  end
end
