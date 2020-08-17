import 'package:aves/model/settings.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/widgets/common/action_delegates/map_style_dialog.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/fullscreen/info/location_section.dart';
import 'package:aves/widgets/fullscreen/overlay/common.dart';
import 'package:flutter/material.dart';

class MapButtonPanel extends StatelessWidget {
  final String geoUri;
  final void Function(double amount) zoomBy;

  static const BorderRadius mapBorderRadius = BorderRadius.all(Radius.circular(24)); // to match button circles
  static const double padding = 4;

  const MapButtonPanel({
    @required this.geoUri,
    @required this.zoomBy,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: TooltipTheme(
            data: TooltipTheme.of(context).copyWith(
              preferBelow: false,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MapOverlayButton(
                  icon: AIcons.style,
                  onPressed: () async {
                    final style = await showDialog<EntryMapStyle>(
                      context: context,
                      builder: (context) => MapStyleDialog(),
                    );
                    if (style != null) {
                      settings.infoMapStyle = style;
                      MapStyleChangedNotification().dispatch(context);
                    }
                  },
                  tooltip: 'Style map...',
                ),
                SizedBox(height: padding),
                MapOverlayButton(
                  icon: AIcons.openInNew,
                  onPressed: () => AndroidAppService.openMap(geoUri),
                  tooltip: 'Show on map...',
                ),
                Spacer(),
                MapOverlayButton(
                  icon: AIcons.zoomIn,
                  onPressed: () => zoomBy(1),
                  tooltip: 'Zoom in',
                ),
                SizedBox(height: padding),
                MapOverlayButton(
                  icon: AIcons.zoomOut,
                  onPressed: () => zoomBy(-1),
                  tooltip: 'Zoom out',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MapOverlayButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const MapOverlayButton({
    @required this.icon,
    @required this.tooltip,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlurredOval(
      child: Material(
        type: MaterialType.circle,
        color: FullscreenOverlay.backgroundColor,
        child: Ink(
          decoration: BoxDecoration(
            border: FullscreenOverlay.buildBorder(context),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            iconSize: 20,
            visualDensity: VisualDensity.compact,
            icon: Icon(icon),
            onPressed: onPressed,
            tooltip: tooltip,
          ),
        ),
      ),
    );
  }
}

class MapStyleChangedNotification extends Notification {}
