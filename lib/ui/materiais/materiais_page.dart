import 'package:flutter/material.dart';

import '../../data/material_repository.dart';
import '../../logic/dinheiro.dart';
import 'material_form_page.dart';

class MateriaisPage extends StatelessWidget {
  final MaterialRepository repositorio;

  const MateriaisPage({super.key, required this.repositorio});

  void _abrirFormulario(BuildContext context, [MaterialAdesivo? material]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            MaterialFormPage(repositorio: repositorio, material: material),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Materiais')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo material'),
      ),
      body: StreamBuilder<List<MaterialAdesivo>>(
        stream: repositorio.observarTodos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Não foi possível carregar.'));
          }
          final materiais = snapshot.data;
          if (materiais == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (materiais.isEmpty) {
            return const _EstadoVazio();
          }
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: materiais.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final m = materiais[i];
              return ListTile(
                title: Text(m.nome),
                subtitle: const Text('Largura 1,10 m'),
                trailing: Text(
                  '${formatarBrl(m.precoPorMetroCentavos)} / m',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () => _abrirFormulario(context, m),
              );
            },
          );
        },
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.layers_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum material cadastrado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre o primeiro material para poder fazer orçamentos.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
