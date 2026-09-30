import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Backend status codes for Job Cards:
/// PATCH /api/v1/job-cards/{id}/status
abstract class JobCardStatusCode {
  static const int toAssign = 1;
  static const int pending = 2;
  static const int started = 3;
  static const int workInProgress = 4;
  static const int completed = 5;
  static const int reAssigned = 6;
}

/// Status of a Job Card / Voucher in production (aligned strictly with backend JobCardStatus 1..6).
enum JobStatus {
  toAssign, // 1: TO_ASSIGN
  pending, // 2: PENDING
  started, // 3: STARTED
  inProgress, // 4: WORK_IN_PROGRESS
  completed, // 5: COMPLETED
  reAssigned, // 6: RE_ASSIGNED
}

extension JobStatusExtension on JobStatus {
  int get code {
    switch (this) {
      case JobStatus.toAssign:
        return JobCardStatusCode.toAssign;
      case JobStatus.pending:
        return JobCardStatusCode.pending;
      case JobStatus.started:
        return JobCardStatusCode.started;
      case JobStatus.inProgress:
        return JobCardStatusCode.workInProgress;
      case JobStatus.completed:
        return JobCardStatusCode.completed;
      case JobStatus.reAssigned:
        return JobCardStatusCode.reAssigned;
    }
  }

  String get backendName {
    switch (this) {
      case JobStatus.toAssign:
        return 'TO_ASSIGN';
      case JobStatus.pending:
        return 'PENDING';
      case JobStatus.started:
        return 'STARTED';
      case JobStatus.inProgress:
        return 'WORK_IN_PROGRESS';
      case JobStatus.completed:
        return 'COMPLETED';
      case JobStatus.reAssigned:
        return 'RE_ASSIGNED';
    }
  }

  static JobStatus fromInt(int? code) {
    switch (code) {
      case 1:
        return JobStatus.toAssign;
      case 2:
        return JobStatus.pending;
      case 3:
        return JobStatus.started;
      case 4:
        return JobStatus.inProgress;
      case 5:
        return JobStatus.completed;
      case 6:
        return JobStatus.reAssigned;
      default:
        return JobStatus.pending;
    }
  }

  static JobStatus fromString(String? name) {
    if (name == null || name.trim().isEmpty) return JobStatus.pending;
    final normalized = name.trim().toUpperCase().replaceAll(' ', '_').replaceAll('-', '_');
    switch (normalized) {
      case '1':
      case 'TO_ASSIGN':
      case 'TOASSIGN':
        return JobStatus.toAssign;
      case '2':
      case 'PENDING':
        return JobStatus.pending;
      case '3':
      case 'STARTED':
        return JobStatus.started;
      case '4':
      case 'WORK_IN_PROGRESS':
      case 'IN_PROGRESS':
      case 'INPROGRESS':
        return JobStatus.inProgress;
      case '5':
      case 'COMPLETED':
      case 'COMPLETE':
        return JobStatus.completed;
      case '6':
      case 'RE_ASSIGNED':
      case 'REASSIGNED':
      case 'REASSIGN':
        return JobStatus.reAssigned;
      default:
        return JobStatus.pending;
    }
  }

  static JobStatus fromAny(dynamic value) {
    if (value == null) return JobStatus.pending;
    if (value is JobStatus) return value;
    if (value is int) return fromInt(value);
    if (value is num) return fromInt(value.toInt());
    final parsedInt = int.tryParse(value.toString());
    if (parsedInt != null) return fromInt(parsedInt);
    return fromString(value.toString());
  }

  String get label {
    switch (this) {
      case JobStatus.toAssign:
        return 'To Assign';
      case JobStatus.pending:
        return 'Pending';
      case JobStatus.started:
        return 'Started';
      case JobStatus.inProgress:
        return 'Work in Progress';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.reAssigned:
        return 'Reassigned';
    }
  }

  Color get textColor {
    switch (this) {
      case JobStatus.toAssign:
        return const Color(0xFF4338CA); // Indigo
      case JobStatus.pending:
        return FactoryColors.statusPendingText; // Crimson red
      case JobStatus.started:
        return const Color(0xFF1D4ED8); // Deep royal blue
      case JobStatus.inProgress:
        return FactoryColors.statusInProgressText; // Amber
      case JobStatus.completed:
        return FactoryColors.statusCompletedText; // Emerald green
      case JobStatus.reAssigned:
        return FactoryColors.statusWipPeachText; // Peach orange
    }
  }

  Color get backgroundColor {
    switch (this) {
      case JobStatus.toAssign:
        return const Color(0xFFEEF2FF); // Light indigo
      case JobStatus.pending:
        return FactoryColors.statusPendingBg; // Light red
      case JobStatus.started:
        return const Color(0xFFEFF6FF); // Light blue
      case JobStatus.inProgress:
        return FactoryColors.statusInProgressBg; // Light amber
      case JobStatus.completed:
        return FactoryColors.statusCompletedBg; // Light green
      case JobStatus.reAssigned:
        return FactoryColors.statusWipPeachBg; // Light peach
    }
  }

  Color get borderColor {
    switch (this) {
      case JobStatus.toAssign:
        return const Color(0xFFC7D2FE);
      case JobStatus.pending:
        return FactoryColors.statusPendingBorder;
      case JobStatus.started:
        return const Color(0xFFBFDBFE);
      case JobStatus.inProgress:
        return FactoryColors.statusInProgressBorder;
      case JobStatus.completed:
        return FactoryColors.statusCompletedBorder;
      case JobStatus.reAssigned:
        return FactoryColors.statusWipPeachBorder;
    }
  }

  bool get isToAssign => this == JobStatus.toAssign;
  bool get isPending => this == JobStatus.pending;
  bool get isStarted => this == JobStatus.started;
  bool get isInProgress => this == JobStatus.inProgress;
  bool get isCompleted => this == JobStatus.completed;
  bool get isReAssigned => this == JobStatus.reAssigned;
  bool get isActive => this == JobStatus.started || this == JobStatus.inProgress;
}
