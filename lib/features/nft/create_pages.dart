import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/market_repository.dart';
import '../../state/market_store.dart';
import '../../widgets/ui.dart';
import 'nft_pages.dart';

class CreatePage extends StatefulWidget {
  final int id;
  const CreatePage(this.id, {super.key});
  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name = TextEditingController(
    text: [50, 51, 70, 71].contains(widget.id)
        ? (collection ? 'Mystic Islands' : 'Nekochimin #477')
        : '',
  );
  final link = TextEditingController(),
      description = TextEditingController(),
      supply = TextEditingController(text: '1');
  String chain = 'Ethereum', category = 'Art', collectionName = 'Nekochimin';
  bool unlockable = false, sensitive = false;
  late String? image = [50, 51, 70, 71].contains(widget.id) ? 'cat-1' : null;
  String? featured, banner;
  final traits = <String>[];
  bool get collection => widget.id >= 69;
  @override
  void dispose() {
    name.dispose();
    link.dispose();
    description.dispose();
    supply.dispose();
    super.dispose();
  }

  Future<void> pick(ValueChanged<String> assign) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
        withData: true,
      );
      if (result == null || !mounted) return;
      final file = result.files.single;
      if (file.size > 2 * 1024 * 1024) {
        context.message('Choose an image smaller than 2 MB for this demo');
        return;
      }
      if (file.bytes != null) {
        setState(
          () => assign('data:image/png;base64,${base64Encode(file.bytes!)}'),
        );
      }
    } catch (e) {
      if (mounted) {
        context.message('Unable to open this file. Try another image.');
      }
    }
  }

  Widget upload(
    String title,
    String hint,
    String? value,
    ValueChanged<String> assign,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Heading(title),
      const Gap(10),
      Text(hint, style: const TextStyle(color: muted, height: 1.5)),
      const Gap(16),
      InkWell(
        onTap: () => pick(assign),
        child: Container(
          height: collection ? 170 : 240,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: primary.withValues(alpha: .3)),
            color: context.fieldColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: value != null
              ? Art(value, width: double.infinity, height: 240)
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, size: 55, color: muted),
                    Gap(16),
                    Text(
                      'Browse File',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
      TextButton(
        onPressed: () =>
            setState(() => assign(collection ? 'collection-0' : 'cat-1')),
        child: const Text('Use sample artwork'),
      ),
      const Gap(18),
    ],
  );
  Widget label(
    String text,
    TextEditingController controller, {
    String? hint,
    bool required = false,
    int lines = 1,
    bool number = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Heading(text),
      const Gap(14),
      TextFormField(
        controller: controller,
        maxLines: lines,
        keyboardType: number ? TextInputType.number : null,
        decoration: InputDecoration(hintText: hint),
        validator: (v) {
          if (required && (v == null || v.trim().isEmpty)) {
            return 'Please enter ${text.toLowerCase()}';
          }
          if (number && (int.tryParse(v ?? '') == null || int.parse(v!) < 1)) {
            return 'Supply must be a positive whole number';
          }
          if (controller == link &&
              v != null &&
              v.isNotEmpty &&
              !RegExp(r'^https?://\S+\.\S+').hasMatch(v)) {
            return 'Enter a valid https:// URL';
          }
          return null;
        },
      ),
      const Gap(24),
    ],
  );
  Future<void> addTrait() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add Property'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. Background: Blue'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty && mounted) {
      setState(() => traits.add(result.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final names = {
      'Nekochimin',
      ...store.createdCollections.map((c) => c.name),
    }.toList();
    return Column(
      children: [
        Expanded(
          child: Form(
            key: form,
            child: PageBody(
              children: [
                upload(
                  collection
                      ? 'Logo Image'
                      : 'Image, Video, Audio, or 3D Model',
                  collection
                      ? 'This image will also be used for navigation. 500 × 500 recommended.'
                      : 'PNG, JPG, WEBP · demo image upload up to 2 MB.',
                  image,
                  (v) => image = v,
                ),
                if (collection) ...[
                  upload(
                    'Featured Image',
                    'Used to feature your collection on the homepage. 800 × 600 recommended.',
                    featured,
                    (v) => featured = v,
                  ),
                  upload(
                    'Banner Image',
                    'Appears at the top of your collection page. 1800 × 600 recommended.',
                    banner,
                    (v) => banner = v,
                  ),
                ],
                label(
                  'Name',
                  name,
                  hint: collection ? 'Ex: Mystic Islands' : 'Item Name',
                  required: true,
                ),
                label(
                  collection ? 'URL' : 'External link (Optional)',
                  link,
                  hint: collection
                      ? 'https://ossea.io/collection/mystic-islands'
                      : 'https://examplesite.domain/',
                ),
                label(
                  'Description (Optional)',
                  description,
                  hint:
                      'Provide a detailed description of your ${collection ? 'collection' : 'item'}.',
                  lines: 4,
                ),
                Heading(collection ? 'Select Category' : 'Collection'),
                const Gap(14),
                DropdownButtonFormField<String>(
                  initialValue: collection ? category : collectionName,
                  items: (collection ? MarketRepository.categories : names)
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    if (collection) {
                      category = v!;
                    } else {
                      collectionName = v!;
                    }
                  }),
                ),
                const Gap(),
                if (collection) ...[
                  const Heading('Links'),
                  const Gap(14),
                  for (final h in [
                    'examplesite.domain',
                    'https://discord.gg/abcdef',
                    'https://twitter.com/abcdef',
                    'https://instagram.com/abcdef',
                  ]) ...[
                    TextFormField(decoration: InputDecoration(hintText: h)),
                    const Gap(12),
                  ],
                  const Gap(12),
                  const Heading('Creator Earnings'),
                  const Gap(12),
                  const Text(
                    'Earn a percentage every time one of your items is sold.',
                    style: TextStyle(color: muted, height: 1.5),
                  ),
                  const Gap(16),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Percentage, e.g. 2.5',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      final p = double.tryParse(v);
                      return p == null || p < 0 || p > 10
                          ? 'Enter a percentage between 0 and 10'
                          : null;
                    },
                  ),
                  const Gap(),
                ] else ...[
                  for (final t in ['Properties', 'Levels', 'Stats'])
                    MenuRow(
                      t,
                      t == 'Properties' ? Icons.label_outline : Icons.bar_chart,
                      onTap: addTrait,
                      trailing: '+',
                    ),
                  for (final trait in traits)
                    Chip(
                      label: Text(trait),
                      onDeleted: () => setState(() => traits.remove(trait)),
                    ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Unlockable Content',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Only revealed to the owner of the item.',
                    ),
                    value: unlockable,
                    onChanged: (v) => setState(() => unlockable = v),
                  ),
                  if (unlockable)
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter unlockable content',
                      ),
                      maxLines: 3,
                    ),
                  const Gap(12),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Explicit & Sensitive Content',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Set this item as explicit and sensitive content',
                  ),
                  value: sensitive,
                  onChanged: (v) => setState(() => sensitive = v),
                ),
                const Gap(),
                if (!collection) label('Supply', supply, number: true),
                const Heading('Blockchain'),
                const Gap(14),
                DropdownButtonFormField<String>(
                  initialValue: chain,
                  items: ['Ethereum', 'Polygon', 'Solana']
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setState(() => chain = v!),
                ),
                const Gap(),
                Heading(collection ? 'Payment Tokens' : 'Freeze Metadata'),
                const Gap(14),
                Text(
                  collection ? 'ETH · Ethereum' : 'Create your item first to lock and store its content in decentralized file storage.',
                  style: const TextStyle(color: muted, height: 1.6),
                ),
                const Gap(),
              ],
            ),
          ),
        ),
        BottomActions(
          'Create',
          secondary: 'Cancel',
          onSecondary: () => Navigator.maybePop(context),
          onPressed: () {
            if (!form.currentState!.validate()) return;
            if (image == null) {
              context.message('Choose an image or use sample artwork');
              return;
            }
            if (collection) {
              store.createdCollections.add(
                CollectionItem(name.text.trim(), featured ?? image!, image!),
              );
              store.save();
              context.go(72);
            } else {
              final item = NftItem(
                id: 'local-${DateTime.now().microsecondsSinceEpoch}',
                name: name.text.trim(),
                collection: collectionName,
                image: image!,
                price: 0,
              );
              store.addItem(item);
              context.go(52, arguments: item);
            }
          },
        ),
      ],
    );
  }
}

