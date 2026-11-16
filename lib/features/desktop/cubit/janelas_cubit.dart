import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JanelasEstado extends Equatable {
  const JanelasEstado({this.appAtivo, this.menuIniciarAberto = false});

  final String? appAtivo;
  final bool menuIniciarAberto;

  JanelasEstado copyWith({
    String? appAtivo,
    bool fecharApp = false,
    bool? menuIniciarAberto,
  }) {
    return JanelasEstado(
      appAtivo: fecharApp ? null : (appAtivo ?? this.appAtivo),
      menuIniciarAberto: menuIniciarAberto ?? this.menuIniciarAberto,
    );
  }

  @override
  List<Object?> get props => [appAtivo, menuIniciarAberto];
}

class JanelasCubit extends Cubit<JanelasEstado> {
  JanelasCubit() : super(const JanelasEstado());

  void abrirApp(String id) => emit(state.copyWith(
        appAtivo: id,
        menuIniciarAberto: false,
      ));

  void fecharApp() => emit(state.copyWith(fecharApp: true));

  void alternarMenuIniciar() => emit(state.copyWith(
        menuIniciarAberto: !state.menuIniciarAberto,
      ));

  void fecharMenuIniciar() => emit(state.copyWith(menuIniciarAberto: false));
}
