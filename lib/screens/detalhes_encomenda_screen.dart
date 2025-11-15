import 'package:flutter/material.dart';
import '../models/encomenda.dart';
import '../services/tracking_service.dart';
import '../services/database_helper.dart';

class DetalhesEncomendaScreen extends StatefulWidget {
  final Encomenda encomenda;
  const DetalhesEncomendaScreen({required this.encomenda, super.key});

  @override
  DetalhesEncomendaScreenState createState() => DetalhesEncomendaScreenState();
}

class DetalhesEncomendaScreenState extends State<DetalhesEncomendaScreen> {
  bool _isUpdating = false;
  late Encomenda _encomenda;
  List<dynamic> _eventos = [];

  @override
  void initState() {
    super.initState();
    _encomenda = widget.encomenda;
    _carregarEventos();
  }

  Future<void> _carregarEventos() async {
    try {
      final trackingService = TrackingService();
      final dados =
          await trackingService.buscarStatus(_encomenda.codigoRastreio);
      setState(() {
        _eventos = dados['eventos'] ?? [];
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar eventos: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _atualizarStatus() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final trackingService = TrackingService();
      final dados =
          await trackingService.buscarStatus(_encomenda.codigoRastreio);

      final eventos = dados['eventos'] as List<dynamic>;
      if (eventos.isNotEmpty) {
        final ultimoEvento = eventos.first;
        final novoStatus = ultimoEvento['status'] ?? _encomenda.status;

        await DatabaseHelper.instance
            .atualizarStatus(_encomenda.id!, novoStatus);

        setState(() {
          _encomenda.status = novoStatus;
          _eventos = eventos;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status atualizado para "$novoStatus"'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Nenhum evento encontrado para este código de rastreio.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar status: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();

    if (lowerStatus.contains('entregue')) {
      return Colors.green;
    }

    if (lowerStatus.contains('trânsito') || lowerStatus.contains('transito')) {
      return Colors.orange;
    }

    if (lowerStatus.contains('postado')) {
      return Colors.blue;
    }

    if (lowerStatus.contains('aguardando')) {
      return Colors.grey;
    }

    return Colors.deepPurple;
  }

  IconData _getStatusIcon(String status) {
    final lowerStatus = status.toLowerCase();

    if (lowerStatus.contains('entregue')) {
      return Icons.done_all;
    }

    if (lowerStatus.contains('trânsito') || lowerStatus.contains('transito')) {
      return Icons.local_shipping;
    }

    if (lowerStatus.contains('postado')) {
      return Icons.assignment_turned_in;
    }

    if (lowerStatus.contains('aguardando')) {
      return Icons.schedule;
    }

    return Icons.local_mall;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalhes da Encomenda',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isUpdating ? null : _atualizarStatus,
            tooltip: 'Atualizar Status',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _carregarEventos,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 20),
          _buildUpdateButton(),
          const SizedBox(height: 24),
          _buildEventsSection(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header com ícone e nome
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      _getStatusColor(_encomenda.status).withValues(alpha: 0.2),
                  child: Icon(
                    _getStatusIcon(_encomenda.status),
                    color: _getStatusColor(_encomenda.status),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _encomenda.nome,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Informações
            _InfoRow(
              icon: Icons.qr_code,
              label: 'Código de Rastreio',
              value: _encomenda.codigoRastreio,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.local_shipping,
              label: 'Transportadora',
              value: _encomenda.transportadora,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Data de Criação',
              value: _encomenda.dataCriacao != null
                  ? _formatarData(_encomenda.dataCriacao!)
                  : 'N/A',
            ),
            const SizedBox(height: 12),
            _StatusRow(
              status: _encomenda.status,
              color: _getStatusColor(_encomenda.status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    if (_isUpdating) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _atualizarStatus,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, size: 20),
            SizedBox(width: 8),
            Text(
              'Atualizar Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.history, color: Colors.deepPurple, size: 20),
            const SizedBox(width: 8),
            Text(
              'Histórico de Eventos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _eventos.length.toString(),
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Lista de eventos
        if (_eventos.isEmpty)
          _buildEmptyEvents()
        else
          ..._eventos.asMap().entries.map((entry) {
            final index = entry.key;
            final evento = entry.value;
            final isFirst = index == 0;

            return Padding(
              padding: EdgeInsets.only(
                bottom: 12,
                top: index == 0 ? 0 : 12,
              ),
              child: _EventoCard(
                evento: evento,
                isFirst: isFirst,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildEmptyEvents() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.history_toggle_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum evento encontrado',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use o botão "Atualizar Status" para buscar informações',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatarData(String data) {
    try {
      final dateTime = DateTime.parse(data);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} às ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return data;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusRow({
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EventoCard extends StatelessWidget {
  final dynamic evento;
  final bool isFirst;

  const _EventoCard({
    required this.evento,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      color: isFirst ? Colors.deepPurple.withValues(alpha: 0.05) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isFirst)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ATUAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isFirst) const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    evento['status'] ?? 'Evento sem descrição',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isFirst ? FontWeight.bold : FontWeight.w600,
                      color: isFirst ? Colors.deepPurple : Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (evento['local'] != null &&
                evento['local'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        evento['local'].toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  '${evento['data'] ?? ''} ${evento['hora'] ?? ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
