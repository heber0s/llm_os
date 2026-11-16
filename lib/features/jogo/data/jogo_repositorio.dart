import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract interface class JogoRepositorio {
  Future<Map<String, dynamic>?> carregar();
  Future<void> salvar(Map<String, dynamic> dados);
  Future<void> limpar();
}

class JogoRepositorioLocal implements JogoRepositorio {
  JogoRepositorioLocal(this._preferencias);

  static const String _chaveEstado = 'llm_os_estado_v1';
  final SharedPreferences _preferencias;

  @override
  Future<Map<String, dynamic>?> carregar() async {
    final jsonSalvo = _preferencias.getString(_chaveEstado);
    if (jsonSalvo == null) return null;

    final decodificado = jsonDecode(jsonSalvo);
    if (decodificado is! Map<String, dynamic>) return null;
    return decodificado;
  }

  @override
  Future<void> salvar(Map<String, dynamic> dados) async {
    await _preferencias.setString(_chaveEstado, jsonEncode(dados));
  }

  @override
  Future<void> limpar() async {
    await _preferencias.remove(_chaveEstado);
  }
}
