import 'package:ovorideuser/core/helper/string_format_helper.dart';
import 'package:ovorideuser/data/services/api_client.dart';

import '../../../core/utils/method.dart';
import '../../../environment.dart';
import '../../model/location/prediction.dart';

class LocationSearchRepo {
  ApiClient apiClient;
  LocationSearchRepo({required this.apiClient});

  Future<String?> getFormattedAddress(double lat, double lng) async {
    printX('=== DEBUG: getFormattedAddress ===');
    printX('Latitude: $lat');
    printX('Longitude: $lng');
    
    const apiKey = Environment.mapKey;
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';
    
    printX('URL da requisição: $url');
    printX('API Key configurada: ${apiKey.isNotEmpty}');

    try {
      final response = await apiClient.request(url, Method.getMethod, null);
      printX('Status da resposta: ${response.statusCode}');
      printX('Resposta: ${response.responseJson}');

      if (response.statusCode == 200) {
        final data = response.responseJson;
        if (data['results'] != null && data['results'].length > 0) {
          final address = data['results'][0]['formatted_address'];
          printX('✅ Endereço obtido: $address');
          return address;
        } else {
          printX('❌ Nenhum resultado encontrado na resposta');
        }
      } else {
        printX('❌ Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      printX('❌ ERRO em getFormattedAddress: $e');
    }
    
    return null;
  }

  Future<dynamic> searchAddressByLocationName({
    String text = '',
    List<String>? countries,
  }) async {
    printX('=== DEBUG: searchAddressByLocationName ===');
    printX('Texto de busca: "$text"');
    printX('Países: $countries');
    
    loggerX(apiClient.getOperatingCountries());
    List<String> codes = apiClient
        .getOperatingCountries()
        .map(
          (e) => 'country:${e.countryCode ?? Environment.defaultCountryCode}',
        )
        .toList();
    loggerX(codes);

    String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$text&key=${Environment.mapKey}&components=${codes.join('|')}&language=en';
    loggerI(url);

    if (countries != null) {
      for (int i = 0; i < countries.length; i++) {
        final country = countries[i];

        if (i == 0) {
          url = "$url&components=country:$country";
        } else {
          url = "$url|country:$country";
        }
      }
    }

    printX('URL final: $url');
    printX('API Key: ${Environment.mapKey}');

    try {
      final response = await apiClient.request(url, Method.getMethod, null);
      printX('Status da resposta: ${response.statusCode}');
      printX('Resposta completa: ${response.responseJson}');
      
      if (response.statusCode == 200) {
        final data = response.responseJson;
        if (data['status'] == 'REQUEST_DENIED') {
          printX('❌ ERRO: REQUEST_DENIED - Verifique se as APIs estão habilitadas');
          printX('Mensagem de erro: ${data['error_message']}');
        } else if (data['status'] == 'OK') {
          printX('✅ Sucesso na busca de endereços');
        } else {
          printX('⚠️ Status inesperado: ${data['status']}');
        }
      }
      
      return response;
    } catch (e) {
      printX('❌ ERRO na requisição: $e');
      rethrow;
    }
  }

  Future<dynamic> getPlaceDetailsFromPlaceId(Prediction prediction) async {
    final url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=${prediction.placeId}&key=${Environment.mapKey}";

    final response = await apiClient.request(url, Method.getMethod, null);
    return response;
  }
}
