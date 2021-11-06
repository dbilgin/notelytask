import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notelytask/cubit/github_cubit.dart';
import 'package:notelytask/models/github_state.dart';
import 'package:notelytask/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class GithubPage extends StatefulWidget {
  const GithubPage({Key? key}) : super(key: key);

  @override
  _GithubPageState createState() => _GithubPageState();
}

class _GithubPageState extends State<GithubPage> {
  final repoUrlController = TextEditingController();
  String? localRepoUrl;

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Github'),
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
                onPressed: () async =>
                    await context.read<GithubCubit>().launchLogin(),
                child: Text('Connect to Github'),
              ),
            ];
          } else if (state.accessToken == null &&
              deviceCode != null &&
              userCode != null &&
              verificationUri != null) {
            children = [
              Text('Your access code'),
              Text(userCode),
              Text('Activation Link'),
              GestureDetector(
                child: Text(
                  verificationUri,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                ),
                onTap: () => launch(verificationUri),
              ),
              ElevatedButton(
                onPressed: () async => await context
                    .read<GithubCubit>()
                    .getAccessToken(deviceCode),
                child: Text('I activated my account'),
              ),
            ];
          } else if (state.accessToken != null) {
            children = [
              Text('Connected to GitHub'),
              TextField(
                controller: repoUrlController,
                onChanged: (value) => setState(() => localRepoUrl = value),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'owner/repo',
                ),
              ),
              ElevatedButton(
                onPressed: localRepoUrl == state.ownerRepo
                    ? null
                    : () => saveRepoUrl(repoUrlController.text),
                child: Text('Save Repo'),
              ),
            ];
          }

          return Column(children: [
            ...children,
            ElevatedButton(
              onPressed: () => context.read<GithubCubit>().reset(),
              child: Text('Reset Github Connection'),
            ),
          ]);
        },
      ),
    );
  }
}
