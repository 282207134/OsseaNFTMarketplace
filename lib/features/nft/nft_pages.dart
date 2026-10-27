import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/market_repository.dart';
import '../../state/market_store.dart';
import '../../widgets/ui.dart';

class TradeRequest {
  final NftItem item;
  final double amount;
  const TradeRequest(this.item, [this.amount = 124.755]);
}

class NftDetailPage extends StatefulWidget {
  final int id;
  final NftItem item;
  const NftDetailPage(
    this.id, {
    super.key,
    this.item = MarketRepository.featured,
  });
  @override
  State<NftDetailPage> createState() => _NftDetailPageState();
}

class _NftDetailPageState extends State<NftDetailPage> {
  late int tab = switch (widget.id) {
    37 => 1,
    38 => 2,
    39 => 3,
    _ => 0,
  };
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final store = StoreScope.of(context);
    final owned =
        store.purchased.contains(item.id) ||
        store.created.any((n) => n.id == item.id) ||
        widget.id >= 52;
    return Column(
      children: [
        Expanded(
          child: PageBody(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Art(item.image, width: double.infinity, radius: 28),
              ),
              const Gap(24),
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Gap(8),
              TextButton(
                onPressed: () => context.go(35),
                child: Text(
                  '${item.collection}  ✹',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
              ),
              const Divider(),
              const Gap(16),
              Row(
                children: [
                  for (var i = 0; i < 4; i++)
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            [
                              Icons.favorite_border,
                              Icons.people_outline,
                              Icons.grid_view,
                              Icons.visibility_outlined,
                            ][i],
                            size: 19,
                            color: muted,
                          ),
                          const Gap(10),
                          Text(
                            [
                              '${83 + (store.favorites.contains(item.id) ? 1 : 0)}',
                              '1',
                              '1',
                              '4,179',
                            ][i],
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          const Gap(6),
                          Text(
                            ['Favorites', 'Owners', 'Editions', 'Visitors'][i],
                            style: const TextStyle(color: muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Gap(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sale ends in 20h 46m 55s',
                      style: TextStyle(color: muted),
                    ),
                    const Gap(20),
                    const Text('Current Price'),
                    const Gap(14),
                    Text(
                      '◆ ${store.listingPrices[item.id] ?? item.price}',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const Gap(6),
                    const Text(
                      '(\$166,948.90)',
                      style: TextStyle(color: muted),
                    ),
                  ],
                ),
              ),
              const Gap(),
              Row(
                children: [
                  Expanded(
                    child: MenuRow(
                      'Metafacely',
                      Icons.verified,
                      onTap: () => context.go(35),
                    ),
                  ),
                  Expanded(
                    child: MenuRow(
                      'Claith_ETH',
                      Icons.person_outline,
                      onTap: () => context.go(63),
                    ),
                  ),
                ],
              ),
              const Gap(12),
              ChoiceTabs(
                const ['Details', 'Offers', 'Listings', 'Item Activity'],
                selected: tab,
                onChanged: (v) => setState(() => tab = v),
              ),
              const Gap(),
              if (tab == 0) ...[
                const Heading('About Collection'),
                const Gap(16),
                Text(
                  '${item.collection} is a collection of random NFT generated and resides on the Ethereum Blockchain. We focus on making NFTs that are unique and rare.',
                  style: const TextStyle(color: muted, height: 1.6),
                ),
                const Gap(),
                const Heading('Properties'),
                const Gap(16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final p in [
                      'BACKGROUND|Dark Grey|16 %',
                      'CLOTHING|Hoody|24 %',
                      'EYES|Glasses|8 %',
                      'HAIR|No Hair|5 %',
                      'TYPE|Human|40 %',
                    ])
                      Container(
                        width: 108,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: primary.withValues(alpha: .07),
                          border: Border.all(
                            color: primary.withValues(alpha: .2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              p.split('|')[0],
                              style: const TextStyle(
                                color: primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Gap(10),
                            Text(
                              p.split('|')[1],
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              p.split('|')[2],
                              style: const TextStyle(
                                fontSize: 11,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const Gap(),
                const Heading('Details'),
                const Gap(12),
                const InfoPair('Contract Address', '0xb7944...57v689'),
                InfoPair('Token ID', item.id),
                const InfoPair('Token Standard', 'ERC-721'),
                const InfoPair('Blockchain', 'Ethereum'),
                const InfoPair('Creator Earnings', '2.5 %'),
                const Gap(),
                const Heading('Price History'),
                const Gap(16),
                SizedBox(
                  height: 150,
                  child: CustomPaint(
                    painter: PriceChart(),
                    size: const Size(double.infinity, 150),
                  ),
                ),
                const Gap(16),
                const InfoPair('All time average price', '◆ 3.5489'),
                const Gap(),
                Heading(
                  'More from this collection',
                  onAll: () => context.go(35),
                ),
                const Gap(16),
                NftGrid(MarketRepository.cats.take(2).toList()),
              ] else ...[
                for (var i = 0; i < 8; i++)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    leading: Art(
                      'rank-${i % 6}',
                      width: 48,
                      height: 48,
                      radius: 48,
                    ),
                    title: Text(
                      tab == 1
                          ? 'Offer from AndrewNFT'
                          : tab == 2
                          ? 'Listing by Claith_ETH'
                          : 'Sale · Metafacely',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text('${i + 1} hours ago'),
                    trailing: Text(
                      '◆ ${(124.755 - i * 2).toStringAsFixed(3)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
              const Gap(),
            ],
          ),
        ),
        if (owned)
          BottomActions(
            store.listed.contains(item.id) || widget.id >= 56
                ? 'Edit Listing'
                : 'Sell',
            secondary: 'Transfer',
            onSecondary: () =>
                context.message('Transfers are unavailable in demo mode'),
            onPressed: () => context.go(53, arguments: item),
          )
        else
          BottomActions(
            'Buy Now',
            secondary: 'Make Offer',
            onPressed: () => context.go(46, arguments: TradeRequest(item)),
            onSecondary: () => context.go(41, arguments: TradeRequest(item)),
          ),
      ],
    );
  }
}

class PriceChart extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = muted.withValues(alpha: .18)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = i * size.height / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final path = Path();
    const values = [.8, .74, .78, .65, .69, .43, .52, .32, .4, .18, .29, .12];
    for (var i = 0; i < values.length; i++) {
      final p = Offset(
        i * size.width / (values.length - 1),
        values[i] * size.height,
      );
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = primary
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant PriceChart oldDelegate) => false;
}

class CheckoutPage extends StatefulWidget {
  final int id;
  final TradeRequest request;
  const CheckoutPage(
    this.id, {
    super.key,
    this.request = const TradeRequest(MarketRepository.featured),
  });
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final amount = TextEditingController(text: '124.755');
  final address = TextEditingController(
    text: '0x7131CA84856767f3126de58848f8E69600000000',
  );
  String expiration = '3 Days', currency = 'ETH';
  String? error;
  bool alternate = true;
  @override
  void initState() {
    super.initState();
    amount.text = '${widget.request.amount}';
  }

  @override
  void dispose() {
    amount.dispose();
    address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.id,
        request = widget.request,
        item = request.item,
        store = StoreScope.of(context);
    final approval = id == 42 || id == 43;
    final signature = id == 44 || id == 47 || id == 54;
    return Column(
      children: [
        Expanded(
          child: PageBody(
            children: [
              if (id == 41) ...[
                Row(
                  children: [
                    const Expanded(child: Heading('Offer Amount')),
                    Text(
                      'Balance: ${store.balance.toStringAsFixed(3)} ETH',
                      style: const TextStyle(fontSize: 11, color: muted),
                    ),
                  ],
                ),
                const Gap(16),
                DropdownButtonFormField<String>(
                  initialValue: currency,
                  items: ['ETH', 'WETH']
                      .map(
                        (v) => DropdownMenuItem(value: v, child: Text('◆  $v')),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => currency = v!),
                ),
                const Gap(16),
                TextField(
                  key: const Key('offer-amount'),
                  controller: amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    errorText: error,
                  ),
                ),
                const Gap(12),
                Text(
                  'Total Offer Amount: ${amount.text} $currency',
                  style: const TextStyle(fontSize: 12, color: muted),
                ),
                const Gap(),
                const Heading('Offer Expiration'),
                const Gap(16),
                DropdownButtonFormField<String>(
                  initialValue: expiration,
                  items: ['1 Day', '3 Days', '7 Days', '1 Month']
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setState(() => expiration = v!),
                ),
                const Gap(16),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: context.fieldColor,
                  title: Text(
                    '${DateTime.now().add(Duration(days: expiration == '1 Day'
                            ? 1
                            : expiration == '7 Days'
                            ? 7
                            : 3)).toLocal()}'
                        .split('.')
                        .first,
                  ),
                  trailing: const Icon(Icons.calendar_month_outlined),
                ),
              ] else if (approval) ...[
                const Art('wallet-0', height: 130, fit: BoxFit.contain),
                const Gap(),
                Text(
                  'Give permission to access your ETH?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Gap(16),
                const Text(
                  'By granting permission, you are allowing the following contract to access your funds.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, height: 1.6),
                ),
                const Gap(),
                const InfoPair('Contract', '0xb7944...57v689'),
                const InfoPair('Gas Fee (estimated)', '0.003 ETH'),
                const Divider(),
                const Gap(),
                const Heading('Permission Request'),
                const Gap(12),
                const Text(
                  'https://ossea.io may access and spend up to this max amount:',
                  style: TextStyle(color: muted, height: 1.6),
                ),
                InfoPair('Approved Amount', '${request.amount} ETH'),
                const InfoPair('Granted to', '0xb7944...57v689'),
                const Gap(),
                const Heading('Data'),
                const InfoPair('Function', 'Approve'),
                const Text(
                  '0x09h6fa0000000000000000000000000000000000000000000000000000000000',
                  style: TextStyle(color: muted, height: 1.6),
                ),
              ] else ...[
                if (signature) ...[
                  const Art('wallet-0', height: 110, fit: BoxFit.contain),
                  const Gap(16),
                  Text(
                    'Signature Request',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Gap(8),
                  const Text('https://ossea.io', textAlign: TextAlign.center),
                  const Gap(8),
                  const Text(
                    '0x7131CA84856767f...8848f8E696',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted),
                  ),
                  const Gap(30),
                ],
                Row(
                  children: [
                    Art(item.image, width: 60, height: 60, radius: 14),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.collection,
                            style: const TextStyle(color: muted, fontSize: 12),
                          ),
                          const Gap(6),
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const Gap(6),
                          const Text(
                            'Quantity: 1',
                            style: TextStyle(fontSize: 12, color: muted),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          id == 44 ? 'Offer' : 'Price',
                          style: const TextStyle(color: muted, fontSize: 12),
                        ),
                        const Gap(8),
                        Text(
                          '◆ ${id == 44 ? request.amount : item.price}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(30),
                if (signature)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Heading('Message'),
                        Gap(16),
                        Text(
                          'offerer:\n0x7131CA848567678fj464dh37f81848f8E696\noffer: 0:\nitemType: 1\ntoken:\n0x7ceB23fD6bC0adD845578270cFf1b9f619\nidentifierOrCriteria: 0\nstartAmount:\n1000000000000000\nendAmount:\n1000000000000000\nconsideration: []',
                          style: TextStyle(color: muted, height: 1.7),
                        ),
                      ],
                    ),
                  )
                else ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Send to a Different Wallet',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    value: alternate,
                    onChanged: (v) => setState(() => alternate = v),
                  ),
                  if (alternate)
                    TextField(
                      controller: address,
                      decoration: InputDecoration(
                        errorText: error,
                        hintText: '0x...',
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                ],
              ],
              const Gap(30),
              const Text(
                'Demo transaction · no funds will be moved',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),
        BottomActions(
          signature
              ? 'Sign'
              : approval
              ? 'Confirm'
              : id == 41
              ? 'Make Offer'
              : 'Complete Purchase',
          secondary: signature
              ? 'Cancel'
              : approval
              ? 'Reject'
              : null,
          onSecondary: () => Navigator.maybePop(context),
          onPressed: () {
            if (id == 41) {
              final value = double.tryParse(amount.text);
              if (value == null ||
                  !value.isFinite ||
                  value <= 0 ||
                  value > store.balance) {
                setState(
                  () => error =
                      'Enter an amount between 0 and your available balance',
                );
                return;
              }
              context.go(43, arguments: TradeRequest(item, value));
            } else if (approval) {
              context.go(44, arguments: request);
            } else if (id == 44) {
              if (!store.connected) {
                context.message('Connect a demo wallet first');
                context.go(4);
                return;
              }
              store.makeOffer(item.id, request.amount);
              context.go(45, arguments: request);
            } else if (id == 46) {
              if (alternate &&
                  !RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address.text)) {
                setState(() => error = 'Enter a valid Ethereum address');
                return;
              }
              context.go(47, arguments: request);
            } else if (id == 47) {
              if (!store.connected) {
                context.message('Connect a demo wallet first');
                context.go(4);
                return;
              }
              if (store.buy(item)) {
                context.go(48, arguments: request);
              } else {
                context.message('You already own this NFT');
              }
            } else if (id == 54) {
              store.listItem(item.id, item.price);
              context.go(55, arguments: request);
            }
          },
        ),
      ],
    );
  }
}

class SuccessContent extends StatelessWidget {
  final int id;
  final NftItem item;
  const SuccessContent(
    this.id, {
    super.key,
    this.item = MarketRepository.featured,
  });
  @override
  Widget build(BuildContext context) {
    final offer = id == 45, listing = id == 55;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              offer
                  ? Icons.local_offer
                  : listing
                  ? Icons.check_rounded
                  : Icons.account_balance_wallet,
              color: Colors.white,
              size: 66,
            ),
          ),
          const Gap(32),
          const Text(
            'Congratulations!',
            style: TextStyle(
              color: primary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(16),
          Text(
            offer
                ? 'You have made an offer for NFT. You can check your offer on the menu Profile → Offers Made'
                : listing
                ? 'Your NFT has been listed successfully. View it in your collection.'
                : 'You have successfully purchased this NFT. Find it in Profile → Purchased.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const Gap(32),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              offer
                  ? 'Go to Offers Made'
                  : listing
                  ? 'View Listing'
                  : 'View Purchased NFT',
              onPressed: () => context.go(
                offer
                    ? 61
                    : listing
                    ? 57
                    : 62,
                arguments: listing ? item : null,
              ),
            ),
          ),
          const Gap(12),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              'Cancel',
              secondary: true,
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
        ],
      ),
    );
  }
}
