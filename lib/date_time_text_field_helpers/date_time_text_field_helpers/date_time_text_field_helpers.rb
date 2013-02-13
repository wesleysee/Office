require File.dirname(__FILE__) + '/date_time_text_field_helpers/form_helpers'
require File.dirname(__FILE__) + '/date_time_text_field_helpers/instance_tag'
require File.dirname(__FILE__) + '/date_time_text_field_helpers/form_builder'

ActionView::Base.send(:include, DateTimeTextFieldHelpers::FormHelpers)
ActionView::Helpers::InstanceTag.send(:include, DateTimeTextFieldHelpers::InstanceTag)
ActionView::Helpers::FormBuilder.send(:include, DateTimeTextFieldHelpers::FormBuilder)
