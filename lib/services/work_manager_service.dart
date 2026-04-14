import 'package:workmanager/workmanager.dart';
import 'notification_service.dart';
import 'sheets_service.dart';

class WorkManagerService {
  static const taskName = "birthdayTask";

  static void init() {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

    Workmanager().registerPeriodicTask(
      "birthdayTaskId",
      taskName,
      frequency: const Duration(minutes: 1),
      initialDelay: const Duration(seconds: 10),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == WorkManagerService.taskName) {
      try {
        final service = SheetsService();
        final dados = await service.fetchPessoas();

        final now = DateTime.now();

        final hojeList = dados.where((p) {
          return p.dataNascimento.day == now.day &&
              p.dataNascimento.month == now.month;
        }).toList();

        if (hojeList.isNotEmpty) {
          final nomes = hojeList.map((e) => e.nome).join(', ');

          await NotificationService.mostrarAgora(
            "🎉 Aniversário hoje!",
            "Hoje é aniversário de: $nomes",
          );
        }
      } catch (e) {
        // evita crash
      }
    }

    return Future.value(true);
  });
}