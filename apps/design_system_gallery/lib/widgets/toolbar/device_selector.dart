import 'package:device_frame_plus/device_frame_plus.dart';
import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

/// A dropdown selector for choosing the preview device.
class DeviceSelector extends StatelessWidget {
  const DeviceSelector({
    super.key,
    required this.selectedDevice,
    required this.devices,
    required this.colorScheme,
    required this.textTheme,
    required this.onDeviceChanged,
  });

  final DeviceInfo selectedDevice;
  final List<DeviceInfo> devices;
  final StreamColorScheme colorScheme;
  final StreamTextTheme textTheme;
  final ValueChanged<DeviceInfo> onDeviceChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.backgroundApp,
        borderRadius: BorderRadius.circular(8),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.borderSurfaceSubtle),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DeviceInfo>(
          value: selectedDevice,
          icon: Icon(
            Icons.unfold_more,
            color: colorScheme.textTertiary,
            size: 16,
          ),
          style: textTheme.captionDefault.copyWith(
            color: colorScheme.textPrimary,
          ),
          dropdownColor: colorScheme.backgroundSurface,
          items: devices.map((device) {
            final isPhone =
                device.name.toLowerCase().contains('iphone') ||
                device.name.toLowerCase().contains('phone') ||
                device.name.toLowerCase().contains('galaxy');
            return DropdownMenuItem(
              value: device,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPhone ? Icons.phone_iphone : Icons.tablet_mac,
                    size: 14,
                    color: colorScheme.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(device.name, style: const TextStyle(fontSize: 13)),
                ],
              ),
            );
          }).toList(),
          onChanged: (device) {
            if (device != null) onDeviceChanged(device);
          },
        ),
      ),
    );
  }
}
