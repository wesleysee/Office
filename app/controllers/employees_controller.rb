require 'axlsx'

class EmployeesController < ApplicationController

  # GET /employees/show_monthly_report
  def show_monthly_report
    months_before = (params[:page].nil? ? 1 : params[:page]).to_i - 1
    this_month_end = Date.today.end_of_month
    @end_date = (this_month_end - (months_before.months)).end_of_month
    @start_date = @end_date.beginning_of_month

    min_date = TimeRecord.minimum(:date)
    min_date = Date.today if min_date.nil?
    num_of_pages = ((this_month_end - min_date).to_i)/30 + 1
    @pages = Kaminari.paginate_array((1..num_of_pages).to_a).page(params[:page]).per(1)

    @records = ActiveRecord::Base.connection.select_all('SELECT id, name, SUM(hours_estimate) AS hours, SUM(regular_pay) AS regular_pay, SUM(allowance_pay) AS allowance_pay, SUM(regular_pay + allowance_pay) AS total_pay
FROM
(SELECT e.id, e.name, t.date, t.regular_time_in_seconds / 3600 AS hours,
CASE WHEN t.regular_time_in_seconds/(3600) >= 6 THEN 1
WHEN t.regular_time_in_seconds/(3600) = 0 THEN 0
ELSE 0.5 END AS hours_estimate,
t.regular_service_pay +
CASE WHEN e.include_saturday_salary = 1 THEN t.adjusted_holiday_pay ELSE t.overtime_pay + t.holiday_pay END AS regular_pay,
t.allowance_pay AS allowance_pay
FROM employees e
INNER JOIN time_records t ON e.id = t.employee_id
LEFT OUTER JOIN holidays h ON h.date = t.date
WHERE t.date >= \'' + @start_date.to_s + '\' AND t.date <= \'' + @end_date.to_s + '\' AND (DAYOFWEEK(t.date) != 1 OR h.id IS NOT NULL) AND e.salaried = 1)
t GROUP BY t.name
ORDER BY t.name ASC')

    respond_to do |format|
      format.html # show_monthly_report.html.erb
    end
  end

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

    offset = 0
    sheet = nil
    employees.each do |employee|
      wb.styles do |s|
        header_style = s.add_style :b => true, :u => true, :alignment => {:horizontal => :center}
        centered = s.add_style :alignment => {:horizontal => :center, :wrap_text => true}
        bordered_centered = s.add_style :alignment => {:vertical => :center, :horizontal => :center, :wrap_text => true}, :border => {:color => 'FF000000', :style => :thin, :edges => [:bottom, :left, :right, :top]}
        bordered_centered_header = s.add_style :alignment => {:horizontal => :center, :wrap_text => true}, :border => {:color => 'FF000000', :style => :thin, :edges => [:bottom, :left, :right, :top]}
        bordered = s.add_style :alignment => {:vertical => :center}, :border => {:color => 'FF000000', :style => :thin, :edges => [:bottom, :left, :right, :top]}
        bottom_border = s.add_style :alignment => {:horizontal => :center}, :border => {:color => 'FF000000', :style => :thin, :edges => [:bottom]}
        time_style = s.add_style :format_code => "[$-409]h:mm AM/PM;@", :alignment => {:horizontal => :center, :vertical => :center}, :border => {:color => 'FF000000', :style => :thin, :edges => [:bottom, :left, :right, :top]}
        hour_style = s.add_style :format_code => "h:mm;@", :alignment => {:horizontal => :center, :vertical => :center}, :border => {:color => 'FF000000', :style => :thin, :edges => [:bottom, :left, :right, :top]}
        small = s.add_style :sz => 8, :alignment => {:vertical => :center, :horizontal => :center, :wrap_text => true}, :border => {:color => 'FF000000', :style => :thin, :edges => [:bottom, :left, :right, :top]}
        amount_style = s.add_style :format_code => "#,##0.00_);[Red](#,##0.00)", :alignment => {:vertical => :center, :horizontal => :center, :wrap_text => true}, :border => {:color => 'FF000000', :style => :thin, :edges => [:bottom, :left, :right, :top]}
        deduction_style = s.add_style :fg_color => "FF0000", :alignment => {:vertical => :center, :horizontal => :right}, :border => {:color => 'FF000000', :style => :thin, :edges => [:bottom, :left, :right, :top]}

        was_nil = sheet.nil?

        sheet = (employee.salaried ? wb.add_worksheet(:name => employee.name, :page_margins => margins) : wb.add_worksheet(:page_margins => margins)) if sheet.nil?

        sheet.add_row ["TIME RECORD AND PAYROLL"], :style => header_style
        sheet.merge_cells("A#{1 + offset}:I#{1 + offset}")
        
        4.times { sheet.add_row [] }

        sheet.add_row ["Name of Employee:", employee.name, "", "", "", "", "Pay Rate:", "", ""]

        sheet["H#{6 + offset}:I6"].each { |c| c.style = amount_style }
        sheet["B#{6 + offset}:E#{6 + offset}"].each { |c| c.style = bottom_border }
        sheet["H#{6 + offset}:I#{6 + offset}"].each { |c| c.style = bottom_border }
        sheet.merge_cells("B#{6 + offset}:E#{6 + offset}")
        sheet.merge_cells("H#{6 + offset}:I#{6 + offset}")

        sheet.add_row []

        sheet.add_row ["Period From:", start_date.strftime("%m/%d/%Y"), "", "to", end_date.strftime("%m/%d/%Y"), ""], :style => [nil, bottom_border, bottom_border, centered, bottom_border, bottom_border]
        sheet.merge_cells("B#{8 + offset}:C#{8 + offset}")
        sheet.merge_cells("E#{8 + offset}:F#{8 + offset}")

        3.times { sheet.add_row [] }

        sheet.add_row ["DAYS", "REGULAR TIME", "", "", "", "TOTAL HOURS", "", "SIGNATURE", ""], :style => bordered_centered_header, :height => 15
        sheet.add_row ["", "A.M.", "", "P.M.", "", "REGULAR TIME", "OVERTIME", "", ""], :style => bordered_centered_header, :height => 15
        sheet.add_row ["", "IN", "OUT", "IN", "OUT", "", "", "", ""], :style => bordered_centered_header, :height => 15
        sheet.merge_cells("A#{12 + offset}:A#{14 + offset}")
        sheet.merge_cells("B#{12 + offset}:E#{12 + offset}")
        sheet.merge_cells("H#{12 + offset}:I#{14 + offset}")
        sheet.merge_cells("B#{13 + offset}:C#{13 + offset}")
        sheet.merge_cells("D#{13 + offset}:E#{13 + offset}")

        if employee.overtime_multiplier != 1
          sheet.merge_cells("F#{12 + offset}:G#{12 + offset}")
          sheet.merge_cells("F#{13 + offset}:F#{14 + offset}")
          sheet.merge_cells("G#{13 + offset}:G#{14 + offset}")
        else
          sheet.merge_cells("F#{12 + offset}:G#{14 + offset}")
        end

        reg_service = [employee.overtime_multiplier != 1 ? "Reg. Service" : "Wage"]
        ot_service = ["O.T. Service"]
        allowance = ["Allowance"]
        holiday = ["Add. Holiday Pay"]
        total_wage = ["TOTAL WAGE"]
        net_amount = ["Net Amt Due"]

        c = "B"
        (1..6).each do |i|
          this_date = start_date + (i-1).days
          time_record = employee.time_records.where("date = ?", this_date).first
          am_start, am_end, pm_start, pm_end = nil

          if not employee.salaried
            reg_service.push ""
            ot_service.push ""
            allowance.push ""
            holiday.push ""
            total_wage.push ""
            net_amount.push ""
          end

          time_placeholder = ""
          if not time_record.nil?
            time_placeholder = "-"
            am_start = date_to_time time_record.am_start
            am_end = date_to_time time_record.am_end
            pm_start = date_to_time time_record.pm_start
            pm_end = date_to_time time_record.pm_end

            if employee.salaried
              reg_service.push time_record.regular_service_pay
              allowance.push time_record.allowance_pay
              holiday.push time_record.holiday_pay > 0 ? time_record.holiday_pay : ""
              if employee.overtime_multiplier != 1
                ot_service.push time_record.overtime_pay
                total_wage.push "=SUM(#{c}#{25 + offset}:#{c}#{27 + offset})"
                net_amount.push "=SUM(#{c}#{28 + offset}:#{c}29)"
              else
                ot_service.push "-"
                total_wage.push "=SUM(#{c}#{25 + offset}:#{c}#{26 + offset})"
                net_amount.push "=SUM(#{c}#{27 + offset}:#{c}#{28 + offset})"
              end
            end
          elsif this_date < Date.today
            time_placeholder = "-"

            am_start = "-"
            am_end = "-"
            pm_start = "-"
            pm_end = "-"

            if employee.salaried
              reg_service.push "-"
              ot_service.push "-"
              allowance.push "-"
              holiday.push ""
              total_wage.push "-"
              net_amount.push "-"
            end
          else
            reg_service.push ""
            ot_service.push ""
            allowance.push ""
            holiday.push ""
            total_wage.push ""
            net_amount.push ""
          end

          c = c.succ

          j = i + 14 + offset
          time_formula = "IF(B#{j}<>\"-\",C#{j}-B#{j},0)+IF(D#{j}<>\"-\",E#{j}-D#{j},0)"
          if employee.overtime_multiplier == 1
            reg_time_formula = "=IF(#{time_formula} = TIME(0,0,0), \"" + time_placeholder + "\"," +
                "#{time_formula})"
            overtime_formula = "-"
          else
            reg_time_formula = "=IF(#{time_formula} = TIME(0,0,0), \"" + time_placeholder + "\"," +
                "IF(#{time_formula}>TIME(#{employee.working_hours},0,0),TIME(#{employee.working_hours},0,0),#{time_formula}))"
            overtime_formula = "=IF(#{time_formula}>TIME(#{employee.working_hours},0,0),#{time_formula} - TIME(#{employee.working_hours},0,0),\"" + time_placeholder + "\")"
          end
          sheet.add_row [Date::DAYNAMES[i], am_start, am_end, pm_start, pm_end, reg_time_formula, overtime_formula, "", ""], :style => bordered, :height => 20
          sheet["B#{j}:E#{j}"].each { |c| c.style = time_style }
          sheet["F#{j}:G#{j}"].each { |c| c.style = hour_style }
          sheet.merge_cells("H#{j}:I#{j}")

          if employee.overtime_multiplier == 1
            sheet.merge_cells("F#{j}:G#{j}")
          end
        end

        3.times { sheet.add_row [] }

        sheet.column_widths 18, 11, 11, 11, 11, 11, 11, 9, 9

        if not employee.salaried
          if offset == 0
            offset = 23
          else
            offset = 0
            sheet = nil
          end
          next
        end

        sheet.add_row ["", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "TOTAL", ""], :style => bordered_centered, :height => 20
        sheet.merge_cells("H24:I24")
        sheet["B24:G24"].each { |c| c.style = small }

        if employee.salaried
          reg_service.push "=SUM(B25:G25)"
          if employee.overtime_multiplier != 1
            holiday.push "=IF(SUM(B29:G29) = 0, \"\", SUM(B29:G29))"
            allowance.push "=SUM(B27:G27)"
            ot_service.push "=SUM(B26:G26)"
            total_wage.push "=SUM(B28:G28)"
            net_amount.push "=SUM(H28:H34)"
          else
            holiday.push "=IF(SUM(B28:G28) = 0, \"\", SUM(B28:G28))"
            allowance.push "=SUM(B26:G26)"
            ot_service.push "-"
            total_wage.push "=SUM(B27:G27)"
            net_amount.push "=SUM(H27:H29)"
          end

          reg_service.push ""
          ot_service.push ""
          allowance.push ""
          holiday.push ""
          total_wage.push ""
          net_amount.push ""
        else
          2.times {
            reg_service.push ""
            ot_service.push ""
            allowance.push ""
            holiday.push ""
            total_wage.push ""
            net_amount.push ""
          }
        end

        deductions = employee.deductions.where("year = ? and week = ?", Date.today.year, Date.today.cweek)

        sss = ["", ""]
        salary_loan = ["", ""]
        pagibig = ["", ""]
        pagibig_loan = ["", ""]

        deductions.each do |deduction|
          case deduction.deduction_type_id
            when 1
              salary_loan[0] = deduction.deduction_month_str
              salary_loan[1] = deduction.amount * -1
            when 2
              pagibig[0] = deduction.deduction_month_str
              pagibig[1] = deduction.amount * -1
            when 3
              sss[0] = deduction.deduction_month_str
              sss[1] = deduction.amount * -1
          end
        end

        adj = 5

        sheet.add_row reg_service, :style => bordered, :height => 20

        if employee.overtime_multiplier != 1
          sheet.add_row ot_service, :style => bordered, :height => 20
        end

        sheet.add_row allowance, :style => bordered, :height => 20
        sheet.add_row total_wage, :style => bordered, :height => 20
        sheet.add_row holiday, :style => bordered, :height => 20
        sheet.add_row ["less: SSS/Philhealth", "", "", "", "", "", sss.first, sss.last, ""], :style => bordered, :height => 20

        if employee.overtime_multiplier != 1
          sheet.add_row ["=\"        witholding tax\"", "", "", "", "", "", "", "", ""], :style => bordered, :height => 20
          sheet.add_row ["=\"        Pag-ibig\"", "", "", "", "", "", pagibig.first, pagibig.last, ""], :style => bordered, :height => 20
          sheet.add_row ["=\"        Salary Loan\"", "", "", "", "", "", salary_loan.first, salary_loan.last, ""], :style => bordered, :height => 20
          sheet.add_row ["=\"        Pag-ibig Loan\"", "", "", "", "", "", pagibig_loan.first, pagibig_loan.last, ""], :style => bordered, :height => 20
          adj = 0
        end

        sheet.add_row net_amount, :style => bordered, :height => 20

        sheet["B25:I#{35-adj}"].each { |c| c.style = amount_style }

        if employee.overtime_multiplier != 1
          sheet.rows[27].cells[0].b = true
          sheet.rows[34].cells[0].b = true
          sheet["G30:G34"].each { |c| c.style = deduction_style }
        else
          sheet.rows[26].cells[0].b = true
          sheet.rows[29].cells[0].b = true
          sheet["G29:G29"].each { |c| c.style = deduction_style }
        end

        (25..(35-adj)).each do |i|
          sheet.merge_cells("H#{i}:I#{i}")
        end

        2.times { sheet.add_row [] }
        sheet.add_row ["", "", "", "", "", "", "Amount received by:", "", ""]
        sheet.merge_cells("G38:I38")

        offset = 0
        sheet = nil
      end
    end

    p.serialize(path + start_date.to_s + '_' + end_date.to_s + '.xlsx')
  end

  def date_to_time(date)
    if not date.nil? then
      date.strftime "%l:%M %p"
    else
      ""
    end
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
        elsif new_time.hour >= 11 and new_time.hour <= 15 and time_record.am_end.nil? and not time_record.am_start.nil? then
          time_record.am_end = new_time
        elsif new_time.hour >= 11 and new_time.hour <= 15 and time_record.pm_start.nil? then
          time_record.pm_start = new_time if time_record.am_end.nil? or time_record.am_end + 5.minutes < new_time
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
    worksheet[row, column] = value
  end

end
