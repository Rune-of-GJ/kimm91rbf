class CoachingProduct < ApplicationRecord
  DEFAULT_PRODUCTS = [
    {
      slug: "single-feedback",
      name: "1:1 첨삭 1회권",
      tagline: "발표, 보이스, 전달력처럼 한 번의 핵심 피드백이 필요한 학생용 상품",
      price: 29_000,
      credits_amount: 1,
      position: 1
    },
    {
      slug: "triple-feedback-pack",
      name: "1:1 첨삭 3회 패키지",
      tagline: "여러 번 반복 연습하면서 흐름 전체를 점검하고 싶은 학생용 묶음 상품",
      price: 79_000,
      credits_amount: 3,
      position: 2
    },
    {
      slug: "interview-intensive",
      name: "면접 집중 첨삭",
      tagline: "자기소개와 꼬리질문까지 이어서 점검할 수 있도록 2회 분량으로 구성한 면접 특화 상품",
      price: 49_000,
      credits_amount: 2,
      position: 3
    }
  ].freeze

  has_many :coaching_purchases, dependent: :restrict_with_exception

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :price) }

  validates :name, :slug, :tagline, presence: true
  validates :slug, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :credits_amount, numericality: { greater_than: 0 }

  def self.ensure_defaults!
    DEFAULT_PRODUCTS.each do |attributes|
      product = find_or_initialize_by(slug: attributes[:slug])
      product.assign_attributes(attributes.merge(active: true))
      product.save! if product.changed?
    end
  end
end
