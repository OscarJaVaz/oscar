import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/responsive.dart';
import '../../riverpodBack/report_back.dart';
import '../../riverpodBack/task_back.dart';
import 'colors_tasks.dart';
import 'widgets/tasks_widgets.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  void _mostrarExito(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: ColorsTasks.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.radiusLG),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            context.spacingLG,
            context.spacingXL,
            context.spacingLG,
            context.spacingXL + MediaQuery.paddingOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: ColorsTasks.primary,
                size: context.checkboxSize * 2.5,
              ),
              SizedBox(height: context.spacingMD),
              Text(
                '¡Tarea creada!',
                style: context.textTitleLG.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ColorsTasks.textPrimary,
                ),
              ),
              SizedBox(height: context.spacingXS),
              Text(
                'La tarea se ha guardado correctamente.',
                style: context.textMD.copyWith(color: ColorsTasks.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacingXL),
              SizedBox(
                width: double.infinity,
                height: context.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsTasks.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.radiusMD),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Cerrar',
                    style: context.textLabel.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(taskProvider);
    final reportState = ref.watch(reportProvider);


    final taskCreated = ref.watch(taskJustCreatedProvider);
    if (taskCreated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {

        if (ref.read(taskJustCreatedProvider)) {
          ref.read(taskJustCreatedProvider.notifier).state = false;
          _mostrarExito(context, ref);
        }
      });
    }

    ref.listen(reportProvider, (prev, next) {
      if (next.status == ReportStatus.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: ColorsTasks.completed,
            duration: const Duration(seconds: 6),
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(reportProvider.notifier).reset();
      } else if (next.status == ReportStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: ColorsTasks.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(reportProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: ColorsTasks.background,
      appBar: AppBar(
        backgroundColor: ColorsTasks.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Mis tareas',
          style: context.textTitleLG.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          tasksState.maybeWhen(
            data: (tasks) => Padding(
              padding: EdgeInsets.only(right: context.spacingMD),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacingSM,
                    vertical: context.spacingXS * 0.5,
                  ),
                  child: Text(
                    '${tasks.where((t) => !t.completed).length} pendientes',
                    style: context.textXS.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: tasksState.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: ColorsTasks.primary),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: EdgeInsets.all(context.spacingMD),
                  child: Text(
                    'Error al cargar tareas:\n$e',
                    textAlign: TextAlign.center,
                    style: context.textMD.copyWith(color: ColorsTasks.danger),
                  ),
                ),
              ),
              data: (tasks) => CustomScrollView(
                slivers: [
                  tasks.isEmpty
                      ? const SliverFillRemaining(
                          hasScrollBody: false,
                          child: TasksEmptyState(),
                        )
                      : SliverPadding(
                          padding: EdgeInsets.only(top: context.spacingSM),
                          sliver: SliverList.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return TaskCard(
                                task: task,
                                onToggle: () => ref
                                    .read(taskProvider.notifier)
                                    .toggleCompleted(task),
                                onEdit: () {
                                  ref
                                      .read(selectedTaskProvider.notifier)
                                      .state = task;
                                  context.push('/edit');
                                },
                                onDelete: () {
                                  final id = task.id;
                                  if (id == null) return;
                                  ref
                                      .read(taskProvider.notifier)
                                      .deleteTask(id);
                                },
                              );
                            },
                          ),
                        ),


                  SliverToBoxAdapter(
                    child: ReportCard(
                      reportState: reportState,
                      onGenerate: () =>
                          ref.read(reportProvider.notifier).generateReport(),
                    ),
                  ),

                  SliverPadding(
                    padding: EdgeInsets.only(bottom: context.spacingXXL),
                  ),
                ],
              ),
            ),
          ),


          if (reportState.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.55),
              child: Center(
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: context.spacingXL),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.radiusMD),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(context.spacingXL),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: ColorsTasks.primary,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: context.spacingMD),
                        Text(
                          'Procesando 100,000 registros...',
                          style: context.textTitleSM.copyWith(
                            fontWeight: FontWeight.w600,
                            color: ColorsTasks.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.spacingXS),
                        Text(
                          'La UI permanece fluida mientras se procesa en segundo plano.',
                          style: context.textSM.copyWith(
                            color: ColorsTasks.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(selectedTaskProvider.notifier).state = null;
          context.push('/add');
        },
        backgroundColor: ColorsTasks.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          'Nueva tarea',
          style: context.textLabel.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}
