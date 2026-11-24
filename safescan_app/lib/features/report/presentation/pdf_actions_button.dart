import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_sizing.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/report_provider.dart';

class PdfActionsButton extends ConsumerWidget {
  const PdfActionsButton({required this.productId, super.key});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportProvider);

    if (state.status == ReportStatus.success && state.file != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: AppSizing.buttonHeight, child: ElevatedButton.icon(onPressed: () async {
            try {
              await SharePlus.instance.share(ShareParams(files: <XFile>[XFile(state.file!.path)], text: 'SafeScan SAMPLE report'));
            } catch (_) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The share sheet could not be opened.')));
            }
          }, icon: const Icon(Icons.share_outlined), label: const Text('Share sample'))),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sample saved at ${state.file!.path}')));
          }, icon: const Icon(Icons.download_outlined), label: const Text('Downloaded sample')),
        ],
      );
    }

    return SizedBox(
      height: AppSizing.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: state.status == ReportStatus.generating ? null : () => ref.read(reportProvider.notifier).generate(productId),
        icon: state.status == ReportStatus.generating
            ? const SizedBox.square(dimension: AppSizing.iconSm, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.description_outlined),
        label: Text(state.status == ReportStatus.generating ? 'Generating...' : 'Generate mock report'),
      ),
    );
  }
}
