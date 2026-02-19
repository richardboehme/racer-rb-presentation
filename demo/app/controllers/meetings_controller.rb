class MeetingsController < ApplicationController
  def index
    @meetings = Meeting.order(held_on: :desc)
  end

  def show
    @meeting = Meeting.find(params[:id])
  end
end
