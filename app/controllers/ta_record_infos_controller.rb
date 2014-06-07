class TaRecordInfosController < ApplicationController
  helper_method :sort_column, :sort_direction

  # GET /ta_record_infos
  # GET /ta_record_infos.json
  def index
    @ta_record_infos = TaRecordInfo.search(params[:search]).order(sort_column + " " + sort_direction).page params[:page]
  end

  def new
    @ta_record_info = TaRecordInfo.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ta_record_info }
    end
  end

  def edit
    @ta_record_info = TaRecordInfo.find(params[:id])
  end

  def create
    @ta_record_info = TaRecordInfo.new(params[:ta_record_info])

    respond_to do |format|
      if @ta_record_info.save
        format.html { redirect_to ta_record_infos_url, notice: 'New Time Record was successfully created.' }
        format.json { render json: @ta_record_info, status: :created, location: @ta_record_info }
      else
        format.html { render action: "new" }
        format.json { render json: @ta_record_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @ta_record_info = TaRecordInfo.find(params[:id])

    respond_to do |format|
      if @ta_record_info.update_attributes(params[:ta_record_info])
        format.html { redirect_to ta_record_infos_url, notice: 'Time Record was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ta_record_info.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @ta_record_info = TaRecordInfo.find(params[:id])
    @ta_record_info.destroy

    respond_to do |format|
      format.html { redirect_to ta_record_infos_url }
      format.json { head :no_content }
    end
  end

  private
  def sort_column
    TaRecordInfo.column_names.include?(params[:sort]) ? params[:sort] : "Date_Time"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
