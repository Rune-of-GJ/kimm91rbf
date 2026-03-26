module ApplicationHelper
  def design_nav_link(label, path, key, active_page)
    classes = ["menu-link"]
    classes << "active" if key == active_page

    link_to label, path, class: classes.join(" ")
  end
end
