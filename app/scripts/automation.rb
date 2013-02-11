class Automation
  def self.start
    controller = EmployeesController.new
    controller.time_record_import
    controller.time_record_generate
  end
end