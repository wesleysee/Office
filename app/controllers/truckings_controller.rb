class TruckingsController < ApplicationController

  # GET /truckings
  # GET /truckings.json
  def index
    @truckings = Trucking.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @truckings }
    end
  end

  # GET /truckings/1
  # GET /truckings/1.json
  def show
    @trucking = Trucking.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @trucking }
    end
  end

  # GET /truckings/new
  # GET /truckings/new.json
  def new
    @trucking = Trucking.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @trucking }
    end
  end

  # GET /truckings/1/edit
  def edit
    @trucking = Trucking.find(params[:id])
  end

  # POST /truckings
  # POST /truckings.json
  def create
    @trucking = Trucking.new(params[:trucking])

    respond_to do |format|
      if @trucking.save
        format.html { redirect_to @trucking, notice: 'Trucking was successfully created.' }
        format.json { render json: @trucking, status: :created, location: @trucking }
      else
        format.html { render action: "new" }
        format.json { render json: @trucking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /truckings/1
  # PUT /truckings/1.json
  def update
    @trucking = Trucking.find(params[:id])

    respond_to do |format|
      if @trucking.update_attributes(params[:trucking])
        format.html { redirect_to @trucking, notice: 'Trucking was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @trucking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /truckings/1
  # DELETE /truckings/1.json
  def destroy
    @trucking = Trucking.find(params[:id])
    @trucking.destroy

    respond_to do |format|
      format.html { redirect_to truckings_url }
      format.json { head :no_content }
    end
  end
end
