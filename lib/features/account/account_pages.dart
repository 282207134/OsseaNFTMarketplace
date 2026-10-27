import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/market_repository.dart';
import '../../navigation/screen_catalog.dart';
import '../../state/market_store.dart';
import '../../widgets/ui.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      for (final m in <(String, IconData, int, Color)>[
        ('My Wallet', Icons.account_balance_wallet, 67, primary),
        ('My Collections', Icons.grid_view_rounded, 68, Colors.orange),
        ('Watchlist', Icons.visibility, 73, green),
        ('Settings', Icons.settings, 74, primary),
        ('Logout', Icons.logout, 81, Colors.red),
      ]) ...[
        MenuRow(m.$1, m.$2, color: m.$4, onTap: () => context.go(m.$3)),
        const Gap(8),
        const Divider(height: 12),
      ],
      const Gap(16),
      const Text(
        'Follow us:',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
      const Gap(18),
      Wrap(
        spacing: 12,
        runSpacing: 14,
        children: [
          for (var i = 0; i < 6; i++)
            SizedBox(
              width: (MediaQuery.sizeOf(context).width - 72) / 3,
              height: 92,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: [
                    Colors.lightBlue,
                    Colors.pink,
                    Colors.indigo,
                    Colors.deepOrange,
                    Colors.cyan,
                    Colors.red,
                  ][i],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => copyText(context, 'https://ossea.io'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      [
                        Icons.alternate_email,
                        Icons.camera_alt,
                        Icons.discord,
                        Icons.reddit,
                        Icons.send,
                        Icons.play_arrow,
                      ][i],
                      size: 26,
                    ),
                    const Gap(8),
                    Text(
                      [
                        'Twitter',
                        'Instagram',
                        'Discord',
                        'Reddit',
                        'Telegram',
                        'YouTube',
                      ][i],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      const Gap(32),
      TextButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScreenGallery()),
        ),
        icon: const Icon(Icons.view_carousel_outlined),
        label: const Text('Explore All Screens'),
      ),
    ],
  );
}

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});
  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int tab = 0;
  void action(String action) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Heading(action),
              const Gap(),
              if (action == 'Receive') ...[
                const Icon(Icons.qr_code_2, size: 140, color: primary),
                const Gap(16),
                const Text(
                  'Demo address — do not send funds',
                  style: TextStyle(color: muted),
                ),
                const Gap(12),
                PrimaryButton(
                  'Copy Address',
                  onPressed: () => copyText(
                    context,
                    '0x7131CA848567678f3126de58848f8E69600000000',
                  ),
                ),
              ] else ...[
                const Text(
                  'Wallet transfers, purchases and swaps require a real wallet integration. This app uses a local demo balance.',
                  style: TextStyle(height: 1.6, color: muted),
                ),
                const Gap(),
                PrimaryButton('Got it', onPressed: () => Navigator.pop(c)),
              ],
              const Gap(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return PageBody(
      children: [
        const Center(
          child: Art(
            'category-collectibles',
            width: 100,
            height: 100,
            radius: 100,
          ),
        ),
        const Gap(16),
        const Text(
          'AndrewNFT',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: primary,
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(10),
        Text(
          '\$${store.purchased.isEmpty ? '410,885.95' : '243,937.05'}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Gap(12),
        Center(
          child: ActionChip(
            avatar: const Art('wallet-0', width: 20, height: 20),
            label: const Text('0x7131CA8...f548f8E696  ▢'),
            onPressed: () => copyText(
              context,
              '0x7131CA848567678f3126de58848f8E69600000000',
            ),
          ),
        ),
        const Gap(18),
        const Divider(),
        const Gap(16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < 4; i++)
              Column(
                children: [
                  IconButton.filledTonal(
                    tooltip: ['Receive', 'Buy', 'Send', 'Swap'][i],
                    onPressed: () =>
                        action(['Receive', 'Buy', 'Send', 'Swap'][i]),
                    icon: Icon(
                      [
                        Icons.file_download_outlined,
                        Icons.shopping_bag_outlined,
                        Icons.send,
                        Icons.swap_vert,
                      ][i],
                      color: primary,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    ['Receive', 'Buy', 'Send', 'Swap'][i],
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
          ],
        ),
        const Gap(),
        ChoiceTabs(
          const ['Tokens', 'NFTs'],
          selected: tab,
          onChanged: (v) => setState(() => tab = v),
        ),
        const Gap(16),
        if (tab == 1) ...[
          if (store.purchased.isEmpty)
            const EmptyState(
              'No NFTs Yet',
              'Explore the marketplace and start your collection.',
            )
          else
            NftGrid(store.ownedItems),
        ] else
          for (var i = 0; i < 4; i++)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              leading: CircleAvatar(
                backgroundColor: [
                  Colors.black,
                  Colors.blue,
                  Colors.orange,
                  Colors.teal,
                ][i],
                child: Text(
                  ['◆', '\$', '◈', '₮'][i],
                  style: const TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
              title: Text(
                [
                  '${store.balance.toStringAsFixed(5)} ETH',
                  '36.348508 USDC',
                  '22.474904 DAI',
                  '58.487037 USDT',
                ][i],
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                ['\$410,750.45', '\$36.4212', '\$22.5198', '\$58.4870'][i],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => action(['Ethereum', 'USDC', 'DAI', 'USDT'][i]),
            ),
        const Gap(),
      ],
    );
  }
}

class CollectionsPage extends StatelessWidget {
  final int id;
  const CollectionsPage(this.id, {super.key});
  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    var items = [
      ...store.createdCollections,
      ...MarketRepository.collections.skip(4),
    ];
    if (id == 73) {
      items = MarketRepository.collections
          .where((c) => store.watchlist.contains(c.name))
          .toList();
    }
    return PageBody(
      children: [
        if (items.isEmpty)
          const EmptyState(
            'Your Watchlist is Empty',
            'Open a collection and tap the eye icon to follow it.',
            icon: Icons.visibility_outlined,
          )
        else
          CollectionGrid(items),
        const Gap(24),
        if (id != 73)
          PrimaryButton('Create a Collection', onPressed: () => context.go(69)),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return PageBody(
      children: [
        for (final m in <(String, IconData, int)>[
          ('E-Wallet', Icons.wallet_outlined, 75),
          ('Notification', Icons.notifications_none, 76),
          ('Security', Icons.shield_outlined, 77),
          ('Language', Icons.chat_bubble_outline, 78),
        ])
          MenuRow(
            m.$1,
            m.$2,
            onTap: () => context.go(m.$3),
            trailing: m.$3 == 78 ? store.language : null,
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(Icons.dark_mode_outlined),
          ),
          title: const Text(
            'Dark Mode',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          value: store.dark,
          onChanged: store.toggleDark,
        ),
        MenuRow('Help Center', Icons.info_outline, onTap: () => context.go(79)),
        MenuRow(
          'Invite Friends',
          Icons.group_outlined,
          onTap: () => context.go(80),
        ),
        MenuRow(
          'Rate us',
          Icons.star_border,
          onTap: () => context.message('Thanks for trying Ossea!'),
        ),
        const Gap(20),
        const Divider(),
        const Gap(16),
        const Text('About', style: TextStyle(color: muted)),
        const Gap(8),
        for (final m in ['Privacy & Policy', 'Terms of Services', 'About us'])
          MenuRow(
            m,
            Icons.info_outline,
            onTap: () => showDialog(
              context: context,
              builder: (c) => AlertDialog(
                title: Text(m),
                content: Text(
                  m == 'About us'
                      ? 'Ossea is a Flutter UI demonstration based on the Pixso Ossea NFT Marketplace kit. Version 1.0.0.'
                      : 'This demonstration stores preferences and sample marketplace activity locally on this device. It does not process real cryptocurrency transactions.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class PreferencePage extends StatefulWidget {
  final int id;
  const PreferencePage(this.id, {super.key});
  @override
  State<PreferencePage> createState() => _PreferencePageState();
}

class _PreferencePageState extends State<PreferencePage> {
  final invited = <int>{1, 4, 7};
  String query = '', helpCategory = 'General';
  int open = 0;
  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    if (widget.id == 75) {
      return PageBody(
        children: [
          const Gap(20),
          const Art('wallet', height: 200, fit: BoxFit.contain),
          const Gap(),
          Heading(store.connected ? 'Connected Wallet' : 'Connect Your Wallet'),
          const Gap(),
          if (store.connected) ...[
            MenuRow(
              store.walletProvider,
              Icons.account_balance_wallet,
              onTap: () => context.go(67),
              trailing: 'Connected',
            ),
            const Gap(20),
            PrimaryButton(
              'Disconnect',
              secondary: true,
              onPressed: store.logout,
            ),
          ] else
            PrimaryButton('Connect Wallet', onPressed: () => context.go(4)),
          const Gap(20),
          const Text(
            'Demo connection · no private keys are requested.',
            style: TextStyle(color: muted),
          ),
        ],
      );
    }
    if (widget.id == 76 || widget.id == 77) {
      final labels = widget.id == 76
          ? [
              'General Notification',
              'Sound',
              'Vibrate',
              'Notify me when there is a sale',
              'Notify me when there is an offer',
              'Notify me when there is an activity',
              'App Updates',
              'New Services Available',
              'New Tips Available',
            ]
          : ['Remember me', 'Biometric ID', 'Face ID', 'Google Authenticator'];
      return PageBody(
        children: [
          for (final title in labels)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                value: store.settings[title] ?? (title != 'Face ID'),
                onChanged: (v) => store.setSetting(title, v),
              ),
            ),
          if (widget.id == 77) ...[
            const Gap(24),
            const Text(
              'Security switches are saved preferences in this UI demo; device authentication is not enabled.',
              style: TextStyle(color: muted, height: 1.6),
            ),
          ],
        ],
      );
    }
    if (widget.id == 78) {
      return PageBody(
        children: [
          const Heading('Suggested'),
          const Gap(14),
          for (final language in ['English (US)', 'English (UK)'])
            SelectionRow(
              contentPadding: EdgeInsets.zero,
              title: Text(
                language,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              value: language,
              groupValue: store.language,
              onChanged: (v) => store.setLanguage(v!),
            ),
          const Divider(),
          const Gap(20),
          const Heading('Language'),
          const Gap(14),
          for (final language in [
            'Mandarin',
            'Hindi',
            'Spanish',
            'French',
            'Arabic',
            'Bengali',
            'Russian',
            'Indonesia',
          ])
            SelectionRow(
              contentPadding: EdgeInsets.zero,
              title: Text(
                language,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              value: language,
              groupValue: store.language,
              onChanged: (v) => store.setLanguage(v!),
            ),
          const Gap(20),
          const Text(
            'Language preference is saved. UI copy follows the English design kit.',
            style: TextStyle(color: muted),
          ),
        ],
      );
    }
    if (widget.id == 79) {
      final questions = [
        'What is Ossea?',
        'How to upload NFT items?',
        'How can I buy NFT?',
        'How can I make a price offer?',
        'How do I exit the app?',
        'How can I deactivate my account?',
      ];
      final answers = [
        'Ossea is a marketplace for discovering, creating, and collecting unique digital art. This app demonstrates the experience using local data.',
        'Tap the + button, choose an image or sample artwork, fill out the form, then tap Create.',
        'Open an NFT, tap Buy Now, and complete the demo signature. Connect a demo wallet first.',
        'Open an NFT, tap Make Offer, enter an amount, approve the currency and sign the demo request.',
        'Open More and choose Logout to disconnect your demo wallet.',
        'All data stays on this device. Clear the app data to reset this demonstration.',
      ];
      return PageBody(
        children: [
          CategoryChips(
            options: const ['General', 'Account', 'Service', 'Applications'],
            selected: helpCategory,
            onChanged: (v) => setState(() => helpCategory = v),
          ),
          const Gap(20),
          SearchBox(
            hint: 'Search',
            onChanged: (v) => setState(() => query = v),
            onFilter: () => setState(() => query = ''),
          ),
          const Gap(24),
          for (var i = 0; i < questions.length; i++)
            if (questions[i].toLowerCase().contains(query.toLowerCase()))
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ExpansionTile(
                  key: ValueKey('$i-$helpCategory'),
                  initiallyExpanded: i == open,
                  onExpansionChanged: (v) => setState(() => open = v ? i : -1),
                  shape: const Border(),
                  title: Text(
                    questions[i],
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  children: [
                    const Divider(),
                    const Gap(10),
                    Text(
                      answers[i],
                      style: const TextStyle(height: 1.6, color: muted),
                    ),
                  ],
                ),
              ),
        ],
      );
    }
    final names = [
      'Maryland Winkles',
      'Edgar Torrey',
      'Krishna Barbe',
      'Francene Vandyne',
      'Cyndy Lillibridge',
      'Alfonzo Schuessler',
      'Thad Eddings',
      'Tanner Stafford',
      'Darron Kulikowski',
      'Janetta Rotolo',
    ];
    return PageBody(
      children: [
        const Text(
          'Sample contacts · invitations are simulated locally',
          style: TextStyle(color: muted, fontSize: 12),
        ),
        const Gap(16),
        for (var i = 0; i < names.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              children: [
                Art('rank-${i % 6}', width: 52, height: 52, radius: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        names[i],
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        '+1-300-555-01${35 + i}',
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  style: invited.contains(i)
                      ? OutlinedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                        )
                      : null,
                  onPressed: () => setState(
                    () => invited.contains(i)
                        ? invited.remove(i)
                        : invited.add(i),
                  ),
                  child: Text(invited.contains(i) ? 'Invited' : 'Invite'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ScreenGallery extends StatelessWidget {
  const ScreenGallery({super.key});
  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Library'),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () => store.toggleDark(),
            icon: Icon(store.dark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: screenCatalog.length,
        itemBuilder: (_, i) {
          final s = screenCatalog[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: primary.withValues(alpha: .08),
              child: Text('${s.id}', style: const TextStyle(color: primary)),
            ),
            title: Text(s.name),
            subtitle: Text(
              '${store.dark ? 'Dark' : 'Light'} · Pixso #${s.id.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(s.id),
          );
        },
      ),
    );
  }
}

Widget logoutPanel(BuildContext context) => Padding(
  padding: const EdgeInsets.all(24),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text(
        'Logout',
        style: TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      const Gap(20),
      const Divider(),
      const Gap(20),
      const Text(
        'Are you sure you want to log out?',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      const Gap(28),
      Row(
        children: [
          Expanded(
            child: PrimaryButton(
              'Cancel',
              secondary: true,
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              'Yes, Logout',
              onPressed: () {
                StoreScope.of(context).logout();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/screen/4', (r) => false);
              },
            ),
          ),
        ],
      ),
      const Gap(16),
    ],
  ),
);
