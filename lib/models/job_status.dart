import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Status of a Job Card / Voucher in production (aligned with backend JobCardStatus 1..6).
enum JobStatus {
  toAssign, // 1
  pending, // 2
  started, // 3
  inProgress, // 4
  completed, // 5
  reAssigned, // 6
  onHold,
}

extension JobStatusExtension on JobStatus {
  int get code {
    switch (this) {
      case JobStatus.toAssign:
        return 1;
      case JobStatus.pending:
        return 2;
      case JobStatus.started:
        return 3;
      case JobStatus.inProgress:
        return 4;
      case JobStatus.completed:
        return 5;
      case JobStatus.reAssigned:
        return 6;
      case JobStatus.onHold:
        return 2; // Default to pending if not directly matched
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
      case JobStatus.onHold:
        return 'On Hold';
    }
  }

  Color get textColor {
    switch (this) {
      case JobStatus.toAssign:
        return FactoryColors.statusPendingText;
      case JobStatus.pending:
        return FactoryColors.statusPendingText;
      case JobStatus.started:
      case JobStatus.inProgress:
        return FactoryColors.statusInProgressText;
      case JobStatus.completed:
        return FactoryColors.statusCompletedText;
      case JobStatus.reAssigned:
        return FactoryColors.statusWipPeachText;
      case JobStatus.onHold:
        return FactoryColors.statusOnHoldText;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case JobStatus.toAssign:
        return FactoryColors.statusPendingBg;
      case JobStatus.pending:
        return FactoryColors.statusPendingBg;
      case JobStatus.started:
      case JobStatus.inProgress:
        return FactoryColors.statusInProgressBg;
      case JobStatus.completed:
        return FactoryColors.statusCompletedBg;
      case JobStatus.reAssigned:
        return FactoryColors.statusWipPeachBg;
      case JobStatus.onHold:
        return FactoryColors.statusOnHoldBg;
    }
  }

  Color get borderColor {
    switch (this) {
      case JobStatus.toAssign:
        return FactoryColors.statusPendingBorder;
      case JobStatus.pending:
        return FactoryColors.statusPendingBorder;
      case JobStatus.started:
      case JobStatus.inProgress:
        return FactoryColors.statusInProgressBorder;
      case JobStatus.completed:
        return FactoryColors.statusCompletedBorder;
      case JobStatus.reAssigned:
        return FactoryColors.statusWipPeachBorder;
      case JobStatus.onHold:
        return FactoryColors.statusOnHoldBorder;
    }
  }

  bool get isToAssign => this == JobStatus.toAssign;
  bool get isPending => this == JobStatus.pending;
  bool get isStarted => this == JobStatus.started;
  bool get isInProgress => this == JobStatus.inProgress;
  bool get isCompleted => this == JobStatus.completed;
  bool get isReAssigned => this == JobStatus.reAssigned;
  bool get isOnHold => this == JobStatus.onHold;
}

