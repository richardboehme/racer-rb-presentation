class ParticipantsController < ApplicationController
  def index
    @participants = Participant.order(:name)
  end

  def show
    @participant = Participant.find(params[:id])
  end
end
