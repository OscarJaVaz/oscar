import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/task.dart';
import '../../../../utils/responsive.dart';
import '../../../riverpodBack/report_back.dart';
import '../colors_tasks.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(task.createdAt);

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: context.spacingLG),
        decoration: BoxDecoration(
          color: ColorsTasks.danger,
          borderRadius: BorderRadius.circular(context.radiusMD),
        ),
        child: Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: context.checkboxSize * 1.1,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onEdit,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: context.spacingMD,
            vertical: context.spacingXS * 0.75,
          ),
          padding: EdgeInsets.all(context.spacingMD),
          decoration: BoxDecoration(
            color: ColorsTasks.surface,
            borderRadius: BorderRadius.circular(context.radiusMD),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: context.checkboxSize,
                  height: context.checkboxSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.completed
                        ? ColorsTasks.completed
                        : Colors.transparent,
                    border: Border.all(
                      color: task.completed
                          ? ColorsTasks.completed
                          : ColorsTasks.textSecondary,
                      width: 2,
                    ),
                  ),
                  child: task.completed
                      ? Icon(
                          Icons.check,
                          size: context.checkboxSize * 0.6,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              SizedBox(width: context.spacingSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: context.textLG.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ColorsTasks.textPrimary,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: ColorsTasks.textSecondary,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      SizedBox(height: context.spacingXS * 0.5),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textMD.copyWith(
                          color: ColorsTasks.textSecondary,
                        ),
                      ),
                    ],
                    SizedBox(height: context.spacingXS),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.spacingXS,
                            vertical: context.spacingXS * 0.375,
                          ),
                          child: Text(
                            task.completed ? 'Completada' : 'Pendiente',
                            style: context.textXS.copyWith(
                              fontWeight: FontWeight.w500,
                              color: task.completed
                                  ? ColorsTasks.completed
                                  : ColorsTasks.pending,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.access_time,
                          size: context.textXS.fontSize,
                          color: ColorsTasks.textSecondary,
                        ),
                        SizedBox(width: context.spacingXS * 0.5),
                        Text(
                          dateStr,
                          style: context.textXS.copyWith(
                            color: ColorsTasks.textSecondary,
                          ),
                        ),
                      ],
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
}

class TasksEmptyState extends StatelessWidget {
  const TasksEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: context.emptyIconSize,
            color: ColorsTasks.divider,
          ),
          SizedBox(height: context.spacingMD),
          Text(
            'No hay tareas aún',
            style: context.textTitleMD.copyWith(
              fontWeight: FontWeight.w600,
              color: ColorsTasks.textSecondary,
            ),
          ),
          SizedBox(height: context.spacingXS),
          Text(
            'Toca el botón + para agregar una tarea',
            style: context.textMD.copyWith(color: ColorsTasks.textSecondary),
          ),
        ],
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final ReportState reportState;
  final VoidCallback onGenerate;

  const ReportCard({
    super.key,
    required this.reportState,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = reportState.isLoading;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.spacingMD,
        vertical: context.spacingSM,
      ),
      decoration: BoxDecoration(
        color: ColorsTasks.surface,
        borderRadius: BorderRadius.circular(context.radiusMD),
        border: Border.all(color: ColorsTasks.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.spacingXS),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: ColorsTasks.primary,
                    size: context.checkboxSize,
                  ),
                ),
                SizedBox(width: context.spacingSM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Procesamiento masivo',
                        style: context.textTitleSM.copyWith(
                          fontWeight: FontWeight.w700,
                          color: ColorsTasks.textPrimary,
                        ),
                      ),
                      Text(
                        'Genera un reporte de 100,000 registros en un hilo secundario (Isolate)',
                        style: context.textSM.copyWith(
                          color: ColorsTasks.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacingMD),
            SizedBox(
              height: context.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onGenerate,
                icon: isLoading
                    ? SizedBox(
                        width: context.spacingMD,
                        height: context.spacingMD,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.play_arrow_rounded),
                label: Text(
                  isLoading ? 'Procesando...' : 'Generar reporte',
                  style: context.textLabel.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsTasks.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      ColorsTasks.primary.withValues(alpha: 0.6),
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.radiusMD),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
