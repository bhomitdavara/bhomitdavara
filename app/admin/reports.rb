ActiveAdmin.register Report do
  menu label: "Reported Users"
  actions :all, except: :new
  scope :active_report, default: true
  scope :all_users_history

  index download_links: [nil] do
    column :user
    column :description
    column 'Reported User' do |report|
      link_to report.reported_user.email , "/admin/users/#{report.reported_user_id}"
    end
    column 'Status' do |report|
      if report.approved? 
        raw('<i class="fas fa-check active"></i>')
      elsif report.rejected?
        raw('<i class="fas fa-times reject"></i>')
      elsif report.review?
        raw('<i class="fas fa-eye"></i>')
      end
    end

    column 'Action' do |report|
      links = []
      div class: "table_actions" do
        if report.review? || report.rejected?
          links << link_to(raw("<i class='fas fa-check'></i> Approve"), approve_report_admin_report_path(report),
                          method: :post, data: { confirm: 'Are you sure approve post?' }, class: 'edit_link member_link')
        end

        if report.review? || report.approved?
          links << link_to(raw("<i class='fas fa-times'></i> Reject"), reject_report_admin_report_path(report),
                          method: :post, data: { confirm: 'Are you sure reject post?' }, class: 'delete_link member_link')
        end
        links.join('   ').html_safe
      end
    end
  end

  member_action :approve_report, method: :post do
    report = Report.find(params[:id])
    user = User.find(report.reported_user_id)
    user.update(status: 1)
    Report.where(reported_user_id: report.reported_user_id).update(is_delete: true)
    redirect_to admin_reports_path, notice: 'Report approved successfully' if report.update(status: 1)
    Message.create(sender_type: "AdminUser", conversation_id: user.conversation.id, content: t('post.check.message'), sender_id: current_admin_user.id) if user.conversation.present?
  end

  member_action :reject_report, method: :post do
    report = Report.find(params[:id])
    user = User.find(report.reported_user_id)
    user.update(status: 0)
    Report.where(reported_user_id: report.reported_user_id).update(is_delete: true)
    redirect_to admin_reports_path, notice: 'Report rejected successfully' if report.update(status: 2)
  end
end
