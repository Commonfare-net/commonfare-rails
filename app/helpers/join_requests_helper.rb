module JoinRequestsHelper
  def join_request_image_path(join_request)
    return join_request.group.avatar.card if current_user.meta == join_request.commoner
    join_request.commoner.avatar.card
  end

  def join_request_title(join_request)
    return join_request.group.name if current_user.meta == join_request.commoner
    join_request.commoner.name
  end

  def join_request_description(join_request)
    return join_request.group.description if current_user.meta == join_request.commoner
    join_request.commoner.description
  end

  def join_request_status_icon(join_request)
    case join_request.aasm_state
    when 'accepted'
      fa_icon('check fw', class: 'text-success')
    when 'rejected'
      fa_icon('times fw', class: 'text-danger')
    when 'pending'
      fa_icon('clock-o fw', class: 'text-warning')
    else
      fa_icon('question-circle-o fw', class: 'text-info')
    end
  end
end
