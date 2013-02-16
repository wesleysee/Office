require 'axlsx'

class EmployeesController < ApplicationController

  # GET /employees/generate_time_records
  def generate_time_records
    time_record_generate

    respond_to do |format|
      format.html { redirect_to employees_path, notice: 'Successfully generated.' }
    end
  end

  # GET /employees/import_from_machine
  def import_from_machine
    time_record_import

    respond_to do |format|
      format.html { redirect_to time_records_path, notice: 'Successfully imported.' }
    end
  end

  def time_record_generate
    path = Rails.application.config.time_records_folder_location
    employees = Employee.where("generate_time_record = true").order("id asc")

    end_date = (Date.today.monday? ? Date.today - 1.day : Date.today.end_of_week) - 1.day
    start_date = end_date - 5.days

    p = Axlsx::Package.new
    p.use_autowidth = false
    wb = p.workbook
    wb.styles.fonts.first.sz = 10
    margins = {:left => 0.25, :right => 0.25, :top => 0.75, :bottom => 0.75, :header => 0.3, :footer => 0.3}

    employees.each do |employee|
      wb.styles do |s|
        header_style = s.add_style :b => true, :u => true, :alignment => { :horizontal=> :center }
        centered = s.add_style :alignment => { :horizontal=> :center, :wrap_text => true }
        bordered_centered = s.add_style :alignment => { :vertical => :center, :horizontal=> :center, :wrap_text => true }, :border => { :color => 'FF000000', :style => :thin, :edges => [:bottom, :left, :right, :top] }
        bordered_centered_header = s.add_style :alignment => { :horizontal=> :center, :wrap_text => true }, :border => { :color => 'FF000000', :style => :thin, :edges => [:bottom, :left, :right, :top] }
        bordered = s.add_style :alignment => { :vertical => :center }, :border => { :color => 'FF000000', :style => :thin, :edges => [:bottom, :left, :right, :top] }
        bottom_border = s.add_style :alignment => { :horizontal=> :center }, :border => { :color => 'FF000000', :style => :thin, :edges => [:bottom] }
        time_style = s.add_style :format_code => "[$-409]h:mm AM/PM;@", :alignment => { :horizontal => :center, :vertical => :center }, :border => { :color => 'FF000000', :style => :thin, :edges => [:bottom, :left, :right, :top] }
        hour_style = s.add_style :format_code => "h:mm;@", :alignment => { :horizontal => :center, :vertical => :center }, :border => { :color => 'FF000000', :style => :thin, :edges => [:bottom, :left, :right, :top] }
        small = s.add_style :sz => 8, :alignment => { :vertical => :center, :horizontal=> :center, :wrap_text => true }, :border => { :color => 'FF000000', :style => :thin, :edges => [:bottom, :left, :right, :top] }

        wb.add_worksheet(:name => employee.name, :page_margins => margins) do |sheet|
          sheet.add_row ["TIME RECORD AND PAYROLL"], :style => header_style
          sheet.merge_cells("A1:I1")

          4.times { sheet.add_row [] }

          salary = employee.salaried ? employee.salary.to_s : ""

          sheet.add_row [ "Name of Employee:", employee.name, "", "", "", "", "Pay Rate:", salary, ""]
          sheet["B6:E6"].each { |c| c.style = bottom_border }
          sheet["H6:I6"].each { |c| c.style = bottom_border }
          sheet.merge_cells("B6:E6")
          sheet.merge_cells("H6:I6")

          sheet.add_row []

          sheet.add_row [ "Period From:", start_date.strftime("%m/%d/%Y"), "", "to", end_date.strftime("%m/%d/%Y"), ""], :style => [nil, bottom_border, bottom_border, centered, bottom_border, bottom_border]
          sheet.merge_cells("B8:C8")
          sheet.merge_cells("E8:F8")

          3.times { sheet.add_row [] }

          sheet.add_row [ "DAYS", "REGULAR TIME", "", "", "", "TOTAL HOURS", "", "SIGNATURE", "" ], :style => bordered_centered_header, :height => 15
          sheet.add_row [ "", "A.M.", "", "P.M.", "", "REGULAR TIME", "OVERTIME", "", ""], :style => bordered_centered_header, :height => 15
          sheet.add_row [ "", "IN", "OUT", "IN", "OUT", "", "", "", ""], :style => bordered_centered_header, :height => 15
          sheet.merge_cells("A12:A14")
          sheet.merge_cells("B12:E12")
          sheet.merge_cells("F12:G12")
          sheet.merge_cells("H12:I14")
          sheet.merge_cells("B13:C13")
          sheet.merge_cells("D13:E13")
          sheet.merge_cells("F13:F14")
          sheet.merge_cells("G13:G14")

          (1..6).each do |i|
            time_record = employee.time_records.where("date = ?", start_date + (i-1).days).first
            am_start, am_end, pm_start, pm_end = nil
            if not time_record.nil?
              am_start = time_record.am_start
              am_end = time_record.am_end
              pm_start = time_record.pm_start
              pm_end = time_record.pm_end
            end

            j = i + 14
            reg_time_formula = "=IF(C#{j}-B#{j}+E#{j}-D#{j} = TIME(0,0,0), \"-\"," +
                    "IF(C#{j}-B#{j}+E#{j}-D#{j}>TIME(#{employee.working_hours},0,0),TIME(#{employee.working_hours},0,0),C#{j}-B#{j}+E#{j}-D#{j}))"
            overtime_formula = "=IF(C#{j}-B#{j}+E#{j}-D#{j}>TIME(#{employee.working_hours},0,0),C#{j}-B#{j}+E#{j}-D#{j} - TIME(#{employee.working_hours},0,0),\"-\")"

            sheet.add_row [Date::DAYNAMES[i], am_start, am_end, pm_start, pm_end, reg_time_formula, overtime_formula, "", ""], :style => bordered, :height => 20
            sheet["B#{j}:E#{j}"].each { |c| c.style = time_style }
            sheet["F#{j}:G#{j}"].each { |c| c.style = hour_style }
            sheet.merge_cells("H#{j}:I#{j}")
          end

          3.times { sheet.add_row [] }

          sheet.add_row [ "", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "TOTAL", "" ], :style => bordered_centered, :height => 20
          sheet.merge_cells("H24:I24")
          sheet["B24:G24"].each { |c| c.style = small }

          sheet.add_row [ "Reg. Service", "", "", "", "", "", "", "", "" ], :style => bordered, :height => 20
          sheet.add_row [ "O.T. Service", "", "", "", "", "", "", "", "" ], :style => bordered, :height => 20
          sheet.add_row [ "Allowance", "", "", "", "", "", "", "", "" ], :style => bordered, :height => 20
          sheet.add_row [ "TOTAL WAGE", "", "", "", "", "", "", "", "" ], :style => bordered, :height => 20
          sheet.add_row [ "Add. Holiday Pay", "", "", "", "", "", "", "", "" ], :style => bordered, :height => 20
          sheet.add_row [ "less: SSS/Philhealth", "", "", "", "", "", "", "", "" ], :style => bordered, :height => 20
          sheet.add_row [ "=\"        witholding tax\"", "", "", "", "", "", "", "", "" ], :style => bordered, :height => 20
          sheet.add_row [ "=\"        Pag-ibig\"", "", "", "", "", "", "", "", "" ], :style => bordered, :height => 20
          sheet.add_row [ "=\"        Salary Loan\"", "", "", "", "", "", "", "", "" ], :style => bordered, :height => 20
          sheet.add_row [ "=\"        Pag-ibig Loan\"", "", "", "", "", "", "", "", "" ], :style => bordered, :height => 20
          sheet.add_row [ "Net Amt. Due", "", "", "", "", "", "", "", "" ], :style => bordered, :height => 20
          sheet.rows[27].cells[0].b = true
          sheet.rows[34].cells[0].b = true

          (25..35).each do |i|
            sheet.merge_cells("H#{i}:I#{i}")
          end

          2.times { sheet.add_row [] }
          sheet.add_row [ "", "", "", "", "", "", "Amount received by:", "", "" ]
          sheet.merge_cells("G38:I38")

          sheet.column_widths 18, 11, 11, 11, 11, 11, 11, 9, 9
        end
      end
    end

    p.serialize(path + start_date.to_s + '_' + end_date.to_s + '.xlsx')
  end

  def time_record_import
    employees = Employee.all

    count = 0
    employees.each do |employee|
      next if employee.salaried and employee.include_saturday_salary
      employee_records = employee.ta_record_infos
      time_record = nil
      employee_records.each do |employee_record|
        record_date = employee_record.Date_Time.to_date
        next if record_date >= Date.today and Time.new.hour < 18
        if time_record.nil? then
          time_record = employee.time_records.where(:date => record_date).first
        elsif time_record.date != record_date then
          time_record.save if time_record.changed?
          time_record = employee.time_records.where(:date => record_date).first
        end
        if time_record.nil?
          time_record = employee.time_records.build
          time_record.salary = time_record.employee.salary
          time_record.date = record_date
          time_record.deductions = 0
        end
        new_time = Time.parse(employee_record.Date_Time + ' UTC').round(5.minutes)
        if new_time.hour < 11 and time_record.am_start.nil? then
          time_record.am_start = new_time
        elsif new_time.hour >= 11 and new_time.hour <= 15 and time_record.am_end.nil? then
          time_record.am_end = new_time
        elsif new_time.hour >= 11 and new_time.hour <= 15 and time_record.pm_start.nil? then
          time_record.pm_start = new_time
        elsif time_record.pm_end.nil? then
          time_record.pm_end = new_time
        end
        employee_record.imported = true
        employee_record.save
        count += 1
      end
      if not time_record.nil? and time_record.changed? then
        time_record.save
        count += 1
      end
    end
    count
  end

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
    @time_records = @employee.time_records.where("date >= ? and date <= ?", @start_date, @end_date).reverse
    min_date = @employee.time_records.minimum(:date)
    min_date = Date.today if min_date.nil?
    num_of_pages = ((this_week_end - min_date).to_i)/7 + 1
    @pages = Kaminari.paginate_array((1..num_of_pages).to_a).page(params[:page]).per(1)

    @deductions = @employee.deductions.where("year = ? and week = ?", @end_date.year, @end_date.cweek)

    @weekly_reg_pay = 0
    @weekly_ot_pay = 0
    @weekly_allowance = 0
    @sat_net_pay = 0
	  @weekly_deductions = 0
    @weekly_holiday_pay = 0
    @gov_deductions = 0
    sun_pay = 0

    @deductions.each do |deduction|
      @weekly_deductions += deduction.amount
      @gov_deductions += deduction.amount
    end

    has_saturday = false
    temp_date = Date.today
    @time_records.each do |time_record|
      puts time_record.date
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

  private
    def replace_cell(worksheet, row, column, value)
      worksheet[row,column] = value
    end
end
