import 'package:network/network.dart';
import 'package:products/src/data/dto/category_dto.dart';
import 'package:products/src/data/dto/product_dto.dart';
import 'package:products/src/data/dto/product_request_dto.dart';
import 'package:products/src/domain/entities/picked_photo.dart';

/// The products endpoints, over the authenticated API client.
class ProductsRemoteSource {
  const ProductsRemoteSource(this._dio);

  final Dio _dio;

  Future<List<ProductDto>> getProducts({
    required int offset,
    required int limit,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/products',
      queryParameters: {'offset': offset, 'limit': limit},
    );
    return _products(response.data!);
  }

  Future<ProductDto> getProduct(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/products/$id');
    return ProductDto.fromJson(response.data!);
  }

  Future<ProductDto> createProduct(ProductRequestDto request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/products',
      data: request.toJson(),
    );
    return ProductDto.fromJson(response.data!);
  }

  Future<ProductDto> updateProduct(int id, ProductRequestDto request) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/products/$id',
      data: request.toJson(),
    );
    return ProductDto.fromJson(response.data!);
  }

  Future<void> deleteProduct(int id) => _dio.delete<Object?>('/products/$id');

  /// `POST /files/upload` (multipart) -> the URL of the stored file.
  Future<String> uploadImage(PickedPhoto photo) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/files/upload',
      data: FormData.fromMap({
        'file': MultipartFile.fromBytes(photo.bytes, filename: photo.name),
      }),
    );
    return response.data!['location'] as String;
  }

  Future<List<CategoryDto>> getCategories() async {
    final response = await _dio.get<List<dynamic>>('/categories');
    return [
      for (final json in response.data!)
        CategoryDto.fromJson(json as Map<String, dynamic>),
    ];
  }

  List<ProductDto> _products(List<dynamic> json) => [
    for (final item in json) ProductDto.fromJson(item as Map<String, dynamic>),
  ];
}
