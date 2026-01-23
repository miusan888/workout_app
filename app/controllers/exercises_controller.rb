class ExercisesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_exercise, only: %i[edit update destroy]

  def index
    @exercise = Exercise.new
    @exercises = current_user.exercises.order(exercised_on: :desc)
  
    weekly = @exercises.group_by { |e| e.exercised_on.to_date.beginning_of_week }
  
    @graph_labels = weekly.keys.sort.map { |d| "#{d.strftime('%m/%d')}週" }
    @graph_data = weekly.keys.sort.map do |week|
      weekly[week].sum { |e| e.duration.to_i }
    end
  end
  
  def create
    @exercise = current_user.exercises.build(exercise_params)
    if @exercise.save
      redirect_to exercises_path, notice: "運動を記録しました！", status: :see_other
    else
      @exercises = current_user.exercises.order(exercised_on: :desc)
  
      weekly = @exercises.group_by { |e| e.exercised_on.to_date.beginning_of_week }
      @graph_labels = weekly.keys.sort.map { |d| "#{d.strftime('%m/%d')}週" }
      @graph_data = weekly.keys.sort.map { |week| weekly[week].sum { |e| e.duration.to_i } }
  
      render :index
    end
  end
  
  

  def edit; end

  def update
    if @exercise.update(exercise_params)
      redirect_to exercises_path, notice: "運動を更新しました！"
    else
      render :edit
    end
  end

  def destroy
    @exercise.destroy
    redirect_to exercises_path, notice: "運動を削除しました！"
  end

  private

  def set_exercise
    @exercise = current_user.exercises.find(params[:id])
  end

  def exercise_params
    params.require(:exercise).permit(:name, :duration, :exercised_on)
  end
end
