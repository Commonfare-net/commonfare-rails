module GroupsHelper
  def new_group_btn_text
    @new_group_after_signup.present? ? s_('Button|Confirm and create profile') : s_('Button|Create')
  end

  def invite_member_btn_text(group)
    return s_('Button|Invite member') if user_signed_in? && current_user.meta.member_of?(group)
    s_('Button|Share this group')
  end
end
