# frozen_string_literal: true

puts "Seeding categories..."
categories = [
  { name: "발표 스피치", description: "효과적인 발표 기술과 스피치 기법" },
  { name: "면접 스피치", description: "면접 상황에서의 효과적인 커뮤니케이션" },
  { name: "커뮤니케이션", description: "일상 및 업무에서의 소통 능력 향상" },
  { name: "설득 화법", description: "청중을 설득하는 말하기 기술" },
  { name: "보이스 트레이닝", description: "목소리 관리와 발성 훈련" }
].map do |cat_data|
  Category.find_or_create_by!(name: cat_data[:name]) do |category|
    category.description = cat_data[:description]
  end
end

puts "Seeding users..."
instructor1 = User.find_or_create_by!(email: "instructor1@speakflow.kr") do |user|
  user.name = "김강사"
  user.password = "password123"
  user.role = "instructor"
end

instructor2 = User.find_or_create_by!(email: "instructor2@speakflow.kr") do |user|
  user.name = "박강사"
  user.password = "password123"
  user.role = "instructor"
end

students = []
5.times do |i|
  students << User.find_or_create_by!(email: "student#{i+1}@speakflow.kr") do |user|
    user.name = "수강생#{i+1}"
    user.password = "password123"
    user.role = "student"
  end
end

puts "Seeding courses..."
courses_data = [
  {
    title: "스토리텔링 프레젠테이션",
    description: "청중을 사로잡는 스토리 구성과 발표 기법",
    category: categories[0],
    instructor: instructor1,
    thumbnail_url: "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
    lectures: [
      { title: "청중 분석과 목표 설정", duration: 600 },
      { title: "메시지 구조화 기법", duration: 720 },
      { title: "오프닝으로 관심 유발하기", duration: 480 },
      { title: "본론의 설득 포인트", duration: 840 },
      { title: "클로징으로 마무리하기", duration: 540 }
    ]
  },
  {
    title: "면접 성공을 위한 스피치",
    description: "면접관을 사로잡는 자기소개와 답변 기술",
    category: categories[1],
    instructor: instructor2,
    thumbnail_url: "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
    lectures: [
      { title: "면접 준비의 기초", duration: 480 },
      { title: "자기소개 스피치 작성", duration: 600 },
      { title: "질문에 대한 효과적 답변", duration: 720 },
      { title: "바디랭귀지 활용", duration: 540 },
      { title: "마무리 인사와 퇴장", duration: 420 }
    ]
  },
  {
    title: "일상 커뮤니케이션 마스터",
    description: "매일의 대화에서 빛나는 소통 기술",
    category: categories[2],
    instructor: instructor1,
    thumbnail_url: "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
    lectures: [
      { title: "적극적 경청의 기술", duration: 480 },
      { title: "명확한 의사 표현", duration: 600 },
      { title: "갈등 상황 대처법", duration: 720 },
      { title: "피드백 주고받기", duration: 540 },
      { title: "네트워킹 스킬", duration: 660 }
    ]
  },
  {
    title: "설득의 심리학",
    description: "마인드 리딩으로 청중을 움직이는 화법",
    category: categories[3],
    instructor: instructor2,
    thumbnail_url: "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
    lectures: [
      { title: "설득의 기본 원리", duration: 600 },
      { title: "감정적 연결 만들기", duration: 720 },
      { title: "논리적 주장 구성", duration: 840 },
      { title: "신뢰 구축 전략", duration: 480 },
      { title: "행동 유도 기법", duration: 540 }
    ]
  },
  {
    title: "프로페셔널 보이스 트레이닝",
    description: "전문가다운 목소리로 자신감 있게 말하기",
    category: categories[4],
    instructor: instructor1,
    thumbnail_url: "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
    lectures: [
      { title: "발성 기초 훈련", duration: 480 },
      { title: "호흡법과 자세 교정", duration: 600 },
      { title: "목소리 톤 조절", duration: 540 },
      { title: "발음 명확화 연습", duration: 720 },
      { title: "스트레스 상황 대처", duration: 480 }
    ]
  }
]

courses = []
courses_data.each do |course_data|
  course = Course.find_or_create_by!(title: course_data[:title]) do |c|
    c.description = course_data[:description]
    c.category = course_data[:category]
    c.instructor = course_data[:instructor]
    c.instructor_name = course_data[:instructor].name
    c.thumbnail_url = course_data[:thumbnail_url]
    c.start_date = Date.today + 7.days
    c.end_date = Date.today + 37.days
    c.enrollment_deadline = Date.today + 6.days
    c.max_access_days = 90
  end
  courses << course

  puts "Creating lectures for #{course.title}..."
  course_data[:lectures].each_with_index do |lecture_data, idx|
    Lecture.find_or_create_by!(course: course, order_no: idx + 1) do |lecture|
      lecture.title = lecture_data[:title]
      lecture.video_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
      lecture.duration = lecture_data[:duration]
    end
  end
end

puts "Seeding enrollments and progress..."
students.each do |student|
  # 각 학생이 랜덤하게 2-3개의 코스를 수강
  enrolled_courses = courses.sample(rand(2..3))
  enrolled_courses.each do |course|
    Enrollment.find_or_create_by!(user: student, course: course)

    # 각 코스의 강의 중 일부를 시청 완료로 설정
    course.lectures.each do |lecture|
      if rand < 0.7 # 70% 확률로 시청 완료
        Progress.find_or_create_by!(user: student, lecture: lecture) do |progress|
          progress.watched = true
          progress.watched_at = Time.now - rand(1..7).days
        end
      end
    end
  end
end

puts "Seed data created successfully!"
puts "Available test accounts:"
puts "Instructor: instructor1@speakflow.kr / password123"
puts "Instructor: instructor2@speakflow.kr / password123"
students.each do |student|
  puts "Student: #{student.email} / password123"
end
