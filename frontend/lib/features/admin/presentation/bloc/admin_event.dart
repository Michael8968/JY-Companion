sealed class AdminEvent {
  const AdminEvent();
}

class AdminLoadEvent extends AdminEvent {
  const AdminLoadEvent();
}

class AdminLoadUsersEvent extends AdminEvent {
  const AdminLoadUsersEvent({this.page = 1, this.role});
  final int page;
  final String? role;
}

class AdminUpdateUserStatusEvent extends AdminEvent {
  const AdminUpdateUserStatusEvent({
    required this.userId,
    required this.isActive,
  });
  final String userId;
  final bool isActive;
}

class AdminLoadAlertsEvent extends AdminEvent {
  const AdminLoadAlertsEvent({this.page = 1, this.status});
  final int page;
  final String? status;
}

class AdminResolveAlertEvent extends AdminEvent {
  const AdminResolveAlertEvent({required this.alertId, this.notes});
  final String alertId;
  final String? notes;
}
