import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/llm_os_app.dart';
import 'features/desktop/cubit/janelas_cubit.dart';
import 'features/jogo/bloc/jogo_bloc.dart';
import 'features/jogo/data/jogo_repositorio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferencias = await SharedPreferences.getInstance();
  final repositorio = JogoRepositorioLocal(preferencias);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<JogoRepositorio>.value(value: repositorio),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<JanelasCubit>(create: (_) => JanelasCubit()),
          BlocProvider<JogoBloc>(
            create: (context) => JogoBloc(
              context.read<JogoRepositorio>(),
            )..add(const JogoInicializacaoSolicitada()),
          ),
        ],
        child: const LlmOsApp(),
      ),
    ),
  );
}
