class AddPerformanceIndexes < ActiveRecord::Migration[8.1]
  def change
    # users.role — admin 페이지 role 필터 쿼리
    add_index :users, :role, if_not_exists: true

    # courses.start_date — 강사 대시보드 upcoming 필터
    add_index :courses, :start_date, if_not_exists: true

    # subscriptions.started_at — 정산 리포트 월별 범위 쿼리
    add_index :subscriptions, :started_at, if_not_exists: true

    # feedback_requests.reviewed_at — 정산 리포트 완료 첨삭 범위 쿼리
    add_index :feedback_requests, :reviewed_at, if_not_exists: true

    # progresses.watched_at — 정산 리포트 시청 기여도 범위 쿼리
    add_index :progresses, :watched_at, if_not_exists: true
  end
end
