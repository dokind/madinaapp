import 'package:madinaapp/models/models.dart';

class DummyData {
  static List<Product> get products => [
        Product(
          id: '1',
          name: 'Шелковая ткань',
          price: 15000.0,
          imagePath: 'assets/images/1.png',
          description:
              'Мягкий, легкий и естественно глянцевый - наша 100% шелковая ткань предлагает элегантную драпировку и дышащий комфорт. Идеально подходит для одежды, аксессуаров или домашнего декора.',
          tag: 'Информация о запасе отсутствует',
          category: 'Шелковая ткань',
          color: 'Белый',
          size: 'M',
          rating: 4.8,
          unit: 'двор',
          images: [
            'assets/images/1.png',
            'assets/images/silk_detail_1.png',
            'assets/images/silk_detail_2.png',
            'assets/images/silk_detail_3.png',
          ],
          availableColors: [
            ProductColor(
                name: 'Черный', colorValue: 0xFF1F2024, isSelected: false),
            ProductColor(
                name: 'Серый', colorValue: 0xFF71727A, isSelected: false),
            ProductColor(
                name: 'Золото', colorValue: 0xFFDAA520, isSelected: true),
            ProductColor(
                name: 'Белый', colorValue: 0xFFE8E9F1, isSelected: false),
            ProductColor(
                name: 'Коралл', colorValue: 0xFFFF6B6B, isSelected: false),
            ProductColor(
                name: 'Бирюзовый', colorValue: 0xFF4ECDC4, isSelected: false),
          ],
        ),
        Product(
          id: '2',
          name: 'Золотистая ткань',
          price: 30000.0,
          imagePath: 'assets/images/2.png',
          description:
              'Элегантная золотистая ткань для особых случаев с роскошным блеском и мягкой текстурой.',
          tag: 'Название продукта отсутствует',
          category: 'Шелковая ткань',
          color: 'Золото',
          size: 'L',
          rating: 4.9,
          unit: 'двор',
          images: [
            'assets/images/2.png',
            'assets/images/gold_detail_1.png',
            'assets/images/gold_detail_2.png',
          ],
          availableColors: [
            ProductColor(
                name: 'Золото', colorValue: 0xFFDAA520, isSelected: true),
            ProductColor(
                name: 'Серебро', colorValue: 0xFFC0C0C0, isSelected: false),
            ProductColor(
                name: 'Бронза', colorValue: 0xFFCD7F32, isSelected: false),
          ],
        ),
        Product(
          id: '3',
          name: 'Чистая льняная ткань',
          price: 15000.0,
          imagePath: 'assets/images/3.png',
          description:
              'Натуральная льняная ткань премиум класса с превосходной воздухопроницаемостью и долговечностью.',
          category: 'Льняная ткань',
          color: 'Серый',
          size: 'S',
          rating: 4.7,
          unit: 'двор',
          images: [
            'assets/images/3.png',
            'assets/images/linen_detail_1.png',
          ],
          availableColors: [
            ProductColor(
                name: 'Серый', colorValue: 0xFF71727A, isSelected: true),
            ProductColor(
                name: 'Белый', colorValue: 0xFFE8E9F1, isSelected: false),
            ProductColor(
                name: 'Бежевый', colorValue: 0xFFF5F5DC, isSelected: false),
          ],
        ),
        Product(
          id: '4',
          name: 'Коралловая ткань',
          price: 18000.0,
          imagePath: 'assets/images/4.png',
          description:
              'Яркая коралловая ткань для летних изделий с яркими цветами и мягкой текстурой.',
          category: 'Хлопковая ткань',
          color: 'Красный',
          size: 'M',
          rating: 4.6,
          unit: 'двор',
          images: [
            'assets/images/4.png',
          ],
          availableColors: [
            ProductColor(
                name: 'Коралл', colorValue: 0xFFFF6B6B, isSelected: true),
            ProductColor(
                name: 'Розовый', colorValue: 0xFFFFB6C1, isSelected: false),
            ProductColor(
                name: 'Оранжевый', colorValue: 0xFFFFA500, isSelected: false),
          ],
        ),
        Product(
          id: '5',
          name: 'Бордовая ткань',
          price: 22000.0,
          imagePath: 'assets/images/5.png',
          description:
              'Роскошная бордовая ткань для вечерних нарядов с глубоким насыщенным цветом.',
          category: 'Шерстяная ткань',
          color: 'Красный',
          size: 'L',
          rating: 4.8,
          unit: 'двор',
          images: [
            'assets/images/5.png',
          ],
          availableColors: [
            ProductColor(
                name: 'Бордовый', colorValue: 0xFF800020, isSelected: true),
            ProductColor(
                name: 'Черный', colorValue: 0xFF1F2024, isSelected: false),
            ProductColor(
                name: 'Темно-синий', colorValue: 0xFF000080, isSelected: false),
          ],
        ),
        Product(
          id: '6',
          name: 'Бежевая ткань',
          price: 16000.0,
          imagePath: 'assets/images/6.png',
          description:
              'Нейтральная бежевая ткань для повседневной одежды с универсальным дизайном.',
          category: 'Хлопковая ткань',
          color: 'Желтый',
          size: 'M',
          rating: 4.5,
          unit: 'двор',
          images: [
            'assets/images/6.png',
          ],
          availableColors: [
            ProductColor(
                name: 'Бежевый', colorValue: 0xFFF5F5DC, isSelected: true),
            ProductColor(
                name: 'Кремовый', colorValue: 0xFFFFFDD0, isSelected: false),
            ProductColor(
                name: 'Желтый', colorValue: 0xFFFFFF00, isSelected: false),
          ],
        ),
        Product(
          id: '7',
          name: 'Серая ткань',
          price: 17000.0,
          imagePath: 'assets/images/7.png',
          description:
              'Классическая серая ткань для деловых костюмов с элегантным внешним видом.',
          category: 'Шерстяная ткань',
          color: 'Серый',
          size: 'L',
          rating: 4.4,
          unit: 'двор',
          images: [
            'assets/images/7.png',
          ],
          availableColors: [
            ProductColor(
                name: 'Серый', colorValue: 0xFF71727A, isSelected: true),
            ProductColor(
                name: 'Темно-серый', colorValue: 0xFF2F3036, isSelected: false),
            ProductColor(
                name: 'Светло-серый',
                colorValue: 0xFFE8E9F1,
                isSelected: false),
          ],
        ),
        Product(
          id: '8',
          name: 'Розовая ткань',
          price: 19000.0,
          imagePath: 'assets/images/8.png',
          description:
              'Нежная розовая ткань для романтических нарядов с мягким оттенком.',
          category: 'Шелковая ткань',
          color: 'Розовый',
          size: 'S',
          rating: 4.7,
          unit: 'двор',
          images: [
            'assets/images/8.png',
          ],
          availableColors: [
            ProductColor(
                name: 'Розовый', colorValue: 0xFFFFB6C1, isSelected: true),
            ProductColor(
                name: 'Светло-розовый',
                colorValue: 0xFFFFD1DC,
                isSelected: false),
            ProductColor(
                name: 'Лососевый', colorValue: 0xFFFA8072, isSelected: false),
          ],
        ),
      ];

