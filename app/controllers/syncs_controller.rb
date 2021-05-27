class SyncsController < ApplicationController
  before_action :set_sync, only: %i[ show edit update destroy ]

  # GET /syncs or /syncs.json
  def index
    @syncs = Sync.all
  end

  # GET /syncs/1 or /syncs/1.json
  def show
  end

  # GET /syncs/new
  # def new
  #   @sync = Sync.new
  # end

  # GET /syncs/1/edit
  def edit
  end

  # POST /syncs or /syncs.json
  def create
    @sync = Sync.new(user: current_user)

    respond_to do |format|
      if @sync.save
        format.html { redirect_to @sync, notice: "Sync source was successfully created." }
        format.json { render :show, status: :created, location: @sync }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @sync.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /syncs/1 or /syncs/1.json
  def update
    respond_to do |format|
      if @sync.update(sync_params)
        format.html { redirect_to @sync, notice: "Sync source was successfully updated." }
        format.json { render :show, status: :ok, location: @sync }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @sync.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /syncs/1 or /syncs/1.json
  def destroy
    @sync.destroy
    respond_to do |format|
      format.html { redirect_to syncs_url, notice: "Sync source was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sync
      @sync = Sync.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def sync_params
      params.require(:sync).permit(:user_id)
    end
end
