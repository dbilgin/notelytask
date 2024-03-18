import 'package:flutter/material.dart';

class NoteListRowFiles extends StatelessWidget {
  const NoteListRowFiles({
    Key? key,
    required this.fileNames,
  }) : super(key: key);
  final Iterable<String> fileNames;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(
            Icons.file_copy,
            color: Colors.white,
            size: 20.0,
          ),
          Expanded(
            child: Text(
              ' ${fileNames.join(', ')}',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
