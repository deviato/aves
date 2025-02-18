import 'package:aves/app_mode.dart';
import 'package:aves/model/device.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/filters/path.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/model/source/collection_source.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/widgets/common/action_mixins/feedback.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/dialogs/add_shortcut_dialog.dart';
import 'package:aves/widgets/explorer/explorer_page.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip.dart';
import 'package:aves/widgets/stats/stats_page.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExplorerActionDelegate with FeedbackMixin {
  final VolumeRelativeDirectory directory;

  ExplorerActionDelegate({required this.directory});

  bool isVisible(
    ExplorerAction action, {
    required AppMode appMode,
  }) {
    final isMain = appMode == AppMode.main;
    final useTvLayout = settings.useTvLayout;
    switch (action) {
      case ExplorerAction.addShortcut:
        return isMain && device.canPinShortcut;
      case ExplorerAction.setHome:
        return isMain && !useTvLayout;
      case ExplorerAction.hide:
      case ExplorerAction.stats:
        return isMain;
    }
  }

  bool canApply(ExplorerAction action) {
    switch (action) {
      case ExplorerAction.addShortcut:
      case ExplorerAction.setHome:
      case ExplorerAction.hide:
      case ExplorerAction.stats:
        return true;
    }
  }

  void onActionSelected(BuildContext context, ExplorerAction action) {
    reportService.log('$runtimeType handles $action');
    switch (action) {
      case ExplorerAction.addShortcut:
        _addShortcut(context);
      case ExplorerAction.setHome:
        _setHome(context);
      case ExplorerAction.hide:
        _hide(context);
      case ExplorerAction.stats:
        _goToStats(context);
    }
  }

  PathFilter _getPathFilter() => PathFilter(directory.dirPath);

  Future<void> _addShortcut(BuildContext context) async {
    final filter = _getPathFilter();
    final defaultName = filter.getLabel(context);
    final collection = CollectionLens(
      source: context.read<CollectionSource>(),
      filters: {filter},
    );

    final result = await showDialog<(AvesEntry?, String)>(
      context: context,
      builder: (context) => AddShortcutDialog(
        defaultName: defaultName,
        collection: collection,
      ),
      routeSettings: const RouteSettings(name: AddShortcutDialog.routeName),
    );
    if (result == null) return;

    final (coverEntry, name) = result;
    if (name.isEmpty) return;

    await appService.pinToHomeScreen(name, coverEntry, route: ExplorerPage.routeName, path: filter.path);
    if (!device.showPinShortcutFeedback) {
      showFeedback(context, FeedbackType.info, context.l10n.genericSuccessFeedback);
    }
  }

  void _setHome(BuildContext context) async {
    settings.setHome(HomePageSetting.explorer, customExplorerPath: directory.dirPath);
    showFeedback(context, FeedbackType.info, context.l10n.genericSuccessFeedback);
  }

  void _hide(BuildContext context) {
    final chipActionDelegate = ChipActionDelegate();
    const action = ChipAction.hide;
    final pathFilter = _getPathFilter();
    if (chipActionDelegate.isVisible(action, filter: pathFilter)) {
      chipActionDelegate.onActionSelected(context, pathFilter, action);
    }
  }

  void _goToStats(BuildContext context) {
    final collection = CollectionLens(
      source: context.read<CollectionSource>(),
      filters: {_getPathFilter()},
    );

    Navigator.maybeOf(context)?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: StatsPage.routeName),
        builder: (context) => StatsPage(
          entries: collection.sortedEntries.toSet(),
          source: collection.source,
        ),
      ),
    );
  }
}
