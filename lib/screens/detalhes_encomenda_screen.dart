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
    if (lowerStatus.contains('entregue')) return Colors.green;
    if (lowerStatus.contains('trânsito') || lowerStatus.contains('transito'))
      return Colors.orange;
    if (lowerStatus.contains('postado')) return Colors.blue;
    if (lowerStatus.contains('aguardando')) return Colors.grey;
    return Colors.deepPurple;
  }

  IconData _getStatusIcon(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('entregue')) return Icons.done_all;
    if (lowerStatus.contains('trânsito') || lowerStatus.contains('transito'))
      return Icons.local_shipping;
    if (lowerStatus.contains('postado')) return Icons.assignment_turned_in;
    if (lowerStatus.contains('aguardando')) return Icons.schedule;
    return Icons.local_mall;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
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
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _isUpdating ? null : _atualizarStatus,
            tooltip: 'Atualizar Status',
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: RefreshIndicator(
          onRefresh: _carregarEventos,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card de informações principais
                Card(
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
                                  _getStatusColor(_encomenda.status ?? '')
                                      .withOpacity(0.2),
                              child: Icon(
                                _getStatusIcon(_encomenda.status ?? ''),
                                color: _getStatusColor(_encomenda.status ?? ''),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _encomenda.nome,
                                style: theme.textTheme.titleLarge?.copyWith(
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

                        // Informações em grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 3,
                          children: [
                            _InfoItem(
                              icon: Icons.qr_code,
                              label: 'Código',
                              value: _encomenda.codigoRastreio,
                            ),
                            _InfoItem(
                              icon: Icons.local_shipping,
                              label: 'Transportadora',
                              value: _encomenda.transportadora,
                            ),
                            _InfoItem(
                              icon: Icons.calendar_today,
                              label: 'Data de Criação',
                              value: _encomenda.dataCriacao != null
                                  ? _formatarData(_encomenda.dataCriacao!)
                                  : 'N/A',
                            ),
                            _StatusItem(
                              status: _encomenda.status ?? 'Desconhecido',
                              color: _getStatusColor(_encomenda.status ?? ''),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Botão de atualização
                if (!_isUpdating)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _atualizarStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
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
                  )
                else
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    ),
                  ),

                const SizedBox(height: 24),

                // Header da lista de eventos
                Row(
                  children: [
                    Icon(Icons.history, color: Colors.deepPurple, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Histórico de Eventos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
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
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(40),
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
                  )
                else
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: _eventos.asMap().entries.map((entry) {
                          final index = entry.key;
                          final evento = entry.value;
                          final isFirst = index == 0;
                          final isLast = index == _eventos.length - 1;

                          return _EventoItem(
                            evento: evento,
                            isFirst: isFirst,
                            isLast: isLast,
                            showLine: _eventos.length > 1,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatarData(String data) {
    try {
      final dateTime = DateTime.parse(data);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return data;
    }
  }
}

// Widget para itens de informação
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.deepPurple),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Widget para status
class _StatusItem extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusItem({
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                'Status',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Widget para eventos da timeline
class _EventoItem extends StatelessWidget {
  final dynamic evento;
  final bool isFirst;
  final bool isLast;
  final bool showLine;

  const _EventoItem({
    required this.evento,
    required this.isFirst,
    required this.isLast,
    required this.showLine,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline vertical
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: Colors.grey.shade300,
              ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isFirst ? Colors.deepPurple : Colors.grey.shade400,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isFirst ? Colors.deepPurple : Colors.grey.shade400,
                  width: 2,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 20,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),

        // Conteúdo do evento
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isFirst ? Colors.deepPurple.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFirst
                    ? Colors.deepPurple.withOpacity(0.2)
                    : Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evento['status'] ?? 'Evento sem descrição',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
                    color: isFirst ? Colors.deepPurple : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                if (evento['local'] != null &&
                    evento['local'].toString().isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          evento['local'].toString(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      '${evento['data'] ?? ''} ${evento['hora'] ?? ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
