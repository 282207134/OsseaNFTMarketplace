import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/market_repository.dart';
import '../state/market_store.dart';
import '../widgets/ui.dart';
import 'account/account_pages.dart';
import 'market/market_pages.dart';
import 'nft/create_pages.dart';
import 'nft/nft_pages.dart';
import 'onboarding/onboarding_pages.dart';
import 'profile/profile_pages.dart';
import 'statistics/statistics_page.dart';

class ScreenHost extends StatefulWidget {
  final int id;
  final Object? argument;
  const ScreenHost({super.key, required this.id, this.argument});
  @override
  State<ScreenHost> createState() => _ScreenHostState();
}

class _ScreenHostState extends State<ScreenHost> {
  int get id => widget.id;
  bool get profile => id >= 58 && id <= 65;
  bool get creator => id >= 32 && id <= 35;
  bool get detail => [36, 37, 38, 39, 40, 52, 56, 57].contains(id);
  bool get main => [
    6,
    7,
    24,
    25,
    29,
    30,
    58,
    59,
    60,
    61,
    62,
    63,
    64,
    65,
    66,
    81,
  ].contains(id);
  NftItem get item => widget.argument is NftItem
      ? widget.argument as NftItem
      : widget.argument is TradeRequest
      ? (widget.argument as TradeRequest).item
      : id >= 49 && id <= 57
      ? MarketRepository.cats[1]
      : MarketRepository.featured;
  TradeRequest get request => widget.argument is TradeRequest
      ? widget.argument as TradeRequest
      : TradeRequest(item);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) initialOverlay();
    });
  }

  void sheet(Widget content) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => SafeArea(child: content),
  );
  void initialOverlay() {
    if ([45, 48, 55].contains(id)) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 24,
          ),
          child: SuccessContent(id, item: item),
        ),
      );
    }
    if (id == 64) sheet(sharePanel(context));
    if (id == 65) {
      sheet(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MenuRow(
              'Edit Profile',
              Icons.edit_outlined,
              onTap: () =>
                  context.message('Profile editing is outside this UI kit'),
            ),
            MenuRow(
              'Share Profile',
              Icons.share_outlined,
              onTap: () => sheet(sharePanel(context)),
            ),
            const Gap(24),
          ],
        ),
      );
    }
    if (id == 81) sheet(logoutPanel(context));
    if ([26, 27, 28, 31].contains(id)) {
      final title = switch (id) {
        26 => 'Categories',
        27 => 'Chains',
        28 => 'Time',
        _ => 'Activity Filter',
      };
      final options = switch (id) {
        26 => ['All Categories', ...MarketRepository.categories.take(5)],
        27 => ['All Chains', 'Ethereum', 'Polygon', 'Solana'],
        28 => ['Last 24 Hours', 'Last 7 Days', 'Last 30 Days', 'All Time'],
        _ => ['All Events', 'Sales', 'Listings', 'Offers', 'Transfers'],
      };
      sheet(
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Heading(title),
              const Gap(16),
              for (final o in options)
                ListTile(
                  title: Text(o),
                  trailing: const Icon(
                    Icons.radio_button_unchecked,
                    color: primary,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.message('$title: $o');
                  },
                ),
              const Gap(16),
            ],
          ),
        ),
      );
    }
  }

  String get title => switch (id) {
    6 || 7 => 'Ossea',
    8 || 9 || 10 => 'Notification',
    11 => widget.argument is String ? widget.argument as String : 'Art',
    12 => 'Popular',
    13 => 'Notable Drops',
    14 => 'Trending Collections',
    15 || 16 || 17 || 18 || 19 || 20 => '',
    21 || 22 => 'Filter',
    23 => 'Sort',
    >= 24 && <= 31 => 'Statistics',
    >= 32 && <= 40 => '',
    41 => 'Make an Offer',
    42 || 43 => 'Approve Currency',
    44 || 45 => 'Confirm Offer',
    46 => 'Buy Now',
    47 || 48 => 'Complete Purchase',
    49 || 50 || 51 => 'Create New Item',
    52 => '',
    53 => 'List Item for Sale',
    54 || 55 => 'Complete Listing',
    56 || 57 => '',
    >= 58 && <= 65 => 'Profile',
    66 || 81 => 'More',
    67 => 'My Wallet',
    68 || 72 => 'My Collections',
    69 || 70 || 71 => 'Create a Collection',
    73 => 'Watchlist',
    74 => 'Settings',
    75 => 'E-Wallet',
    76 => 'Notification',
    77 => 'Security',
    78 => 'Language',
    79 => 'Help Center',
    80 => 'Invite Friends',
    _ => '',
  };
  Widget body() {
    if (id <= 5) return OnboardingPage(id);
    if (id <= 7) return const HomePage();
    if (id <= 10) return NotificationPage(id);
    if (id <= 14) {
      return BrowsePage(
        id,
        category: widget.argument is String ? widget.argument as String : 'Art',
      );
    }
    if (id <= 20) return SearchPage(id);
    if (id <= 23) return FilterPage(id);
    if (id <= 31) return StatisticsPage(id);
    if (id <= 35) {
      return ProfilePage(
        id,
        collection: widget.argument is CollectionItem
            ? widget.argument as CollectionItem
            : null,
      );
    }
    if (id <= 40 || [52, 56, 57].contains(id)) {
      return NftDetailPage(id, item: item);
    }
    if ([45, 48, 55].contains(id)) {
      return CheckoutPage(
        id == 45
            ? 44
            : id == 48
            ? 47
            : 54,
        request: request,
      );
    }
    if (id <= 48 || id == 54) return CheckoutPage(id, request: request);
    if (id <= 51 || [69, 70, 71].contains(id)) return CreatePage(id);
    if (id == 53) return ListingPage(item: item);
    if (profile) return ProfilePage(id);
    if (id == 66 || id == 81) return const MorePage();
    if (id == 67) return const WalletPage();
    if ([68, 72, 73].contains(id)) return CollectionsPage(id);
    if (id == 74) return const SettingsPage();
    return PreferencePage(id);
  }

  void options() {
    sheet(
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MenuRow(
              'Copy Link',
              Icons.link,
              onTap: () =>
                  copyText(context, 'https://ossea.io/items/${item.id}'),
            ),
            MenuRow(
              'View Collection',
              Icons.grid_view_outlined,
              onTap: () => context.go(35),
            ),
            MenuRow(
              'View Profile',
              Icons.person_outline,
              onTap: () => context.go(63),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return Scaffold(
      appBar: id <= 2
          ? null
          : AppBar(
              toolbarHeight: 72,
              title: title.isEmpty ? null : Text(title),
              leading: main
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Art('logo', radius: 0),
                    )
                  : IconButton(
                      tooltip: 'Back',
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          context.go(7);
                        }
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
              actions: [
                if (id == 6 || id == 7)
                  IconButton(
                    tooltip: 'Notifications',
                    onPressed: () => context.go(9),
                    icon: const Icon(Icons.notifications_none_rounded),
                  )
                else if (profile || creator || detail) ...[
                  if (detail)
                    IconButton(
                      tooltip: 'Favorite',
                      onPressed: () => store.toggleFavorite(item.id),
                      icon: Icon(
                        store.favorites.contains(item.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: store.favorites.contains(item.id)
                            ? primary
                            : null,
                      ),
                    ),
                  if (creator)
                    IconButton(
                      tooltip: 'Watch collection',
                      onPressed: () => store.toggleWatch(
                        widget.argument is CollectionItem
                            ? (widget.argument as CollectionItem).name
                            : 'Metafacely NFT',
                      ),
                      icon: Icon(
                        store.watchlist.contains(
                              widget.argument is CollectionItem
                                  ? (widget.argument as CollectionItem).name
                                  : 'Metafacely NFT',
                            )
                            ? Icons.visibility
                            : Icons.visibility_outlined,
                        color: primary,
                      ),
                    ),
                  IconButton(
                    tooltip: 'Share',
                    onPressed: () => sheet(sharePanel(context)),
                    icon: const Icon(Icons.send_outlined),
                  ),
                  IconButton(
                    tooltip: 'More options',
                    onPressed: options,
                    icon: const Icon(Icons.more_horiz),
                  ),
                ] else if (id == 68 || id == 72)
                  IconButton(
                    tooltip: 'Create collection',
                    onPressed: () => context.go(69),
                    icon: const Icon(Icons.add),
                  )
                else if (id == 66)
                  IconButton(
                    tooltip: 'Screen library',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScreenGallery()),
                    ),
                    icon: const Icon(Icons.view_carousel_outlined),
                  ),
                const SizedBox(width: 12),
              ],
            ),
      body: SafeArea(
        top: id <= 2,
        bottom: !main,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: KeyedSubtree(key: ValueKey('screen-$id'), child: body()),
          ),
        ),
      ),
      bottomNavigationBar: main ? bottomNav() : null,
    );
  }

  Widget bottomNav() {
    final selected = id <= 7
        ? 0
        : id <= 31
        ? 1
        : profile
        ? 3
        : 4;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < 5; i++)
                if (i == 2)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary,
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: .3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      tooltip: 'Create NFT',
                      onPressed: () => context.go(49),
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  )
                else
                  InkWell(
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      '/screen/${[7, 24, 49, 63, 66][i]}',
                    ),
                    child: SizedBox(
                      width: 62,
                      height: 48,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            [
                              Icons.home_rounded,
                              Icons.bar_chart_rounded,
                              Icons.add,
                              Icons.person_outline_rounded,
                              Icons.more_horiz_rounded,
                            ][i],
                            size: 25,
                            color: i == selected
                                ? primary
                                : muted.withValues(alpha: .65),
                          ),
                          const Gap(4),
                          Text(
                            ['Home', 'Statistics', '', 'Profile', 'More'][i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: i == selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: i == selected ? primary : muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
