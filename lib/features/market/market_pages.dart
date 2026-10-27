import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/market_repository.dart';
import '../../widgets/ui.dart';
import '../../state/market_store.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      SearchBox(onTap: () => context.go(15)),
      const Gap(),
      SizedBox(
        height: 160,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: MarketRepository.categories.length,
          separatorBuilder: (_, i) => const SizedBox(width: 16),
          itemBuilder: (_, i) => InkWell(
            onTap: () =>
                context.go(11, arguments: MarketRepository.categories[i]),
            child: SizedBox(
              width: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Art(
                    [
                      'category-art',
                      'category-collectibles',
                      'category-domains',
                    ][i % 3],
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: .6),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 18,
                    left: 18,
                    child: Text(
                      MarketRepository.categories[i],
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      const Gap(20),
      Heading('Notable Drops', onAll: () => context.go(13)),
      const Gap(14),
      SizedBox(
        height: 216,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (_, i) => const SizedBox(width: 16),
          itemBuilder: (_, i) => InkWell(
            onTap: () => context.go(40),
            child: SizedBox(
              width: 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Art(
                    i == 1 ? 'drop-horror' : 'drop-human',
                    width: 180,
                    height: 180,
                  ),
                  const Gap(10),
                  Text(
                    [
                      '3D Human Rarible',
                      'World of Horror',
                      'Creative Universe',
                    ][i],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      const Gap(16),
      Heading('Trending Collections', onAll: () => context.go(14)),
      const Gap(16),
      SizedBox(
        height: 190,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          separatorBuilder: (_, i) => const SizedBox(width: 16),
          itemBuilder: (_, i) => SizedBox(
            width: 180,
            child: CollectionCard(MarketRepository.collections[i]),
          ),
        ),
      ),
      const Gap(),
      Heading('Top Collections', onAll: () => context.go(24)),
      const Gap(14),
      const CollectionGrid(MarketRepository.collections),
      const Gap(),
      Heading('Popular NFTs', onAll: () => context.go(12)),
      const Gap(16),
      NftGrid([MarketRepository.featured, ...MarketRepository.cats.take(3)]),
    ],
  );
}

class BrowsePage extends StatelessWidget {
  final int id;
  final String category;
  const BrowsePage(this.id, {super.key, this.category = 'Art'});
  @override
  Widget build(BuildContext context) {
    if (id == 13) {
      return PageBody(
        children: [
          for (var i = 0; i < 4; i++) ...[
            InkWell(
              onTap: () => context.go(40),
              child: Art(
                i.isEven ? 'drop-human' : 'drop-horror',
                width: double.infinity,
                height: 320,
              ),
            ),
            const Gap(16),
            Heading(i.isEven ? '3D Human Rarible' : 'World of Horror'),
            const Gap(8),
            const Text(
              'A new world of unique digital collectibles.',
              style: TextStyle(color: muted),
            ),
            const Gap(28),
          ],
        ],
      );
    }
    if (id == 14) {
      return const PageBody(
        children: [CollectionGrid(MarketRepository.collections)],
      );
    }
    if (id == 12) {
      return PageBody(
        children: [
          CategoryChips(
            selected: 'Art',
            onChanged: (v) => context.go(11, arguments: v),
          ),
          const Gap(16),
          NftGrid([MarketRepository.featured, ...MarketRepository.cats]),
        ],
      );
    }
    return PageBody(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            const Art('collection-0', height: 128, width: double.infinity),
            Positioned(
              bottom: -38,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: const Art(
                  'category-art',
                  width: 96,
                  height: 96,
                  radius: 96,
                ),
              ),
            ),
          ],
        ),
        const Gap(56),
        Text(
          'Explore $category',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Gap(16),
        const Text(
          'Discover extraordinary art from inspiring creators around the world. Find a collection that speaks to you.',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted, height: 1.5),
        ),
        const Gap(24),
        const Divider(),
        const Gap(12),
        const Heading('Popular Collections'),
        const Gap(20),
        const CollectionGrid(MarketRepository.collections),
      ],
    );
  }
}

class SearchPage extends StatefulWidget {
  final int id;
  const SearchPage(this.id, {super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController query;
  Timer? timer;
  bool loading = false;
  int tab = 0;
  String sort = 'Recently Listed';
  Map<String, dynamic>? filters;
  @override
  void initState() {
    super.initState();
    query = TextEditingController(
      text: widget.id == 17
          ? 'No matching NFT'
          : widget.id >= 18
          ? '3D Art'
          : '',
    );
    tab = widget.id == 19 ? 1 : 0;
    if (widget.id == 16) {
      loading = true;
      timer = Timer(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => loading = false);
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    query.dispose();
    super.dispose();
  }

  void changed(String v) {
    timer?.cancel();
    setState(() => loading = true);
    timer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => loading = false);
    });
  }

