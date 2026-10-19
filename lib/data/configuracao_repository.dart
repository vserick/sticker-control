import 'app_database.dart';

abstract class ConfiguracaoRepository {
  /// Nome da empresa usado na mensagem de WhatsApp, ou `null` se não definido.
  Future<String?> lerNomeEmpresa();

  /// Nome em branco apaga a configuração.
  Future<void> salvarNomeEmpresa(String nome);

  /// Modelo próprio da mensagem de WhatsApp, ou `null` para usar o padrão.
  Future<String?> lerModeloMensagem();

  /// Modelo em branco apaga a configuração (volta ao padrão).
  Future<void> salvarModeloMensagem(String modelo);
}

class DriftConfiguracaoRepository implements ConfiguracaoRepository {
  static const _chaveNomeEmpresa = 'nome_empresa';
  static const _chaveModeloMensagem = 'modelo_mensagem';

  final AppDatabase _db;

  DriftConfiguracaoRepository(this._db);

  @override
  Future<String?> lerNomeEmpresa() => _ler(_chaveNomeEmpresa);

  @override
  Future<void> salvarNomeEmpresa(String nome) =>
      _salvar(_chaveNomeEmpresa, nome.trim());

  @override
  Future<String?> lerModeloMensagem() => _ler(_chaveModeloMensagem);

  @override
  Future<void> salvarModeloMensagem(String modelo) =>
      _salvar(_chaveModeloMensagem, modelo.trim());

  Future<String?> _ler(String chave) async {
    final linha = await (_db.select(
      _db.configuracoes,
    )..where((c) => c.chave.equals(chave))).getSingleOrNull();
    return linha?.valor;
  }

  Future<void> _salvar(String chave, String valor) async {
    if (valor.isEmpty) {
      await (_db.delete(
        _db.configuracoes,
      )..where((c) => c.chave.equals(chave))).go();
      return;
    }
    await _db
        .into(_db.configuracoes)
        .insertOnConflictUpdate(
          ConfiguracoesCompanion.insert(chave: chave, valor: valor),
        );
  }
}
