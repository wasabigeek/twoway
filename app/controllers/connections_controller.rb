class ConnectionsController < ApplicationController
  before_action :set_connection, only: %i[ show edit update destroy ]

  # GET /connections or /connections.json
  def index
    @connections = Connection.all
  end

  # GET /connections/1 or /connections/1.json
  def show
    calendar_service = Google::Apis::CalendarV3::CalendarService.new
    calendar_service.authorization = Google::Auth::UserRefreshCredentials.new(
      client_id:     Rails.application.credentials.google_client_id,
      client_secret: Rails.application.credentials.google_client_secret,
      scope:         @connection.scope,
      access_token:  @connection.access_token,
      refresh_token: @connection.refresh_token,
      # expires_at:    data.fetch("expiration_time_millis", 0) / 1000
    )

    @calendars = calendar_service.list_calendar_lists()
  end

  # GET /connections/new
  def new
    @connection = Connection.new
  end

  # GET /connections/1/edit
  def edit
  end

  # POST /connections or /connections.json
  def create
    @connection = Connection.new(connection_params)

    respond_to do |format|
      if @connection.save
        format.html { redirect_to @connection, notice: "Connection was successfully created." }
        format.json { render :show, status: :created, location: @connection }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @connection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /connections/1 or /connections/1.json
  def update
    respond_to do |format|
      if @connection.update(connection_params)
        format.html { redirect_to @connection, notice: "Connection was successfully updated." }
        format.json { render :show, status: :ok, location: @connection }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @connection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /connections/1 or /connections/1.json
  def destroy
    @connection.destroy
    respond_to do |format|
      format.html { redirect_to connections_url, notice: "Connection was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_connection
      @connection = Connection.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def connection_params
      params.require(:connection).permit(:name)
    end
end
