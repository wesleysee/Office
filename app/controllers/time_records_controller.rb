class TimeRecordsController < ApplicationController

  # GET /time_records
  def index
    @time_records = TimeRecord.order(:created_at).page params[:page]
  end

  def show
    @employee = Employee.find(params[:employee_id])
    @time_record = @employee.time_records.find_by_id(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @time_record }
    end
  end

  def new
    @employee = Employee.find(params[:employee_id])
    @time_record = @employee.time_records.build
    @time_record.init
    last_time_record = TimeRecord.find_by_employee_id(@employee.id)
    @time_record.date = last_time_record.nil? ? (Date.today - 1.day) : (last_time_record.date + 1.day)
    @time_record.date = @time_record.date + 1.day if @time_record.date.sunday? and not Date.today.monday?

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @time_record }
    end
  end

  def edit
    @employee = Employee.find(params[:employee_id])
    @time_record = @employee.time_records.find_by_id(params[:id])
    @time_record.init
  end

  def create
    @employee = Employee.find(params[:employee_id])
    @time_record = @employee.time_records.build(params[:time_record])

    respond_to do |format|
      if @time_record.save
        format.html { redirect_to @employee, notice: 'Time Record was successfully created.' }
        format.json { render json: @time_record, status: :created, location: @time_record }
      else
        format.html { render action: "new" }
        format.json { render json: @time_record.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @employee = Employee.find(params[:employee_id])
    @time_record = @employee.time_records.find_by_id(params[:id])

    respond_to do |format|
      if @time_record.update_attributes(params[:time_record])
        format.html { redirect_to @employee, notice: 'Time Record was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @time_record.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @employee = Employee.find(params[:employee_id])
    @time_record = @employee.time_records.find_by_id(params[:id])
    @time_record.destroy

    respond_to do |format|
      format.html { redirect_to @employee }
      format.json { head :no_content }
    end
  end

  def calculator
    @employee = Employee.find(params[:employee_id])
    @time_record = @employee.time_records.build(params[:time_record])
    @time_record.do_calculations
    respond_to do |format|
      format.js
    end
  end

  # GET /employees/bulk_add
  def bulk_add
    @errors = []
    @errors_count = 0
    employees = Employee.where("salaried = ? and include_saturday_salary = ?", true, true)
    @time_records = employees.map do |employee|
      time_record = employee.time_records.build
      time_record.init
      time_record
    end

    respond_to do |format|
      format.html # bulk_add.html.erb
    end
  end

  def bulk_create
    success = true
    @time_records = []
    @errors = []
    @errors_count = 0
    TimeRecord.transaction do
      params[:time_records].each do |p|
        employee = Employee.find(p[0])
        p[1].merge! params[:time_record]
        time_record = employee.time_records.build(p[1])
        success = (success and time_record.save)
        if time_record.errors.any?
          @errors.concat(time_record.errors.full_messages)
          @errors_count += time_record.errors.count
        end
        @time_records.push(time_record)
        raise ActiveRecord::Rollback if not success
      end
    end

    respond_to do |format|
      if success
        format.html { redirect_to employees_path, notice: 'Time Records were successfully created.' }
      else
        format.html { render action: "bulk_add" }
      end
    end
  end

  def bulk_calculator
    @holiday = Holiday.find_by_date Date.civil(params[:time_record]["date(1i)"].to_i, params[:time_record]["date(2i)"].to_i, params[:time_record]["date(3i)"].to_i)
    @time_records = []
    if not params.nil? and not params[:time_records].nil?
      params[:time_records].each do |p|
        employee = Employee.find(p[0])
        p[1].merge! params[:time_record]
        time_record = employee.time_records.build(p[1])
        time_record.do_calculations
        @time_records.push(time_record)
      end
    end

    respond_to do |format|
      format.js
    end
  end

  def send_notifications
    @employee = Employee.find(params[:employee_id])
    @time_record = @employee.time_records.find_by_id(params[:time_record_id])
    @time_record.send_notifications

    respond_to do |format|
      format.html { redirect_to @employee }
    end
  end

end
