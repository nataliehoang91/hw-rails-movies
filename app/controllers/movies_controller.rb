class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
     if !params[:sort].present? && session[:sort].present?
      redirect_to movies_path({:sort => session[:sort]}.merge(params))
      return
    end
    
    if !params[:ratings].present? && session[:ratings].present?
      redirect_to movies_path({:ratings => session[:ratings]}.merge(params))
      return
    end

    session[:sort] = params[:sort]
    session[:ratings] = params[:ratings]
    
    if params[:sort] == "title" 
      @movies=Movie.all.order(:title)
    elsif params[:sort]== "release_date"
      @movies=Movie.all.order(:release_date)
    else
      @movies = Movie.all
    end

    selected_ratings = Movie.all_ratings
    
    if params[:ratings].present?
      selected_ratings = params[:ratings].keys
      @movies = @movies.where(rating: params[:ratings].keys)
    end

    @all_ratings = Movie.all_ratings.map{ |rating| {name: rating, checked: selected_ratings.include?(rating)}}
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
