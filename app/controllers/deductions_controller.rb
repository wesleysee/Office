class DeductionsController < ApplicationController

  def show
    @employee = Employee.find(params[:employee_id])
    @deduction = @employee.deductions.find_by_id(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @deduction }
    end
  end

  def new
    @employee = Employee.find(params[:employee_id])
    @deduction = @employee.deductions.build

    weeks_ago = params[:week_ago]
    weeks_ago = 1 if weeks_ago.nil?
    weeks_ago = weeks_ago.to_i - 1
    deduction_date = Date.today - weeks_ago.weeks
    @deduction.week = deduction_date.cweek
    @deduction.year = deduction_date.year

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @deduction }
    end
  end

  def edit
    @employee = Employee.find(params[:employee_id])
    @deduction = @employee.deductions.find_by_id(params[:id])
  end

  def create
    @employee = Employee.find(params[:employee_id])
    @deduction = @employee.deductions.build(params[:deduction])

    respond_to do |format|
      if @deduction.save
        format.html { redirect_to @employee, notice: 'Deduction was successfully created.' }
        format.json { render json: @deduction, status: :created, location: @deduction }
      else
        format.html { render action: "new" }
        format.json { render json: @deduction.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @employee = Employee.find(params[:employee_id])
    @deduction = @employee.deductions.find_by_id(params[:id])

    respond_to do |format|
      if @deduction.update_attributes(params[:deduction])
        format.html { redirect_to @employee, notice: 'Deduction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @deduction.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @employee = Employee.find(params[:employee_id])
    @deduction = @employee.deductions.find_by_id(params[:id])
    @deduction.destroy

    respond_to do |format|
      format.html { redirect_to @employee }
      format.json { head :no_content }
    end
  end
end
