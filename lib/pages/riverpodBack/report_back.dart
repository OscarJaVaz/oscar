import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Debe ser top-level para poder pasarse a compute() — los closures no funcionan aquí.
String _massiveProcessing(int count) {
  final buffer = StringBuffer();
  int filtered = 0;

  for (int i = 0; i < count; i++) {
    buffer.write(
      '{"id":$i,"titulo":"Tarea generada $i","valor":${i * 31},"activo":${i % 2 == 0}}',
    );
    if (i * 31 > count ~/ 2) filtered++;
  }

  return '$count registros procesados — '
      'Filtrados (valor > ${count ~/ 2}): $filtered — '
      'Tamaño total: ${buffer.length} bytes.';
}

enum ReportStatus { idle, loading, done, error }

class ReportState {
  final ReportStatus status;
  final String message;

  const ReportState({required this.status, this.message = ''});

  bool get isLoading => status == ReportStatus.loading;
}

final reportProvider =
    StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier();
});

class ReportNotifier extends StateNotifier<ReportState> {
  ReportNotifier() : super(const ReportState(status: ReportStatus.idle));

  Future<void> generateReport() async {
    if (state.isLoading) return;
    state = const ReportState(status: ReportStatus.loading);

    try {
      final result = await compute(_massiveProcessing, 100000);
      state = ReportState(status: ReportStatus.done, message: result);
    } catch (e) {
      state = ReportState(
        status: ReportStatus.error,
        message: 'Error durante el procesamiento: $e',
      );
    }
  }

  void reset() => state = const ReportState(status: ReportStatus.idle);
}
