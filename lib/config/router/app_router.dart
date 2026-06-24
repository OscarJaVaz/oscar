import 'package:go_router/go_router.dart';

import '../../pages/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'tasks',
      builder: (context, state) => const TasksScreen(),
    ),
    GoRoute(
      path: '/add',
      name: 'add-task',
      builder: (context, state) => const AddEditTaskScreen(),
    ),
    GoRoute(
      path: '/edit',
      name: 'edit-task',
      builder: (context, state) => const AddEditTaskScreen(),
    ),
  ],
);
