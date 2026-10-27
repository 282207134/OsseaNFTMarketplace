import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/market_repository.dart';
import '../../widgets/ui.dart';

class StatisticsPage extends StatefulWidget {
  final int id;
  const StatisticsPage(this.id, {super.key});
  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late int tab = widget.id >= 29 ? 1 : 0;
  late int expanded = widget.id == 25 || widget.id == 30 ? 0 : -1;
  String category = 'All Categories',
      chain = 'All Chains',
      time = 'Last 24 Hours';
  Future<void> choose(
    String title,
    List<String> options,
    ValueChanged<String> changed,
  ) async {
    final value = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(c).textTheme.headlineSmall),
              const Gap(),
              for (final o in options)
                ListTile(
                  title: Text(o),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(c, o),
                ),
            ],
          ),
        ),
      ),
    );
    if (value != null && mounted) setState(() => changed(value));
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ChoiceTabs(
        const ['♧ Rankings', '▧ Activity'],
        selected: tab,
        onChanged: (v) => setState(() => tab = v),
      ),
      const Gap(12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              OutlinedButton(
                onPressed: () => choose('Categories', [
                  'All Categories',
                  ...MarketRepository.categories.take(5),
                ], (v) => category = v),
                child: Text('$category  ▾'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => choose('Chains', [
                  'All Chains',
                  'Ethereum',
                  'Polygon',
                  'Solana',
                ], (v) => chain = v),
                child: Text('$chain  ▾'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => choose('Time', [
                  'Last 24 Hours',
                  'Last 7 Days',
                  'Last 30 Days',
                  'All Time',
                ], (v) => time = v),
                child: Text('$time  ▾'),
              ),
            ],
          ),
        ),
      ),
      Expanded(
        child: PageBody(
          children: [
            for (var i = 0; i < 12; i++) ...[
              InkWell(
                onTap: () => setState(() => expanded = expanded == i ? -1 : i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      if (tab == 0) ...[
                        SizedBox(
                          width: 25,
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Art('rank-${i % 6}', width: 56, height: 56, radius: 56),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              MarketRepository.rankingNames[i % 6],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              tab == 0
                                  ? '+ more'
                                  : 'Sale · ${i + 1} minutes ago',
                              style: const TextStyle(
                                color: muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '◆ ${['847.36', '659.42', '4,378.94', '7,250.55', '435.88', '3,265.79'][i % 6]}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const Gap(8),
                          Text(
                            i % 3 == 2 ? '-43.27 %' : '+96.24 %',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: i % 3 == 2 ? Colors.red : green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (expanded == i)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.fieldColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      InfoPair(
                        'Floor Price',
                        chain == 'Polygon' ? '0.57 MATIC' : '0.57 ETH',
                      ),
                      InfoPair('Volume ($time)', '8,752.55'),
                      const InfoPair('Owners', '4.7K'),
                      TextButton(
                        onPressed: () => context.go(35),
                        child: const Text('View Collection'),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 1),
            ],
          ],
        ),
      ),
    ],
  );
}
