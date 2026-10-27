import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import '../data/market_repository.dart';
import '../state/market_store.dart';

class SelectionRow extends StatelessWidget {
  final Widget title;
  final String value, groupValue;
  final ValueChanged<String?> onChanged;
  final EdgeInsetsGeometry? contentPadding;
  const SelectionRow({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.contentPadding,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    checked: value == groupValue,
    inMutuallyExclusiveGroup: true,
    child: ListTile(
      contentPadding: contentPadding,
      title: title,
      trailing: Icon(
        value == groupValue
            ? Icons.radio_button_checked
            : Icons.radio_button_off,
        color: primary,
      ),
      onTap: () => onChanged(value),
    ),
  );
}

extension Navigation on BuildContext {
  Future<T?> go<T>(int id, {Object? arguments}) =>
      Navigator.of(this).pushNamed<T>('/screen/$id', arguments: arguments);
  void message(String text) => ScaffoldMessenger.of(this).showSnackBar(
    SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
  );
  Color get fieldColor => Theme.of(this).brightness == Brightness.dark
      ? const Color(0xFF1F222A)
      : const Color(0xFFF5F5F5);
}

class Art extends StatelessWidget {
  final String name;
  final double? width, height;
  final double radius;
  final BoxFit fit;
  const Art(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.radius = 20,
    this.fit = BoxFit.cover,
  });
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image(
      image: name.startsWith('data:')
          ? MemoryImage(base64Decode(name.split(',').last))
          : AssetImage('assets/images/$name.png') as ImageProvider,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, e, s) => Container(
        width: width,
        height: height,
        color: primary.withValues(alpha: .1),
        child: const Icon(Icons.image_outlined, color: primary),
      ),
    ),
  );
}

class PageBody extends StatelessWidget {
  final List<Widget> children;
  const PageBody({super.key, required this.children});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
    children: children,
  );
}

class Gap extends StatelessWidget {
  final double size;
  const Gap([this.size = 24, Key? key]) : super(key: key);
  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}

class Heading extends StatelessWidget {
  final String text;
  final VoidCallback? onAll;
  const Heading(this.text, {super.key, this.onAll});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(text, style: Theme.of(context).textTheme.titleLarge),
      ),
      if (onAll != null)
        TextButton(
          onPressed: onAll,
          child: const Text(
            'See All',
            style: TextStyle(fontWeight: FontWeight.w700, color: primary),
          ),
        ),
    ],
  );
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final IconData? icon;
  const PrimaryButton(
    this.label, {
    super.key,
    this.onPressed,
    this.secondary = false,
    this.icon,
  });
  @override
  Widget build(BuildContext context) => FilledButton(
    style: secondary
        ? FilledButton.styleFrom(
            backgroundColor: primary.withValues(alpha: .1),
            foregroundColor: primary,
          )
        : null,
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 19), const SizedBox(width: 10)],
        Text(label),
      ],
    ),
  );
}