  static List<Order> get orders => [
        Order(
          id: 'AN9981200172',
          customerName: 'Нурбек Закхайев',
          description: 'Льняная ткань - 5 продуктов, разные цвета . . .',
          timeAgo: '2 дня назад',
          status: OrderStatus.completed,
          category: 'Льняная ткань',
          priceRange: '15000-25000',
          customerRating: 4.8,
          products: [
            products[2],
            products[1],
            products[5],
            products[6],
            products[7]
          ],
        ),
        Order(
          id: '1',
          customerName: 'Дэвид -младший',
          description: 'Шелковая ткань - 20 ярдов, льняная ткань . . .',
          timeAgo: '20 минут назад',
          status: OrderStatus.actionRequired,
          category: 'Шелковая ткань',
          priceRange: '20000-30000',
          customerRating: 4.6,
          products: [products[0], products[2]],
        ),
        Order(
          id: '2',
          customerName: 'Джон Доу',
          description: 'Сатинированная ткань - 40 ярдов, льняная ткань . . .',
          timeAgo: '1 день назад',
          status: OrderStatus.refundRequested,
          category: 'Хлопковая ткань',
          priceRange: '15000-20000',
          customerRating: 3.5,
          products: [products[1], products[3]],
        ),
        Order(
          id: '3',
          customerName: 'Мария Петрова',
          description: 'Бордовая ткань - 15 ярдов, розовая ткань . . .',
          timeAgo: '2 часа назад',
          status: OrderStatus.processing,
          category: 'Шерстяная ткань',
          priceRange: '18000-25000',
          customerRating: 4.3,
          products: [products[4], products[7]],
        ),
      ];

