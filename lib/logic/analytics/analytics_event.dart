import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

/// Recompute analytics from currently-loaded Firestore streams.
class AnalyticsRefreshRequested extends AnalyticsEvent {
  const AnalyticsRefreshRequested();
}