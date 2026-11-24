import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RepositoryMode { mock, real }

class RepositoryModeNotifier extends Notifier<RepositoryMode> {
  @override
  RepositoryMode build() => RepositoryMode.mock;

  void setMode(RepositoryMode mode) => state = mode;
}

final repositoryModeProvider = NotifierProvider<RepositoryModeNotifier, RepositoryMode>(RepositoryModeNotifier.new);
