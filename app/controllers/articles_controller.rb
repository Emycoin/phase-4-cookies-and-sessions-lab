class ArticlesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordNotFound, with: :page_limit_reached

  def increment_views
    session[:page_views] ||= 0
    session[:page_views] += 1
  end

  def index
    articles = Article.all.includes(:user).order(created_at: :desc)
    render json: articles, each_serializer: ArticleListSerializer
  end

  def show
    increment_views 
    if session[:page_views] >= 0 && session[:page_views] < 3
      article = Article.find(params[:id])
      render json: article
    else
      page_limit_reached
    end
  end

  private

  def record_not_found
    render json: { error: 'Article not found' }, status: :not_found
  end
  def page_limit_reached
    render json: { error: 'Maximum pageview limit reached' }, status: 401
  end
end
