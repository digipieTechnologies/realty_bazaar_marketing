// File: lib/modules/dashboard/screens/brokers_tab_screen.dart
// Purpose: Display and manage registered brokers list with real-time Supabase RPC data, search, and pagination.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_constants.dart';
import '../../../providers/brokers/brokers_provider.dart';
import '../../../util/common_ext.dart';
import '../widgets/brokers/broker_table_widget.dart';

class BrokersTabScreen extends StatefulWidget {
  const BrokersTabScreen({super.key});

  @override
  State<BrokersTabScreen> createState() => _BrokersTabScreenState();
}

class _BrokersTabScreenState extends State<BrokersTabScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrokersProvider>().fetchBrokers(page: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrokersProvider>();
    final isMobile = context.isMobileUI;

    return SingleChildScrollView(
      padding: AppConstants.getTabPadding(context, bottomExtra: isMobile ? 68.0 : 76.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Broker Table / List Container
          BrokerTableWidget(
            brokers: provider.brokers,
            isLoading: provider.isLoading,
            currentPage: provider.currentPage,
            totalPages: provider.totalPages,
            totalItems: provider.totalItems,
            onSearchChanged: (query) {
              provider.fetchBrokers(page: 1, searchQuery: query);
            },
            onPageChanged: (page) {
              provider.fetchBrokers(
                page: page,
                searchQuery: provider.searchQuery,
              );
            },
          ),
        ],
      ),
    );
  }
}
