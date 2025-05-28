import 'package:equatable/equatable.dart';

class AllDoneState extends Equatable {
  final bool signalActive;
  final bool telegramActive;

  const AllDoneState({
    this.signalActive = true,
    this.telegramActive = true,
  });

  AllDoneState copyWith({
    bool? signalActive,
    bool? telegramActive,
  }) {
    return AllDoneState(
      signalActive: signalActive ?? this.signalActive,
      telegramActive: telegramActive ?? this.telegramActive,
    );
  }

  @override
  List<Object> get props => [signalActive, telegramActive];
}