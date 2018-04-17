module GroupsHelper
  def new_group_btn_text
    @new_group_after_signup.present? ? s_('Button|Confirm and create profile') : s_('Button|Create')
  end
end
