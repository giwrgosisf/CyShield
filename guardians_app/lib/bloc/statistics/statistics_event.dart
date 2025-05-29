
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';


@immutable
abstract class StatisticsEvent  extends Equatable{
  const StatisticsEvent();

  @override
  List<Object> get props => [];
}


class LoadStatistics extends StatisticsEvent{
  final List<String> kidIds;
  const LoadStatistics(this.kidIds);

  @override
  List<Object> get props => [kidIds];
}