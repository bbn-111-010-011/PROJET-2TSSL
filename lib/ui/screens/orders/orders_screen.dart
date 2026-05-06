import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/order.dart';
import '../../../providers/orders_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final orders = provider.orders;
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des achats'),
        actions: [
          IconButton(
            tooltip: 'Actualiser Supabase',
            onPressed: provider.loading ? null : () => provider.loadOrders(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!provider.isSupabaseConfigured)
            const MaterialBanner(
              content: Text('Supabase n’est pas configuré : l’historique distant ne sera pas disponible.'),
              actions: [SizedBox.shrink()],
            ),
          if (provider.error != null)
            MaterialBanner(
              content: Text(provider.error!),
              actions: [
                TextButton(
                  onPressed: () => provider.loadOrders(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          if (provider.loading)
            const LinearProgressIndicator(),
          Expanded(
            child: orders.isEmpty
                ? const Center(child: Text('Aucun achat pour le moment'))
                : ListView.separated(
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final Order order = orders[index];
                      return ExpansionTile(
                        title: Text('Commande #${order.id}'),
                        subtitle: Text('${df.format(order.date)} • Total ${order.total.toStringAsFixed(2)} €'),
                        children: [
                          ...order.items.map(
                            (it) => ListTile(
                              leading: CircleAvatar(
                                backgroundImage: it.image.isNotEmpty ? NetworkImage(it.image) : null,
                                child: it.image.isEmpty ? const Icon(Icons.image_not_supported) : null,
                              ),
                              title: Text(it.title),
                              subtitle: Text(
                                '${it.categoryName} • ${it.price.toStringAsFixed(2)} €  × ${it.quantity}  = ${it.lineTotal.toStringAsFixed(2)} €',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