class ListingPage extends StatefulWidget {
  final NftItem item;
  const ListingPage({super.key, required this.item});
  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  final price = TextEditingController(text: '0.075');
  int type = 0;
  bool bundle = false, reserve = false;
  String duration = '1 month';
  String? error;
  @override
  void dispose() {
    price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: PageBody(
          children: [
            Row(
              children: [
                Art(widget.item.image, width: 90, height: 90),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Gap(8),
                      Text(
                        widget.item.collection,
                        style: const TextStyle(color: primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(28),
            const Heading('Type'),
            const Gap(16),
            ChoiceTabs(
              const ['Fixed Price', 'Time Auction'],
              selected: type,
              onChanged: (v) => setState(() => type = v),
            ),
            const Gap(),
            const Heading('Price'),
            const Gap(16),
            TextField(
              controller: price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                prefixText: '◆ ETH    ',
                errorText: error,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const Gap(12),
            Text(
              'Total Amount: \$${((double.tryParse(price.text) ?? 0) * 1277).toStringAsFixed(2)} USD',
              style: const TextStyle(color: muted),
            ),
            const Gap(),
            const Heading('Duration'),
            const Gap(14),
            DropdownButtonFormField<String>(
              initialValue: duration,
              items: [
                '1 week',
                '1 month',
                '3 months',
              ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => setState(() => duration = v!),
            ),
            const Gap(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sell as Bundle'),
              value: bundle,
              onChanged: (v) => setState(() => bundle = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reserve for Specific Buyer'),
              subtitle: const Text(
                "This item can be purchased as soon as it's listed",
              ),
              value: reserve,
              onChanged: (v) => setState(() => reserve = v),
            ),
            if (reserve)
              const TextField(
                decoration: InputDecoration(hintText: 'Buyer wallet address'),
              ),
            const Gap(),
            const Heading('Fee'),
            const Gap(14),
            const InfoPair('Service Fee', '2.5 %'),
            const InfoPair('Creator Fee', '5 %'),
            const Gap(),
          ],
        ),
      ),
      BottomActions(
        'Complete Listing',
        onPressed: () {
          final p = double.tryParse(price.text);
          if (p == null || !p.isFinite || p <= 0) {
            setState(() => error = 'Enter a price greater than zero');
            return;
          }
          context.go(
            54,
            arguments: TradeRequest(
              NftItem(
                id: widget.item.id,
                name: widget.item.name,
                collection: widget.item.collection,
                image: widget.item.image,
                price: p,
              ),
            ),
          );
        },
      ),
    ],
  );
}
