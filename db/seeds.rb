# frozen_string_literal: true

categories = [
  "발표 스피치",
  "면접 스피치",
  "커뮤니케이션",
  "설득 화법",
  "보이스 트레이닝"
].map do |name|
  Category.find_or_create_by!(name: name) do |category|
    category.description = "#{name} 관련 학습 카테고리"
  end
end

instructor = User.find_or_create_by!(email: "instructor@speakflow.kr") do |user|
  user.name = "기본 강사"
  user.password = "password123"
  user.role = "instructor"
end

student = User.find_or_create_by!(email: "student@speakflow.kr") do |user|
  user.name = "기본 수강생"
  user.password = "password123"
  user.role = "student"
end

course = Course.find_or_create_by!(title: "스토리텔링 프레젠테이션") do |c|
  c.description = "청중을 설득하는 발표 스토리 구성법"
  c.category = categories.first
  c.instructor = instructor
  c.instructor_name = instructor.name
  c.thumbnail_url = "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg"
end

["청중 분석과 목표 설정", "메시지 구조화", "오프닝/클로징 설계"].each_with_index do |title, idx|
  Lecture.find_or_create_by!(course: course, order_no: idx + 1) do |lecture|
    lecture.title = title
    lecture.video_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    lecture.duration = 600 + (idx * 120)
  end
end

Enrollment.find_or_create_by!(user: student, course: course)
