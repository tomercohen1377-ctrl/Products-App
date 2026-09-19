/// A product as the live API returns it.
Map<String, dynamic> productJson({
  int id = 7,
  String title = 'Classic Blue Baseball Cap',
  num price = 79,
  String description = 'Adjustable strap.',
  List<Object?> images = const ['https://i.imgur.com/mp3rUty.jpeg'],
  Map<String, dynamic>? category = const {
    'id': 1,
    'name': 'Clothes',
    'slug': 'clothes',
    'image': 'https://i.imgur.com/QkIa5tT.jpeg',
    'creationAt': '2026-09-19T04:16:07.000Z',
    'updatedAt': '2026-09-19T04:16:07.000Z',
  },
}) => {
  'id': id,
  'title': title,
  'slug': 'slug',
  'price': price,
  'description': description,
  'category': ?category,
  'images': images,
  'creationAt': '2026-09-19T04:16:07.000Z',
  'updatedAt': '2026-09-19T04:16:07.000Z',
};
