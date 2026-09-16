/// User roles supported in the Factory App.
enum UserRole {
  worker,
  supervisor,
}

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.worker:
        return 'Factory Worker';
      case UserRole.supervisor:
        return 'Factory Supervisor';
    }
  }

  String get shortCode {
    switch (this) {
      case UserRole.worker:
        return 'WRK';
      case UserRole.supervisor:
        return 'SUP';
    }
  }

  bool get isWorker => this == UserRole.worker;
  bool get isSupervisor => this == UserRole.supervisor;
}
