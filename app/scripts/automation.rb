class Automation
  def self.start
    controller = EmployeesController.new
    count = controller.time_record_import
    controller.time_record_generate if count > 0
  end
end