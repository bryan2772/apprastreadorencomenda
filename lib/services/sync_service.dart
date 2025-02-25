import 'package:flutter/material.dart';
import '../models/encomenda.dart';
import 'api_service.dart';
import 'database_helper.dart';

class SyncService {
  final ApiService _apiService = ApiService();

  /// Método para sincronizar os dados: envia os não sincronizados (push)
  /// e busca as encomendas remotas (pull)
  Future<void> syncEncomendas() async {
    await _pushLocalChanges();
    await _pullRemoteEncomendas();
  }

  /// Envia as encomendas que não foram sincronizadas para o servidor
  Future<void> _pushLocalChanges() async {
    List<Encomenda> unsyncedEncomendas = await DatabaseHelper.instance.getUnsyncedEncomendas();
    for (var encomenda in unsyncedEncomendas) {
      try {
        int remoteId = await _apiService.inserirEncomenda(encomenda);
        await DatabaseHelper.instance.markEncomendaSynced(encomenda.id!, remoteId);
      } catch (e) {
        debugPrint("Erro ao sincronizar (push) encomenda ${encomenda.id}: $e");
      }
    }
  }

  /// Busca as encomendas remotas e atualiza o banco local
  Future<void> _pullRemoteEncomendas() async {
    try {
      List<Encomenda> remoteEncomendas = await _apiService.listarEncomendas();
      for (var remoteEncomenda in remoteEncomendas) {
        // Verifica se a encomenda já existe localmente pelo remoteId
        final localEncomenda = await DatabaseHelper.instance.getEncomendaByRemoteId(remoteEncomenda.id!);
        if (localEncomenda == null) {
          // Se não existir, insere-a localmente e marca como sincronizada
          Map<String, dynamic> json = remoteEncomenda.toJson();
          json['syncStatus'] = 1;
          json['remoteId'] = remoteEncomenda.id;
          await DatabaseHelper.instance.insertFromRemote(json);
        } else {
          // Se já existir, você pode atualizar o registro se for necessário
          // (implemente um método de update se quiser mesclar alterações)
        }
      }
    } catch (e) {
      debugPrint("Erro ao puxar (pull) as encomendas remotas: $e");
    }
  }
}
