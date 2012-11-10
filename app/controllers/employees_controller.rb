class EmployeesController < ApplicationController
  # GET /employees
  # GET /employees.json
  def index
    @employees = Employee.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @employees }
    end
  end

  # GET /employees/1
  # GET /employees/1.json
  def show
    @employee = Employee.find(params[:id])
    weeks_before = (params[:page].nil? ? 1 : params[:page]).to_i - 1
    this_week_end = Date.today.monday? ? Date.today - 1.day : Date.today.end_of_week
    @end_date = this_week_end - (weeks_before.weeks)
    @start_date = @end_date - 6.days
    @time_records = @employee.time_records.where("date >= ? and date <= ?", @start_date, @end_date)
    min_date = @employee.time_records.minimum(:date)
    num_of_pages = ((this_week_end - min_date).to_i)/7 + 1
    @pages = Kaminari.paginate_array((1..num_of_pages).to_a).page(params[:page]).per(1)

    @weekly_reg_pay = 0
    @weekly_ot_pay = 0
    @weekly_allowance = 0
    @sat_net_pay = 0
	  @weekly_deductions = 0
    @weekly_holiday_pay = 0
    sun_pay = 0

    has_saturday = false
    temp_date = Date.today
    @time_records.each do |time_record|
      temp_date = time_record.date
      if time_record.date.sunday?
        sun_pay = time_record.total_pay
        next
      end
	    @weekly_reg_pay += time_record.regular_service_pay
      @weekly_deductions += time_record.deductions
      @weekly_ot_pay += time_record.overtime_pay
      @weekly_allowance += time_record.allowance_pay
      @weekly_holiday_pay += time_record.holiday_pay
      if time_record.date.saturday?
        has_saturday = true
        @sat_net_pay = time_record.total_pay - time_record.salary if @employee.include_saturday_salary
      end
    end

    @weekly_reg_pay += @employee.salary if not has_saturday and @employee.include_saturday_salary and (Date.today - temp_date.end_of_week).to_i <= 1
	  @weekly_reg_pay_with_ded = @weekly_reg_pay - @weekly_deductions + @weekly_holiday_pay
    @weekly_total_pay = @weekly_reg_pay_with_ded + @weekly_ot_pay + @weekly_allowance
    @sat_sun_pay = @sat_net_pay + sun_pay

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @employee }
    end
  end

  # GET /employees/new
  # GET /employees/new.json
  def new
    @employee = Employee.new
    @employee.salary = 426

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @employee }
    end
  end

  # GET /employees/1/edit
  def edit
    @employee = Employee.find(params[:id])
  end

  # POST /employees
  # POST /employees.json
  def create
    @employee = Employee.new(params[:employee])

    respond_to do |format|
      if @employee.save
        format.html { redirect_to @employee, notice: 'Employee was successfully created.' }
        format.json { render json: @employee, status: :created, location: @employee }
      else
        format.html { render action: "new" }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /employees/1
  # PUT /employees/1.json
  def update
    @employee = Employee.find(params[:id])

    respond_to do |format|
      if @employee.update_attributes(params[:employee])
        format.html { redirect_to @employee, notice: 'Employee was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employees/1
  # DELETE /employees/1.json
  def destroy
    @employee = Employee.find(params[:id])
    @employee.destroy

    respond_to do |format|
      format.html { redirect_to employees_url }
      format.json { head :no_content }
    end
  end
end