class BottomActions extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final String? secondary;
  final VoidCallback? onSecondary;
  const BottomActions(
    this.label, {
    super.key,
    this.onPressed,
    this.secondary,
    this.onSecondary,
  });
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
    ),
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
    child: SafeArea(
      top: false,
      child: Row(
        children: [
          if (secondary != null) ...[
            Expanded(
              child: PrimaryButton(
                secondary!,
                secondary: true,
                onPressed: onSecondary,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(child: PrimaryButton(label, onPressed: onPressed)),
        ],
      ),
    ),
  );
}

class ChoiceTabs extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  const ChoiceTabs(
    this.labels, {
    super.key,
    required this.selected,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          InkWell(
            onTap: () => onChanged(i),
            child: Container(
              constraints: BoxConstraints(
                minWidth:
                    (MediaQuery.sizeOf(context).width - 48) /
                    (labels.length > 3 ? 3 : labels.length),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: selected == i ? 3 : 1,
                    color: selected == i
                        ? primary
                        : Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected == i ? primary : muted,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class SearchBox extends StatelessWidget {
  final String hint;
  final VoidCallback? onTap, onFilter;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  const SearchBox({
    super.key,
    this.hint = 'Search NFT, creator, collection, ...',
    this.onTap,
    this.onFilter,
    this.onChanged,
    this.controller,
  });
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    readOnly: onTap != null,
    onTap: onTap,
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.search_rounded, color: muted, size: 22),
      suffixIcon: IconButton(
        tooltip: 'Filter',
        icon: const Icon(Icons.tune_rounded, color: primary, size: 21),
        onPressed: onFilter ?? () => context.go(22),
      ),
    ),
  );
}

class CategoryChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final List<String> options;
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onChanged,
    this.options = MarketRepository.categories,
  });
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final item in options)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(item),
              showCheckmark: false,
              selected: selected == item,
              onSelected: (_) => onChanged(item),
              selectedColor: primary,
              labelStyle: TextStyle(
                color: selected == item ? Colors.white : primary,
                fontWeight: FontWeight.w700,
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
      ],
    ),
  );
}

class CollectionCard extends StatelessWidget {
  final CollectionItem item;
  const CollectionCard(this.item, {super.key});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => context.go(35, arguments: item),
    borderRadius: BorderRadius.circular(20),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Art(item.image, height: 100, width: double.infinity, radius: 18),
              Positioned(
                bottom: -22,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 3,
                    ),
                  ),
                  child: Art(item.avatar, width: 48, height: 48, radius: 48),
                ),
              ),
            ],
          ),
          const Gap(28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const Gap(5),
          Text(
            item.handle,
            style: const TextStyle(fontSize: 11, color: primary),
          ),
          const Gap(14),
        ],
      ),
    ),
  );
}

class CollectionGrid extends StatelessWidget {
  final List<CollectionItem> items;
  const CollectionGrid(this.items, {super.key});
  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      mainAxisExtent: 190,
    ),
    itemCount: items.length,
    itemBuilder: (_, i) => CollectionCard(items[i]),
  );
}

class NftGrid extends StatelessWidget {
  final List<NftItem> items;
  const NftGrid(this.items, {super.key});
  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      mainAxisExtent: 278,
    ),
    itemCount: items.length,
    itemBuilder: (_, i) {
      final item = items[i];
      final store = StoreScope.of(context);
      return InkWell(
        onTap: () => context.go(40, arguments: item),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Art(item.image, width: double.infinity, radius: 16),
              ),
              const Gap(10),
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Gap(5),
              Text(
                item.collection,
                style: const TextStyle(color: primary, fontSize: 12),
              ),
              Row(
                children: [
                  const Icon(Icons.diamond_outlined, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${item.price}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Favorite ${item.name}',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => store.toggleFavorite(item.id),
                    icon: Icon(
                      store.favorites.contains(item.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 18,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class MenuRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final String? trailing;
  final Color color;
  const MenuRow(
    this.title,
    this.icon, {
    super.key,
    this.onTap,
    this.trailing,
    this.color = primary,
  });
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    onTap: onTap,
    leading: CircleAvatar(
      backgroundColor: color.withValues(alpha: .08),
      child: Icon(icon, color: color, size: 22),
    ),
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trailing != null)
          Text(trailing!, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, size: 20),
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const EmptyState(
    this.title,
    this.subtitle, {
    super.key,
    this.icon = Icons.search_off_rounded,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 70),
    child: Column(
      children: [
        Icon(icon, size: 110, color: primary.withValues(alpha: .35)),
        const Gap(28),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const Gap(14),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted, height: 1.6),
        ),
      ],
    ),
  );
}

Future<void> copyText(BuildContext context, String value) async {
  await Clipboard.setData(ClipboardData(text: value));
  if (context.mounted) context.message('Copied to clipboard');
}

class InfoPair extends StatelessWidget {
  final String label, value;
  const InfoPair(this.label, this.value, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: muted)),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
