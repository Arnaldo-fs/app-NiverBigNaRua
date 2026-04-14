import 'package:http/http.dart' as http;
import '../models/pessoa.dart';

class SheetsService {
  final String url =
      "https://docs.google.com/spreadsheets/d/1Lsjlpr5UWE3pvcMLXxLYlW3Dw1Gx_HbhozafsbhQQcU/export?format=csv";

  Future<List<Pessoa>> fetchPessoas() async {
    final response = await http.get(Uri.parse(url));

    print("STATUS: ${response.statusCode}");

    if (response.statusCode != 200) {
      throw Exception("Erro ao buscar dados");
    }

    final lines = response.body.split('\n');

    List<Pessoa> pessoas = [];

    for (int i = 1; i < lines.length; i++) {
      try {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final cols = _parseCsv(line);

        if (cols.length < 5) continue;

        final nome = cols[2].trim();
        final dataStr = cols[4].trim();

        if (nome.isEmpty || dataStr.isEmpty) continue;

        final data = _parseData(dataStr);

        pessoas.add(Pessoa(
          nome: nome,
          dataNascimento: data,
        ));
      } catch (e) {
        print("Erro linha $i: ${lines[i]}");
      }
    }

    print("TOTAL: ${pessoas.length}");

    return pessoas;
  }


  List<String> _parseCsv(String line) {
    List<String> result = [];
    String buffer = '';
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(buffer);
        buffer = '';
      } else {
        buffer += char;
      }
    }

    result.add(buffer);
    return result;
  }

  DateTime _parseData(String data) {
    final partes = data.split('/');

    return DateTime(
      int.parse(partes[2]),
      int.parse(partes[1]),
      int.parse(partes[0]),
    );
  }
}