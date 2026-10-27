import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../state/market_store.dart';
import '../../widgets/ui.dart';

class OnboardingPage extends StatefulWidget {
  final int id;
  const OnboardingPage(this.id, {super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int step = 0;
  final address = TextEditingController();
  String? error;
  @override
  void dispose() {
    address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.id == 1) {
      return Center(
        child: InkWell(
          onTap: () => context.go(2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Art('logo', width: 100, height: 100),
              const Gap(24),
              Text('Ossea', style: Theme.of(context).textTheme.headlineLarge),
            ],
          ),
        ),
      );
    }
    if (widget.id == 2) {
      return Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Art('rocket', fit: BoxFit.contain, width: double.infinity),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              children: [
                Text(
                  [
                    'Launch and Grow\nyour great NFT!',
                    'Discover extraordinary\ndigital collectibles',
                    'Create, collect and\nshare your own world',
                  ][step],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const Gap(20),
                const Text(
                  'Explore unique digital art, connect with creators, and discover your next collection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                const Gap(28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (i) => Container(
                      margin: const EdgeInsets.all(3),
                      height: 6,
                      width: step == i ? 28 : 6,
                      decoration: BoxDecoration(
                        color: step == i ? primary : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                const Gap(28),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    step == 2 ? 'Get Started' : 'Next',
                    onPressed: () {
                      if (step < 2) {
                        setState(() => step++);
                      } else {
                        StoreScope.of(context).finishOnboarding();
                        context.go(4);
                      }
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    StoreScope.of(context).finishOnboarding();
                    context.go(7);
                  },
                  child: const Text('Explore as guest'),
                ),
              ],
            ),
          ),
        ],
      );
    }
    if (widget.id == 5) {
      return PageBody(
        children: [
          const Art('wallet', height: 220, fit: BoxFit.contain),
          const Gap(),
          const Heading('Connect with ETH Address'),
          const Gap(12),
          const Text(
            'Enter your public Ethereum address to view your collection.',
            style: TextStyle(color: muted, height: 1.5),
          ),
          const Gap(),
          TextField(
            controller: address,
            decoration: InputDecoration(hintText: '0x...', errorText: error),
          ),
          const Gap(),
          PrimaryButton(
            'Connect Wallet',
            onPressed: () {
              if (!RegExp(r'^0x[a-fA-F0-9]{40}$')
                  .hasMatch(address.text.trim())) {
                setState(
                  () => error = 'Enter a valid 42-character Ethereum address',
                );
                return;
              }
              StoreScope.of(context).connect('ETH Address');
              context.go(7);
            },
          ),
          const Gap(16),
          const Text(
            'Demo connection · public address only',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted),
          ),
        ],
      );
    }
    final providers = [
      'Metamask',
      'Coinbase Wallet',
      'WalletConnect',
      'Trust Wallet',
      'Fortmatic',
      'Rainbow',
      'Ledger',
    ];
    return PageBody(
      children: [
        const Art('wallet', height: 250, fit: BoxFit.contain),
        const Gap(20),
        const Text(
          'Login to Your Wallet',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: primary,
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(12),
        const Text(
          'Connect to any wallet to securely store your digital goods NFT & cryptocurrencies.',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted, fontSize: 16, height: 1.5),
        ),
        const Gap(28),
        for (var i = 0; i < providers.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: i < 5
                  ? Art('wallet-$i', width: 46, height: 46, radius: 8)
                  : const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: primary,
                      size: 38,
                    ),
              title: Text(
                providers[i],
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              trailing: i == 0
                  ? const Text(
                      'Popular',
                      style: TextStyle(fontSize: 10, color: primary),
                    )
                  : null,
              onTap: () {
                StoreScope.of(context).connect(providers[i]);
                context.message('Demo wallet connected');
                context.go(7);
              },
            ),
          ),
        TextButton(
          onPressed: () => context.go(5),
          child: const Text('Connect with ETH Address'),
        ),
        const Text(
          'Demo mode: no real wallet signature or funds.',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted),
        ),
        const Gap(),
      ],
    );
  }
}
