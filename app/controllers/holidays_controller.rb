# encoding: utf-8

require 'nokogiri'
require 'open-uri'

class HolidaysController < ApplicationController
  helper_method :sort_column, :sort_direction

  def index
    if not params[:retrieve].nil?
      retrieve_holidays(params[:retrieve])
    end

    @holidays = Holiday.search(params[:search]).order(sort_column + " " + sort_direction).page params[:page]
  end

  def retrieve_holidays(url)
    doc = Nokogiri::HTML(open(url))

    doc.css('div#main-content div.large-6 div.entry-content p').each do |entry|
      content_split = entry.content.split(" ")
      if not entry.content.nil? and Date::MONTHNAMES.include? content_split[0]
        index = entry.content.index("–")
        date = Date.parse(entry.content[0..index])

        existing = Holiday.where("date = ?", date).first

        if existing.nil?
          last_index = entry.content.rindex("(")
          name = entry.content[index + 2..last_index - 1].strip
          type = entry.content[last_index + 1..-2]

          holiday = Holiday.new
          holiday.date = date
          holiday.name = name
          holiday.multiplier = (type.downcase.include? "non-working") ? 0.3 : 1
          holiday.save
        end
      end
    end

  end

  # GET /holidays/1
  # GET /holidays/1.json
  def show
    @holiday = Holiday.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @holiday }
    end
  end

  # GET /holidays/new
  # GET /holidays/new.json
  def new
    @holiday = Holiday.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @holiday }
    end
  end

  # GET /holidays/1/edit
  def edit
    @holiday = Holiday.find(params[:id])
  end

  # POST /holidays
  # POST /holidays.json
  def create
    @holiday = Holiday.new(params[:holiday])

    respond_to do |format|
      if @holiday.save
        format.html { redirect_to holidays_url, notice: 'Holiday was successfully created.' }
        format.json { render json: @holiday, status: :created, location: @holiday }
      else
        format.html { render action: "new" }
        format.json { render json: @holiday.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /holidays/1
  # PUT /holidays/1.json
  def update
    @holiday = Holiday.find(params[:id])

    respond_to do |format|
      if @holiday.update_attributes(params[:holiday])
        format.html { redirect_to holidays_url, notice: 'Holiday was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @holiday.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /holidays/1
  # DELETE /holidays/1.json
  def destroy
    @holiday = Holiday.find(params[:id])
    @holiday.destroy

    respond_to do |format|
      format.html { redirect_to holidays_url }
      format.json { head :no_content }
    end
  end

  private
  def sort_column
    Holiday.column_names.include?(params[:sort]) ? params[:sort] : "Date"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