  Future<void> filter() async {
    final result = await context.go<Map<String, dynamic>>(22);
    if (result != null && mounted) setState(() => filters = result);
  }

  @override
  Widget build(BuildContext context) {
    final q = query.text.toLowerCase().trim();
    var items =
        [
              ...StoreScope.of(context).createdCollections,
              ...MarketRepository.collections,
            ]
            .where(
              (c) =>
                  q.isEmpty ||
                  q == '3d art' ||
                  c.name.toLowerCase().contains(q),
            )
            .toList();
    if (filters != null) {
      items = items
          .where(
            (c) =>
                (filters!['category'] == 'All' ||
                    filters!['category'] == c.category) &&
                (filters!['chain'] == 'All Chains' ||
                    filters!['chain'] == c.chain) &&
                (filters!['status'] == 'New' ||
                    filters!['status'] == 'Has Offers' ||
                    filters!['status'] == c.status) &&
                (filters!['min'] == null ||
                    c.floorPrice >= (filters!['min'] as double)) &&
                (filters!['max'] == null ||
                    c.floorPrice <= (filters!['max'] as double)),
          )
          .toList();
    }
    if (sort == 'Name A–Z') items.sort((a, b) => a.name.compareTo(b.name));
    if (sort == 'Name Z–A') items.sort((a, b) => b.name.compareTo(a.name));
    if (sort == 'Price: Low to High') {
      items.sort((a, b) => a.floorPrice.compareTo(b.floorPrice));
    }
    if (sort == 'Price: High to Low') {
      items.sort((a, b) => b.floorPrice.compareTo(a.floorPrice));
    }
    if (sort == 'Recently Created') items = items.reversed.toList();
    final nfts = StoreScope.of(context).allItems
        .where(
          (n) =>
              q.isEmpty ||
              q == '3d art' ||
              n.name.toLowerCase().contains(q) ||
              n.collection.toLowerCase().contains(q),
        )
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SearchBox(
            controller: query,
            onChanged: changed,
            onFilter: filter,
          ),
        ),
        const Gap(10),
        if (q.isNotEmpty)
          ChoiceTabs(
            const ['Collections', 'Creators'],
            selected: tab,
            onChanged: (v) => setState(() => tab = v),
          ),
        Expanded(
          child: PageBody(
            children: [
              if (q.isEmpty) ...[
                const Heading('All Categories'),
                const Gap(16),
                SizedBox(
                  height: 150,
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => context.go(
                                11,
                                arguments: MarketRepository.categories[i],
                              ),
                              child: Art(
                                [
                                  'category-art',
                                  'category-collectibles',
                                  'category-domains',
                                ][i],
                                height: 150,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Gap(),
                const Heading('Trending Collections'),
                const Gap(18),
              ],
              if (filters != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Filter: ${filters!['category']} · ${filters!['chain']}',
                    style: const TextStyle(color: primary),
                  ),
                ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(80),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (widget.id == 20 && nfts.isNotEmpty)
                NftGrid(nfts)
              else if (items.isEmpty)
                const EmptyState(
                  'Not Found',
                  "Sorry, we couldn't find any results. Try a different search.",
                )
              else if (tab == 1) ...[
                for (final c in items)
                  MenuRow(
                    c.name,
                    Icons.verified,
                    color: primary,
                    trailing: 'Creator',
                    onTap: () => context.go(35, arguments: c),
                  ),
              ] else
                CollectionGrid(items),
              if (items.isNotEmpty && q.isNotEmpty) ...[
                const Gap(24),
                PrimaryButton(
                  'Show All Items',
                  onPressed: () => context.go(20),
                ),
              ],
              const Gap(16),
              TextButton.icon(
                onPressed: () async {
                  final value = await context.go<String>(23);
                  if (value != null && mounted) setState(() => sort = value);
                },
                icon: const Icon(Icons.sort),
                label: Text(sort),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FilterPage extends StatefulWidget {
  final int id;
  const FilterPage(this.id, {super.key});
  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String category = 'All',
      chain = 'All Chains',
      status = 'Buy Now',
      sort = 'Recently Listed';
  final minimum = TextEditingController(), maximum = TextEditingController();
  String? error;
  @override
  void dispose() {
    minimum.dispose();
    maximum.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.id == 23) {
      return PageBody(
        children: [
          for (final value in [
            'Recently Listed',
            'Recently Created',
            'Recently Sold',
            'Price: Low to High',
            'Price: High to Low',
            'Name A–Z',
            'Name Z–A',
          ])
            SelectionRow(
              title: Text(value),
              value: value,
              groupValue: sort,
              onChanged: (v) {
                setState(() => sort = v!);
                Navigator.pop(context, v);
              },
            ),
        ],
      );
    }
    return Column(
      children: [
        Expanded(
          child: PageBody(
            children: [
              const Heading('Status'),
              const Gap(12),
              CategoryChips(
                options: const ['Buy Now', 'On Auction', 'New', 'Has Offers'],
                selected: status,
                onChanged: (v) => setState(() => status = v),
              ),
              const Gap(),
              const Heading('Price'),
              const Gap(14),
              DropdownButtonFormField<String>(
                initialValue: 'ETH',
                decoration: const InputDecoration(),
                items: const [
                  DropdownMenuItem(value: 'ETH', child: Text('◆  ETH')),
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                ],
                onChanged: (_) => setState(() {}),
              ),
              const Gap(14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minimum,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Min'),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(12), child: Text('—')),
                  Expanded(
                    child: TextField(
                      controller: maximum,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Max'),
                    ),
                  ),
                ],
              ),
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red)),
              const Gap(),
              const Heading('Categories'),
              const Gap(8),
              for (final c in ['All', ...MarketRepository.categories])
                SelectionRow(
                  contentPadding: EdgeInsets.zero,
                  title: Text(c),
                  value: c,
                  groupValue: category,
                  onChanged: (v) => setState(() => category = v!),
                ),
              const Gap(),
              const Heading('Chains'),
              for (final c in [
                'All Chains',
                'Ethereum',
                'Polygon',
                'Klaytn',
                'Solana',
              ])
                SelectionRow(
                  contentPadding: EdgeInsets.zero,
                  title: Text(c),
                  value: c,
                  groupValue: chain,
                  onChanged: (v) => setState(() => chain = v!),
                ),
            ],
          ),
        ),
        BottomActions(
          'Apply',
          secondary: 'Reset',
          onSecondary: () => setState(() {
            category = 'All';
            chain = 'All Chains';
            status = 'Buy Now';
            minimum.clear();
            maximum.clear();
            error = null;
          }),
          onPressed: () {
            final min = double.tryParse(minimum.text),
                max = double.tryParse(maximum.text);
            if ((minimum.text.isNotEmpty && min == null) ||
                (maximum.text.isNotEmpty && max == null) ||
                (min != null && min < 0) ||
                (max != null && max < 0) ||
                (min != null && max != null && min > max)) {
              setState(() => error = 'Enter a valid price range');
              return;
            }
            Navigator.pop(context, {
              'category': category,
              'chain': chain,
              'status': status,
              'min': min,
              'max': max,
            });
          },
        ),
      ],
    );
  }
}

class NotificationPage extends StatefulWidget {
  final int id;
  const NotificationPage(this.id, {super.key});
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late int selected = widget.id == 10 ? 1 : 0;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      ChoiceTabs(
        const ['General', 'NFTs'],
        selected: selected,
        onChanged: (v) => setState(() => selected = v),
      ),
      Expanded(
        child: PageBody(
          children: [
            if (widget.id == 8 && selected == 0)
              const EmptyState(
                'No Notifications Yet',
                'Your notifications will appear here.',
                icon: Icons.notifications_none_rounded,
              )
            else if (selected == 1) ...[
              for (var i = 0; i < 7; i++)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  leading: Art('cat-${i + 1}', width: 60, height: 60),
                  title: Text(
                    'Nekochimin #${1053 + i * 13}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('${i + 1} minutes ago'),
                  trailing: Text(
                    '◆ 0.${624 + i * 21}',
                    style: const TextStyle(
                      color: green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () =>
                      context.go(40, arguments: MarketRepository.cats[i]),
                ),
            ] else ...[
              for (var i = 0; i < 5; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 27,
                            backgroundColor: primary.withValues(alpha: .1),
                            child: Icon(
                              [
                                Icons.security,
                                Icons.wallet_outlined,
                                Icons.system_update,
                                Icons.update,
                                Icons.check_circle_outline,
                              ][i],
                              color: primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              [
                                'Security Updates!',
                                'Multiple Wallet Features!',
                                'Ossea Has Updates!',
                                'New Updates Available!',
                                'Wallet Connected!',
                              ][i],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (i < 2)
                            const Text('New', style: TextStyle(color: primary)),
                        ],
                      ),
                      const Gap(12),
                      Text(
                        '${20 - i} Dec, 2022  |  20:49 PM',
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                      const Gap(10),
                      Text(
                        [
                          'Now Ossea has a Two-Factor Authentication. Try it now to make your account more secure.',
                          'Try Ossea new feature, now you can link your multiple wallet accounts.',
                          'Now you can make an offer and buy multiple NFTs at once.',
                          'Update Ossea to discover the latest features and collections.',
                          'Your wallet is connected to Ossea. Enjoy exploring.',
                        ][i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(height: 1.5),
                      ),
                      const Gap(12),
                      const Divider(),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    ],
  );
}
