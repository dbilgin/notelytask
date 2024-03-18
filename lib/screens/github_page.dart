import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/models/github_state.dart';
import 'package:notelytask/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class GithubPage extends StatefulWidget {
  const GithubPage({Key? key, this.code}) : super(key: key);
  final String? code;

  @override
  State<GithubPage> createState() => _GithubPageState();
}

class _GithubPageState extends State<GithubPage> {
  final repoUrlController = TextEditingController();
  String? localRepoUrl;

  @override
  void initState() {
    final ghCode = widget.code;
    if (ghCode != null) {
      context.read<GithubCubit>().getAccessToken(ghCode);
    }

    repoUrlController.text = context.read<GithubCubit>().state.ownerRepo ?? '';
    localRepoUrl = repoUrlController.text;
    super.initState();
  }

  @override
  void dispose() {
    repoUrlController.dispose();
    super.dispose();
  }

  void saveRepoUrl(String repoUrl) {
    saveToRepoAlert(
      context: context,
      onPressed: (bool keepLocal) async {
        await context.read<GithubCubit>().setRepoUrl(repoUrl, keepLocal);
      },
    );
  }

  Future<void> _startConnectionToGithub() async {
    if (kIsWeb) {
      final url = Uri.https(
        'github.com',
        '/login/oauth/authorize',
        {
          'client_id': dotenv.env['GITHUB_CLIENT_ID'],
          'scope': 'repo',
        },
      );
      if (await canLaunchUrl(url)) {
        launchUrl(
          url,
          webOnlyWindowName: '_self',
        );
      }
    } else {
      await context.read<GithubCubit>().launchLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Github',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: BlocBuilder<GithubCubit, GithubState>(
        builder: (context, state) {
          var deviceCode = state.deviceCode;
          var userCode = state.userCode;
          var verificationUri = state.verificationUri;
          List<Widget> children = [];

          if (state.accessToken == null && deviceCode == null) {
            children = [
              ElevatedButton(
                onPressed: _startConnectionToGithub,
                child: const Text('Connect to Github'),
              ),
            ];
          } else if (state.accessToken == null &&
              deviceCode != null &&
              userCode != null &&
              verificationUri != null) {
            void onCopyPressed() {
              Clipboard.setData(ClipboardData(text: userCode));
              showSnackBar(context, 'Copied!');
            }

            children = [
              Text(
                'Your access code',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Row(
                children: [
                  SelectableText(
                    userCode,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.copy,
                      color: Color(0xff2e8fff),
                    ),
                    tooltip: 'Copy Code',
                    onPressed: onCopyPressed,
                  ),
                ],
              ),
              Text(
                'Activation Link',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              GestureDetector(
                child: Text(
                  verificationUri,
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                ),
                onTap: () => launchUrl(Uri.parse(verificationUri)),
              ),
              ElevatedButton(
                onPressed: () async => await context
                    .read<GithubCubit>()
                    .getAccessToken(deviceCode),
                child: const Text('I activated my account'),
              ),
            ];
          } else if (state.accessToken != null) {
            children = [
              Text(
                'Connected to GitHub',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(
                height: 50.0,
                width: MediaQuery.of(context).size.width - 100,
                child: TextField(
                  controller: repoUrlController,
                  onChanged: (value) => setState(() => localRepoUrl = value),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'owner/repo',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: localRepoUrl == state.ownerRepo
                    ? null
                    : () => saveRepoUrl(repoUrlController.text),
                style: ElevatedButton.styleFrom(
                  disabledForegroundColor: Colors.grey.withOpacity(0.38),
                  disabledBackgroundColor: Colors.grey.withOpacity(0.12),
                ),
                child: const Text('Save Repo'),
              ),
            ];
          }

          return BlocListener<GithubCubit, GithubState>(
            listener: (context, state) {
              if (state.error && repoUrlController.text.isNotEmpty) {
                showSnackBar(context, 'Error integrating repository.');

                repoUrlController.text = '';
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment: WrapAlignment.center,
                  direction: Axis.vertical,
                  runSpacing: 24.0,
                  spacing: 12.0,
                  children: [
                    ...children,
                    ElevatedButton(
                      onPressed: () => context.read<GithubCubit>().reset(),
                      child: const Text('Reset Github Connection'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
