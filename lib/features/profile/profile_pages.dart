import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/market_repository.dart';
import '../../state/market_store.dart';
import '../../widgets/ui.dart';

class ProfilePage extends StatefulWidget {
  final int id;
  final CollectionItem? collection;
  const ProfilePage(this.id, {super.key, this.collection});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool get creator => widget.id >= 32 && widget.id <= 35;
  late int tab = creator
      ? (widget.id <= 33 ? 1 : 0)
      : switch (widget.id) {
          59 => 2,
          60 => 3,
          61 => 4,
          62 => 5,
          _ => 0,
        };
  String category = 'Art', query = '';
  bool readMore = false;
  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final name = creator
        ? (widget.collection?.name ?? 'Metafacely NFT')
        : 'Nekochimin';
    final tabs = creator
        ? ['Items', 'Activity']
        : [
            'Collected',
            'Created',
            'Favorited',
            'Activity',
            'Offers Made',
            'Purchased',
          ];
    var items = creator
        ? [MarketRepository.featured, ...MarketRepository.cats]
        : [
            ...MarketRepository.cats,
            ...(store.purchased.contains('9167')
                ? [MarketRepository.featured]
                : <NftItem>[]),
          ];
    if (!creator && tab == 1) items = store.created;
    if (!creator && tab == 2) {
      items = items.where((n) => store.favorites.contains(n.id)).toList();
    }
    if (!creator && tab == 5) {
      items = items.where((n) => store.purchased.contains(n.id)).toList();
    }
    if (query.isNotEmpty) {
      items = items
          .where((n) => n.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    return PageBody(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Art(
              creator
                  ? (widget.collection?.image ?? 'creator-cover')
                  : 'profile-cover',
              width: double.infinity,
              height: 128,
            ),
            Positioned(
              bottom: -50,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Art(
                  creator
                      ? (widget.collection?.avatar ?? 'creator-avatar')
                      : 'profile-avatar',
                  width: 100,
                  height: 100,
                  radius: 100,
                ),
              ),
            ),
          ],
        ),
        const Gap(66),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.verified, color: Colors.blue, size: 23),
          ],
        ),
        const Gap(12),
        Text(
          '$name is a collection of random NFT generated and resides on the Ethereum Blockchain. We focus on making NFTs that are unique${readMore ? ' and rare. Discover a new story in every collectible.' : ''}',
          maxLines: readMore ? 8 : 3,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted, height: 1.45),
        ),
        TextButton(
          onPressed: () => setState(() => readMore = !readMore),
          child: Text(readMore ? 'Read less' : 'Read more...'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final icon in [
              Icons.language,
              Icons.discord,
              Icons.alternate_email,
              Icons.camera_alt_outlined,
              Icons.send_outlined,
            ])
              IconButton(
                tooltip: 'Copy collection link',
                onPressed: () => copyText(
                  context,
                  'https://ossea.io/collection/${name.toLowerCase().replaceAll(' ', '-')}',
                ),
                icon: Icon(icon, color: primary, size: 21),
              ),
          ],
        ),
        const Divider(),
        const Gap(12),
        Row(
          children: [
            for (var i = 0; i < 4; i++)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      (creator
                          ? ['10K', '4.7K', '◆ 5.5', '◆ 299K']
                          : ['1.7K', '329', '◆ 0.55', '◆ 12.5K'])[i],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      ['Items', 'Owners', 'Floor Price', 'Total Volume'][i],
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const Gap(20),
        ChoiceTabs(
          tabs,
          selected: tab,
          onChanged: (v) => setState(() => tab = v),
        ),
        const Gap(20),
        if ((creator && tab == 1) || (!creator && tab == 3)) ...[
          for (var i = 0; i < 8; i++)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              leading: Art('cat-${i + 1}', width: 55, height: 55),
              title: Text(
                'Sale · ${MarketRepository.cats[i].name}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('${i + 1} hours ago'),
              trailing: const Text('◆ 0.075', style: TextStyle(color: green)),
              onTap: () => context.go(40, arguments: MarketRepository.cats[i]),
            ),
        ] else if (!creator && tab == 4) ...[
          if (store.offers.isEmpty)
            const EmptyState(
              'No Offers Yet',
              'Offers you make will appear here.',
              icon: Icons.local_offer_outlined,
            )
          else
            for (final entry in store.offers.entries)
              MenuRow(
                'Metafacely #${entry.key}',
                Icons.local_offer_outlined,
                trailing: '◆ ${entry.value}',
                onTap: () => context.go(40),
              ),
        ] else ...[
          SearchBox(
            hint: 'Search Item',
            onChanged: (v) => setState(() => query = v),
          ),
          const Gap(14),
          CategoryChips(
            selected: category,
            onChanged: (v) => setState(() => category = v),
          ),
          const Gap(16),
          if (items.isEmpty)
            EmptyState(
              tab == 1 ? 'Create Your First NFT' : 'No Items Yet',
              tab == 2
                  ? 'Tap a heart to save your favorite NFTs.'
                  : 'Your items will appear here.',
              icon: Icons.grid_view_rounded,
            )
          else
            NftGrid(items),
          if (!creator && tab == 1)
            PrimaryButton('Create New Item', onPressed: () => context.go(49)),
        ],
      ],
    );
  }
}

Widget sharePanel(BuildContext context) => Padding(
  padding: const EdgeInsets.all(24),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('Share', style: Theme.of(context).textTheme.headlineSmall),
      const Gap(24),
      Wrap(
        spacing: 12,
        runSpacing: 14,
        children: [
          for (final label in [
            'Copy Link',
            'Twitter',
            'Instagram',
            'Discord',
            'Telegram',
            'WhatsApp',
          ])
            SizedBox(
              width: 100,
              child: Column(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => copyText(
                      context,
                      'https://ossea.io/collection/nekochimin',
                    ),
                    icon: Icon(
                      label == 'Copy Link' ? Icons.link : Icons.share_outlined,
                    ),
                  ),
                  Text(label),
                ],
              ),
            ),
        ],
      ),
      const Gap(),
      PrimaryButton(
        'Copy Collection Link',
        onPressed: () =>
            copyText(context, 'https://ossea.io/collection/nekochimin'),
      ),
      const Gap(12),
    ],
  ),
);