  static List<Order> get logisticOrders => [
        Order(
          id: 'AN998120012',
          customerName: 'Нурбек Заккайев',
          status: OrderStatus.pending,
          date: DateTime.now().subtract(const Duration(minutes: 20)),
          products: products.take(5).toList(),
          totalAmount: 62000.00,
          customerAddress: 'А. Токомбаева -стрит 15 Бишкек, 722040 Кыргызстан',
          shopName: 'Ткань A23',
          timeAgo: '20 минут назад',
          description:
              'Шелковая ткань - 20 ярдов, льняная - 10 ярдов, прозрачная ткань драпировки - 25 ярдов',
          category: 'Шелковая ткань',
        ),
        Order(
          id: 'AN998120013',
          customerName: 'Айгуль Султанова',
          status: OrderStatus.pending,
          date: DateTime.now().subtract(const Duration(minutes: 20)),
          products: products.take(3).toList(),
          totalAmount: 45000.00,
          customerAddress: 'А. Токомбаева -стрит 15 Бишкек, 722040 Кыргызстан',
          shopName: 'Ткань A23',
          timeAgo: '20 минут назад',
          description:
              'Шелковая ткань - 20 ярдов, льняная - 10 ярдов, прозрачная ткань драпировки - 25 ярдов',
          category: 'Шелковая ткань',
        ),
        Order(
          id: 'AN998120014',
          customerName: 'Эркин Мурзаев',
          status: OrderStatus.pending,
          date: DateTime.now().subtract(const Duration(minutes: 20)),
          products: products.take(4).toList(),
          totalAmount: 58000.00,
          customerAddress: 'А. Токомбаева -стрит 15 Бишкек, 722040 Кыргызстан',
          shopName: 'Ткань A23',
          timeAgo: '20 минут назад',
          description:
              'Шелковая ткань - 20 ярдов, льняная - 10 ярдов, прозрачная ткань драпировки - 25 ярдов',
          category: 'Шелковая ткань',
        ),
        Order(
          id: 'AN998120015',
          customerName: 'Жамила Касымова',
          status: OrderStatus.pending,
          date: DateTime.now().subtract(const Duration(minutes: 20)),
          products: products.take(2).toList(),
          totalAmount: 30000.00,
          customerAddress: 'А. Токомбаева -стрит 15 Бишкек, 722040 Кыргызстан',
          shopName: 'Ткань A23',
          timeAgo: '20 минут назад',
          description:
              'Шелковая ткань - 20 ярдов, льняная - 10 ярдов, прозрачная ткань драпировки - 25 ярдов',
          category: 'Шелковая ткань',
        ),
      ];

  static List<Product> get featuredProducts => products.take(2).toList();

  static List<Product> get catalogProducts => products;
}
