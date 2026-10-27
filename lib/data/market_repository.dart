class CollectionItem {
  final String name, image, avatar;
  final String category, chain, status;
  final double floorPrice;
  const CollectionItem(
    this.name,
    this.image,
    this.avatar, {
    this.category = 'Art',
    this.chain = 'Ethereum',
    this.status = 'Buy Now',
    this.floorPrice = .075,
  });
  String get handle => name.toLowerCase().replaceAll(' ', '_');
}

class NftItem {
  final String id, name, collection, image;
  final double price;
  const NftItem({
    required this.id,
    required this.name,
    required this.collection,
    required this.image,
    required this.price,
  });
}

/// Local fixture boundary: replace this repository to connect a real backend.
class MarketRepository {
  static const categories = [
    'Art',
    'Collectibles',
    'Domain Names',
    'Music',
    'Photography',
    'Sports',
    'Trading Cards',
    'Utility',
    'Virtual Worlds',
  ];
  static const collections = [
    CollectionItem('3D Zombieya', 'collection-zombie', 'avatar-zombie'),
    CollectionItem('Surface AI Labs', 'collection-surface', 'avatar-surface'),
    CollectionItem('Paradise Islands', 'discover-2', 'avatar-2'),
    CollectionItem('Dynamically', 'discover-3', 'avatar-3'),
    CollectionItem('Dose of Art', 'collection-0', 'avatar-0'),
    CollectionItem(
      'Crypto Diamonds',
      'collection-1',
      'avatar-1',
      category: 'Collectibles',
      chain: 'Polygon',
      floorPrice: .2,
    ),
    CollectionItem(
      'Secret Stones',
      'collection-2',
      'avatar-2',
      status: 'On Auction',
      floorPrice: .08,
    ),
    CollectionItem('Glassica', 'collection-3', 'avatar-3'),
    CollectionItem('3D Skull Faces', 'collection-4', 'avatar-4'),
    CollectionItem('Dynamic Water', 'collection-5', 'avatar-5'),
    CollectionItem('Meteorite NFT', 'collection-6', 'avatar-6'),
    CollectionItem('Art Cubica', 'collection-7', 'avatar-7'),
    CollectionItem('Metafacely NFT', 'creator-cover', 'creator-avatar'),
  ];
  static const featured = NftItem(
    id: '9167',
    name: 'Metafacely #9167',
    collection: 'Metafacely NFT',
    image: 'nft-main',
    price: 125.6975,
  );
  static final cats = List.generate(
    8,
    (i) => NftItem(
      id: 'cat-$i',
      name: 'Nekochimin #${[33, 309, 359, 385, 493, 318, 444, 249][i]}',
      collection: 'Nekochimin',
      image: 'cat-${i + 1}',
      price: [.09, .075, .08, .09, .075, .06, .085, .08][i],
    ),
  );
  static const rankingNames = [
    'Futuristic Realism',
    'Artistic Alpha',
    'Imaginations',
    'Nova Auroras',
    'Spells of Genesis',
    'Crypto Jackpot',
  ];
}
