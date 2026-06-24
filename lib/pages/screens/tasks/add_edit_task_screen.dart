import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/responsive.dart';
import '../../../domain/entities/task.dart';
import '../../riverpodBack/task_back.dart';
import 'colors_tasks.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  const AddEditTaskScreen({super.key});

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;

  Task? get _task => ref.read(selectedTaskProvider);
  bool get _isEditing => _task != null;

  @override
  void initState() {
    super.initState();
    final task = ref.read(selectedTaskProvider);
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(taskProvider.notifier);
      if (_isEditing) {
        await notifier.updateTask(
          _task!.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
          ),
        );
        if (mounted) context.pop();
      } else {
        await notifier.createTask(
          _titleController.text.trim(),
          _descriptionController.text.trim(),
        );
        if (mounted) {
          // Activa la señal ANTES de navegar — tasks_screen mostrará el modal
          ref.read(taskJustCreatedProvider.notifier).state = true;
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: ColorsTasks.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: ColorsTasks.background,
          appBar: AppBar(
          backgroundColor: ColorsTasks.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            _isEditing ? 'Editar tarea' : 'Nueva tarea',
            style: context.textTitleLG.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(context.spacingLG),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.spacingXS),
                _buildLabel(context, 'Título'),
                SizedBox(height: context.spacingXS),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  style: context.textMD,
                  decoration: _inputDecoration(context, 'Introduce el título de la tarea'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'El título es requerido'
                      : null,
                ),
                SizedBox(height: context.spacingLG),
                _buildLabel(context, 'Descripción'),
                SizedBox(height: context.spacingXS),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                  // Done solo cierra el teclado, no ejecuta guardar
                  onEditingComplete: () => FocusScope.of(context).unfocus(),
                  style: context.textMD,
                  decoration:
                      _inputDecoration(context, 'Introduce la descripción de la tarea'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'La descripción es requerida'
                      : null,
                ),
                SizedBox(height: context.spacingXL),
                SizedBox(
                  height: context.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsTasks.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.radiusMD),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox.square(
                            dimension: context.checkboxSize,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _isEditing ? 'Guardar cambios' : 'Crear tarea',
                            style: context.textLabel.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: context.textMD.copyWith(
        fontWeight: FontWeight.w600,
        color: ColorsTasks.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    final radius = context.radiusMD;
    return InputDecoration(
      hintText: hint,
      hintStyle: context.textMD.copyWith(color: ColorsTasks.textSecondary),
      filled: true,
      fillColor: ColorsTasks.surface,
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.spacingMD,
        vertical: context.spacingSM,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: ColorsTasks.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: ColorsTasks.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: ColorsTasks.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: ColorsTasks.danger),
      ),
    );
  }
}
