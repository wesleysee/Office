class TaRecordInfosController < ApplicationController
  helper_method :sort_column, :sort_direction

  # GET /ta_record_infos
  # GET /ta_record_infos.json
  def index
    @ta_record_infos = TaRecordInfo.search(params[:search]).order(sort_column + " " + sort_direction).page params[:page]
  end

  private
    def sort_column
      TaRecordInfo.column_names.include?(params[:sort]) ? params[:sort] : "Date_Time"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : "desc"
    end
end
