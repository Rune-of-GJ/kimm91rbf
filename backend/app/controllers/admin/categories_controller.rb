module Admin
  class CategoriesController < BaseController
    before_action :set_category, only: [:update, :destroy]

    def index
      @query = params[:q].to_s.strip
      @new_category = Category.new
      load_index_data
    end

    def create
      @query = params[:q].to_s.strip
      @new_category = Category.new(category_params)

      if @new_category.save
        redirect_to admin_categories_path(q: @query.presence), notice: "#{@new_category.name} 카테고리를 만들었습니다."
      else
        load_index_data
        render :index, status: :unprocessable_entity
      end
    end

    def update
      @query = params[:q].to_s.strip

      if @category.update(category_params)
        redirect_to admin_categories_path(q: @query.presence), notice: "#{@category.name} 카테고리를 수정했습니다."
      else
        @new_category = Category.new
        load_index_data
        render :index, status: :unprocessable_entity
      end
    end

    def destroy
      category_name = @category.name

      if @category.destroy
        redirect_to admin_categories_path(q: params[:q].presence), notice: "#{category_name} 카테고리를 삭제했습니다."
      else
        redirect_to admin_categories_path(q: params[:q].presence), alert: @category.errors.full_messages.join(", ")
      end
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :description)
    end

    def load_index_data
      @category_counts = {
        total: Category.count,
        courses: Course.count,
        used: Category.joins(:courses).distinct.count,
        empty: Category.left_outer_joins(:courses).where(courses: { id: nil }).distinct.count
      }

      scope = Category.includes(:courses).order(created_at: :desc)
      if @query.present?
        pattern = "%#{ActiveRecord::Base.sanitize_sql_like(@query)}%"
        scope = scope.where("categories.name LIKE :pattern OR categories.description LIKE :pattern", pattern: pattern)
      end
      @categories = scope
    end
  end
end
