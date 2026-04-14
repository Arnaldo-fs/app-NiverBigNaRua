import 'package:flutter/material.dart';
import '../models/pessoa.dart';
import '../services/sheets_service.dart';
import '../services/notification_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Pessoa> pessoas = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    try {
      final dados = await SheetsService().fetchPessoas();

      final hoje = getHoje();

      final hojeList = dados.where((p) {
        return p.dataNascimento.day == hoje.day &&
            p.dataNascimento.month == hoje.month;
      }).toList();

      // 🔔 NOTIFICAÇÃO REAL (SÓ SE TIVER ANIVERSARIANTE)
      if (hojeList.isNotEmpty) {
        final nomes = hojeList.map((e) => e.nome).join(', ');

        Future.delayed(const Duration(seconds: 2), () async {
          await NotificationService.mostrarAgora(
            "🎉 Aniversário hoje!",
            "Hoje é aniversário de: $nomes",
          );
        });
      }

      setState(() {
        pessoas = dados;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  DateTime getHoje() {
    return DateTime.now();
  }

  bool isHoje(DateTime data, DateTime hoje) {
    return data.day == hoje.day && data.month == hoje.month;
  }

  Widget buildCard(Pessoa p, Color cor) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.cake,
                size: 28,
                color: Color.fromARGB(255, 199, 3, 183),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      p.nome,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 60, 30, 10),
                      ),
                    ),
                    Text(
                      "${p.dataNascimento.day.toString().padLeft(2, '0')}/"
                      "${p.dataNascimento.month.toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title, Color cor) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget dividerLine() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: Container(
          width: 350,
          height: 3,
          color: const Color.fromARGB(255, 113, 1, 128),
        ),
      ),
    );
  }

  Widget todayCard(List<Pessoa> hojeList) {
    return Column(
      children: [
        const SizedBox(height: 45),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                hojeList.length == 1
                    ? "Hoje: ${hojeList.first.nome}"
                    : "Hoje: ${hojeList.map((e) => e.nome).join(', ')}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 45),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hoje = getHoje();

    final hojeList = pessoas.where((p) {
      return isHoje(p.dataNascimento, hoje);
    }).toList();

    final jaFizeram = pessoas.where((p) {
      return p.dataNascimento.month == hoje.month &&
          p.dataNascimento.day < hoje.day &&
          !isHoje(p.dataNascimento, hoje);
    }).toList();

    final emBreve = pessoas.where((p) {
      return p.dataNascimento.month == hoje.month &&
          p.dataNascimento.day > hoje.day &&
          !isHoje(p.dataNascimento, hoje);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "🎂 Aniversariantes do Mês",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (jaFizeram.isNotEmpty) ...[
            const SizedBox(height: 50),
            sectionTitle("Já fizeram", Colors.orange),
            ...jaFizeram.map((p) => buildCard(p, Colors.orange)),
          ],
          if (hojeList.isNotEmpty) ...[
            dividerLine(),
            todayCard(hojeList),
            dividerLine(),
          ] else
            dividerLine(),
          if (emBreve.isNotEmpty) ...[
            sectionTitle("Em breve", Colors.green),
            ...emBreve.map((p) => buildCard(p, Colors.green)),
          ],
        ],
      ),
    );
  }
}