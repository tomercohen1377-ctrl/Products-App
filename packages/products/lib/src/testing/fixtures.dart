import 'package:products/src/domain/entities/category.dart';
import 'package:products/src/domain/entities/product.dart';
import 'package:products/src/domain/entities/product_draft.dart';

/// Sample data shared by previews and tests. Images are real, stable URLs so
/// previews look like the app.
const clothes = Category(
  id: 1,
  name: 'Clothes',
  imageUrl: 'https://i.imgur.com/QkIa5tT.jpeg',
);
const electronics = Category(
  id: 2,
  name: 'Electronics',
  imageUrl: 'https://i.imgur.com/ZANVnHE.jpeg',
);
const furniture = Category(
  id: 3,
  name: 'Furniture',
  imageUrl: 'https://i.imgur.com/Qphac99.jpeg',
);

const categoryFixtures = [clothes, electronics, furniture];

const productFixture = Product(
  id: 2,
  title: 'Classic Red Pullover Hoodie',
  price: 10,
  description:
      'Elevate your casual wardrobe with our Classic Red Pullover Hoodie. '
      'Crafted with a soft cotton blend for ultimate comfort, this vibrant red '
      'hoodie features a kangaroo pocket, adjustable drawstring hood, and '
      'ribbed cuffs for a snug fit.',
  images: [
    'https://i.imgur.com/1twoaDy.jpeg',
    'https://i.imgur.com/FDwQgLy.jpeg',
    'https://i.imgur.com/kg1ZhhH.jpeg',
  ],
  category: clothes,
);

/// A dozen distinct products for list and deck previews and tests.
final List<Product> productFixtures = [
  productFixture,
  const Product(
    id: 4,
    title: 'Classic Grey Hooded Sweatshirt',
    price: 90,
    description: 'Soft cotton blend with a front kangaroo pocket.',
    images: ['https://i.imgur.com/R2PN9Wq.jpeg'],
    category: clothes,
  ),
  const Product(
    id: 5,
    title: 'Classic Black Hooded Sweatshirt',
    price: 79.5,
    description: 'Perfect for chilly evenings or lazy weekends.',
    images: ['https://i.imgur.com/cSytoSD.jpeg'],
    category: clothes,
  ),
  const Product(
    id: 6,
    title: 'Classic Comfort Fit Joggers',
    price: 25,
    description: 'Relaxed joggers with an elastic waistband.',
    images: ['https://i.imgur.com/ZKGofuB.jpeg'],
    category: clothes,
  ),
  const Product(
    id: 7,
    title: 'Classic Blue Baseball Cap',
    price: 79,
    description: 'Adjustable strap, breathable fabric.',
    images: ['https://i.imgur.com/mp3rUty.jpeg'],
    category: clothes,
  ),
  const Product(
    id: 8,
    title: 'Classic Red Baseball Cap',
    price: 98,
    description: 'A timeless cap for every day.',
    images: ['https://i.imgur.com/9LFjwpI.jpeg'],
    category: clothes,
  ),
  const Product(
    id: 9,
    title: 'Classic Wireless Headphones',
    price: 61,
    description: 'Over-ear headphones with 30 hours of battery life.',
    images: ['https://i.imgur.com/R3iobJA.jpeg'],
    category: electronics,
  ),
  const Product(
    id: 10,
    title: 'Sleek Smartwatch',
    price: 86,
    description: 'Track your day with a bright always-on display.',
    images: ['https://i.imgur.com/wXuQ7bm.jpeg'],
    category: electronics,
  ),
  const Product(
    id: 11,
    title: 'Modern Accent Chair',
    price: 35,
    description: 'Compact accent chair with a solid oak frame.',
    images: ['https://i.imgur.com/cBuLvBi.jpeg'],
    category: furniture,
  ),
  const Product(
    id: 12,
    title: 'Minimalist Side Table',
    price: 58,
    description: 'A small table that fits anywhere.',
    images: ['https://i.imgur.com/KeqG6r4.jpeg'],
    category: furniture,
  ),
  const Product(
    id: 13,
    title: 'Ergonomic Desk Lamp',
    price: 84,
    description: 'Adjustable arm and warm, dimmable light.',
    images: ['https://i.imgur.com/UsFIvYs.jpeg'],
    category: electronics,
  ),
  const Product(
    id: 14,
    title: 'Scandinavian Bookshelf',
    price: 43.25,
    description: 'Five shelves, easy assembly.',
    images: ['https://i.imgur.com/eGOUveI.jpeg'],
    category: furniture,
  ),
];

const draftFixture = ProductDraft(
  title: 'Classic Red Pullover Hoodie',
  price: 10,
  description: 'A comfy hoodie.',
  categoryId: 1,
  images: ['https://i.imgur.com/1twoaDy.jpeg'],
);
